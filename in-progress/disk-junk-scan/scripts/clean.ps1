param(
  [Parameter(Mandatory = $true)][string]$Manifest,
  [string]$OutFile = "$env:TEMP\junk-clean-result.txt"
)
$ErrorActionPreference = 'Continue'

# ---------- helpers
function Expand-Env([string]$s) {
  $guard = 0
  while ($s -match '%[^%]+%' -and $guard -lt 10) {
    $guard++
    $m = [regex]::Match($s, '%([^%]+)%')
    if (-not $m.Success) { break }
    $name = $m.Groups[1].Value
    $v = [Environment]::GetEnvironmentVariable($name)
    if ($null -eq $v) { break }
    $s = $s.Remove($m.Index, $m.Length).Insert($m.Index, $v)
  }
  return $s
}

$Profile  = $env:USERPROFILE.TrimEnd('\')
$Local    = $env:LOCALAPPDATA.TrimEnd('\')
$TempD    = $env:TEMP.TrimEnd('\')
$Win      = $env:WINDIR.TrimEnd('\')
$ProgData = $env:PROGRAMDATA.TrimEnd('\')
$OpProtect = "$Local\Temp\opencode"
$allowedRoots = @($Profile, $Local, $TempD, $Win, $ProgData)

$denyRes = @(
  '(\\Downloads|\\Documents|\\Desktop|\\Pictures|\\Videos|\\Music)(\\|$)'
  '\\OneDrive'
  '\\node_modules(\\|$)'
  '\\\.git(\\|$)'
  '\\\.ssh(\\|$)'
  '\\\.gnupg(\\|$)'
  '\\\.aws(\\|$)'
  '\\\.azure(\\|$)'
  '\\\.config\\opencode(\\|$)'
  '(^|\\)WinSxS(\\|$)'
  'Program Files'
  'Windows\.old'
  'System Volume Information'
  '\\Recovery(\\|$)'
  '\\PerfLogs(\\|$)'
  '\$Recycle\.Bin'
  '(pagefile|hiberfil|swapfile)\.sys$'
  '\.vhdx$'
  '\\Docker\\wsl(\\|$)'
  '(Virtual Machines|Hyper-V)'
  '\\Start Menu(\\|$)'
  '\\Templates(\\|$)'
  '\\Recent(\\|$)'
)
$winAllow = @("$Win\Temp", "$Win\Logs", "$Win\Prefetch", "$Win\Minidump", "$Win\LiveKernelReports", ($Win + '\Installer\$PatchCache$'), "$Win\SoftwareDistribution\Download")
$winFiles = @("$Win\MEMORY.DMP")
$pdAllow  = @("$ProgData\Package Cache", "$ProgData\Microsoft\Windows\WER", "$ProgData\Microsoft\Windows\DeliveryOptimization")

function Eq([string]$a, [string]$b) { $a.Equals($b, [StringComparison]::OrdinalIgnoreCase) }
function Pref([string]$a, [string]$b) { $a.StartsWith($b + '\', [StringComparison]::OrdinalIgnoreCase) }

function Get-RefuseReason([string]$full) {
  $inRoot = $null
  foreach ($r in $script:allowedRoots) { if (Pref $full $r) { $inRoot = $r; break } }
  if (-not $inRoot) { return 'OUT-OF-ALLOWED-ROOTS' }
  if ((Eq $full $script:OpProtect) -or (Pref $full $script:OpProtect)) { return 'PROTECTED-TOOL-DIR' }
  foreach ($re in $script:denyRes) { if ($full -match $re) { return "DENYLIST" } }
  if ((Eq $inRoot $script:Win)) {
    foreach ($a in $script:winAllow) { if ((Eq $full $a) -or (Pref $full $a)) { return $null } }
    foreach ($f in $script:winFiles) { if (Eq $full $f) { return $null } }
    return 'WIN-ALLOWLIST-MISS'
  }
  if ((Eq $inRoot $script:ProgData)) {
    foreach ($a in $script:pdAllow) { if ((Eq $full $a) -or (Pref $full $a)) { return $null } }
    return 'PROGDATA-ALLOWLIST-MISS'
  }
  return $null
}

function Clear-Dir([string]$root) {
  $freed = [int64]0; $ok = 0; $fail = 0; $skip = 0
  $stack = [System.Collections.Generic.Stack[string]]::new()
  $stack.Push($root)
  while ($stack.Count -gt 0) {
    $dir = $stack.Pop()
    if ((Eq $dir $script:OpProtect)) { $skip++; continue }
    try { $files = [System.IO.Directory]::GetFiles($dir) } catch { $fail++; continue }
    foreach ($f in $files) {
      try {
        $len = [System.IO.FileInfo]::new($f).Length
        try { [System.IO.File]::Delete($f) }
        catch {
          [System.IO.File]::SetAttributes($f, [System.IO.FileAttributes]::Normal)
          [System.IO.File]::Delete($f)
        }
        $freed += $len; $ok++
      } catch { $fail++ }
    }
    try { $dirs = [System.IO.Directory]::GetDirectories($dir) } catch { $fail++; continue }
    foreach ($d in $dirs) {
      if ((Eq $d $script:OpProtect)) { $skip++; continue }
      try {
        $attr = [System.IO.File]::GetAttributes($d)
        if ($attr -band [System.IO.FileAttributes]::ReparsePoint) { $skip++; continue }
      } catch { $fail++; continue }
      $stack.Push($d)
    }
  }
  return @{ freed = $freed; ok = $ok; fail = $fail; skip = $skip }
}

# ---------- load manifest
if (-not (Test-Path -LiteralPath $Manifest)) {
  Write-Output "CLEAN-ERROR manifest-not-found: $Manifest"
  exit 2
}
$lines = @(Get-Content -LiteralPath $Manifest -Encoding UTF8)

$drives = @{}
foreach ($d in @(Get-PSDrive -PSProvider FileSystem -ErrorAction SilentlyContinue | Where-Object { $_.Name -match '^[A-Z]$' -and $null -ne $_.Free })) {
  $drives[$d.Name] = [int64]$d.Free
}

$results = New-Object System.Collections.ArrayList
$accepted = New-Object System.Collections.ArrayList

function Add-Result([string]$status, [int64]$freed, [int]$ok, [int]$fail, [int]$skip, [string]$reason, [string]$path) {
  [void]$script:results.Add([pscustomobject]@{ status = $status; freed = $freed; ok = $ok; fail = $fail; skip = $skip; reason = $reason; path = $path })
}

foreach ($raw in $lines) {
  $line = "$raw".Trim()
  if ($line -eq '' -or $line.StartsWith('#')) { continue }
  $exp = Expand-Env $line
  $items = @()
  if ($exp -match '[\*\?]') { $items = @(Get-Item -Path $exp -Force -ErrorAction SilentlyContinue) }
  else { $items = @(Get-Item -LiteralPath $exp -Force -ErrorAction SilentlyContinue) }
  if ($items.Count -eq 0) { Add-Result 'MISSING' 0 0 0 0 'not-found' $exp; continue }
  foreach ($it in $items) {
    $full = $it.FullName
    $nested = $false
    foreach ($a in $accepted) { if (Pref $full $a) { $nested = $true; break } }
    if ($nested) { Add-Result 'NESTED' 0 0 0 0 'already-covered' $full; continue }
    $reason = Get-RefuseReason $full
    if ($reason) { Add-Result 'REFUSED' 0 0 0 0 $reason $full; continue }
    if ($it.PSIsContainer) {
      try {
        $attr = [System.IO.File]::GetAttributes($full)
        if ($attr -band [System.IO.FileAttributes]::ReparsePoint) { Add-Result 'REFUSED' 0 0 0 0 'ROOT-REPARSE' $full; continue }
      } catch { Add-Result 'REFUSED' 0 0 0 0 'STAT-FAIL' $full; continue }
      [void]$accepted.Add($full)
      $s = Clear-Dir $full
      Add-Result 'OK' $s.freed $s.ok $s.fail $s.skip '' $full
    } else {
      $reason = Get-RefuseReason $full
      if ($reason) { Add-Result 'REFUSED' 0 0 0 0 $reason $full; continue }
      [void]$accepted.Add($full)
      $freed = 0L; $ok = 0; $fail = 0
      try {
        $len = [System.IO.FileInfo]::new($full).Length
        try { [System.IO.File]::Delete($full) }
        catch { [System.IO.File]::SetAttributes($full, [System.IO.FileAttributes]::Normal); [System.IO.File]::Delete($full) }
        $freed = $len; $ok = 1
      } catch { $fail = 1 }
      Add-Result 'OK' $freed $ok $fail 0 '' $full
    }
  }
}

# ---------- report
$totFree = 0L; $totOk = 0; $totFail = 0; $totSkip = 0; $refused = 0; $missing = 0; $nested = 0
$report = @('=== CLEAN RESULT ===', ('manifest=' + $Manifest), ('time=' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')), '', 'status|freedMB|deleted|failed|skipped|reason|path')
foreach ($r in $results) {
  $totFree += $r.freed; $totOk += $r.ok; $totFail += $r.fail; $totSkip += $r.skip
  if ($r.status -eq 'REFUSED') { $refused++ }
  if ($r.status -eq 'MISSING') { $missing++ }
  if ($r.status -eq 'NESTED') { $nested++ }
  $report += ('{0}|{1}|{2}|{3}|{4}|{5}|{6}' -f $r.status, [math]::Round($r.freed / 1MB, 1), $r.ok, $r.fail, $r.skip, $r.reason, $r.path)
}
$report += ''
$report += ('TOTAL freedMB={0} deleted={1} failed={2} skipped={3} refused={4} missing={5} nested={6}' -f [math]::Round($totFree / 1MB, 1), $totOk, $totFail, $totSkip, $refused, $missing, $nested)
$report += ''
$report += '=== DRIVE FREE (bytes) before/after/delta ==='
foreach ($d in $drives.Keys | Sort-Object) {
  $now = $null
  $g = Get-PSDrive -Name $d -PSProvider FileSystem -ErrorAction SilentlyContinue
  if ($g -and $null -ne $g.Free) { $now = [int64]$g.Free }
  $before = $drives[$d]
  $delta = if ($null -ne $now) { $now - $before } else { 0 }
  $report += ('{0}: {1} -> {2} ({3:+#;-#;0})' -f $d, $before, $now, $delta)
}
$report | Set-Content -LiteralPath $OutFile -Encoding UTF8
Write-Output ("CLEAN-DONE freedMB={0} deleted={1} failed={2} refused={3} result={4}" -f [math]::Round($totFree / 1MB, 1), $totOk, $totFail, $refused, $OutFile)
