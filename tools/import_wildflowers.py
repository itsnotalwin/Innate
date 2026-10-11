#!/usr/bin/env python3
"""Pack legally downloaded flower sprites without changing their source pixels."""
import argparse
import hashlib
import json
from pathlib import Path
from PIL import Image

ROOT = Path(__file__).resolve().parents[1]


def pack(files, destination, cell_size, columns):
    atlas = Image.new('RGBA', (columns * cell_size, ((len(files) + columns - 1) // columns) * cell_size))
    entries = {}
    for index, path in enumerate(files):
        sprite = Image.open(path).convert('RGBA')
        if max(sprite.size) > cell_size:
            raise ValueError(f'Sprite does not fit its atlas cell: {path}')
        slot = [index % columns, index // columns]
        atlas.alpha_composite(sprite, (slot[0] * cell_size + (cell_size - sprite.width) // 2,
                                     slot[1] * cell_size + cell_size - sprite.height))
        entries[path.stem] = {'slot': slot, 'size': list(sprite.size),
                              'sha256': hashlib.sha256(path.read_bytes()).hexdigest()}
    destination.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(destination)
    return entries


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--btl', required=True, type=Path)
    parser.add_argument('--karsiori', required=True, type=Path)
    args = parser.parse_args()
    btl = [args.btl / f'{number:03d}.png' for number in range(1, 101)]
    karsiori = sorted(path for path in args.karsiori.rglob('*.png')
                      if path.parent.name.lower().startswith('flower ') and 'pot' not in path.parent.name.lower())
    if not karsiori:
        raise ValueError('No Karsiori flowers found')
    catalog = {
        'btl': pack(btl, ROOT / 'assets/wildflowers/btl/flowers.png', 16, 10),
        'karsiori': pack(karsiori, ROOT / 'assets/wildflowers/karsiori/flowers.png', 80, 8),
    }
    (ROOT / 'assets/wildflowers/catalog.json').write_text(json.dumps(catalog, indent=2) + '\n')


if __name__ == '__main__':
    main()
