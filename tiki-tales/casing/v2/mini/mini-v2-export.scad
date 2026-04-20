// ============================================================
// Mini Test v2 — Individual Exports (50% scale)
// ============================================================
// Export each part separately:
//   part="toybox_base"    — toybox bottom half
//   part="toybox_lid"     — toybox top half
//   part="bunny_lid"      — bunny fused onto bayonet lid (one piece)
//   part="fig_cup"        — bayonet cup (NFC tag goes here)
// ============================================================

$fn = 40;
s = 1.0;  // full scale
part = "bunny_lid";  // change this to export each part

// ---- Toybox ----
use <tiki-tales-base-v2.scad>

// ---- Figurine base params (matching figurine-base.scad v4.3) ----
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

// Bayonet
bn = 3; bw_t = 3.0; btol = 0.35; bd_t = 0.8;
bdrop = 2.5; bsweep = 30; bch = 2.0;

// Bunny raw mesh
bunny_raw_h = 78.61;
bunny_raw_min_z = -39.31;
bunny_target_h = 65;
bunny_sf = bunny_target_h / bunny_raw_h;

// ---- Figurine cup (bayonet) ----
module fig_cup() {
    difference() {
        cylinder(d=fb_dia, h=fb_cup_h);
        translate([0, 0, fb_floor])
            cylinder(d=fb_inner, h=fb_cup_h - fb_floor + 0.01);
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

// ---- Figurine lid (bayonet) ----
module fig_lid() {
    cylinder(d=fb_dia, h=fb_lid_h);
    translate([0, 0, -fb_lip])
        difference() {
            cylinder(d=fb_lip_od, h=fb_lip);
            translate([0, 0, -0.01])
                cylinder(d=fb_lip_id, h=fb_lip + 0.02);
        }
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

// ---- Bunny fused onto lid (one solid piece) ----
module bunny_lid() {
    // Lid at origin (flat top at Z=0 to fb_lid_h, lip goes negative)
    fig_lid();
    // Bunny sitting on lid top
    translate([0, 0, fb_lid_h + bunny_raw_min_z * bunny_sf * -1])
        scale([bunny_sf, bunny_sf, bunny_sf])
            import("../figurines/raw/bunny.stl", convexity=5);
}

// ============================================================
// EXPORT SELECTOR
// ============================================================

if (part == "toybox_base") {
    scale([s, s, s])
        base();
}
else if (part == "toybox_lid") {
    // Flipped for printing (top surface on bed)
    scale([s, s, s])
        translate([0, 85, 9.9])
            rotate([180, 0, 0])
                lid();
}
else if (part == "bunny_lid") {
    // Bunny+lid fused, printed upright (lid lip at bottom needs support
    // or print lip-up with bunny on top)
    scale([s, s, s])
        bunny_lid();
}
else if (part == "fig_cup") {
    scale([s, s, s])
        fig_cup();
}
