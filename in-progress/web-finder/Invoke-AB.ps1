# Invoke-AB.ps1 - run agent-browser out-of-tree (spawned by WMI, output to files +
# sentinel), so the opencode shell tool's stdout pipe is never inherited -> no hang.
# Usage: & .\Invoke-AB.ps1 --session <name> [--headed] <agent-browser args...>
$AB = $args
if (-not $AB -or $AB.Count -eq 0) { Write-Output "usage: Invoke-AB.ps1 <agent-browser args...>"; exit 2 }

$dir = Join-Path $env:TEMP 'abwrap'
if (-not (Test-Path -LiteralPath $dir)) { New-Item -ItemType Directory -Force -Path $dir | Out-Null }

# --- locate agent-browser (portable, no hardcoded path) ---
$exe = $env:AGENT_BROWSER_EXE
if (-not $exe) {
  # prefer the real binary; .cmd/.ps1 shims must be `call`ed from a batch file
  $c = Get-Command 'agent-browser-win32-x64.exe' -ErrorAction SilentlyContinue
  if (-not $c) { $c = Get-Command 'agent-browser.exe' -ErrorAction SilentlyContinue }
  if (-not $c) { $c = Get-Command 'agent-browser.cmd' -ErrorAction SilentlyContinue }
  if (-not $c) { $c = Get-Command 'agent-browser.bat' -ErrorAction SilentlyContinue }
  if ($c) {
    $p = $c.Source
    # npm shim location -> real binary next to node_modules (shim does the same lookup)
    $bin = Join-Path (Split-Path -Parent $p) 'node_modules\agent-browser\bin\agent-browser-win32-x64.exe'
    if (Test-Path -LiteralPath $bin) { $exe = $bin }
    elseif ($p -match '\.ps1$') { $exe = $null }   # cmd cannot run a .ps1 shim
    else { $exe = $p }
  }
}
if (-not $exe) { Write-Output "error: agent-browser not found - put it in PATH or set AGENT_BROWSER_EXE"; exit 1 }
$prefix = if ($exe -match '\.(cmd|bat)$') { 'call ' } else { '' }

$stamp = [guid]::NewGuid().ToString('N').Substring(0,8)
$out = Join-Path $dir "out_$stamp.txt"
$err = Join-Path $dir "err_$stamp.txt"
$done = Join-Path $dir "done_$stamp.txt"
$bat = Join-Path $dir "run_$stamp.cmd"

$argLine = ($AB | ForEach-Object {
  if ($_ -match '[&|<>^%\s"]') { '"' + ($_ -replace '"','""') + '"' } else { $_ }
}) -join ' '

$text = "@echo off`r`n$prefix`"$exe`" $argLine > `"$out`" 2> `"$err`"`r`necho x > `"$done`"`r`n"
[System.IO.File]::WriteAllText($bat, $text, [Text.Encoding]::ASCII)

$r = Invoke-CimMethod -ClassName Win32_Process -MethodName Create -Arguments @{CommandLine='cmd /c "' + $bat + '"'}
if ($r.ReturnValue -ne 0) { Write-Output "spawn failed: ReturnValue=$($r.ReturnValue)"; exit 1 }

$limit = 600   # 60s, 100ms poll
$i = 0
while ((-not (Test-Path -LiteralPath $done)) -and $i -lt $limit) { Start-Sleep -Milliseconds 100; $i++ }
$timedOut = -not (Test-Path -LiteralPath $done)

if (Test-Path -LiteralPath $out) { $c2 = Get-Content -LiteralPath $out; if ($c2) { $c2 } }
if (Test-Path -LiteralPath $err) { $e = Get-Content -LiteralPath $err; if ($e) { "--- stderr ---"; $e } }
if ($timedOut) { "[still running after 60s; command left detached]" }

Remove-Item -LiteralPath $bat,$done -ErrorAction SilentlyContinue
if (-not $timedOut) { Remove-Item -LiteralPath $out,$err -ErrorAction SilentlyContinue }
exit $(if ($timedOut) { 124 } else { 0 })
