#!/usr/bin/env python3
import datetime
import json
from pathlib import Path
import shutil
import sys
import subprocess
import tomllib

root = Path(__file__).resolve().parent
app = Path.home() / '.config/herdr-app'
old = tomllib.loads((Path.home() / '.config/herdr/config.toml').read_text())
keys = json.loads((app / 'keys.json').read_text())
settings = json.loads((app / 'settings.json').read_text())
settings.setdefault('sounds', {})['enabled'] = old['ui']['sound']['enabled']
settings['appearance'] = 'dark'
colors = old['theme']['custom']
settings.setdefault('colors', {}).update({
    'background': colors['panel_bg'], 'chrome': colors['panel_bg'],
    'canvas': colors['surface_dim'], 'surface': colors['surface0'],
    'raised': colors['surface1'], 'selected': colors['active_row_bg'],
    'selection': colors['selection_bg'], 'border': colors['overlay0'],
    'foreground': colors['text'], 'muted': colors['subtext0'], 'accent': colors['accent'],
})
actions = {}
mapping = {
    'settings': 'app.settings', 'toggle_sidebar': 'layout.toggle:sidebar',
    'help': 'app.help', 'workspace_picker': 'mod.open:minimal-picker', 'goto': 'mod.open:minimal-picker',
    'previous_agent': 'agent.prev', 'next_agent': 'agent.next',
    'new_tab': 'tab.new', 'previous_tab': 'tab.prev', 'next_tab': 'tab.next',
    'rename_tab': 'mod.open:minimal-rename', 'close_tab': 'tab.close',
    'split_vertical': 'pane.split:right', 'split_horizontal': 'pane.split:down',
    'close_pane': 'pane.close', 'zoom': 'pane.zoom',
    'new_workspace': 'space.new', 'rename_workspace': 'space.rename',
    'previous_workspace': 'space.prev', 'next_workspace': 'space.next',
}
def bind(chord, action):
    chord = chord.replace('+', '-').replace('period', '.').replace('minus', '-').replace('slash', '/')
    if chord.startswith('prefix-'):
        actions[chord[7:]] = action
    else:
        keys['global'][chord] = action

for name, action in mapping.items():
    chords = old['keys'].get(name, '')
    for chord in chords if isinstance(chords, list) else [chords]:
        if chord:
            bind(chord, action)
for i in range(1, 10):
    bind(f'prefix+{i}', f'tab.select:{i}')
    bind(f'alt+{i}', f'tab.select:{i}')
    bind(f'prefix+shift+{i}', f'space.select:{i}')
for item in old['keys']['command']:
    if item['type'] in ('pane', 'popup') and 'scrollback-nvim' not in item['command']:
        bind(item['key'], {
            'shell': item['command'], 'name': item['description'],
            'popup': item['type'] == 'popup',
        })
actions['shift-r'] = 'mod.open:recap'
actions['shift-w'] = {'worktree': 'new'}
actions['ctrl-w'] = {'worktree': 'open'}
keys['global']['ctrl-space'] = 'mod.open:legacy-prefix'
if keys['global'].get('f2') == 'tab.rename':
    keys['global']['f2'] = 'mod.open:minimal-rename'
for chord, action in keys['global'].items():
    if action == 'app.palette':
        keys['global'][chord] = 'mod.open:minimal-palette'
keys['global']['ctrl-shift-p'] = 'mod.open:minimal-palette'
output = root / 'generated'
output.mkdir(exist_ok=True)
for name, data in [('keys.json', keys), ('settings.json', settings)]:
    (output / name).write_text(json.dumps(data, indent=2) + '\n')
mod = root / 'mods/legacy-prefix'
(mod / 'bindings.js').write_text('export default ' + json.dumps(actions, indent=2) + ';\n')
if '--install' in sys.argv:
    stamp = datetime.datetime.now().strftime('%Y%m%d-%H%M%S')
    target = app / 'mods/legacy-prefix'
    if target.exists():
        raise SystemExit(f'Refusing to overwrite {target}')
    for name in ('keys.json', 'settings.json'):
        shutil.copy2(app / name, app / f'{name}.backup-{stamp}')
    shutil.copytree(mod, target)
    subprocess.run(['herdr-app', 'check', str(target)], check=True, timeout=30)
    for name in ('keys.json', 'settings.json'):
        shutil.copy2(output / name, app / name)
    print(f'Installed; backups end in .backup-{stamp}')
else:
    print(f'Prepared in {output}; run with --install to apply')
