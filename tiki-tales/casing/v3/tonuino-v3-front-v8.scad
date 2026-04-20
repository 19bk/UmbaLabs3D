// ============================================================
// Tonuino v3 — Front Panel v8
// ============================================================
// Clean-room rebuild of Tonuino V2 Part 2 using 2D slices from
// the original STL to preserve the fit-critical back profile
// without unioning filler solids into the imported mesh.
// ============================================================

$fn = 48;

part2 = "tonuino-original/Tonuino V2 - Part 2 (1).stl";

// Original Part 2 thickness landmarks from slice inspection.
y_back_outer = -1.0;
y_back_mid = -0.6;
y_front = -0.2;
y_top = 2.6;
slice_h = 0.02;

// Speaker geometry measured from the original opening, then reduced
// to the requested 45 mm perforated grille.
spk_cx = -8.0;
spk_cz = 0.0;
grille_d = 45.0;
grille_hole_d = 2.8;
grille_pitch = 5.2;
grille_margin = 1.6;

// Exact screw-hole centers are taken from the original slice, not
// from the earlier guessed "corner" positions.
screw_d = 4.4;
screw_positions = [
    [-34.0,  26.0],
    [-34.0, -26.0],
    [ 18.0,  26.0],
    [ 18.0, -26.0]
];

// New LED hole added clear of the speaker and button cluster.
led_d = 5.5;
led_x = 35.0;
led_z = 10.0;

// Inner speaker retention ridge.
ridge_od = 50.0;
ridge_id = 45.0;
ridge_id_top = 48.0;
ridge_h = 3.0;
ridge_lug_count = 6;
ridge_lug_width = 10.0;

module original_slice_2d(y0) {
    projection(cut=true)
        translate([0, 0, -y0])
            rotate([90, 0, 0])
                import(part2, convexity=10);
}

module outer_outline_2d() {
    // The panel outline is convex, so hull() strips the internal holes while
    // keeping the original rounded perimeter from the STL slice.
    hull()
        original_slice_2d(y_back_outer);
}

module slice_inner_hole_2d(y0) {
    difference() {
        hull()
            original_slice_2d(y0);
        original_slice_2d(y0);
    }
}

module place_2d_at_y(y0, h=slice_h) {
    translate([0, y0, 0])
        rotate([-90, 0, 0])
            linear_extrude(height=h)
                children();
}

module speaker_grille_holes() {
    for (gx = [-grille_d/2 : grille_pitch : grille_d/2])
        for (gz = [-grille_d/2 : grille_pitch : grille_d/2])
            if (sqrt(gx * gx + gz * gz) <= grille_d/2 - grille_margin)
                translate([spk_cx + gx, 0, spk_cz + gz])
                    rotate([90, 0, 0])
                        cylinder(d=grille_hole_d, h=(y_top - y_back_outer) + ridge_h + 2, center=true);
}

module speaker_support_lugs() {
    for (a = [0 : 360 / ridge_lug_count : 360 - 360 / ridge_lug_count])
        rotate([0, 0, a])
            intersection() {
                difference() {
                    cylinder(d=ridge_od, h=ridge_h + 0.2);
                    translate([0, 0, -0.1])
                        cylinder(d1=ridge_id, d2=ridge_id_top, h=ridge_h + 0.4);
                }

                translate([ridge_od / 4, 0, (ridge_h + 0.2) / 2])
                    cube([ridge_od / 2, ridge_lug_width, ridge_h + 0.6], center=true);
            }
}

module front_panel() {
    difference() {
        union() {
            // Start from a full-thickness slab matching the original outer
            // perimeter, then cut the stepped rear recesses from measured
            // slice profiles. This avoids hidden internal hull volumes.
            place_2d_at_y(y_back_outer, y_top - y_back_outer)
                outer_outline_2d();

            // Speaker support lugs.
            // A segmented support clears the center acoustically and avoids
            // the continuous annular feature Bambu flagged as a cantilever.
            translate([spk_cx, y_top - 0.2, spk_cz])
                rotate([-90, 0, 0])
                    speaker_support_lugs();
        }

        // Keep the speaker area as one connected solid disc with perforations.
        intersection() {
            translate([spk_cx, 0, spk_cz])
                rotate([90, 0, 0])
                    cylinder(d=grille_d, h=(y_top - y_back_outer) + ridge_h + 2, center=true);
            speaker_grille_holes();
        }

        // Recreate the original stepped rear face as clean recess cuts.
        place_2d_at_y(y_back_outer - 0.01, (y_back_mid - y_back_outer) + 0.02)
            slice_inner_hole_2d(y_back_outer);

        place_2d_at_y(y_back_mid - 0.01, (y_front - y_back_mid) + 0.02)
            slice_inner_hole_2d(y_back_mid);

        // Preserve the original mounting holes.
        for (p = screw_positions)
            translate([p[0], 0, p[1]])
                rotate([90, 0, 0])
                    cylinder(d=screw_d, h=(y_top - y_back_outer) + ridge_h + 2, center=true);

        // Add the LED hole.
        translate([led_x, 0, led_z])
            rotate([90, 0, 0])
                cylinder(d=led_d, h=(y_top - y_back_outer) + ridge_h + 2, center=true);
    }
}

// Rotated flat for printing, smooth front face down.
translate([45.8, 35.3, 0])
    rotate([-90, 0, 0])
        front_panel();
