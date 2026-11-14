param([Parameter(Mandatory=$true)][int]$Phase)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$target = Join-Path $projectRoot "_archive/checkpoints/phase_$Phase"
New-Item -ItemType Directory -Force -Path $target | Out-Null
foreach ($name in @('app','services','ui','core','scripts','scenes','tests','tools','localization','assets','docs','project.godot','export_presets.cfg','.gitignore')) {
    $source = Join-Path $projectRoot $name
    if (Test-Path -LiteralPath $source) { Copy-Item -LiteralPath $source -Destination $target -Recurse -Force }
}
Get-Date -Format o | Set-Content -LiteralPath (Join-Path $target 'TIMESTAMP.txt')
Get-ChildItem -LiteralPath $target -Recurse -File | ForEach-Object { $_.FullName } | Set-Content -LiteralPath (Join-Path $target 'FILES.txt')
