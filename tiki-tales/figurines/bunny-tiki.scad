// ============================================================
// Tiki Tales — Bunny Figurine with Bayonet NFC Base
// ============================================================
// Source: "Népszerű Nyuszi Figura" (Popular Bunny Figure)
// Raw size: 50.0 x 57.5 x 78.6mm (centered at origin)
// Target: ~65mm tall body + base
//
// ASSEMBLY:
//   1. Print bunny body (glue to lid top)
//   2. Print base cup + lid (bayonet lock)
//   3. Drop NFC tag into cup, hot-glue
//   4. Drop magnet on top, hot-glue
//   5. Snap lid closed (bayonet twist)
//   6. Glue bunny to lid
// ============================================================

$fn = 60;

// ---- RAW MESH INFO ----
raw_file    = "raw/bunny.stl";
raw_height  = 78.61;    // Z dimension of raw mesh
raw_min_z   = -39.31;   // lowest Z in raw mesh
raw_width   = 50.01;    // X dimension
raw_depth   = 57.45;    // Y dimension

// ---- TARGET DIMENSIONS ----
body_height = 65;        // bunny body height (mm)

// ---- SCALE ----
scale_f = body_height / raw_height;  // ~0.827x (bunny is already big, scale down)

// ---- BASE PARAMETERS (match figurine-base.scad v4.3) ----
base_dia    = 46;
lid_h       = 3.0;

// ============================================================
// BUNNY MODULE
// ============================================================
module bunny() {
    // Scale, center on origin, sit on base lid
    translate([0, 0, lid_h - raw_min_z * scale_f])
        scale([scale_f, scale_f, scale_f])
            import(raw_file, convexity=10);
}

// ============================================================
// BASE (imported from figurine-base.scad)
// ============================================================
module base_cup() {
    use <figurine-base.scad>
    cup();
}

module base_lid() {
    use <figurine-base.scad>
    lid();
}

// ============================================================
// RENDER MODES
// ============================================================
mode = "assembly";

if (mode == "bunny") {
    bunny();
}
else if (mode == "assembly") {
    // Cup at origin
    translate([0, 0, 0]) {
        color("#FF6B35") cup();
        // Lid seated on cup
        translate([0, 0, 11])  // cup_h
            color("#F7B801") lid();
        // Bunny on lid
        translate([0, 0, 11])
            color("#00D9C0", 0.9) bunny();
    }
}
else if (mode == "bunny_only") {
    // Just the bunny for separate printing
    translate([0, 0, -raw_min_z * scale_f])
        scale([scale_f, scale_f, scale_f])
            import(raw_file, convexity=10);
}
else if (mode == "print_plate") {
    // All 3 pieces on one plate
    translate([-35, 0, 0])
        cup();
    translate([35, 0, lid_h])
        mirror([0, 0, 1])
            lid();
    // Bunny standing upright, offset
    translate([0, 55, 0])
        translate([0, 0, -raw_min_z * scale_f])
            scale([scale_f, scale_f, scale_f])
                import(raw_file, convexity=10);
}

// Include the base modules
use <figurine-base.scad>

// ============================================================
echo("=== Tiki Tales — Bunny Figurine ===");
echo(str("Scale: ", scale_f, "x"));
echo(str("Bunny body: ", body_height, "mm tall"));
echo(str("Bunny footprint: ", raw_width * scale_f, " x ", raw_depth * scale_f, "mm"));
echo(str("Base: ", base_dia, "mm dia"));
echo(str("Total height: ~", body_height + lid_h + 11, "mm"));
