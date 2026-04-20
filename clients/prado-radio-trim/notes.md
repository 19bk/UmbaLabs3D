# Notes — Prado Radio Trim

## 2026-02-21
- Project initiated
- Client wants custom trim/bezel for Sony XAV-AX8500 in 2018 Prado
- Radio specs confirmed: 269×167mm face, 178×50×158mm chassis
- **Next step:** Client to provide dashboard opening measurements and reference photos

## 2026-02-22
- Correction from client: old/current radio is Eclipse Future Link AVN-R8W (not Sony XAV-AX8500)
- Action: updated `profile.md` radio section and reset radio dimensions to pending confirmation
- Scope clarification: Eclipse AVN-R8W is OEM radio to remove; Sony XAV-AX8500 is installed unit
- Design intent: create 3D printed clip-in trim to fill the dash gap left after OEM removal and Sony installation

## 2026-03-09
- Client provided photos (5 images) and measurements of dash opening
- Eclipse radio removed, Sony XAV-AX8500 installed, metal DIN cage still in place
- Key gaps: top 5cm, bottom 1.5cm, sides 3cm each, total opening 21×11cm
- Dash face is angled/slanting — need exact angle for trim design
- Yellow snap clips visible on side mounting — trim should use same clip points
- Screw holes available on metal bracket for additional securing
- **Status moved to In Progress** — ready to start 3D design
- **Still needed:** exact dash slant angle (use phone inclinometer app or angle finder)
- Additional clear front-on photo received — confirms:
  - Single DIN cage mounted high in the Toyota 200mm wide opening
  - Large gap below cage, smaller gaps on sides
  - Sony floating screen will sit in front of trim piece
  - RCA cables and wiring harness visible behind
- **Radio dimensions confirmed via research:**
  - OEM Eclipse AVN-R8W: 205.5 × 104 × 165mm (Toyota 200mm wide format)
  - Sony XAV-AX8500: 178 × 50 × 158mm chassis (single DIN), 269 × 167mm floating screen
  - Toyota Prado 150 dash opening: ~200 × 100mm
- **Trim design approach:** Adapter frame — 200×100mm outer, 178×50mm DIN cutout, positioned to match cage location (biased toward top of opening)

## 2026-03-11
- **Test fit v1 taken to car** — results:
  - Width: 204.2mm body too wide (opening is ~200mm)
  - Height: 7mm off at top (trim too tall)
  - din_y=15mm confirmed perfect — bottom flush with Sony cage
  - Sides need to hug Sony cage and fill L-shaped gap
  - Dash angle measured at 24.2° (bubble level app) — was estimated at 12°
  - Max body depth ~15mm before cavity widens into metallic chassis
- **Test fit v3 created** (`radio-trim-testfit.scad`):
  - Corrected outer dims: 199×97mm body, 15mm depth, 0.3mm tol
  - Added L-bracket relief cuts: 38mm vert × 30mm horiz on both sides
  - Body has corner cutouts so it clears Sony cage L-bracket protrusions
  - Flange (face plate) remains full rectangle — sits on dash face
  - Top and bottom body sections connected through flange
  - STL exported for printing
- **Next after v3 fits**: add 24.2° dash angle, snap clips, final wall thickness

## 2026-03-10
- **Dimension research completed** — see `files/dimension-research.md` for full report
- Eclipse AVN-R8W specs confirmed from operation manual p.203-204: 205.5×104×165mm, 2.5kg
- Sony XAV-AX8500 specs confirmed from Help Guide: 269×167×263mm overall, 178×50×158mm chassis, 2.6kg
- Sony connector bracket adjustable: width 25mm (5 steps, 12.5mm pitch), depth 20mm (3 steps, 10mm pitch)
- Eclipse installation manual (取付説明書) downloaded from DENSO TEN — shows bracket mounting but no dimensioned chassis drawing
- Sony Operating Instructions (doc 5-050-132) has dimension diagram on p.79 at ManualsLib but rendered as image, not extractable
- Two local Sony "operating" PDFs are corrupted and unusable
- **Key gap:** Neither radio has a fully dimensioned chassis outline drawing available digitally — may need to measure physical units or trace from printed manuals
