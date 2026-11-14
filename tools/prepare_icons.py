from pathlib import Path
root=Path(__file__).resolve().parents[1]/'assets/icons'
root.mkdir(parents=True,exist_ok=True)
paths={
'play':'<path d="M9 5l11 7-11 7z"/>',
'pause':'<path d="M8 5v14M16 5v14"/>',
'home':'<path d="M3 11l9-8 9 8M6 10v11h12V10M10 21v-7h4v7"/>',
'settings':'<circle cx="12" cy="12" r="4"/><path d="M12 2v3m0 14v3M2 12h3m14 0h3M5 5l2 2m10 10 2 2M5 19l2-2M17 7l2-2"/>',
'stats':'<path d="M5 20v-7m7 7V4m7 16V9"/>',
'calendar':'<rect x="4" y="5" width="16" height="16" rx="3"/><path d="M8 3v4m8-4v4M4 10h16m-11 5h6"/>',
'flame':'<path d="M13 2c1 7 7 7 7 13a8 8 0 01-16 0c0-4 4-6 5-10 3 3 2 6 4 7 2-3 1-6 0-10z"/>',
'check':'<path d="M5 12l5 5L20 6"/>',
'close':'<path d="M5 5l14 14M19 5L5 19"/>',
'back':'<path d="M14 5l-7 7 7 7M7 12h14"/>',
'volume':'<path d="M3 9h4l5-5v16l-5-5H3zM16 8a6 6 0 010 8m3-11a10 10 0 010 14"/>',
'vibrate':'<rect x="8" y="3" width="8" height="18" rx="2"/><path d="M4 6L2 9l2 3-2 3 2 3m16-12 2 3-2 3 2 3-2 3"/>',
'globe':'<circle cx="12" cy="12" r="9"/><ellipse cx="12" cy="12" rx="4" ry="9"/><path d="M3 12h18"/>',
'info':'<circle cx="12" cy="12" r="9"/><path d="M12 11v6m0-11v1"/>',
'shield':'<path d="M12 2l8 4v7c0 5-8 9-8 9s-8-4-8-9V6z"/>',
'reset':'<path d="M4 9a8 8 0 111 9M4 3v6h6"/>',
}
for name, shape in paths.items():
    (root/f'{name}.svg').write_text('<svg xmlns="http://www.w3.org/2000/svg" width="24" height="24" viewBox="0 0 24 24"><g fill="none" stroke="#E8EEFB" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">'+shape+'</g></svg>',encoding='utf-8')
