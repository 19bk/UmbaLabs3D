# 3D Design Lessons Learned — Feedback Loop

> **Purpose**: Every mistake becomes a rule. Every rule prevents the same mistake.
> Review this file at the START of every 3D design session.

---

## Surface Quality Rules (from research)

### Design Phase
16. **Wall thickness = multiples of 0.4mm** (0.8, 1.2, 1.6mm) — non-multiples cause gap-fill blobs on surface.
17. **Chamfer bottom edges, fillet top edges** — bottom fillets sag, top fillets print clean.
18. **Add a sharp vertical edge on every part** — gives the slicer a corner to hide the seam.
19. **4 walls for cosmetic parts** — 2-3 walls show infill ghosting through the surface.
20. **No features smaller than 0.8mm** — they print as blobs, not features.

### Slicer Phase
21. **Scarf seam ON for all cosmetic prints** — single biggest improvement for seam hiding.
22. **Outer wall speed ≤ 40mm/s for quality** — inner walls can stay fast.
23. **Monotonic top surface** — eliminates scarring from directional changes.
24. **Ironing ON for flat tops** — 10% flow, 15mm/s. Adds time but eliminates top surface texture.
25. **Smooth PEI plate** for glass-smooth bottom surface on visible parts.

### A1 Specific
26. **Tall parts get Y-axis ringing** — A1 is bed-slinger. Keep cosmetic parts short or slow down.
27. **PLA at 200-210°C** — lower = less stringing, cleaner retractions.
28. **Bed at 55°C max** — higher causes elephant's foot.
29. **Don't increase retraction past 0.8mm** — causes clogs on A1's direct drive.

---

### RULE ZERO — THE MOST IMPORTANT RULE
30. **DO NOT CHANGE ANYTHING THE USER DIDN'T ASK FOR.** No "improvements", no "optimizations", no shape changes, no thickness changes, no edge changes. If unsure, ASK. Do not guess. Do not assume. Every unauthorized change wastes filament and time.

---

## Critical Rules (from real failures)

### STL Modification
1. **NEVER add geometry that changes the original surface profile** — fill blocks, cubes, and cylinders alter rounded edges. Use `hull()` + `intersection()` to fill holes while preserving shape.
2. **Fill first, cut second** — when replacing a circular hole with a rectangle: hull-fill the circle to make solid wall, THEN cut the rectangle.
3. **Count features before modifying** — render the original from the relevant angle, count every hole/feature, document positions BEFORE touching anything.

### Print Failures
4. **Solid cylinders > 20mm diameter overheat** — use tube walls (2mm) for proper FDM cooling.
5. **Fill blocks must match panel thickness EXACTLY** — `pt + 1` creates visible bumps. Use `pt` only.
6. **Flat bottom = bed adhesion** — no rounded bottom edges (pillow/fillet). Full flat contact.
7. **Ridge/features print UP, smooth face DOWN** — orient for print, not for viewing.
8. **Floating geometry = non-manifold** — after ANY CSG on STL, check `Simple: yes`.

### Dimensional Errors
9. **One change per print iteration** — never change >2 parameters at once when debugging fit.
10. **Bayonet tab must fit inside channel** — write Z-stack math in comments: `tab_bottom`, `tab_top`, `channel_bottom`, `channel_top`, verify clearance ≥ 0.3mm.
11. **Speaker center from mesh data, not estimates** — verify circular feature centers before building geometry around them.
12. **Rectangle must fully contain circle when replacing** — if it doesn't, the circle remnant shows.

### Workflow
13. **Version files: v1, v2, v3** — NEVER overwrite working files.
14. **Mini test prints at 25% scale** — verify fit before wasting filament on full size.
15. **Export checklist is MANDATORY** — no STL leaves without `Simple: yes` + visual inspection.

---

## Incident Log

### 2026-03-25: Fill Block Changed Body Shape
- **What happened**: Added a cube to fill the circular switch hole. The cube had sharp edges that replaced the body's rounded surface.
- **Root cause**: CSG union of a flat cube with a curved STL mesh creates a visible seam where the flat surface meets the curve.
- **Fix**: Used `hull()` of the original body (which fills all holes while preserving shape), intersected with a local area, then cut the rectangle.
- **Rule**: Use `hull() + intersection()` to fill STL holes, never raw cubes.

### 2026-03-25: Front Panel Thicker at Button Area
- **What happened**: Fill block was `pt + 1` thick (4.6mm) instead of `pt` (3.6mm). Created a visible bump on the panel.
- **Root cause**: Added extra thickness "for safety" without checking.
- **Fix**: Changed to exact panel thickness `pt`.
- **Rule**: Fill blocks MUST match the surrounding thickness exactly.

### 2026-03-25: Extra Screw Holes Added
- **What happened**: Re-cut screw holes at guessed positions (X=40, Z=±28) that didn't match the original (X=39, Z=±29). Created 6 holes instead of 4.
- **Root cause**: Didn't render the original to count and locate holes before modifying.
- **Fix**: Removed fake holes. Used narrower fill block that doesn't cover corner screws.
- **Rule**: Render original → count features → document positions → then modify.

### 2026-03-25: Speaker Grille Offset from Ridge
- **What happened**: Set speaker center at X=-7 by guess. Actual center was different. Grille didn't align with ridge.
- **Root cause**: Estimated position from a render instead of measuring from mesh data.
- **Fix**: Verified center from Part 2 mesh analysis.
- **Rule**: Measure circular feature centers from mesh data before building around them.

### 2026-03-15: Bayonet Tab Jammed
- **What happened**: Tab height (1.6mm) exceeded channel height (1.8mm) at the seated position. Tab hit the channel roof during twist.
- **Root cause**: Tab Z position calculated without checking global coordinates when lid is seated.
- **Fix**: Added Z-stack math in comments, reduced tab height, repositioned to bottom of lip.
- **Rule**: For engaging/moving parts, write the full Z-stack calculation and verify clearance.

### 2026-03-14: Lid Melting During Print
- **What happened**: Solid 41mm cylinder lip overheated — too much material in one spot, no cooling between passes.
- **Root cause**: FDM can't cool a solid cylinder efficiently — needs air gaps.
- **Fix**: Changed to tube walls (2mm thick) instead of solid.
- **Rule**: No solid cylinders > 20mm diameter. Use tube walls.

### 2026-03-14: Box Warping
- **What happened**: Toybox base warped and lifted off the bed at corners.
- **Root cause**: Pillow shape with 4mm rounded bottom edges = minimal bed contact.
- **Fix**: Replaced pillow with flat-bottom rbox.
- **Rule**: Flat bottom, full bed contact. No rounded bottom edges.

### 2026-03-14: Cup Print Failing to Stick
- **What happened**: Figurine base cup kept failing on Bambu A1.
- **Root cause**: 1.5mm bottom fillet reduced contact area. Thin features at first layer.
- **Fix**: Removed fillet, flat bottom, added brim.
- **Rule**: First layer must be flat with maximum bed contact. Use brim for small parts.

---

## Review Protocol

**At session start:**
1. Read this file
2. Check which rules apply to the current task
3. If a rule was violated in the last session, call it out before starting

**After each print failure:**
1. Add an incident entry (what happened, root cause, fix, rule)
2. Add the rule to the Critical Rules section
3. Update CLAUDE.md if the rule is broadly applicable

**Monthly:**
1. Review all rules — remove any that are no longer relevant
2. Consolidate similar rules
3. Count violations per rule — focus training on the most-violated ones
