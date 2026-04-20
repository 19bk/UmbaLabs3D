# Tiki Tales Casing — Changelog

Versioning scheme: **MAJOR.MINOR.PATCH**
- **MAJOR** — form-factor change (toybox → Tonuino redesign)
- **MINOR** — feature added (RC522 holder, retention ring)
- **PATCH** — dimension tweak (hole position, rim height)

Each version folder is self-contained: `lid.scad` + `lid.stl` + `base.stl` + `README.md`.
Render any version by running OpenSCAD on its `lid.scad` — imports resolve to `../source/original-lid.stl`.

The `latest/` symlink points to the current recommended print.

---

## [2.2.0] — 2026-04-20 — Figurine retention ring
- Adds a raised ring (Ø58 inner / Ø64 outer / 2.5 mm tall, chamfered) around the figurine dish opening
- Prevents figurine from sliding sideways off the lid
- All 2.1.0 features retained (RC522 holder, removed obsolete posts)
- Mesh: `Simple: yes`

**Status:** current recommended print. `latest → 2.2.0/`.

## [2.1.0] — 2026-04-19 — RC522 holder added
- Removes 4 obsolete mounting posts (Ø4.5, at (23/77, 25.5/59.5))
- Adds 4 RC522 standoffs (Ø4 × 1.6 mm shoulder → Ø2.5 × 4.4 mm pin)
- Adds 40.4 × 60.4 mm alignment rim (4 mm tall, 1 mm wall) with 0.2 mm/side PCB clearance
- Hole positions from user schematic (centerline offsets ±12.7/±13.15 top, ±17.55/±17.75 bottom)
- PCB test-fit confirmed (see `test-prints/rc522-holder/`)
- Mesh: `Simple: yes`

## [2.0.0] — 2026-03-16 — Baseline toybox
- Original lid and base generated from `source/base.scad` (v5 speaker base design)
- No RC522 provisions
- Starting point for all subsequent iterations

---

## Experiments (not on release track)
- `experiments/dish-reinforcement-disc.*` — Ø40 × 2 mm reinforcement under the figurine dish. Explored as an anti-pillowing fix; superseded by slicer settings + retention ring approach. Retained for reference.

## Test prints
- `test-prints/rc522-holder/` — standalone PCB-fit validator (~4 g filament). Validated hole positions before committing to full-lid prints.

## Legacy / parallel tracks (not yet migrated to semver)
- `v1/` — first-generation toybox (March 2026). Kept flat until retired.
- `v3/` — Tonuino-based redesign (draft, multiple front-panel iterations). To be formalised as `3.0.0-tonuino` when that branch ships its first print-ready lid.
- `archive/v2-flat-layout/` — original flat v2 folder, preserved as-is for one commit cycle. Delete after confirming semver layout works end-to-end.

## Source
- `source/original-lid.stl`, `source/original-base.stl` — unmodified baseline from 2.0.0
- `source/base.scad` — v5 speaker base OpenSCAD source (parametric)
- `source/bunny-lid-variant.stl`, `source/fig-cup-variant.stl` — alternative lid shapes (unused on release track)
