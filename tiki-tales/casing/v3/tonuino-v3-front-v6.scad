// ============================================================
// Tonuino v3 — Front Panel v6
// ============================================================
// Uses hull() of original Part 2 to fill holes while preserving
// the exact rim, rounded corners, and thickness profile.
//
// Flow:
//   1. Hull the original → fills ALL holes (speaker, buttons)
//      while keeping rim, corners, thickness
//   2. Intersect hull with local areas to only fill what we need
//   3. Union with original (keeps screw holes, details)
//   4. Cut grille + LED hole
//   5. Add ridge ring on inside
// ============================================================

$fn = 40;

part2 = "tonuino-original/Tonuino V2 - Part 2 (1).stl";

// Panel dimensions
panel_y_min = -1;
panel_y_max = 2.6;
py = 0.8;
pt = 3.6;

// Speaker center
spk_cx = -7;
spk_cz = 0;

// Ridge ring (inside)
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

// LED hole
led_d = 5.5;
led_x = 35;
led_z = 10;

// ============================================================
// Rotate flat for printing — smooth front face on bed, ridge UP
translate([45.8, 35.3, 0])
rotate([-90, 0, 0])
difference() {
    union() {
        // Original Part 2 — all features preserved
        import(part2, convexity=10);

        // Fill speaker opening — hull preserves rim/edges/thickness
        intersection() {
            hull() import(part2, convexity=10);
            // Only fill the speaker area
            translate([spk_cx - 40, panel_y_min - 1, spk_cz - 40])
                cube([80, pt + 2, 80]);
        }

        // Fill 3 button holes — hull preserves rim/edges/thickness
        intersection() {
            hull() import(part2, convexity=10);
            // Only fill the right side (where buttons are)
            translate([20, panel_y_min - 1, -36])
                cube([30, pt + 2, 72]);
        }

        // Ridge ring on inside
        translate([spk_cx, panel_y_max, spk_cz])
            rotate([-90, 0, 0])
                difference() {
                    cylinder(d=ridge_od, h=ridge_h);
                    translate([0, 0, -0.1])
                        cylinder(d=ridge_id, h=ridge_h + 0.2);
                }
    }

    // Brick grille — clipped to 45mm circle
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
}
