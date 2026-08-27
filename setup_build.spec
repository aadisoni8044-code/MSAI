# -*- mode: python ; coding: utf-8 -*-
"""
PyInstaller build specification for PyCodeStudio executable packaging.
"""

import os
from PyInstaller.utils.hooks import collect_data_files, collect_submodules

block_cipher = None

added_files = [
    ('config', 'config'),
    ('assets', 'assets'),
    ('plugins', 'plugins'),
]

hidden_imports = [
    'PyQt6.Qsci',
    'Pygments',
    'pygments.lexers',
    'pygments.formatters',
] + collect_submodules('editor') + collect_submodules('explorer') + collect_submodules('terminal')

a = Analysis(
    ['main.py'],
    pathex=[],
    binaries=[],
    datas=added_files,
    hiddenimports=hidden_imports,
    hookspath=[],
    hooksconfig={},
    runtime_hooks=[],
    excludes=[],
    win_no_prefer_redirects=False,
    win_private_assemblies=False,
    cipher=block_cipher,
    noarchive=False,
)

pyz = PYZ(a.pure, a.zipped_data, cipher=block_cipher)

exe = EXE(
    pyz,
    a.scripts,
    [],
    exclude_binaries=True,
    name='PyCodeStudio',
    debug=False,
    bootloader_ignore_signals=False,
    strip=False,
    upx=True,
    console=False,
    disable_windowed_traceback=False,
    argv_emulation=False,
    target_arch=None,
    codesign_identity=None,
    entitlements_file=None,
    icon='assets/app_icon.png' if os.path.exists('assets/app_icon.png') else None,
)

coll = COLLECT(
    exe,
    a.binaries,
    a.zipfiles,
    a.datas,
    strip=False,
    upx=True,
    upx_exclude=[],
    name='PyCodeStudio',
)
