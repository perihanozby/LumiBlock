from pathlib import Path
root=Path(__file__).resolve().parents[1]
for name in ['home','daily','stats','settings','pause','game_over','language_picker','about','privacy']:
    folder=root/'ui/screens'/name
    folder.mkdir(parents=True,exist_ok=True)
    (folder/f'{name}_screen.gd').write_text(f'extends MenuScreen\n\nfunc _init() -> void:\n\tscreen_id="{name}"\n',encoding='utf-8')
    (folder/f'{name}_screen.tscn').write_text(f'''[gd_scene load_steps=2 format=3]
[ext_resource type="Script" path="res://ui/screens/{name}/{name}_screen.gd" id="1"]
[node name="{name.title()}Screen" type="Control"]
script = ExtResource("1")
''',encoding='utf-8')
