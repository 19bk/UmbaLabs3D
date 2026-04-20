// ============================================================
// Tonuino v3 — Front Panel v4 (simple approach)
// ============================================================
// 1. Import original Part 2
// 2. Fill speaker opening with OVERSIZED solid disc (covers entire hole + edges)
// 3. Fill 3 button holes with oversized cylinders
// 4. Cut brick grille pattern through the filled speaker area
// 5. Cut LED hole
// NO dimension changes. Original screw holes untouched.
// ============================================================

$fn = 40;

part2 = "tonuino-original/Tonuino V2 - Part 2 (1).stl";

// Panel Y range: -1 to 2.6 (3.6mm thick)
py = 0.8;           // panel Y center
pt = 3.6;           // panel thickness

// Speaker opening center
spk_cx = -7;
spk_cz = 0;
spk_fill_d = 70;     // OVERSIZED fill disc — covers opening + merges into walls

// 3 button holes on right side (approximate centers from render)
// These are ~13mm diameter holes
btn_fill_d = 20;     // oversized to fully cover
btn_positions = [
    [35, py, 18],     // top button
    [35, py, 0],      // middle button
    [35, py, -18],    // bottom button
];

// Power button (~14mm, top-right) — also fill it
pwr_pos = [38, py, 28];
pwr_fill_d = 20;

// Brick grille slot pattern
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
led_z = 10;

// ============================================================
// BUILD
// ============================================================
difference() {
    union() {
        // ORIGINAL Part 2 — all geometry preserved
        import(part2, convexity=10);

        // Fill speaker opening — oversized disc merges with panel walls
        translate([spk_cx, py, spk_cz])
            rotate([90, 0, 0])
                cylinder(d=spk_fill_d, h=pt, center=true);

        // Speaker housing ridge on INSIDE of panel (like v2 speaker ledge)
        // Ring that the speaker sits against — holds it centered
        // Protrudes inward (positive Y direction = inside the box)
        spk_ring_od = 48;    // speaker outer diameter + clearance
        spk_ring_id = 43;    // speaker body sits inside this
        spk_ring_h  = 3;     // ridge height (protrudes inward)
        translate([spk_cx, panel_y_max, spk_cz])
            rotate([90, 0, 0])
                difference() {
                    cylinder(d=spk_ring_od, h=spk_ring_h);
                    translate([0, 0, -0.1])
                        cylinder(d=spk_ring_id, h=spk_ring_h + 0.2);
                }

        // Fill entire right side
        translate([22, -1.5, -36])
            cube([24, pt + 1, 72]);
    }

    // Cut brick grille — slots clipped to the 43mm circle
    // Intersection ensures nothing overflows, slots touch the edge
    grille_d = 43;
    rows = floor(grille_d / slot_pitch_z);
    cols = floor(grille_d / slot_pitch_x);
    intersection() {
        // Clip boundary — 43mm circle
        translate([spk_cx, py, spk_cz])
            rotate([90, 0, 0])
                cylinder(d=grille_d, h=pt+4, center=true);
        // All slots (generate more than needed, intersection clips them)
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

    // Cut LED hole
    translate([led_x, py, led_z])
        rotate([90, 0, 0])
            cylinder(d=led_d, h=pt+2, center=true);

    // Re-open the 2 right-side corner screw holes at original positions
    for (pos = [[39, 29], [39, -29]])
        translate([pos[0], py, pos[1]])
            rotate([90, 0, 0])
                cylinder(d=4, h=pt+4, center=true);

    // Trim any fill that extends beyond original panel outline
    // Cut everything outside the panel bounding box
    // Panel X: -45.8 to 45.8, Z: -35.3 to 35.3
    translate([46, -2, -40]) cube([20, 6, 80]);    // right
    translate([-66, -2, -40]) cube([20, 6, 80]);   // left
    translate([-50, -2, 35.5]) cube([100, 6, 20]); // top
    translate([-50, -2, -55]) cube([100, 6, 20]);  // bottom
}
