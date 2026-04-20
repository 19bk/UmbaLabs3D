# Test Print — RC522 Holder (standalone)

Minimal fit-test for the RC522 mounting features. Prints in ~15 min, <5 g filament.

## Purpose
Validate peg positions + PCB fit before committing to full-lid prints. Mirrors the peg/rim geometry from casing `2.1.0+`.

## Dimensions
46.4 × 66.4 × 7.6 mm (baseplate + rim + pegs)

## Print settings
PLA, 0.2 mm layers, 20 % infill, no supports, no brim needed.

## What to check
1. RC522 PCB drops in with finger pressure (no force)
2. All 4 pins enter PCB holes simultaneously
3. PCB seats flat on all 4 shoulders
4. If BL/BR pegs miss holes → re-measure PCB hole-to-edge on your actual module and update `holes[]` in `../../{VERSION}/lid.scad`
