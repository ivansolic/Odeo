<#
.SYNOPSIS
  Odeo installer entry point for Windows PowerShell.

.DESCRIPTION
  This does NOT reimplement the installer. It finds a bash that Windows can reach
  (WSL first, Git Bash second) and runs the real ./install.sh through it.

  Why an entry point and not a port: Odeo's guarantees are 22 bash scripts with exit
  codes, the merge gate, the secret scan, the publish guard. Rewriting them in
  PowerShell would create a second implementation of every guard, and two
  implementations of a guard drift, which ends with a rule that is enforced on one
  platform and merely believed on the other. One implementation, reached from both
  shells, is the honest shape.

  So PowerShell is where you start; bash is still what runs.

.EXAMPLE
  .\install.ps1
  .\install.ps1 -Link
  .\install.ps1 -Lang de
#>
[CmdletBinding()]
param(
    # Symlink instead of copy, so `git pull` updates the installed system live.
    [switch]$Link,
    # Non-interactive document language: en | de | hr | fr
    [ValidateSet('en', 'de', 'hr', 'fr')]
    [string]$Lang,
    # Skip WSL and use Git Bash even if WSL is available.
    [switch]$UseGitBash
)

$ErrorActionPreference = 'Stop'

function Write-Step { param($m) Write-Host "  $m" }
function Write-Bad  { param($m) Write-Host $m -ForegroundColor Red }
function Write-Note { param($m) Write-Host $m -ForegroundColor Yellow }

$repoRoot = $PSScriptRoot
if (-not (Test-Path (Join-Path $repoRoot 'install.sh'))) {
    Write-Bad "install.sh is not next to this script. Run .\install.ps1 from inside the cloned Odeo folder."
    exit 2
}

Write-Host ""
Write-Host "Odeo installer (Windows)" -ForegroundColor Cyan
Write-Host "The guards are bash scripts, so this hands off to WSL or Git Bash."
Write-Host ""

# Everything pasted into a bash command line goes through here first: the repo path, and
# every flag. A Windows home directory can hold an apostrophe (C:\Users\O'Brien\...), which
# unescaped CLOSES the single-quoted string and turns the rest into shell syntax, so the
# install runs in the wrong directory or fails somewhere unrelated. Doubling it the way bash
# requires ('\'') costs one function.
#
# The FLAGS go through it too, though today's are four validated literals. The test that
# guards this file asserts every option install.sh accepts is reachable from here, so this
# block is where future options land, and one of them will eventually carry a value that is
# not from a ValidateSet. Quoting now costs nothing; noticing later costs a defect.
function ConvertTo-BashSingleQuoted {
    param([string]$Text)
    "'" + ($Text -replace "'", "'\''") + "'"
}

# Build the argument string once; both shells take the same flags.
# BEGIN sh-args   (tests/install-ps1.test.sh extracts exactly this block to learn which
#                  flags are passed through, and checks each against install.sh's real
#                  parser; keep both markers, the test fails LOUD if either one moves)
$shArgs = @()
if ($Link) { $shArgs += '--link' }
if ($Lang) { $shArgs += @('--lang', $Lang) }
$shArgString = (($shArgs | ForEach-Object { ConvertTo-BashSingleQuoted $_ }) -join ' ')
# END sh-args

# ---------------------------------------------------------------------------
# 1. WSL, preferred. `wsl.exe` exists on modern Windows even with NO distro
#    installed, so its presence proves nothing: `wsl -l -q` must list one.
#    Checking only for the command is how a Windows install "succeeds" into a
#    machine that cannot run a single script.
# ---------------------------------------------------------------------------
function Get-WslReady {
    if ($UseGitBash) { return $false }
    if (-not (Get-Command wsl.exe -ErrorAction SilentlyContinue)) { return $false }
    try {
        $distros = & wsl.exe -l -q 2>$null
        if ($LASTEXITCODE -ne 0) { return $false }
        return [bool](($distros | Where-Object { $_.Trim() -ne '' }) )
    } catch { return $false }
}

# ---------------------------------------------------------------------------
# 2. Git Bash. Found via PATH, then the two standard install locations.
# ---------------------------------------------------------------------------
function Get-GitBashPath {
    # The bash.exe in System32 is the WSL shim, not Git Bash: running the installer through
    # it while Get-WslReady said no (no distro, or -UseGitBash) is how the "fall back to Git
    # Bash" path would quietly go back to the WSL that was ruled out. SysWOW64 is the same
    # shim seen from a 32-bit PowerShell, so both spellings are excluded.
    $onPath = Get-Command bash.exe -ErrorAction SilentlyContinue
    if ($onPath -and $onPath.Source -notmatch 'System32|SysWOW64') { return $onPath.Source }
    foreach ($p in @(
            "$env:ProgramFiles\Git\bin\bash.exe",
            "${env:ProgramFiles(x86)}\Git\bin\bash.exe",
            "$env:LOCALAPPDATA\Programs\Git\bin\bash.exe")) {
        if (Test-Path $p) { return $p }
    }
    return $null
}

if (Get-WslReady) {
    Write-Step "using WSL"
    # wslpath turns C:\Users\... into /mnt/c/Users/..., which is what bash needs.
    # Inside try/catch for the same reason Get-WslReady is: with $ErrorActionPreference =
    # 'Stop', a native command writing to stderr raises NativeCommandError on Windows
    # PowerShell 5.1, which is what `.\install.ps1` starts by default on Windows. Uncaught,
    # the user meets a stack trace instead of the message written for them right below.
    $wslRepo = $null
    $wslRc = 1          # failure until the call says otherwise, set INSIDE the try: after an
                        # exception $LASTEXITCODE still holds whatever ran last, so testing it
                        # would make this path fail closed by luck rather than by construction.
    try {
        $wslRepo = (& wsl.exe wslpath -a "$repoRoot" 2>$null)
        $wslRc = $LASTEXITCODE
    } catch {
        $wslRc = 1
    }
    if ($wslRc -ne 0 -or -not $wslRepo) {
        Write-Bad "Could not translate '$repoRoot' into a WSL path."
        Write-Host "Install from WSL instead (cd into the clone there and run ./install.sh),"
        Write-Host "or use Git Bash with: .\install.ps1 -UseGitBash"
        exit 1
    }
    $wslRepo = $wslRepo.Trim()
    & wsl.exe bash -lc "cd $(ConvertTo-BashSingleQuoted $wslRepo) && ./install.sh $shArgString"
    $rc = $LASTEXITCODE
}
else {
    $gitBash = Get-GitBashPath
    if (-not $gitBash) {
        Write-Bad "No bash found, so Odeo cannot install yet."
        Write-Host ""
        Write-Host "Odeo's guarantees are bash scripts: the merge gate, the secret scan, the"
        Write-Host "publish guard. PowerShell and cmd cannot run them, so one of these is needed."
        Write-Host ""
        Write-Host "  RECOMMENDED, Windows Subsystem for Linux:" -ForegroundColor Cyan
        Write-Host "    wsl --install"
        Write-Host "    (restart, then run .\install.ps1 again)"
        Write-Host ""
        Write-Host "  ALTERNATIVE, Git for Windows (includes Git Bash):" -ForegroundColor Cyan
        Write-Host "    winget install --id Git.Git -e"
        Write-Host "    (then run .\install.ps1 again)"
        Write-Host ""
        Write-Note "WSL is the better of the two: 'install --link' creates symlinks, which WSL"
        Write-Note "allows by default and native Windows permits only in developer mode."
        exit 1
    }

    Write-Step "using Git Bash ($gitBash)"
    Write-Note "Note: WSL is the better-supported path. On Git Bash, '-Link' asks install.sh"
    Write-Note "to symlink into ~/.claude instead of copying, and native Windows creates"
    Write-Note "symlinks only in developer mode. Without it, install without -Link and re-run"
    Write-Note "the installer after a 'git pull' to update."
    $unixRepo = $repoRoot -replace '\\', '/'
    & $gitBash -lc "cd $(ConvertTo-BashSingleQuoted $unixRepo) && ./install.sh $shArgString"
    $rc = $LASTEXITCODE
}

Write-Host ""
if ($rc -eq 0) {
    Write-Host "Odeo installed." -ForegroundColor Green
    Write-Host "Open the shell you installed from (WSL or Git Bash) and run 'claude' in a project."
    Write-Note "Run Odeo's commands from that same shell: the gates are bash and are not"
    Write-Note "reachable from PowerShell. A session started in PowerShell would give you the"
    Write-Note "workflow without the guards, which is the half that makes it trustworthy."
}
else {
    Write-Bad "install.sh exited with code $rc. The output above is from the real installer."
}
exit $rc
