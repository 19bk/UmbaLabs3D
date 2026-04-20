// ============================================================
// Tonuino v3 — Front Panel v5
// ============================================================
// Original Part 2 with:
//   1. Speaker opening filled, re-cut to 45mm (v2 diameter)
//   2. Ridge ring on inside (48mm OD / 43mm ID)
//   3. Brick grille inside the 43mm ridge
//   4. 3 button holes filled solid
//   5. 4 corner screws kept as-is
//   6. LED hole added
// ============================================================

$fn = 40;

part2 = "tonuino-original/Tonuino V2 - Part 2 (1).stl";

// Panel dimensions
panel_y_min = -1;
panel_y_max = 2.6;
py = 0.8;
pt = 3.6;

// Speaker — centered on original opening
spk_cx = -7;
spk_cz = 0;
spk_opening = 45;       // v2 diameter
spk_fill_d = 70;        // oversized to fill original ~60mm opening

// Ridge ring (inside) — sits around the speaker opening
ridge_od = 50;           // outside the 45mm opening
ridge_id = 45;           // matches speaker opening
ridge_h = 3;

// Grille — fills the 45mm opening
grille_d = 45;           // matches speaker opening
slot_w = 6;
slot_h = 2.2;
slot_r = 1.0;
slot_pitch_x = slot_w + 1.8;
slot_pitch_z = slot_h + 1.5;

// LED hole
led_d = 5.5;
led_x = 35;
led_z = 10;

// ============================================================
// Rotate flat for printing — smooth front face on bed, ridge points UP
translate([45.8, 35.3, 0])
rotate([-90, 0, 0])
difference() {
    union() {
        // Original Part 2
        import(part2, convexity=10);

        // Fill original speaker opening completely
        translate([spk_cx, py, spk_cz])
            rotate([90, 0, 0])
                cylinder(d=spk_fill_d, h=pt, center=true);

        // Fill 3 button holes — exact panel thickness
        translate([22, panel_y_min, -36])
            cube([24, pt, 72]);

        // Ridge ring on inside — protrudes INTO the box (+Y direction)
        translate([spk_cx, panel_y_max, spk_cz])
            rotate([-90, 0, 0])
                difference() {
                    cylinder(d=ridge_od, h=ridge_h);
                    translate([0, 0, -0.1])
                        cylinder(d=ridge_id, h=ridge_h + 0.2);
                }
    }

    // Brick grille fills the 45mm opening (no separate opening cut needed) — clipped to 43mm ridge circle
    rows = floor(grille_d / slot_pitch_z);
    cols = floor(grille_d / slot_pitch_x);
    intersection() {
        translate([spk_cx, py, spk_cz])
            rotate([90, 0, 0])
                cylinder(d=grille_d, h=pt + 4, center=true);
        union() {
            for (row = [-rows/2 : rows/2]) {
                off = (abs(row) % 2 == 1) ? slot_pitch_x/2 : 0;
                for (col = [-cols/2 : cols/2]) {
                    sx = col * slot_pitch_x + off;
                    sz = row * slot_pitch_z;
                    if (sqrt(sx*sx + sz*sz) < grille_d/2 + slot_w)
                        translate([spk_cx + sx, py, spk_cz + sz])
                            rotate([90, 0, 0])
                                hull() {
                                    for (dx = [-(slot_w/2-slot_r), slot_w/2-slot_r])
                                        translate([dx, 0, 0])
                                            cylinder(r=slot_r, h=pt+2, center=true);
                                }
                }
            }
        }
    }

    // LED hole
    translate([led_x, py, led_z])
        rotate([90, 0, 0])
            cylinder(d=led_d, h=pt + 2, center=true);

    // Trim fill to panel outline
    translate([46, -2, -40]) cube([20, 6, 80]);
    translate([-66, -2, -40]) cube([20, 6, 80]);
    translate([-50, -2, 35.5]) cube([100, 6, 20]);
    translate([-50, -2, -55]) cube([100, 6, 20]);
}
