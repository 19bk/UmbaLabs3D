// ============================================================
// Tiki Tales — Figurine Maker
// ============================================================
// Takes any cute animal STL → adds NFC base with:
//   - NFC sticker pocket (NTAG213, 25mm)
//   - Neodymium magnet hole (10x3mm)
//   - Weight pocket (M8 washer / coin)
//   - Felt pad recess
//   - Flat 40mm base for stability
//   - Safety: all sealed, no small parts
//
// USAGE:
//   1. Download figurine STL → put in raw/ folder
//   2. Set raw_file below (or pass via -D on command line)
//   3. Render → Export as STL to ready/ folder
//
// PRINT INSTRUCTIONS:
//   - PLA, 0.2mm layers, 80-100% infill
//   - Pause at z = 1.5mm
//   - Insert: NFC sticker (face down), magnet, washer
//   - Resume print — top layers seal everything
//   - Apply 38mm felt pad on bottom after print
// ============================================================

$fn = 60;

// ---- INPUT FILE ----
// Change this to your downloaded figurine STL path
raw_file = "raw/PUT_YOUR_FILE_HERE.stl";

// ---- FIGURINE PARAMETERS ----
target_height  = 70;    // desired total height (mm) including base
base_dia       = 46;    // base diameter (wider for ~30mm NFC keychain disc)
base_h         = 5;     // base thickness (mm)
body_min_thick = 10;    // minimum feature thickness for safety (mm)

// ---- NFC POCKET (bottom of base, for NFC keychain disc) ----
nfc_dia   = 32;    // pocket diameter (keychain disc ~30mm + clearance)
nfc_depth = 0.3;   // shallow centering recess (tag sits in cavity)

// ---- MAGNET HOLE (10x3mm neodymium disc) ----
mag_dia   = 10.3;  // hole diameter (press fit with 0.3mm clearance)
mag_depth = 3.2;   // hole depth (magnet is 3mm + 0.2mm clearance)
mag_offset_x = 0;  // centered
mag_offset_y = 8;  // offset from center (away from NFC)

// ---- WEIGHT POCKET (M8 washer, coin, or steel balls) ----
wt_dia    = 16;    // pocket diameter
wt_depth  = 2.2;   // pocket depth (M8 washer is ~1.6mm)
wt_offset_x = 0;
wt_offset_y = -8;  // opposite side from magnet

// ---- FELT PAD RECESS (covers bottom) ----
felt_dia   = 44;   // slightly smaller than base (base_dia - 2)
felt_depth = 0.6;  // recess depth

// ---- PAUSE HEIGHT (for print-pause-insert method) ----
pause_z = 1.5;     // pause print at this Z height to insert components
                    // Below this: felt recess + bottom skin
                    // Above this: cavities get sealed by continued printing

// ---- SAFETY ROUNDING ----
base_edge_r = 2;   // fillet radius on base edges (no sharp corners)

// ============================================================
// MODULES
// ============================================================

// The universal NFC base — attach to any figurine
module nfc_base() {
    difference() {
        // Solid base disc with rounded edges
        hull() {
            // Bottom edge (rounded)
            translate([0, 0, base_edge_r])
                cylinder(d=base_dia - base_edge_r*2, h=0.01);
            translate([0, 0, base_edge_r])
                rotate_extrude()
                    translate([base_dia/2 - base_edge_r, 0, 0])
                        circle(r=base_edge_r);
            // Top edge (flat — figurine body sits here)
            cylinder(d=base_dia, h=base_h);
        }

        // ---- Felt pad recess (very bottom) ----
        translate([0, 0, -0.01])
            cylinder(d=felt_dia, h=felt_depth + 0.01);

        // ---- NFC sticker pocket (centered, just above felt) ----
        translate([0, 0, felt_depth])
            cylinder(d=nfc_dia, h=nfc_depth);

        // ---- Magnet hole (offset, deeper) ----
        translate([mag_offset_x, mag_offset_y, felt_depth])
            cylinder(d=mag_dia, h=mag_depth);

        // ---- Weight pocket (opposite side from magnet) ----
        translate([wt_offset_x, wt_offset_y, felt_depth])
            cylinder(d=wt_dia, h=wt_depth);
    }
}

// Scale a figurine to target height, measure from bounding box
// Note: OpenSCAD import() doesn't expose bounding box,
// so you measure in your slicer and set scale_factor manually
module scaled_figurine(file, s=1.0) {
    scale([s, s, s])
        import(file, convexity=10);
}

// ============================================================
// PREVIEW: Base only (for checking cavities)
// ============================================================
module preview_base() {
    difference() {
        nfc_base();
        // Cut in half to see cavities
        translate([0, -50, -1])
            cube([50, 100, 50]);
    }
}

// ============================================================
// ASSEMBLY: Figurine + NFC Base
// ============================================================

// The figurine scale factor — measure your raw STL height in slicer,
// then set this so final height = target_height
// Example: if raw STL is 35mm tall, scale = 70/35 = 2.0
figurine_scale = 1.0;  // ← ADJUST THIS after measuring raw STL

// Z offset: how far up to shift the figurine so it sits on the base
// If the raw figurine has its own base at z=0, set this to base_h
// If it floats, you may need to adjust
figurine_z_offset = base_h;

// ---- RENDER MODE ----
mode = "base_only";  // "base_only", "base_cross_section", "full", "figurine_only"

if (mode == "base_only") {
    // Just the universal NFC base (for testing/verifying cavities)
    nfc_base();
}
else if (mode == "base_cross_section") {
    // Cross-section view to verify cavity depths
    preview_base();
}
else if (mode == "figurine_only") {
    // Just the imported figurine (for measuring)
    scaled_figurine(raw_file, figurine_scale);
}
else if (mode == "full") {
    // Complete figurine with NFC base
    union() {
        nfc_base();
        translate([0, 0, figurine_z_offset])
            scaled_figurine(raw_file, figurine_scale);
    }
}

// ============================================================
echo("=== Tiki Tales Figurine Maker ===");
echo(str("Base: ", base_dia, "mm dia x ", base_h, "mm tall"));
echo(str("NFC pocket: ", nfc_dia, "mm x ", nfc_depth, "mm deep"));
echo(str("Magnet hole: ", mag_dia, "mm x ", mag_depth, "mm deep"));
echo(str("Weight pocket: ", wt_dia, "mm x ", wt_depth, "mm deep"));
echo(str("Felt recess: ", felt_dia, "mm x ", felt_depth, "mm deep"));
echo(str("Pause print at z = ", pause_z, "mm to insert components"));
echo(str("Target total height: ", target_height, "mm"));
