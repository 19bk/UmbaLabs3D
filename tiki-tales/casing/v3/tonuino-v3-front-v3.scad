// ============================================================
// Tonuino v3 — Front Panel (original Part 2 + modifications)
// ============================================================
// Base: ORIGINAL Part 2 STL unchanged (keeps all screw holes, dims, shape)
// Mods:
//   1. Fill 3 tactile button holes with solid slab
//   2. Add brick grille disc into speaker opening
//   3. Add LED hole in the filled area
// ============================================================

$fn = 40;

part2 = "tonuino-original/Tonuino V2 - Part 2 (1).stl";

// Part 2 orientation: thin in Y (Y=-1 to Y=2.6, thickness ~3.6mm)
// Speaker opening center: approximately X=-7, Z=0
// 3 button holes: right side, X~30-40, Z~-18, 0, +18
// Power button: X~38, Z~28

panel_y_min = -1;
panel_y_max = 2.6;
panel_thick = panel_y_max - panel_y_min;

// Speaker grille params (brick pattern like original Part 4)
spk_cx = -7;       // speaker opening center X
spk_cz = 0;        // speaker opening center Z
spk_d  = 66;       // grille diameter — oversized to fully merge with panel walls
slot_w = 6;
slot_h = 2.2;
slot_r = 1.0;
slot_gap_x = 1.8;
slot_gap_z = 1.5;
slot_pitch_x = slot_w + slot_gap_x;
slot_pitch_z = slot_h + slot_gap_z;

// LED hole
led_d = 5.5;
led_x = 35;
led_z = 10;        // mid-right area, clear of everything

// ============================================================
// BRICK GRILLE DISC (fills the speaker opening)
// ============================================================
module brick_grille() {
    // Solid disc positioned at the speaker opening
    translate([spk_cx, (panel_y_min + panel_y_max)/2, spk_cz])
        rotate([90, 0, 0])
            difference() {
                cylinder(d=spk_d, h=panel_thick, center=true);

                // Brick slot pattern
                rows = floor(spk_d / slot_pitch_z);
                cols = floor(spk_d / slot_pitch_x);
                for (row = [-rows/2 : rows/2]) {
                    off = (abs(row) % 2 == 1) ? slot_pitch_x/2 : 0;
                    for (col = [-cols/2 : cols/2]) {
                        x = col * slot_pitch_x + off;
                        z = row * slot_pitch_z;
                        if (sqrt(x*x + z*z) < spk_d/2 - slot_w/2 - 1)
                            translate([x, z, 0])
                                hull() {
                                    for (dx = [-(slot_w/2-slot_r), slot_w/2-slot_r])
                                        translate([dx, 0, 0])
                                            cylinder(r=slot_r, h=panel_thick+1, center=true);
                                }
                    }
                }
            }
}

// ============================================================
// FINAL PANEL
// ============================================================
difference() {
    union() {
        // ORIGINAL Part 2 — untouched geometry, all screw holes in place
        import(part2, convexity=10);

        // Fill right side (covers 3 button holes + small screw holes near buttons)
        // Slab from X=25 to X=46, full Z height, matching panel Y thickness
        translate([25, panel_y_min, -36])
            cube([21, panel_thick, 72]);

        // Brick grille disc fills the speaker opening
        brick_grille();
    }

    // Trim the fill slab to panel outline (cut corners to match rounded rect)
    // The original panel has rounded corners at ~5mm radius
    // Cut the excess that sticks beyond the panel edges
    translate([40, panel_y_min - 0.1, 30])
        difference() {
            cube([10, panel_thick + 0.2, 10]);
            translate([0, -0.1, 0])
                rotate([-90, 0, 0])
                    cylinder(r=5, h=panel_thick + 0.4);
        }
    translate([40, panel_y_min - 0.1, -40])
        difference() {
            cube([10, panel_thick + 0.2, 10]);
            translate([0, -0.1, 10])
                rotate([-90, 0, 0])
                    cylinder(r=5, h=panel_thick + 0.4);
        }

    // Power button hole REMOVED — filled solid (no weird circle)

    // Re-open the 2 original corner screw holes that the slab covered
    translate([40, 0, 28])
        rotate([90, 0, 0])
            cylinder(d=3.4, h=10, center=true);
    translate([40, 0, -28])
        rotate([90, 0, 0])
            cylinder(d=3.4, h=10, center=true);

    // LED hole
    translate([led_x, 0, led_z])
        rotate([90, 0, 0])
            cylinder(d=led_d, h=10, center=true);
}
