// Prado 2018 Radio Trim — Sony XAV-AX8500 in Toyota 200mm Opening
// v1.0 — 2026-03-09
//
// OEM: Eclipse AVN-R8W (205.5 × 104 × 165mm, Toyota 200mm wide format)
// New: Sony XAV-AX8500 (178 × 50mm DIN chassis, 269 × 167mm floating screen)
// Dash opening: ~200 × 100mm (Toyota 200mm wide standard)

// ── Parameters (all in mm) ────────────────────────────────────

// Dash opening (outer dimensions of trim)
dash_w = 200;       // Toyota 200mm wide opening
dash_h = 100;       // Double DIN height
corner_r = 3;       // Corner radius of dash opening

// Sony DIN chassis cutout
din_w = 178;         // Sony chassis width
din_h = 50;          // Sony chassis height (single DIN)
din_corner_r = 2;    // DIN cutout corner radius

// DIN position within the opening
// From photos: cage is mounted toward the top of the opening
// 15mm from top edge, leaving ~35mm gap below
din_offset_top = 15;     // gap from top of trim to top of DIN cutout
din_offset_left = (dash_w - din_w) / 2;  // centered horizontally = 11mm

// Depth
trim_depth = 38;     // 3.8cm from dash face to DIN cage (from measurement)
flange_depth = 3;    // front lip that sits against dash face

// Front flange (lip that overlaps the dash opening edge)
flange_overhang = 5; // how far the lip extends beyond the opening on each side
flange_w = dash_w + flange_overhang * 2;
flange_h = dash_h + flange_overhang * 2;
flange_thickness = 2.5; // thickness of the front lip

// Wall thickness
wall = 2.5;

// Tolerances
tol = 0.5;           // gap for press fit into dash opening

// ── Modules ───────────────────────────────────────────────────

module rounded_rect(w, h, r) {
    offset(r) square([w - 2*r, h - 2*r], center=false);
}

module trim_body() {
    // Main body — outer shell that fits into the dash opening
    difference() {
        // Outer block (dash opening size - tolerance)
        translate([tol, tol, 0])
        linear_extrude(trim_depth)
            rounded_rect(dash_w - tol*2, dash_h - tol*2, corner_r);

        // Hollow out the inside (leave walls)
        translate([wall, wall, -1])
        linear_extrude(trim_depth + 2)
            rounded_rect(dash_w - wall*2, dash_h - wall*2, corner_r - 1);
    }
}

module din_cutout() {
    // Cut the DIN slot through the back wall
    translate([din_offset_left, dash_h - din_offset_top - din_h, -1])
    linear_extrude(trim_depth + 2)
        rounded_rect(din_w, din_h, din_corner_r);
}

module front_flange() {
    // Front lip/flange that sits flush against dash face and prevents trim from falling in
    translate([-(flange_overhang - tol), -(flange_overhang - tol), trim_depth - flange_thickness])
    linear_extrude(flange_thickness)
        rounded_rect(flange_w, flange_h, corner_r + flange_overhang);
}

module flange_cutout() {
    // Cut opening in flange matching the outer wall opening
    // (so it's a frame, not a solid plate)
    translate([wall, wall, trim_depth - flange_thickness - 1])
    linear_extrude(flange_thickness + 2)
        rounded_rect(dash_w - wall*2, dash_h - wall*2, corner_r - 1);
}

module screw_posts() {
    // Screw mounting posts — align with DIN cage screw holes
    // Two posts on each side of the DIN cutout
    post_r = 4;
    hole_r = 1.5;  // M3 screw

    positions = [
        // Left side posts
        [din_offset_left - post_r - 2, dash_h - din_offset_top - 5],
        [din_offset_left - post_r - 2, dash_h - din_offset_top - din_h + 5],
        // Right side posts
        [din_offset_left + din_w + post_r + 2, dash_h - din_offset_top - 5],
        [din_offset_left + din_w + post_r + 2, dash_h - din_offset_top - din_h + 5],
    ];

    for (pos = positions) {
        difference() {
            translate([pos[0], pos[1], 0])
            linear_extrude(trim_depth - flange_thickness)
                circle(post_r, $fn=20);

            translate([pos[0], pos[1], -1])
            linear_extrude(trim_depth + 2)
                circle(hole_r, $fn=16);
        }
    }
}

module clip_tabs() {
    // Snap-fit clip tabs on sides to engage with Toyota dash clips
    clip_w = 8;
    clip_h = 3;
    clip_depth = 15;
    clip_hook = 1.5;

    // Left side clips (2)
    for (y_pos = [25, 70]) {
        // Clip arm
        translate([-clip_h + tol, y_pos - clip_w/2, trim_depth/2 - clip_depth/2])
        cube([clip_h, clip_w, clip_depth]);

        // Hook at the end
        translate([-clip_h - clip_hook + tol, y_pos - clip_w/2, trim_depth/2 - clip_depth/2])
        cube([clip_hook, clip_w, 3]);
    }

    // Right side clips (2)
    for (y_pos = [25, 70]) {
        translate([dash_w - tol, y_pos - clip_w/2, trim_depth/2 - clip_depth/2])
        cube([clip_h, clip_w, clip_depth]);

        translate([dash_w + clip_h - tol, y_pos - clip_w/2, trim_depth/2 - clip_depth/2])
        cube([clip_hook, clip_w, 3]);
    }
}

// ── Assembly ──────────────────────────────────────────────────

$fn = 40;

difference() {
    union() {
        trim_body();
        front_flange();
        screw_posts();
        clip_tabs();
    }

    // Cut the DIN opening through everything
    din_cutout();

    // Cut the flange center out (make it a frame)
    flange_cutout();
}
