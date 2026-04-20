// ============================================================
// Tiki Tales — Elephant Figurine with Openable NFC Base
// ============================================================
// Source: "Cute little elephant" by Kacper1263 (MakerWorld)
// Raw size: 11.0 x 11.8 x 11.1mm (needs scaling)
// Target: ~62mm tall body + 10mm base cup = 72mm total
//
// CONCEPT: Two separate pieces
//   1. Elephant body — printed hollow (15% infill, 2mm walls)
//   2. Base cup — open tray with NFC pocket + ball bearing space
//   Elephant press-fits onto base cup via friction rim
//
// PRINT:
//   - Elephant: PLA, 0.2mm, 15% infill, 2mm walls, supports
//   - Base cup: PLA, 0.2mm, 100% infill (it's small + structural)
//
// ASSEMBLY:
//   1. Place NFC sticker (face up) in bottom pocket
//   2. Drop ball bearings into cup cavity
//   3. Press elephant onto base — rim holds it
//   4. Apply felt pad on bottom
// ============================================================

$fn = 80;

// ---- RAW MESH INFO ----
raw_file   = "raw/elephant.stl";
raw_height = 11.1;    // Z dimension of raw mesh
raw_min_z  = -5.6;    // lowest Z in raw mesh

// Bottom center offset (elephant sits asymmetrically)
raw_bottom_cx = 0.083;
raw_bottom_cy = 1.857;

// ---- TARGET DIMENSIONS ----
body_height = 62;     // elephant body height

// ---- SCALE ----
scale_f = body_height / raw_height;  // ~5.6x

// ---- BASE CUP PARAMETERS ----
base_dia    = 46;     // outer diameter (wider for ~30mm NFC keychain disc)
base_h      = 10;     // taller cup for ball bearings
wall        = 2;      // cup wall thickness
floor_h     = 2;      // cup floor thickness
base_edge_r = 1.5;    // bottom edge fillet

// Friction-fit rim (elephant presses onto this)
rim_h       = 3;      // rim height above cup lip
rim_t       = 1.2;    // rim wall thickness
rim_gap     = 0.3;    // clearance for press fit

// ---- NFC POCKET (inside cup floor) ----
nfc_dia   = 32;       // keychain disc body ~30mm + clearance
nfc_depth = 0.3;      // shallow centering recess (tag sits in open cavity)

// ---- BALL BEARING SPACE ----
// Interior cavity: ~36mm dia x ~7.4mm deep
// Fits plenty of 6mm steel ball bearings for weight

// ---- FELT PAD RECESS (bottom exterior) ----
felt_dia   = 44;      // proportional (base_dia - 2)
felt_depth = 0.6;

// ============================================================
// BASE CUP MODULE — open tray with NFC pocket
// ============================================================
module base_cup() {
    difference() {
        union() {
            // Outer cup body with rounded bottom edge
            hull() {
                // Bottom rounded edge
                translate([0, 0, base_edge_r])
                    rotate_extrude()
                        translate([base_dia/2 - base_edge_r, 0, 0])
                            circle(r=base_edge_r);
                // Top edge (flat)
                cylinder(d=base_dia, h=base_h);
            }

            // Friction-fit rim (protrudes above cup)
            translate([0, 0, base_h])
                difference() {
                    cylinder(d=base_dia - wall*2 + rim_t*2, h=rim_h);
                    translate([0, 0, -0.01])
                        cylinder(d=base_dia - wall*2, h=rim_h + 0.02);
                }
        }

        // ---- Interior cavity (hollow cup) ----
        translate([0, 0, floor_h])
            cylinder(d=base_dia - wall*2, h=base_h - floor_h + 0.01);

        // ---- NFC sticker pocket (recessed into floor) ----
        translate([0, 0, floor_h - nfc_depth])
            cylinder(d=nfc_dia, h=nfc_depth + 0.01);

        // ---- Felt pad recess (bottom exterior) ----
        translate([0, 0, -0.01])
            cylinder(d=felt_dia, h=felt_depth + 0.01);
    }
}

// ============================================================
// ELEPHANT MODULE (scaled + centered + positioned on base)
// ============================================================
module elephant() {
    // Scale up, center on bottom contact area, sit on base
    translate([0, 0, base_h + rim_h - raw_min_z * scale_f])
        scale([scale_f, scale_f, scale_f])
            translate([-raw_bottom_cx, -raw_bottom_cy, 0])
                import(raw_file, convexity=10);
}

// ============================================================
// RENDER MODES
// ============================================================
mode = "base_cup";
// "base_cup"        — just the base cup (export this as STL)
// "base_cross"      — cross-section of base to verify cavities
// "elephant"        — just the elephant (for reference)
// "assembly"        — both pieces together (preview only)
// "exploded"        — exploded view (preview only)

if (mode == "base_cup") {
    base_cup();
}
else if (mode == "base_cross") {
    difference() {
        base_cup();
        translate([-50, -50, -1])
            cube([50, 100, 50]);
    }
}
else if (mode == "elephant") {
    elephant();
}
else if (mode == "assembly") {
    base_cup();
    elephant();
}
else if (mode == "exploded") {
    base_cup();
    translate([0, 0, 15])  // lift elephant to show gap
        elephant();
}

// ============================================================
echo("=== Tiki Tales — Elephant (Openable Base) ===");
echo(str("Scale factor: ", scale_f, "x"));
echo(str("Body height: ", body_height, "mm"));
echo(str("Base cup: ", base_dia, "mm x ", base_h, "mm"));
echo(str("Interior cavity: ", base_dia - wall*2, "mm x ", base_h - floor_h, "mm"));
echo(str("Rim: ", rim_h, "mm tall, ", rim_t, "mm thick"));
echo(str("NFC pocket: ", nfc_dia, "mm x ", nfc_depth, "mm"));
echo(str("Total height: ~", body_height + base_h + rim_h, "mm"));
