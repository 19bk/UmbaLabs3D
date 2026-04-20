$fn = 40;

part1 = "tonuino-original/Tonuino V2 - Part 1 (2).stl";

switch_w = 20;
switch_h = 13.5;
switch_d = 9;
switch_cy = 32;
switch_cz = -1.3;

// Sample the intact left wall just outside the old switch opening, then
// extrude that exact wall section inward only in the local switch area.
fill_slice_x = -48.2;
fill_depth = 4.8;

module side_wall_slice_2d(x0) {
    projection(cut=true)
        translate([-x0, 0, 0])
            rotate([0, 90, 0])
                import(part1, convexity=10);
}

module switch_wall_patch() {
    intersection() {
        translate([fill_slice_x, 0, 0])
            rotate([0, 90, 0])
                linear_extrude(height=fill_depth)
                    side_wall_slice_2d(fill_slice_x);

        translate([-49.2, switch_cy - 10, switch_cz - 10])
            cube([7, 20, 20]);
    }
}

// Original body with the legacy switch opening locally re-skinned from the
// real side-wall profile, then cut back to the rectangular KCD1 opening.
difference() {
    union() {
        import(part1, convexity=10);
        switch_wall_patch();
    }

    translate([-55, switch_cy - switch_h/2, switch_cz - switch_d/2])
        cube([20, switch_h, switch_d]);
}
