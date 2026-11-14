. "$PSScriptRoot/environment.ps1"
Invoke-GodotChecked -Arguments @('--headless', '--editor', '--path', '.', '--quit') -Evidence 'parser'
Invoke-GodotChecked -Arguments @('--headless', '--path', '.', '--script', 'res://tests/run_all.gd') -Evidence 'run-all'
