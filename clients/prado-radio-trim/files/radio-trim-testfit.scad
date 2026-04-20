// Prado 2018 Radio Trim — TEST FIT SHELL v3
// L-shaped cutout matching actual cage/bracket profile
//
// The gap around the Sony cage is L-shaped on each side:
//   38mm from opening edge to bracket (upper, most of height)
//   30mm from opening edge to bracket (lower, bottom 9mm)
//   Same both sides
//
// Cutout visible from front:
//   Upper: 199 - 38×2 = 123mm wide
//   Lower: 199 - 30×2 = 139mm wide (9mm tall)
//
// The L-shaped fill extends FULL DEPTH, not just flange face.
//
// Print: flange face DOWN on build plate
// 0.2mm layers, 2 perimeters, 10% infill, no supports

// ── Dimensions ───────────────────────────────────────────────

outer_w = 199;
outer_h = 97;
outer_r = 12;     // matches dash opening corners (~20 KES coin radius)

// L-shaped cutout (from opening edge to bracket, same both sides)
fill_upper = 38;    // wider gap (bracket stepped inward)
fill_lower = 30;    // narrower gap (bracket stepped outward)
step_h     = 9;     // height of the 30mm section (7mm + 2mm wiggle)
cutout_h   = 51;    // cage opening height
cutout_y   = 15;    // confirmed flush with Sony cage

// Derived cutout widths
cutout_upper_w = outer_w - fill_upper * 2;   // 123mm
cutout_lower_w = outer_w - fill_lower * 2;   // 139mm

depth           = 15;
flange_overhang = 3;
flange_t        = 2;
wall            = 1.5;
tol             = 0.3;

// Bolt arc groove on inner bottom edge of cutout
bolt_arc_w      = 35;    // groove width (3.5cm)
bolt_arc_depth  = 8;     // how far the arc dips into the 15mm strip (leaves 7mm)

$fn = 50;

// ── Modules ──────────────────────────────────────────────────

module rounded_rect_2d(w, h, r) {
    offset(r) offset(-r)
        square([w, h]);
}

// L-shaped cutout profile with bolt arc groove
cutout_r = 2;     // corner radius for cutout edges

module l_cutout_2d() {
    // Round both convex and concave corners: offset(-r), offset(2r), offset(-r)
    offset(r=-cutout_r) offset(r=2*cutout_r) offset(r=-cutout_r) {
        // Lower section (wider, 139mm, 9mm tall)
        translate([(outer_w - cutout_lower_w) / 2, cutout_y])
            square([cutout_lower_w, step_h]);

        // Upper section (narrower, 123mm, rest of height)
        translate([(outer_w - cutout_upper_w) / 2, cutout_y + step_h])
            square([cutout_upper_w, cutout_h - step_h]);

        // Bolt arc groove — shallow arc on inner bottom edge
        intersection() {
            translate([outer_w / 2, cutout_y])
                scale([1, bolt_arc_depth / (bolt_arc_w / 2)])
                    circle(d=bolt_arc_w);
            translate([(outer_w - bolt_arc_w) / 2, cutout_y - bolt_arc_depth])
                square([bolt_arc_w, bolt_arc_depth]);
        }
    }
}

// Body profile: outer rectangle minus L-cutout
module body_profile() {
    difference() {
        rounded_rect_2d(outer_w - tol*2, outer_h - tol*2, outer_r);
        translate([-tol, -tol])
            l_cutout_2d();
    }
}

// ── Test Fit Shell ───────────────────────────────────────────

module testfit() {
    difference() {
        union() {
            // Body shell (L-shaped cutout built into profile)
            translate([tol, tol, flange_t])
            linear_extrude(depth)
                body_profile();

            // Front flange
            translate([-(flange_overhang - tol), -(flange_overhang - tol), 0])
            linear_extrude(flange_t)
                rounded_rect_2d(
                    outer_w + flange_overhang*2 - tol*2,
                    outer_h + flange_overhang*2 - tol*2,
                    outer_r
                );
        }

        // L-cutout through flange too
        translate([0, 0, -1])
        linear_extrude(flange_t + 1.1)
            l_cutout_2d();

        // Hollow body interior (outer walls only, no ridge around cutout)
        translate([tol, tol, flange_t + wall])
        linear_extrude(depth + 1)
            difference() {
                offset(-wall)
                    rounded_rect_2d(outer_w - tol*2, outer_h - tol*2, outer_r);
                translate([-tol, -tol])
                    l_cutout_2d();
            }
    }
}

testfit();
