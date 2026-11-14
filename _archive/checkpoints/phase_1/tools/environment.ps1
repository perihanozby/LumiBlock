$ErrorActionPreference = 'Stop'
$ProjectRoot = Split-Path $PSScriptRoot -Parent
$env:APPDATA = Join-Path $ProjectRoot '.runtime/AppData/Roaming'
$env:LOCALAPPDATA = Join-Path $ProjectRoot '.runtime/AppData/Local'
$env:USERPROFILE = Join-Path $ProjectRoot '.runtime/profile'
$env:JAVA_HOME = 'C:\Program Files\Eclipse Adoptium\jdk-17.0.21.9-hotspot'
$env:ANDROID_HOME = 'C:\Android\Sdk'
$env:ANDROID_SDK_ROOT = $env:ANDROID_HOME
$env:ANDROID_USER_HOME = Join-Path $ProjectRoot '.android-user'
$env:ANDROID_SDK_HOME = Join-Path $ProjectRoot '.android-sdk-home'
$env:TEMP = Join-Path $ProjectRoot '.runtime/tmp'
$env:TMP = $env:TEMP
$Godot = 'C:\Users\perih\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64.exe'
foreach ($directory in @($env:APPDATA, $env:LOCALAPPDATA, $env:USERPROFILE, $env:ANDROID_USER_HOME, $env:TEMP)) {
    New-Item -ItemType Directory -Force -Path $directory | Out-Null
}
Set-Location -LiteralPath $ProjectRoot

function Invoke-GodotChecked {
    param([string[]]$Arguments, [string]$Evidence = 'godot')
    New-Item -ItemType Directory -Force build/evidence | Out-Null
    $stdout = "build/evidence/$Evidence.stdout"
    $stderr = "build/evidence/$Evidence.stderr"
    $process = Start-Process -FilePath $Godot -ArgumentList $Arguments -Wait -PassThru -WindowStyle Hidden -RedirectStandardOutput $stdout -RedirectStandardError $stderr
    Get-Content $stdout, $stderr
    if ($process.ExitCode -ne 0) { throw "Godot exit $($process.ExitCode): $Evidence" }
    if (Select-String -Path $stdout,$stderr -Pattern 'SCRIPT ERROR|Parse Error|Failed to load script' -Quiet) { throw "Script errors: $Evidence" }
    Write-Output "EXIT 0: $Evidence"
}
