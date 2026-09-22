# Build script for Flutter APK
# Usage: Open PowerShell in workspace root and run: .\scripts\build_apk.ps1
# Requires Flutter SDK on PATH and Android SDK configured.

param(
    [string] $buildMode = "release",
    [string] $apiBaseUrl = "http://localhost:8081"
)

Write-Host "Starting Flutter build (mode=$buildMode, api=$apiBaseUrl)"

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$mobileRoot = Join-Path $workspaceRoot "apps\mobile"
Set-Location -Path $mobileRoot

# Fetch packages
flutter pub get

# Build APK
if ($buildMode -eq "release") {
    flutter build apk --release --dart-define=API_BASE_URL=$apiBaseUrl
} else {
    flutter build apk --$buildMode --dart-define=API_BASE_URL=$apiBaseUrl
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed. Check Flutter logs above."
    exit $LASTEXITCODE
}

# APK output location
$apkPath = Join-Path -Path (Get-Location) -ChildPath "build\app\outputs\flutter-apk\app-$buildMode.apk"
Write-Host "APK built: $apkPath"

# Return to workspace root
Set-Location -Path $workspaceRoot
