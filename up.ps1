param(
    [switch]$Uninstall
)

# Get the script directory (where chrome folder is located)
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$chromeSource = Join-Path $scriptDir "chrome"

# Find Firefox profile directory
$firefoxProfilesPath = Join-Path $env:APPDATA "Mozilla\Firefox\Profiles"
$defaultProfile = Get-ChildItem -Path $firefoxProfilesPath -Directory -Filter "*.default-release" | Select-Object -First 1

if (-not $defaultProfile) {
    Write-Host "Error: Could not find Firefox default-release profile." -ForegroundColor Red
    exit 1
}

$chromeTarget = Join-Path $defaultProfile.FullName "chrome"

if ($Uninstall) {
    Write-Host "Removing profile from Firefox..."
    if (Test-Path $chromeTarget) {
        Remove-Item -Path $chromeTarget -Recurse -Force
    }
} else {
    Write-Host "Applying profile to Firefox..."
    if (Test-Path $chromeTarget) {
        Remove-Item -Path $chromeTarget -Recurse -Force
    }
    Copy-Item -Path $chromeSource -Destination $defaultProfile.FullName -Recurse -Force
}

Write-Host "Restarting Firefox..."
# Stop Firefox if running
Get-Process -Name "firefox" -ErrorAction SilentlyContinue | Stop-Process -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 1
# Start Firefox
Start-Process "firefox.exe"
Write-Host "Done!"

