# Run on a physical phone (same Wi‑Fi as your PC).
# Edit env.device.json with your PC LAN IP, then:
#   .\scripts\run-device.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

$envFile = Join-Path $PWD "env.device.json"
if (-not (Test-Path $envFile)) {
  Copy-Item (Join-Path $PWD "env.device.json.example") $envFile
  Write-Host "Created env.device.json — edit your LAN IP if needed, then re-run."
}

flutter pub get
flutter run --dart-define-from-file=env.device.json @args
