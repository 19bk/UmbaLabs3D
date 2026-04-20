# 2.2.0 — Figurine retention ring

Adds a raised ring around the figurine dish on the outer top so figurines don't slide off.

## Changes vs 2.1.0
- Raised cylindrical wall on outer top surface (negative-Z side), centered on dish:
  - Inner Ø: **58 mm** (1.3 mm pinch vs Ø59.3 dish opening — snug fit)
  - Outer Ø: **64 mm** (3 mm wall thickness)
  - Height: **2.5 mm** above outer top surface
  - 0.8 mm chamfer on top inner & outer edges (clean print, easy insertion)
  - 0.5 mm skirt embedded into lid surface for union

## Tuning knobs (in `lid.scad`)
| Parameter | Current | Increase if... | Decrease if... |
|---|---|---|---|
| `dish_ring_id` | 58 | Figurine won't drop in | Figurine sits loose |
| `dish_ring_h` | 2.5 | Figurine tips over | Insertion is too tight |
| `dish_ring_chamfer` | 0.8 | — | Ring feels sharp |

## Print orientation
Dish-side UP on bed. Ring prints as clean vertical perimeters over the flat lid top. No supports.
0.12 mm layers on the ring region for smoothest chamfer finish.

## Mesh
`Simple: yes`, 2 volumes.

## Build
```
openscad -o lid.stl lid.scad
```
