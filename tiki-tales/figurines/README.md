# Tiki Tales Figurines

## Step 1: Download STLs from Printables

Download these manually (free, by Toby3D):
- [Cute Mini Animals Ed.1](https://www.printables.com/model/1369232-cute-mini-animals) — turtle, fox, whale, koala, etc.
- [Cute Mini Animals Ed.2](https://www.printables.com/model/1385342-cute-mini-animals-edition-2)
- [Cute Mini Animals Ed.3](https://www.printables.com/model/1385880-cute-mini-animals-edition-3)
- [Cute Mini Dinosaurs](https://www.printables.com/model/1401795-cute-mini-dinosaurs)

Place downloaded `.stl` files in this `figurines/raw/` folder.

## Step 2: Process with OpenSCAD

Open `figurine-maker.scad`, set the filename, and export:
```bash
# Process a single figurine:
openscad -o ready/hare-ready.stl \
  -D 'raw_file="raw/fox.stl"' \
  -D 'target_height=70' \
  figurine-maker.scad

# Or open in OpenSCAD GUI and adjust interactively
```

## Step 3: Print

- PLA, 0.2mm layers, **80-100% infill**
- No supports needed (if figurine is chunky)
- **Pause at z=1.5mm** → insert NFC sticker + magnet + washer → resume

## Folder Structure
```
figurines/
├── README.md              # This file
├── figurine-maker.scad    # Universal base adder tool
├── raw/                   # Downloaded STLs (unmodified)
└── ready/                 # Processed STLs (with NFC base)
```
