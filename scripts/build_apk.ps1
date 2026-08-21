# Build script for Flutter APK
# Usage: Open PowerShell in workspace root and run: .\scripts\build_apk.ps1
# Requires Flutter SDK on PATH and Android SDK configured.

param(
    [string] $buildMode = "release"
)

Write-Host "Starting Flutter build (mode=$buildMode)"

Set-Location -Path "..\frontend"

# Fetch packages
flutter pub get

# Build APK
if ($buildMode -eq "release") {
    flutter build apk --release
} else {
    flutter build apk --$buildMode
}

if ($LASTEXITCODE -ne 0) {
    Write-Error "Flutter build failed. Check Flutter logs above."
    exit $LASTEXITCODE
}

# APK output location
$apkPath = Join-Path -Path (Get-Location) -ChildPath "build\app\outputs\flutter-apk\app-$buildMode.apk"
Write-Host "APK built: $apkPath"

# Return to workspace root
Set-Location -Path "..\"
