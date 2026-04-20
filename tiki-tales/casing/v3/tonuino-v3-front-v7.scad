// ============================================================
// Tonuino v3 — Front Panel v7
// ============================================================
// Original Part 2 preserved exactly. Fills match inner panel
// thickness (2.8mm, Y=-0.2 to 2.6), not rim thickness (3.6mm).
// Rounded corners and raised rim untouched.
// ============================================================

$fn = 40;

part2 = "tonuino-original/Tonuino V2 - Part 2 (1).stl";

// Panel profile (from mesh analysis):
//   Rim:   Y=-1.0 to 2.6 (3.6mm) — around edges
//   Inner: Y=-0.2 to 2.6 (2.8mm) — recessed center area
inner_y_min = -0.2;
inner_y_max = 2.6;
inner_t = inner_y_max - inner_y_min;  // 2.8mm
py = (inner_y_min + inner_y_max) / 2; // 1.2

// Speaker center
spk_cx = -7;
spk_cz = 0;

// Ridge ring
ridge_od = 50;
ridge_id = 45;
ridge_h = 3;

// Grille
grille_d = 45;
slot_w = 6;
slot_h = 2.2;
slot_r = 1.0;
slot_pitch_x = slot_w + 1.8;
slot_pitch_z = slot_h + 1.5;

// LED
led_d = 5.5;
led_x = 35;
led_z = 10;

// ============================================================
// Rotate flat for printing — smooth front face on bed, ridge UP
translate([45.8, 35.3, 0])
rotate([-90, 0, 0])
difference() {
    union() {
        // Original Part 2 — untouched
        import(part2, convexity=10);

        // Fill speaker opening — oversized disc, full thickness
        translate([spk_cx, 0.8, spk_cz])
            rotate([90, 0, 0])
                cylinder(d=80, h=4, center=true);

        // Fill 3 button holes — match surrounding panel thickness
        // Stays inside the rim boundary, does not extend to corners
        translate([22, -1, -30])
            cube([20, 3.6, 60]);

        // Ridge ring on inside
        translate([spk_cx, inner_y_max, spk_cz])
            rotate([-90, 0, 0])
                difference() {
                    cylinder(d=ridge_od, h=ridge_h);
                    translate([0, 0, -0.1])
                        cylinder(d=ridge_id, h=ridge_h + 0.2);
                }
    }

    // Brick grille — clipped to 45mm
    rows = floor(grille_d / slot_pitch_z);
    cols = floor(grille_d / slot_pitch_x);
    intersection() {
        translate([spk_cx, py, spk_cz])
            rotate([90, 0, 0])
                cylinder(d=grille_d, h=inner_t + 4, center=true);
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
                                            cylinder(r=slot_r, h=inner_t+2, center=true);
                                }
                }
            }
        }
    }

    // LED hole
    translate([led_x, py, led_z])
        rotate([90, 0, 0])
            cylinder(d=led_d, h=inner_t + 4, center=true);
}
