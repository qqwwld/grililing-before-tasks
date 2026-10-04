#Requires -Version 5.1
<#
  scan.ps1 - read-only inventory of junk/cache locations and large folders.

  NEVER deletes, moves, renames or modifies any file. The only file it writes
  is the JSON report at -OutFile. Directory sizes come from robocopy /L (list
  mode, no writes, /XJ skips junctions).

  Output JSON sections:
    known  - probed known cache/junk locations (id, path, sizeMB, running)
    deep   - name-matched cache/log dirs found under the user profile
    tree   - large directories found by the layered full-disk sweep
#>
[CmdletBinding()]
param(
  [string[]]$Drives,          # e.g. -Drives C:,D: ; default = all fixed drives
  [string]$OutFile,           # JSON output path (default: %TEMP%\junk-scan-<ts>.json)
  [switch]$KnownOnly,         # only probe known locations (fast)
  [string]$Path,              # measure a single path instead of a full scan
  [double]$MinTreeMB = 300,   # tree sweep: drill/record only dirs >= this
  [int]$MaxDepth = 4,         # tree sweep: max drill depth (drive root children = 1)
  [double]$DeepMinMB = 10,    # deep name scan: record matches >= this
  [int]$MaxSeconds = 900      # time budget; on expiry stop and set truncated=true
)

$sw = [System.Diagnostics.Stopwatch]::StartNew()
$deadline = (Get-Date).AddSeconds($MaxSeconds)
$truncated = $false

# ---------------------------------------------------------------- sizing (robocopy /L)
function Get-TreeBytes {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) { return 0L }
  $item = Get-Item -LiteralPath $Path -Force -ErrorAction SilentlyContinue
  if ($null -eq $item) { return 0L }
  if (-not $item.PSIsContainer) { return [int64]$item.Length }
  $out = & "$env:SystemRoot\System32\robocopy.exe" $Path $env:TEMP /L /S /BYTES /XJ /R:0 /W:0 /NFL /NDL /NJH /NP 2>$null
  # summary prints 3 fixed numeric lines: dirs, files, bytes (locale-independent)
  $numLines = @()
  foreach ($line in $out) {
    if ($line -match '^\s*\S+\s*:\s+\d+(\s+\d+)*\s*$') { $numLines += $line }
  }
  if ($numLines.Count -ge 3 -and $numLines[2] -match '(\d+)') { return [int64]$matches[1] }
  return 0L
}

function Expand-Paths {
  param([string]$Raw)
  $p = [Environment]::ExpandEnvironmentVariables($Raw)
  if ($p -match '[\*\?]') {
    try { return @(Get-ChildItem -Path $p -Force -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName) }
    catch { return @() }
  }
  if (Test-Path -LiteralPath $p) {
    try { return @((Get-Item -LiteralPath $p -Force -ErrorAction Stop).FullName) } catch { return @() }
  }
  return @()
}

# ---------------------------------------------------------------- single-path mode
if ($Path) {
  $targets = @(Expand-Paths -Raw $Path)
  $pathTree = @()
  foreach ($t in $targets) {
    $pathTree += [pscustomobject]@{ path = $t; depth = 0; sizeMB = [math]::Round((Get-TreeBytes -Path $t) / 1MB, 1) }
  }
  $one = [pscustomobject]@{
    mode        = 'path'
    generatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
    hostname    = $env:COMPUTERNAME
    tree        = $pathTree
    skipped     = @()
  }
  if (-not $OutFile) { $OutFile = Join-Path $env:TEMP ('junk-scan-path-{0}.json' -f (Get-Date -Format 'yyyyMMdd-HHmmss')) }
  $one | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $OutFile -Encoding UTF8
  Write-Output ("path mode: {0} entries -> {1}" -f $pathTree.Count, $OutFile)
  return
}

# ---------------------------------------------------------------- known locations
# id must match an entry in references/known-junk-locations.md
$knownSpec = @(
  # --- system ---
  @{ id = 'sys-temp-user';             path = '%LOCALAPPDATA%\Temp' },
  @{ id = 'sys-temp-windows';          path = '%WINDIR%\Temp' },
  @{ id = 'sys-update-download';       path = '%WINDIR%\SoftwareDistribution\Download' },
  @{ id = 'sys-windows-logs';          path = '%WINDIR%\Logs' },
  @{ id = 'sys-minidump';              path = '%WINDIR%\Minidump' },
  @{ id = 'sys-memory-dump';           path = '%WINDIR%\MEMORY.DMP' },
  @{ id = 'sys-wer-user';              path = '%LOCALAPPDATA%\Microsoft\Windows\WER' },
  @{ id = 'sys-wer-shared';            path = '%PROGRAMDATA%\Microsoft\Windows\WER' },
  @{ id = 'sys-crash-dumps';           path = '%LOCALAPPDATA%\CrashDumps' },
  @{ id = 'sys-inet-cache';            path = '%LOCALAPPDATA%\Microsoft\Windows\INetCache' },
  @{ id = 'sys-thumb-cache';           path = '%LOCALAPPDATA%\Microsoft\Windows\Explorer' },
  @{ id = 'sys-delivery-optimization'; path = '%PROGRAMDATA%\Microsoft\Windows\DeliveryOptimization\Cache' },
  @{ id = 'sys-d3d-shader-cache';      path = '%LOCALAPPDATA%\D3DSCache' },
  @{ id = 'sys-nvidia-gl-cache';       path = '%LOCALAPPDATA%\NVIDIA\GLCache' },
  @{ id = 'sys-nvidia-dx-cache';       path = '%LOCALAPPDATA%\NVIDIA\DXCache' },
  @{ id = 'sys-amd-dx-cache';          path = '%LOCALAPPDATA%\AMD\DxCache' },
  @{ id = 'sys-amd-vk-cache';          path = '%LOCALAPPDATA%\AMD\VkCache' },
  @{ id = 'sys-prefetch';              path = '%WINDIR%\Prefetch' },
  @{ id = 'sys-live-kernel-reports';   path = '%WINDIR%\LiveKernelReports' },
  @{ id = 'sys-patch-cache';           path = '%WINDIR%\Installer\$PatchCache$' },
  @{ id = 'sys-package-cache';         path = '%PROGRAMDATA%\Package Cache' },
  @{ id = 'sys-store-app-temps';       path = '%LOCALAPPDATA%\Packages\*\TempState' },
  @{ id = 'sys-store-ac-temp';         path = '%LOCALAPPDATA%\Packages\*\AC\Temp' },
  @{ id = 'sys-store-ac-inetcache';    path = '%LOCALAPPDATA%\Packages\*\AC\INetCache' },
  # --- browsers ---
  @{ id = 'chrome-cache';              path = '%LOCALAPPDATA%\Google\Chrome\User Data\*\Cache';            procs = @('chrome') },
  @{ id = 'chrome-code-cache';         path = '%LOCALAPPDATA%\Google\Chrome\User Data\*\Code Cache';       procs = @('chrome') },
  @{ id = 'edge-cache';                path = '%LOCALAPPDATA%\Microsoft\Edge\User Data\*\Cache';           procs = @('msedge', 'msedgewebview2') },
  @{ id = 'edge-code-cache';           path = '%LOCALAPPDATA%\Microsoft\Edge\User Data\*\Code Cache';      procs = @('msedge', 'msedgewebview2') },
  @{ id = 'firefox-cache2';            path = '%LOCALAPPDATA%\Mozilla\Firefox\Profiles\*\cache2';          procs = @('firefox') },
  @{ id = 'opera-cache';               path = '%LOCALAPPDATA%\Opera Software\Opera Stable\Cache';          procs = @('opera') },
  @{ id = 'opera-code-cache';          path = '%LOCALAPPDATA%\Opera Software\Opera Stable\Code Cache';     procs = @('opera') },
  # --- dev tools ---
  @{ id = 'npm-cache';                 path = '%LOCALAPPDATA%\npm-cache' },
  @{ id = 'yarn-cache';                path = '%LOCALAPPDATA%\Yarn\Cache' },
  @{ id = 'pnpm-store';                path = '%LOCALAPPDATA%\pnpm\store' },
  @{ id = 'pnpm-cache-dir';            path = '%LOCALAPPDATA%\pnpm-cache' },
  @{ id = 'pip-cache';                 path = '%LOCALAPPDATA%\pip\cache' },
  @{ id = 'uv-cache';                  path = '%LOCALAPPDATA%\uv\cache' },
  @{ id = 'poetry-cache';              path = '%LOCALAPPDATA%\pypoetry\Cache' },
  @{ id = 'conda-pkgs';                path = '%USERPROFILE%\*conda*\pkgs' },
  @{ id = 'cargo-registry-cache';      path = '%USERPROFILE%\.cargo\registry\cache' },
  @{ id = 'go-build-cache';            path = '%LOCALAPPDATA%\go-build' },
  @{ id = 'go-pkg-mod';                path = '%USERPROFILE%\go\pkg\mod' },
  @{ id = 'gradle-caches';             path = '%USERPROFILE%\.gradle\caches' },
  @{ id = 'maven-repository';          path = '%USERPROFILE%\.m2\repository' },
  @{ id = 'nuget-http-cache';          path = '%LOCALAPPDATA%\NuGet\v3-cache' },
  @{ id = 'nuget-packages';            path = '%USERPROFILE%\.nuget\packages' },
  @{ id = 'electron-cache';            path = '%LOCALAPPDATA%\electron\Cache' },
  @{ id = 'electron-builder-cache';    path = '%LOCALAPPDATA%\electron-builder\Cache' },
  @{ id = 'puppeteer-cache';           path = '%USERPROFILE%\.cache\puppeteer' },
  @{ id = 'playwright-cache';          path = '%LOCALAPPDATA%\ms-playwright' },
  @{ id = 'user-dot-cache';            path = '%USERPROFILE%\.cache' },
  # --- app data (cache mixed with data; agent grades these) ---
  @{ id = 'app-wechat-local';          path = '%LOCALAPPDATA%\Tencent\WeChat';   procs = @('wechat', 'weixin') },
  @{ id = 'app-weixin-local';          path = '%LOCALAPPDATA%\Tencent\Weixin';   procs = @('weixin') },
  @{ id = 'app-qq-local';              path = '%LOCALAPPDATA%\Tencent\QQ';       procs = @('qq') },
  @{ id = 'app-wemeet';                path = '%LOCALAPPDATA%\Tencent\WeMeet';   procs = @('wemeetapp', 'wemeet') },
  @{ id = 'app-wps-kingsoft';          path = '%LOCALAPPDATA%\Kingsoft';         procs = @('wps', 'wpscloudsvr', 'wpsdoccenter', 'et', 'wpp') },
  @{ id = 'app-dingtalk';              path = '%LOCALAPPDATA%\DingTalk';         procs = @('dingtalk') },
  @{ id = 'app-feishu';                path = '%LOCALAPPDATA%\Feishu';           procs = @('feishu', 'lark') },
  @{ id = 'steam-htmlcache';           path = '%LOCALAPPDATA%\Steam\htmlcache';  procs = @('steam') },
  @{ id = 'epic-webcache';             path = '%LOCALAPPDATA%\EpicGamesLauncher\Saved\webcache*'; procs = @('epicgameslauncher') },
  @{ id = 'docker-wsl-disk';           path = '%LOCALAPPDATA%\Docker\wsl';       procs = @('docker desktop', 'com.docker.service', 'vmmem', 'wsl') }
)

# ---------------------------------------------------------------- resolve drives
$allFixed = @(Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3' | Select-Object -ExpandProperty DeviceID)
if ($Drives) {
  $driveIds = @()
  foreach ($d in $Drives) { $driveIds += ('{0}:' -f ($d -replace ':$', '')) }
}
else {
  $driveIds = $allFixed
}

# ---------------------------------------------------------------- running processes
$runningProcs = @{}
Get-Process -ErrorAction SilentlyContinue | ForEach-Object {
  $runningProcs[$_.ProcessName.ToLowerInvariant()] = $true
}
function Test-ProcRunning {
  param([object[]]$Procs)
  if (-not $Procs) { return $false }
  foreach ($p in $Procs) {
    if ($runningProcs.ContainsKey([string]$p.ToLowerInvariant())) { return $true }
  }
  return $false
}

# ---------------------------------------------------------------- skip paths (never size/drill)
$skipPaths = @(
  "$env:WINDIR",
  "$env:ProgramFiles",
  "${env:ProgramFiles(x86)}"
)
foreach ($d in $driveIds) {
  $skipPaths += "$d\Windows"
  $skipPaths += "$d\Program Files"
  $skipPaths += "$d\Program Files (x86)"
  $skipPaths += ('{0}\$Recycle.Bin' -f $d)
  $skipPaths += "$d\System Volume Information"
}
function Test-SkipPath {
  param([string]$P)
  $p = $P.TrimEnd('\')
  foreach ($s in $script:skipPaths) {
    if ($p.Length -ge $s.Length -and
        $p.StartsWith($s, [StringComparison]::OrdinalIgnoreCase) -and
        ($p.Length -eq $s.Length -or $p[$s.Length] -eq '\')) { return $true }
  }
  return $false
}

# ---------------------------------------------------------------- phase 1: known probes
$spec = @()
foreach ($item in $knownSpec) { $spec += $item }
foreach ($d in $driveIds) {
  $spec += @{ id = ('sys-recycle-bin-' + $d.TrimEnd(':')); path = ('{0}\$Recycle.Bin' -f $d) }
}

$known = @()
foreach ($item in $spec) {
  if ((Get-Date) -gt $deadline) { $truncated = $true; break }
  $expanded = @(Expand-Paths -Raw $item.path)
  $size = 0L
  foreach ($m in $expanded) {
    $skipPaths += $m.TrimEnd('\')
    $size += Get-TreeBytes -Path $m
  }
  $procs = @()
  if ($item.procs) { $procs = @($item.procs) }
  $known += [pscustomobject]@{
    id      = $item.id
    path    = $item.path
    exists  = ($expanded.Count -gt 0)
    matches = $expanded.Count
    sizeMB  = [math]::Round($size / 1MB, 1)
    procs   = $procs
    running = (Test-ProcRunning -Procs $procs)
    error   = $null
  }
}

# ---------------------------------------------------------------- phase 2: layered full-disk sweep
$tree = @()
$rootFiles = @()
$minBytes = [int64]($MinTreeMB * 1MB)

function Sweep-Dir {
  param([string]$Dir, [int]$Depth)
  if ((Get-Date) -gt $script:deadline) { $script:truncated = $true; return }
  $children = @(Get-ChildItem -LiteralPath $Dir -Directory -Force -ErrorAction SilentlyContinue)
  foreach ($c in $children) {
    if ((Get-Date) -gt $script:deadline) { $script:truncated = $true; return }
    $full = $c.FullName
    try {
      if ($c.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }
    } catch { continue }
    if (Test-SkipPath -P $full) { continue }
    $b = Get-TreeBytes -Path $full
    $record = $false
    if ($Depth -eq 1) { $record = $true }
    elseif ($Depth -eq 2) { $record = ($b -gt 0) }
    elseif ($b -ge $script:minBytes) { $record = $true }
    if ($record) {
      $script:tree += [pscustomobject]@{ path = $full; depth = $Depth; sizeMB = [math]::Round($b / 1MB, 1) }
    }
    if ($b -ge $script:minBytes -and $Depth -lt $script:MaxDepth) {
      Sweep-Dir -Dir $full -Depth ($Depth + 1)
    }
  }
}

if (-not $KnownOnly) {
  foreach ($d in $driveIds) {
    if ((Get-Date) -gt $deadline) { $truncated = $true; break }
    $root = '{0}\' -f $d
    $topFiles = @(Get-ChildItem -LiteralPath $root -File -Force -ErrorAction SilentlyContinue)
    foreach ($f in $topFiles) {
      try { $len = $f.Length } catch { $len = 0 }
      if ($len -ge $minBytes) {
        $rootFiles += [pscustomobject]@{ path = $f.FullName; sizeMB = [math]::Round($len / 1MB, 1) }
      }
    }
    Sweep-Dir -Dir $root -Depth 1
  }
}

# ---------------------------------------------------------------- phase 3: deep name scan
# stack walk over the user profile; name-match via regex; skip known/system paths
$deep = @()
$deepDropped = 0
if (-not $KnownOnly) {
  $namePattern = '^(Cache|cache|Code Cache|GPUCache|ShaderCache|GrShaderCache|DawnWebGPUCache|CacheStorage|CachedData|cache2|Temp|temp|TempState|Logs|logs|Log|log|CrashDumps|Crashpad|crashpad|SquirrelTemp)$'
  $legacyJunction = '\\(Application Data|Local Settings|My Documents|Cookies|SendTo|Start Menu|Templates)\\'
  $stack = [System.Collections.Generic.Stack[object]]::new()
  $stack.Push([pscustomobject]@{ path = $env:USERPROFILE; depth = 1 })
  $deepCount = 0
  while ($stack.Count -gt 0) {
    if ((Get-Date) -gt $deadline) { $truncated = $true; break }
    $cur = $stack.Pop()
    if ($cur.depth -gt 8) { continue }
    $children = @(Get-ChildItem -LiteralPath $cur.path -Directory -Force -ErrorAction SilentlyContinue)
    foreach ($c in $children) {
      $full = $c.FullName
      if ($full -match $legacyJunction) { continue }
      try {
        if ($c.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { continue }
      } catch { continue }
      if (Test-SkipPath -P $full) { continue }
      if ($c.Name -match $namePattern) {
        $b = Get-TreeBytes -Path $full
        if ($b -ge ($DeepMinMB * 1MB)) {
          if ($deepCount -lt 400) {
            $deep += [pscustomobject]@{ path = $full; sizeMB = [math]::Round($b / 1MB, 1); depth = $cur.depth }
            $deepCount++
          }
          else { $deepDropped++ }
        }
      }
      if ($cur.depth -lt 8) { $stack.Push([pscustomobject]@{ path = $full; depth = ($cur.depth + 1) }) }
    }
  }
}

# ---------------------------------------------------------------- assemble output
# dedup: drop tree entries already reported by the deep scan
$seenDeep = @{}
foreach ($d in $deep) { $seenDeep[$d.path.ToLowerInvariant()] = $true }
$treeFinal = @()
foreach ($t in $tree) {
  if ($seenDeep.ContainsKey($t.path.ToLowerInvariant())) { continue }
  $treeFinal += $t
}
$treeFinal = @($treeFinal | Sort-Object sizeMB -Descending)
$deepFinal = @($deep | Sort-Object sizeMB -Descending)

$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).
  IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

$disks = @()
foreach ($dk in (Get-CimInstance Win32_LogicalDisk -Filter 'DriveType=3')) {
  $disks += [pscustomobject]@{
    drive   = $dk.DeviceID
    volume  = $dk.VolumeName
    sizeGB  = [math]::Round($dk.Size / 1GB, 1)
    freeGB  = [math]::Round($dk.FreeSpace / 1GB, 1)
    freePct = [math]::Round(($dk.FreeSpace / $dk.Size) * 100, 1)
  }
}

$knownSum = 0.0
foreach ($k in $known) { $knownSum += $k.sizeMB }
$deepSum = 0.0
foreach ($dd in $deepFinal) { $deepSum += $dd.sizeMB }

$result = [pscustomobject]@{
  mode        = $(if ($KnownOnly) { 'known-only' } else { 'full' })
  generatedAt = (Get-Date).ToString('yyyy-MM-ddTHH:mm:ss')
  hostname    = $env:COMPUTERNAME
  isAdmin     = $isAdmin
  durationSec = [int]$sw.Elapsed.TotalSeconds
  truncated   = $truncated
  minTreeMB   = $MinTreeMB
  maxDepth    = $MaxDepth
  drives      = $driveIds
  disks       = $disks
  known       = $known
  deep        = $deepFinal
  tree        = $treeFinal
  rootFiles   = $rootFiles
  totals      = [pscustomobject]@{
    knownMB      = [math]::Round($knownSum, 1)
    knownCount   = $known.Count
    deepMB       = [math]::Round($deepSum, 1)
    deepCount    = $deepFinal.Count
    deepDropped  = $deepDropped
    treeCount    = $treeFinal.Count
    rootFileCount = $rootFiles.Count
  }
}

if (-not $OutFile) {
  $OutFile = Join-Path $env:TEMP ('junk-scan-{0}.json' -f (Get-Date -Format 'yyyyMMdd-HHmmss'))
}
$result | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $OutFile -Encoding UTF8

Write-Output ("scan done: mode={0} known={1} deep={2} tree={3} truncated={4} sec={5}" -f `
    $result.mode, $known.Count, $deepFinal.Count, $treeFinal.Count, $truncated, $result.durationSec)
Write-Output ("json: {0}" -f $OutFile)
