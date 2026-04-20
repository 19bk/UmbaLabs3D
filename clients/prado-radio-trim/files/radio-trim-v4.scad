// Prado 2018 Radio Trim v4 — With snap-fit retention clips
// OEM: Eclipse AVN-R8W  → 205.5 × 104mm face (Toyota 200mm wide format)
// New: Sony XAV-AX8500  → 178 × 50mm DIN chassis
//
// Key changes from v3:
// - Added snap-fit retention clips on sides (Toyota-style spring clips)
// - Added top/bottom friction ribs for secure hold
// - Reinforced walls around clip areas
// - Print orientation: front face down (flange on build plate)

// ── Dimensions (mm) ──────────────────────────────────────────

// Outer = The cavity opening inside the gloss black fascia
outer_w = 205;       // slightly under Eclipse 205.5mm for clearance
outer_h = 104;       // Eclipse height

// Inner cutout = Sony DIN chassis
din_w = 179;          // Sony 178mm + 1mm clearance
din_h = 51;           // Sony 50mm + 1mm clearance

// Corner radii (from photo analysis — fascia has rounded corners ~8mm)
outer_r = 8;
din_r = 2;

// DIN cutout position (low in the opening — per photos and measurements)
din_x = (outer_w - din_w) / 2;   // ~13mm centered horizontally
din_y = 15;                        // 15mm from bottom edge

// Depth
depth = 25;           // body goes into the cavity

// Front flange (sits against the gloss fascia surface)
flange_overhang = 4;  // overlap beyond the cavity opening edge
flange_t = 2.5;       // thickness of the lip

// Dash angle (tilt backward — top of dash is further from driver than bottom)
dash_angle = 12;      // degrees from vertical (estimated from side photo)

// Wall thickness
wall = 2.5;

// Tolerances
tol = 0.4;            // clearance on outer dimensions

// ── Snap Clip Parameters ────────────────────────────────────

// Toyota-style spring clips that flex inward during insertion,
// then snap outward to grip behind the metal dash frame edge
clip_w = 10;          // width of each clip tab
clip_t = 1.5;         // thickness of the flexible arm
clip_depth = 18;      // how far back the clip arm extends
clip_hook = 2;        // hook overhang (catches behind dash frame)
clip_hook_h = 3;      // height of the hook barb
clip_gap = 0.8;       // gap between clip arm and body wall (flex room)

// Clip positions: 2 per side, at 1/3 and 2/3 height
clip_y_positions = [outer_h * 0.3, outer_h * 0.7];

// ── Friction Rib Parameters ─────────────────────────────────

// Small raised ribs on top and bottom walls to create friction fit
rib_h = 0.6;          // how far the rib protrudes
rib_w = 3;            // width of each rib
rib_depth = 15;       // length along depth axis
rib_count = 3;        // number of ribs on top and bottom

// ── Modules ──────────────────────────────────────────────────

$fn = 60;

module rounded_rect_2d(w, h, r) {
    offset(r) offset(-r)
        square([w, h]);
}

// ── Snap Clip Module ─────────────────────────────────────────

module snap_clip() {
    // A single clip arm with hook
    // Oriented along +Z (depth), hook pointing outward (+X)
    //
    // The arm is a thin cantilever beam that flexes inward when
    // the trim is pushed into the cavity, then the hook snaps
    // outward behind the metal frame edge.

    union() {
        // Flexible arm (cantilever beam)
        cube([clip_t, clip_w, clip_depth]);

        // Hook barb at the end of the arm
        // Angled entry face for easy insertion, square catch face
        translate([0, 0, clip_depth - clip_hook_h])
        hull() {
            cube([clip_t, clip_w, clip_hook_h]);
            translate([clip_t + clip_hook, 0, clip_hook_h * 0.3])
                cube([0.1, clip_w, clip_hook_h * 0.7]);
        }
    }
}

// ── Main Trim Body ───────────────────────────────────────────

module trim() {
    difference() {
        union() {
            // Body — fits into the dash cavity
            rotate([dash_angle, 0, 0])
            translate([tol, tol, 0])
            linear_extrude(depth)
                rounded_rect_2d(outer_w - tol*2, outer_h - tol*2, outer_r);

            // Front flange — sits on the fascia surface
            rotate([dash_angle, 0, 0])
            translate([-(flange_overhang - tol), -(flange_overhang - tol), -flange_t])
            linear_extrude(flange_t)
                rounded_rect_2d(
                    outer_w + flange_overhang*2 - tol*2,
                    outer_h + flange_overhang*2 - tol*2,
                    outer_r + flange_overhang
                );

            // ── Left side clips ──
            for (y_pos = clip_y_positions) {
                rotate([dash_angle, 0, 0])
                translate([
                    -(clip_t + clip_gap),   // outside left wall
                    y_pos - clip_w/2,
                    3                        // start 3mm back from front
                ])
                mirror([1, 0, 0])           // hook points left (outward)
                snap_clip();
            }

            // ── Right side clips ──
            for (y_pos = clip_y_positions) {
                rotate([dash_angle, 0, 0])
                translate([
                    outer_w + clip_gap,     // outside right wall
                    y_pos - clip_w/2,
                    3
                ])
                snap_clip();
            }

            // ── Top friction ribs ──
            for (i = [0 : rib_count - 1]) {
                rib_x = outer_w * (i + 1) / (rib_count + 1);
                rotate([dash_angle, 0, 0])
                translate([rib_x - rib_w/2, outer_h - tol, 5])
                    cube([rib_w, rib_h, rib_depth]);
            }

            // ── Bottom friction ribs ──
            for (i = [0 : rib_count - 1]) {
                rib_x = outer_w * (i + 1) / (rib_count + 1);
                rotate([dash_angle, 0, 0])
                translate([rib_x - rib_w/2, tol - rib_h, 5])
                    cube([rib_w, rib_h, rib_depth]);
            }
        }

        // DIN cutout — all the way through body + flange
        rotate([dash_angle, 0, 0])
        translate([din_x, din_y, -flange_t - 1])
        linear_extrude(depth + flange_t + 2)
            rounded_rect_2d(din_w, din_h, din_r);

        // Hollow out the body interior (save material, reduce print time)
        // Leave walls of 'wall' thickness on all sides
        // But DON'T hollow where clips attach — reinforce those areas
        rotate([dash_angle, 0, 0])
        translate([wall + tol, wall + tol, wall])
        linear_extrude(depth + 1)
            rounded_rect_2d(outer_w - wall*2 - tol*2, outer_h - wall*2 - tol*2, outer_r - wall);

        // Cut the bottom flat so it sits on the print bed
        translate([-50, -50, -100])
            cube([outer_w + 100, 100, 100]);
    }
}

// ── Build ────────────────────────────────────────────────────

trim();
