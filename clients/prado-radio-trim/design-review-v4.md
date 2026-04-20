# Engineering Design Review: Prado 150 Radio Trim Adapter v4

| Field | Value |
|-------|-------|
| **Author** | UmbaLabs 3D |
| **Date** | 2026-03-10 |
| **Revision** | v4 |
| **Status** | Draft — Peer Review Requested |
| **Reviewer** | *(your name here)* |
| **CAD file** | `files/radio-trim-v4.scad` |
| **STL file** | `files/radio-trim-v4.stl` |

---

## 1. Problem Statement

**Vehicle:** 2018 Toyota Land Cruiser Prado 150 (J150 series)

The client removed the OEM Eclipse AVN-R8W navigation unit (Toyota 200mm wide format) and installed a Sony XAV-AX8500 aftermarket head unit. The Sony uses a standard single-DIN chassis that is substantially smaller than the Eclipse cavity, leaving visible gaps on all sides.

| Dimension | Eclipse (OEM) | Sony (New) | Gap |
|-----------|--------------|------------|-----|
| Width | 205.5mm | 178mm | 27.5mm (13.75mm/side) |
| Height | 104mm | 50mm | 54mm total |
| Depth | 165mm | 158mm | 7mm |

The Sony has a floating 10.1" touchscreen (269 × 167mm) that sits in front of the trim, so the screen overhangs the trim on all sides. The trim only needs to look clean in the narrow visible border between the screen edge and the fascia opening.

### Requirements

1. Clip securely into the dash cavity — no visible screws from the front
2. Clean finished face around the Sony DIN chassis opening
3. Sony floating screen sits in front unobstructed
4. Survive Kenyan vehicle interior temperatures (up to 70°C in direct sun)
5. Removable for service access (no permanent adhesives)
6. Match OEM appearance (black, flush flange against gloss fascia)

---

## 2. Dimension Sources and Confidence Levels

| Parameter | Value in v4 | Source | Confidence | Notes |
|-----------|-------------|--------|------------|-------|
| Eclipse face width | 205.5mm | Operation manual p.204 (仕様) | **High** | Manufacturer spec, confirmed model AVN-R8W (W = wide) |
| Eclipse face height | 104mm | Operation manual p.204 | **High** | Manufacturer spec |
| Eclipse depth | 165mm | Operation manual p.204 | **High** | Not critical — trim depth is only 25mm |
| Sony DIN width | 178mm | Sony Help Guide specs | **High** | Confirmed across multiple sources |
| Sony DIN height | 50mm | Sony Help Guide specs | **High** | Standard single DIN |
| Sony DIN depth | 158mm | Sony Help Guide specs | **High** | Not critical for trim |
| Dash cavity width | ~200-210mm | Client ruler measurement (20-21cm) | **Medium** | Rounded to nearest cm; fascia opening vs total gap unclear |
| Dash cavity height | ~110mm | Client ruler measurement (11cm) | **Medium** | Includes gap beyond Eclipse envelope |
| Corner radius | 8mm | Photo analysis of gloss fascia | **Low** | Estimated from photos, could be 5-10mm |
| DIN Y position | 15mm from bottom | Client gap measurement (1.5cm bottom) | **Medium** | Consistent with photos showing cage low in opening |
| Dash angle | 12° from vertical | Estimated from side-view photos | **Low** | Never physically measured. Biggest risk. |
| Cavity depth | 38mm | Client measurement (3.8cm protrusion) | **Medium** | Trim only uses 25mm of this |

### What we don't have

- No dimensioned chassis outline drawing for either radio (only text specs)
- Eclipse installation manual is image-based with no numeric face plate dimensions
- Sony Operating Instructions p.79 has a dimension diagram but could not be extracted digitally (ManualsLib renders as image; PDF downloads were corrupted or blocked)
- No measurement of the metal frame edge thickness (affects clip engagement)
- No inclinometer measurement of the dash angle
- No caliper measurements of the fascia corner radius

---

## 3. Design Decisions and Trade-offs

### 3.1 Outer Dimensions: 205 × 104mm

We use the Eclipse face dimensions as a proxy for the dash cavity size, reduced by 0.5mm on width for clearance (205.5 → 205mm). The rationale: the Eclipse was designed as a precision fit for this cavity, so its face dimensions define the opening better than the client's ruler measurements (20cm rounds to anywhere from 198-205mm).

The client measured 21cm total gap width and 20cm fascia opening. The 205mm outer body fits within the fascia opening; the 4mm flange overhang on each side extends to ~213mm total, covering the fascia edge.

**Trade-off:** If the cavity is actually larger (say 210mm), the body will be 5mm undersized and may shift laterally. The snap clips mitigate this by centering the trim, and the flange provides visual coverage.

### 3.2 DIN Cutout: 179 × 51mm

Sony chassis is 178 × 50mm. We added 1mm clearance on width and height (0.5mm per side). This is a pass-through opening (not a retention feature), so clearance is generous to allow the Sony chassis to thread through without binding.

**Position:** Centered horizontally: `(205 - 179) / 2 = 13mm` each side. Vertically: 15mm from bottom edge, derived from client's 1.5cm bottom gap measurement.

**Validation:** Client measured top gap = 5cm, DIN height = 5cm, bottom gap = 1.5cm. Total = 11.5cm vs 11cm measured. The ~5mm discrepancy is within tape-measure error margin. The 15mm bottom offset checks out: `15mm + 50mm DIN + 39mm top gap = 104mm = Eclipse height`.

### 3.3 Body Depth: 25mm

The cavity is 38mm deep (client measurement). We use only 25mm because:
- Deep enough for the 18mm snap clip arms + 3mm inset from front
- Shallow enough to leave 13mm clearance behind for RCA connectors and wiring harness
- Reduces material use and print time
- No structural benefit to filling the full cavity depth

### 3.4 Front Flange: 4mm overhang, 2.5mm thick

The flange sits against the gloss fascia surface and prevents push-through. Design choices:
- **4mm overhang:** Enough to cover the fascia edge and provide visual closure, not so much that it looks bulky. The Sony floating screen covers most of the flange face anyway.
- **2.5mm thick:** Provides rigidity without creating an excessive step from the fascia surface. Thin enough to be unobtrusive under the screen overhang.
- The flange follows the same corner radius as the outer body (8mm + 4mm = 12mm flange radius).

### 3.5 Wall Thickness: 2.5mm

Standard for FDM structural parts. At 0.4mm nozzle / 0.45mm line width, this gives ~5-6 perimeters, making the walls essentially solid. The body interior is hollowed to save material (~60-80g vs ~150g solid).

### 3.6 Tolerance: 0.4mm per side

- v1 used 0.5mm (too loose)
- v2 used 0.3mm (tight friction fit)
- v4 uses 0.4mm: the snap clips provide positive retention, so the body-to-cavity fit can be slightly loose. The clips do the holding; the body just needs to slide in without binding.

### 3.7 Dash Angle: 12°

The entire body + flange is rotated 12° around the X axis. This tilts the front face to match the dashboard surface (top of dash is further from the driver than the bottom). The bottom of the part is cut flat for the print bed.

**This is the highest-risk parameter.** Estimated from a side-view photo. If the actual angle is 8° or 16°, the flange will have a visible 2-3mm gap on one edge.

---

## 4. Snap Clip Mechanism

### 4.1 Design Concept

Toyota OEM trim pieces use spring clips that flex inward during insertion, then snap outward to hook behind the metal frame edge. The client's photos show yellow OEM retaining clips on the bracket sides. The v4 design replicates this in printed plastic.

### 4.2 Clip Geometry

```
Parameters:
  clip_w     = 10mm    (width of each clip tab)
  clip_t     = 1.5mm   (arm thickness — the flexing beam)
  clip_depth = 18mm    (cantilever arm length)
  clip_hook  = 2mm     (hook overhang — catches behind frame)
  clip_hook_h = 3mm    (hook barb height)
  clip_gap   = 0.8mm   (flex room between arm and body wall)
```

**Layout:** 4 clips total — 2 per side at 30% and 70% of outer height (y = 31.2mm and 72.8mm). This spacing distributes retention force evenly and avoids the corner radii zones.

**Hook profile:** The entry face is angled (generated with `hull()` between the arm tip and an offset point). This provides a ramp for smooth insertion. The catch face is square, resisting pullout.

```
Side view of one clip:

    Body wall
    │
    │  ┌─ 0.8mm gap ─┐
    │  │              │
    │  │   ┌──────────┤ clip arm (1.5mm thick × 18mm long)
    │  │   │          │
    │  │   │     ╱────┘ hook (2mm overhang, angled entry)
    │  │   │    ╱
    │  │   └───╱
    │  │
```

### 4.3 Cantilever Beam Analysis

The clip arm acts as a cantilever fixed at the body wall, loaded at the hook tip during insertion.

```
Beam:  L = 18mm, w = 10mm, t = 1.5mm
I = w × t³ / 12 = 10 × 1.5³ / 12 = 2.81 mm⁴

For PETG (E ≈ 2.0 GPa):
  δ = 2mm (hook must deflect flush for insertion)
  F = 3 × E × I × δ / L³
  F = 3 × 2000 × 2.81 × 2 / 18³
  F ≈ 5.8 N per clip

Total insertion force: ~23N (4 clips) — firm push, easily achievable by hand

For PLA (E ≈ 3.5 GPa):
  F ≈ 10.1N per clip, ~40N total — quite stiff, risk of breakage
```

**Conclusion:** PETG is the better material choice. PLA clips will be stiffer and more brittle, with higher risk of snapping during insertion or fatigue failure from thermal cycling.

### 4.4 Friction Ribs (Secondary Retention)

```
Parameters:
  rib_h     = 0.6mm   (protrusion height)
  rib_w     = 3mm     (width)
  rib_depth = 15mm    (length along depth axis)
  rib_count = 3       (per surface: top and bottom)
```

6 ribs total (3 top, 3 bottom) provide:
- Secondary friction retention
- Anti-rattle (prevents the trim from vibrating against the cavity walls)
- Vertical self-centering in the cavity

Positioned starting 5mm back from the front face to avoid impeding initial insertion.

### 4.5 Design Evolution

| Version | Retention Method | Issue |
|---------|-----------------|-------|
| v1 | Side clip tabs + M3 screw posts | Client reported "not working" — geometry issues |
| v2 | Friction fit only (no clips) | Relied on tight tolerance — insufficient retention |
| v3 | Friction fit + flange | Better but no positive retention mechanism |
| **v4** | **Snap clips + friction ribs + flange** | **Current design** |

---

## 5. Known Risks and Uncertainties

### Critical (must resolve before final print)

| # | Risk | Impact | Mitigation |
|---|------|--------|------------|
| 1 | **Dash angle wrong** (12° estimate) | Flange gap 2-3mm on one edge, visibly poor fit | Client measures with phone inclinometer before printing |
| 2 | **Clip doesn't engage** (frame edge unknown) | Trim won't stay in, falls out | Test print with clips first; add screw holes as backup |

### High

| # | Risk | Impact | Mitigation |
|---|------|--------|------------|
| 3 | Corner radius mismatch (8mm est.) | Corners float or bind against fascia | Test fit with thin shell; adjustable parameter |
| 4 | PLA used instead of PETG | Clips snap, body warps in heat | Specify PETG. PLA is not acceptable for final part. |

### Medium

| # | Risk | Impact | Mitigation |
|---|------|--------|------------|
| 5 | Outer dims undersized (cavity > 205mm) | Trim shifts laterally | Clips center the trim; flange covers gap |
| 6 | DIN position off by 2-3mm | Sony chassis slightly misaligned | Sony has built-in bracket adjustment (25mm W, 20mm D) |
| 7 | Clip arms too thin for print quality | Clips break during insertion | Print with 0.4mm nozzle minimum, 3+ perimeters |

### Low

| # | Risk | Impact | Mitigation |
|---|------|--------|------------|
| 8 | PETG clip fatigue from thermal cycling | Clips weaken over months | Monitor; 2mm hook provides good engagement margin |
| 9 | Body hollowing weakens clip roots | Clip base delaminates from wall | (see Section 8, Q3 — reinforcement gap in code) |

---

## 6. Print Recommendations

| Setting | Value | Rationale |
|---------|-------|-----------|
| **Material** | PETG (black) | Heat resistance (Tg ~80°C), clip flexibility, UV stability. PLA is NOT acceptable. |
| **Nozzle** | 0.4mm | Standard; good detail for clip arms |
| **Layer height** | 0.2mm | Good balance of quality and speed |
| **Perimeters** | 4 minimum | 2.5mm walls = ~6 perimeters at 0.4mm, mostly solid |
| **Infill** | 30% gyroid | Only applies to flange (body walls are solid perimeters) |
| **Orientation** | Front face (flange) DOWN on build plate | Best surface finish on visible face; clip arms print vertically (strongest for flex) |
| **Supports** | Yes — under clip hooks | Hooks have overhang > 45°. Tree supports recommended. |
| **Bed adhesion** | Brim (5mm) | Large flat flange provides good adhesion; brim prevents corner lifting |
| **Print time** | ~3-5 hours (est.) | Depending on printer speed |
| **Material usage** | ~60-80g PETG | With hollow body |
| **Post-processing** | Light sanding of flange face if layer lines visible | The flange is partially hidden under Sony screen |

---

## 7. Test Fit Strategy

### Phase 0: Verify Dimensions (Before ANY Print)

Client needs to provide:
1. Dash angle — phone inclinometer app, phone flat against radio fascia
2. Cavity corner radius — photo with ruler held against corner
3. Confirm whether the metal bracket edge is accessible from inside the cavity (for clip engagement)

### Phase 1: Paper Template

Print the front face outline at 1:1 scale on paper (just the 2D profile with DIN cutout marked). Client holds it against the dash opening to verify:
- Outer dimensions fit within fascia opening
- Corner radii align
- DIN cutout lines up with Sony cage

**Cost:** free. **Time:** 5 minutes.

### Phase 2: Thin Test Shell

Print outer shell only — 8mm depth, no clips, no friction ribs, 15% infill.
Verify:
- Body slides into cavity with appropriate resistance
- Flange sits flush against fascia at correct angle
- DIN cutout aligns with Sony chassis

**Cost:** ~20g PETG. **Time:** ~45 minutes.

### Phase 3: Full Test Print

Print complete v4 with clips. Test:
- Insertion force (should be a firm push, not a hammer)
- Clip engagement (should feel a distinct "click")
- Retention (pull firmly — should resist > 10N pullout)
- Flange flush (no gaps > 0.5mm around perimeter)
- DIN alignment (Sony chassis passes through cleanly)
- Rattle test (tap/shake — no buzzing or vibration)

### Phase 4: Final Print

Adjust parameters based on test fit. Print in final material/color. Consider:
- Foam gasket tape on back of flange (anti-rattle, gap compensation)
- Light sanding / vapor smoothing if surface finish matters

---

## 8. Open Questions for Reviewer

1. **Dash angle:** Is 12° reasonable for a Prado 150 center stack? No published reference exists. Should we design the flange with a small chamfer to accommodate ±3° error?

2. **Cavity vs Eclipse dimensions:** The Eclipse face is 205.5 × 104mm but the client measured 20cm × 11cm for the opening. Should the outer dimensions match the Eclipse spec or the client's measurement? (Current design uses Eclipse.)

3. **Clip root reinforcement:** The code has a comment saying "DON'T hollow where clips attach — reinforce those areas" but the hollowing cut does NOT spare the clip zones. The clips attach to standard 2.5mm walls. Should we add local 4mm thickening around clip roots? This is a **code-comment discrepancy** that needs resolution.

4. **Clip hook geometry:** The angled entry face is generated with `hull()`. Is this sufficient draft for smooth insertion? Would an explicit 30° chamfer be more reliable/predictable?

5. **Single-piece vs split:** At 205 × 104mm the part fits most 220mm+ beds. Should we offer a two-piece option for smaller printers (top/bottom halves joined by snap pins)?

6. **Backup screw retention:** v1 had M3 screw posts aligned with bracket holes. v4 relies entirely on clips + friction. Should we add countersunk screw hole provisions in the flange corners (hidden under screen overhang) as a fallback?

7. **Thermal cycling fatigue:** PETG cantilever clips undergo daily temperature swings (20-70°C). Expected lifecycle? Should we recommend a spring steel clip insert instead of printed clips for longevity?

8. **Flange-to-fascia interface:** Should we add a 1mm foam gasket channel on the flange back face? This would compensate for minor angle mismatch and prevent rattle against the gloss surface.

9. **Wiring clearance:** The body is 25mm deep and the cavity is 38mm. The 13mm gap behind holds RCA cables and a wiring harness. Is there risk of the body pressing against wiring during insertion? Should we add a chamfer on the rear inside edges?

---

## Appendix A: Parameter Quick Reference

```openscad
// All dimensions in mm
outer_w = 205;        // Cavity width (Eclipse face - 0.5mm)
outer_h = 104;        // Cavity height (Eclipse face)
din_w = 179;          // DIN cutout width (Sony 178 + 1mm)
din_h = 51;           // DIN cutout height (Sony 50 + 1mm)
outer_r = 8;          // Fascia corner radius (photo estimate)
din_r = 2;            // DIN cutout corner radius
din_x = 13;           // DIN horizontal offset (centered)
din_y = 15;           // DIN vertical offset from bottom
depth = 25;           // Body depth into cavity
flange_overhang = 4;  // Flange beyond cavity edge
flange_t = 2.5;       // Flange thickness
dash_angle = 12;      // Dash tilt from vertical (degrees)
wall = 2.5;           // Wall thickness
tol = 0.4;            // Clearance tolerance per side

// Clip parameters
clip_w = 10;          // Clip tab width
clip_t = 1.5;         // Clip arm thickness (flex beam)
clip_depth = 18;      // Clip arm length (cantilever)
clip_hook = 2;        // Hook catch overhang
clip_hook_h = 3;      // Hook barb height
clip_gap = 0.8;       // Flex clearance between arm and wall

// Friction rib parameters
rib_h = 0.6;          // Rib protrusion
rib_w = 3;            // Rib width
rib_depth = 15;       // Rib length
rib_count = 3;        // Ribs per surface (top and bottom)
```

## Appendix B: File Manifest

| File | Description | Status |
|------|-------------|--------|
| `files/radio-trim-v4.scad` | Current OpenSCAD parametric source | Active |
| `files/radio-trim-v4.stl` | Exported mesh for printing (273KB) | Generated |
| `files/radio-trim-v4.png` | Isometric render | Generated |
| `files/radio-trim-v4-front.png` | Front view render | Generated |
| `files/radio-trim-v4-side.png` | Side view render | Generated |
| `files/radio-trim-v3.scad` | Previous version (no clips) | Superseded |
| `files/radio-trim-v2.scad` | Simplified frame (no angle) | Superseded |
| `files/radio-trim-v1.scad` | First attempt (clips + screws) | Superseded |
| `files/dimension-research.md` | Full dimension research & sources | Reference |
| `profile.md` | Client profile & measurements | Reference |
| `notes.md` | Project communication log | Reference |

## Appendix C: Design Evolution

```
v1 ──→ v2 ──→ v3 ──→ v4
│       │       │       │
│       │       │       └─ + snap clips + friction ribs
│       │       └───────── + 8mm corner radius, 12° dash angle, hollow body
│       └───────────────── Simplified to pure frame (dimensions-first approach)
└───────────────────────── Initial attempt with clips + screw posts (geometry issues)
```
