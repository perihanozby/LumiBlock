. "$PSScriptRoot/environment.ps1"
Invoke-GodotChecked -Arguments @('--headless','--editor','--path','.','--quit') -Evidence 'android-build-parser'
$exportArguments = @('--headless','--path','.')
if (-not (Test-Path -LiteralPath 'android/build/build.gradle')) { $exportArguments += '--install-android-build-template' }
$exportArguments += @('--export-debug','"Android Debug"','build/lumiblock-debug.apk')
Invoke-GodotChecked -Arguments $exportArguments -Evidence 'android-debug-export'
if (-not (Test-Path -LiteralPath 'build/lumiblock-debug.apk')) { throw 'No APK produced' }
Get-Item -LiteralPath 'build/lumiblock-debug.apk' | Select-Object Name,Length
Get-FileHash -LiteralPath 'build/lumiblock-debug.apk' -Algorithm SHA256
if ((Get-Item -LiteralPath 'build/lumiblock-debug.apk').Length -gt 32MB) { throw 'APK exceeds 32 MiB (PowerShell 32MB)' }
