# 2.1.0 — RC522 holder

Adds RC522 RFID module mounting to the lid interior.

## Changes vs 2.0.0
- Removed 4 obsolete mounting posts (Ø4.5 × 3.5 mm)
- Added 4 standoffs for RC522 PCB:
  - Base shoulder: Ø4 × 1.6 mm (PCB rests on this)
  - Pin: Ø2.5 × 4.4 mm (passes through Ø3 mm PCB holes with 0.25 mm/side clearance)
  - Total standoff height: 6 mm above cavity floor
- Added 40.4 × 60.4 mm PCB alignment rim (4 mm tall, 1 mm wall)
- PCB underside sits at Z=3.2 → 1.6 mm antenna clearance below PCB

## Peg positions (lid XY absolute)
| Peg | X | Y |
|---|---|---|
| TL | 37.30 | 65.65 |
| TR | 63.15 | 65.65 |
| BL | 32.45 | 28.15 |
| BR | 67.75 | 28.25 |

## Verification
- Test print (`../test-prints/rc522-holder/`) confirmed hole alignment
- Mesh: `Simple: yes`, 2 volumes

## Build
```
openscad -o lid.stl lid.scad
```
