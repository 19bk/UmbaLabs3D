// ============================================================
// Mini Test Print — v2 Toybox + Figurine Base (50% scale)
// ============================================================
// All 4 pieces on one plate. Quick print to verify fit.
// ============================================================

$fn = 40;  // lower res for speed

s = 0.5;

// ---- Include toybox modules ----
use <tiki-tales-base-v2.scad>

// ---- Figurine base parameters (inline, matching figurine-base.scad v4.3) ----
fb_dia    = 46;
fb_wall   = 2.0;
fb_floor  = 2.0;
fb_cup_h  = 11;
fb_lid_h  = 3.0;
fb_lip    = 2.5;
fb_lip_tol = 0.2;
fb_lip_wall = 2.0;
fb_inner  = fb_dia - fb_wall * 2;
fb_lip_od = fb_inner - fb_lip_tol * 2;
fb_lip_id = fb_lip_od - fb_lip_wall * 2;
fb_lip_r  = fb_lip_od / 2;

// Bayonet params
bn       = 3;
bw_t     = 3.0;
btol     = 0.35;
bd_t     = 0.8;
bdrop    = 2.5;
bsweep   = 30;
bch      = 2.0;

module fig_cup() {
    difference() {
        cylinder(d=fb_dia, h=fb_cup_h);
        translate([0, 0, fb_floor])
            cylinder(d=fb_inner, h=fb_cup_h - fb_floor + 0.01);
        // Bayonet slots
        for (a = [0 : 360/bn : 359])
            rotate([0, 0, a]) {
                sw = bw_t + btol * 2;
                sd = bd_t + 0.5;
                r = fb_inner / 2;
                translate([r - 0.01, -sw/2, fb_cup_h - bdrop])
                    cube([sd + 0.02, sw, bdrop + 0.01]);
                for (deg = [0 : 3 : bsweep - 3])
                    hull() {
                        rotate([0, 0, deg])
                            translate([r - 0.01, -sw/2, fb_cup_h - bdrop])
                                cube([sd + 0.02, sw, bch]);
                        rotate([0, 0, deg + 3])
                            translate([r - 0.01, -sw/2, fb_cup_h - bdrop])
                                cube([sd + 0.02, sw, bch]);
                    }
            }
    }
}

module fig_lid() {
    cylinder(d=fb_dia, h=fb_lid_h);
    translate([0, 0, -fb_lip])
        difference() {
            cylinder(d=fb_lip_od, h=fb_lip);
            translate([0, 0, -0.01])
                cylinder(d=fb_lip_id, h=fb_lip + 0.02);
        }
    // Bayonet tabs
    for (a = [0 : 360/bn : 359])
        rotate([0, 0, a]) {
            tab_z = -fb_lip + 0.1;
            tab_h = bch - 0.5;
            translate([fb_lip_r - 0.01, -bw_t/2, tab_z])
                hull() {
                    cube([0.01, bw_t, tab_h]);
                    translate([bd_t * 0.7, 0, 0.1])
                        cube([0.01, bw_t, tab_h - 0.2]);
                }
        }
}

// ============================================================
// PRINT PLATE — all at 50% scale
// ============================================================

// Toybox base (50%)
translate([0, 0, 0])
    scale([s, s, s])
        base();

// Toybox lid (50%, flipped)
translate([60, 0, 0])
    scale([s, s, s])
        translate([0, 85, 9.9])
            rotate([180, 0, 0])
                lid();

// Figurine cup (50%)
translate([5, 52, 0])
    scale([s, s, s])
        fig_cup();

// Figurine lid (50%, flipped)
translate([22, 52, 0])
    scale([s, s, s])
        translate([0, 0, fb_lid_h])
            mirror([0, 0, 1])
                fig_lid();

// Bunny body (50%, standing upright)
translate([5, 80, 0])
    scale([s, s, s])
        translate([0, 0, 39.31 * (65/78.61)])  // sit flat on bed
            scale([65/78.61, 65/78.61, 65/78.61])
                translate([0, 0, 39.31])
                    import("../figurines/raw/bunny.stl", convexity=5);

echo("=== Mini Test v2 — 50% scale, 5 pieces (with bunny) ===");
