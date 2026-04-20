// ============================================================
// Tonuino v3 — Front Panel (rebuilt from scratch)
// ============================================================
// Clean parametric rebuild — no STL patching, no seams.
// Matches Part 2 outer dimensions exactly.
//
// Changes from original:
//   - 3 button holes REMOVED (solid surface)
//   - Power button hole replaced with LED hole (5.5mm)
//   - Speaker grille is flush dot-pattern (integrated, not floating)
//   - No screw speaker mounts
// ============================================================

$fn = 40;

// ---- Panel outer dimensions (from Part 2 mesh) ----
pw = 91.6;       // width (X)
ph = 70.6;       // height (Z)
pt = 3.6;        // thickness (Y)
pcr = 5;         // corner radius

// ---- Speaker grille ----
spk_d = 60;      // speaker opening diameter
spk_x = -7;      // center X offset (left of center)
spk_z = 0;       // center Z (vertically centered)
dot_d = 2.5;     // grille hole diameter

// ---- Screw holes (4 corners — matched to original Part 2) ----
screw_d = 3.4;
screw_positions = [
    [-40, -28],    // bottom-left
    [-40,  28],    // top-left
    [ 40, -28],    // bottom-right
    [ 40,  28],    // top-right
];

// ---- LED hole (top-right, clear of grille and screw holes) ----
// Grille right edge: spk_x + spk_d/2 = -7 + 30 = 23
// Screw hole at [40, 28] — LED needs 5mm clearance from both
led_d = 5.5;
led_x = 35;       // between grille edge (23) and screw (40)
led_z = 20;        // between center and top screw (28), 8mm from edge

// ============================================================
// SPEAKER GRILLE (brick/honeycomb slot pattern — matches Tonuino original)
// ============================================================
// Horizontal slots arranged in offset rows (brick pattern)
slot_w = 6;        // slot width
slot_h = 2.2;      // slot height
slot_r = 1.0;      // slot corner radius
slot_gap_x = 1.8;  // gap between slots horizontally
slot_gap_z = 1.5;  // gap between rows vertically
slot_pitch_x = slot_w + slot_gap_x;   // 7.8mm
slot_pitch_z = slot_h + slot_gap_z;   // 3.7mm

module brick_pattern(dia) {
    rows = floor(dia / slot_pitch_z);
    cols = floor(dia / slot_pitch_x);
    for (row = [-rows/2 : rows/2]) {
        offset_x = (abs(row) % 2 == 1) ? slot_pitch_x / 2 : 0;
        for (col = [-cols/2 : cols/2]) {
            x = col * slot_pitch_x + offset_x;
            z = row * slot_pitch_z;
            // Only cut if slot center is inside the speaker circle
            if (sqrt(x*x + z*z) < dia/2 - slot_w/2 - 1)
                translate([x, z, 0])
                    hull() {
                        for (dx = [-(slot_w/2 - slot_r), slot_w/2 - slot_r])
                            translate([dx, 0, 0])
                                cylinder(r=slot_r, h=pt + 1, center=true);
                    }
        }
    }
}

// ============================================================
// FRONT PANEL
// ============================================================
module front_panel() {
    difference() {
        // Solid rounded rectangle plate
        translate([0, 0, pt/2])
            hull() {
                for (x = [-pw/2 + pcr, pw/2 - pcr])
                    for (z = [-ph/2 + pcr, ph/2 - pcr])
                        translate([x, z, 0])
                            cylinder(r=pcr, h=pt, center=true);
            }

        // Speaker grille (brick slot pattern — flush, cut through plate)
        translate([spk_x, spk_z, pt/2])
            brick_pattern(spk_d);

        // 4 screw holes
        for (p = screw_positions)
            translate([p[0], p[1], -0.1])
                cylinder(d=screw_d, h=pt + 0.2);

        // LED hole (top-right, replaces power button)
        translate([led_x, led_z, -0.1])
            cylinder(d=led_d, h=pt + 0.2);
    }
}

// Orient to match original Part 2 (thin in Y direction)
rotate([90, 0, 0])
    front_panel();
