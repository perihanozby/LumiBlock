. "$PSScriptRoot/environment.ps1"
Invoke-GodotChecked -Arguments @('--path','.','--rendering-driver','opengl3','--resolution','1024x768','--script','res://tools/capture_screens.gd') -Evidence 'cube-capture'
