// ============================================================
// Tiki Tales — Speaker Base v5 (Measured Ports + LED Diffuser)
// ============================================================
//
// v5 CHANGES:
//   - All port dimensions from user measurements + 0.3mm tolerance
//   - Ports distributed: USB-C BACK, SD LEFT, switch RIGHT
//   - LED diffuser assembly with press-fit channel + dome recess
//   - Wider speaker (42mm) and figurine dish (56mm)
//   - Professional stepped lid joint with snap bumps
//   - Steel washer locating ring below RC522
//
// DESIGN PHILOSOPHY (learned from Toniebox + Yoto):
//   - TOP is sacred: flat, clean, only for figurine placement
//   - Speaker fires FORWARD through front face grille
//   - Ports distributed around body (back/left/right)
//   - LED with diffuser on FRONT face
//   - Shape: chunky rounded rectangle, pillow-soft edges
//   - Minimal visual noise — clean surfaces, no clutter
//   - Two-part: shallow lid (top) + deep base (bottom)
//
// PORT LAYOUT:
//   FRONT:  Speaker grille (42mm, centered mid-height)
//           LED hole (5.5mm, 5mm from bottom, with diffuser recess)
//   BACK:   USB-C port (10.6 x 3.6mm, centered, 5mm from bottom)
//   LEFT:   SD card slot (13.6 x 1.6mm, centered along depth, 5mm from bottom)
//   RIGHT:  Slide switch (4.6 x 1.6mm, centered along depth, 5mm from bottom)
//   TOP:    Figurine dish (56mm, centered)
//
// Components (actual parts on hand):
//   - Speaker: 42mm dia, 25mm depth
//   - RFID-RC522: 40 x 60 x 4mm
//   - Arduino Pro Mini: 33 x 18 x 6mm
//   - MP3-TF-16P: 21 x 20 x 5mm
//   - HW-373 v1.2.1 USB-C charger: 26 x 17 x 4mm
//   - Slide switch: 4mm x 1mm (actual)
//   - Li-Po battery: ~55 x 35 x 8mm
//   - RGB LED: 5.2mm dia
//   - NFC keychain tags: ~30mm disc + tab, 3mm thick
//
// Print: PLA, 0.2mm layers, 15-20% infill, no supports
// ============================================================

$fn = 60;

// ---- Tolerances ----
tol  = 0.3;
wall = 3.0;         // chunky walls = drop-proof + toy feel
top_t = 1.6;        // thin top for NFC read-through

// ---- Component sizes (with clearance) ----
spk_d   = 42 + tol*2;   // speaker diameter (measured 42mm)
spk_h   = 25 + tol;     // speaker depth

rc_w    = 40 + tol*2;   // RC522 width
rc_l    = 60 + tol*2;   // RC522 length
rc_t    = 4 + tol;      // RC522 thickness (PCB + pins)
rc_hw   = 34;            // hole spacing width
rc_hl   = 54;            // hole spacing length

apm_w   = 18 + tol*2;   // Arduino Pro Mini
apm_l   = 33 + tol*2;

dfp_w   = 20 + tol*2;   // DFPlayer
dfp_l   = 21 + tol*2;

chg_w   = 17 + tol*2;   // USB-C charger
chg_l   = 26 + tol*2;

bat_w   = 35 + tol*2;   // battery
bat_l   = 55 + tol*2;
bat_h   = 8 + tol;

// ---- Port dimensions (user-measured + 0.3mm tolerance each side) ----
usbc_pw = 10 + tol*2;   // USB-C port width (measured 10mm)
usbc_ph = 3 + tol*2;    // USB-C port height (measured 3mm)
usbc_from_floor = 5;     // 5mm from interior floor

sd_pw   = 13 + tol*2;   // SD card slot width (measured 13mm)
sd_ph   = 1.3 + tol*2;  // SD card slot height (measured 1.3mm)
sd_from_floor = 5;       // 5mm from interior floor

sw_pw   = 4 + tol*2;    // Slide switch width (measured 4mm)
sw_ph   = 1 + tol*2;    // Slide switch height (measured 1mm)
sw_from_floor = 5;       // 5mm from interior floor

// ---- LED diffuser assembly ----
led_d       = 5.2;       // LED body diameter (measured)
led_hole    = 5.5;       // through-hole (LED + clearance)
led_press_d = 5.5;       // inner press-fit channel diameter
led_press_depth = wall - 0.8;  // press-fit channel depth (from inside)
led_recess_d = 7;        // outer diffuser recess diameter
led_recess_depth = 1.2;  // diffuser dome cap depth
led_from_floor = 5;      // 5mm from interior floor

// ---- Body dimensions ----
// Sized to fit all components with breathing room
bw = 100;    // body width (X)
bd = 85;     // body depth (Y)
bh = 52;     // body total height (Z)
cr = 14;     // corner radius (XY plane)
er = 4;      // edge radius (Z — pillow rounding, must be < lid_h/2)

// ---- Split line ----
lid_h  = top_t + rc_t + 4;    // ~10mm — just enough for RC522
base_h = bh - lid_h;          // ~42mm — holds everything else

// ---- Lip joint ----
lip_h = 3;
lip_t = 1.5;

// ---- Screw posts (M3) ----
post_od = 7;
post_id = 2.8;   // tight for self-tapping M3 into PLA

// ---- Speaker position (front face, centered vertically) ----
spk_x  = bw / 2;           // centered horizontally
spk_z  = base_h / 2 + 4;   // centered-ish on front face

// ---- NFC zone (top, centered) ----
nfc_x  = bw / 2;
nfc_y  = bd / 2;
nfc_dish_d  = 56;    // shallow dish diameter (wider for 46mm figurine base)
nfc_dish_depth = 0.6; // very subtle

// ---- LED window (front face, below speaker) ----
led_x  = bw / 2;
led_z  = wall + led_from_floor;

// ---- Steel washer (below RC522 in lid) ----
washer_d  = 35;      // 35mm steel washer for magnet attraction
washer_t  = 1.0;     // washer thickness
washer_wall = 0.8;   // centering ring wall thickness

// ============================================================
// SHAPE PRIMITIVES
// ============================================================

// Pillow box: Minkowski of rbox + sphere
// Gives: XY corner radius = cr, Z edge radius = er
// This is the correct way to get different XY and Z radii
module pillow(w, d, h, r, e) {
    minkowski() {
        translate([e, e, e])
            rbox(w - e*2, d - e*2, h - e*2, max(r - e, 2));
        sphere(r=e);
    }
}

// Simpler rounded box for internal cavities (fast)
module rbox(w, d, h, r) {
    hull() {
        for (x = [r, w-r], y = [r, d-r])
            translate([x, y, 0])
                cylinder(r=r, h=h);
    }
}

// Clean dot-pattern speaker grille (circular arrangement)
module speaker_grille(dia, hole_d, depth) {
    n_rings = floor(dia / (hole_d * 2.5));
    for (ring = [0 : n_rings]) {
        if (ring == 0) {
            // Center hole
            cylinder(d=hole_d, h=depth);
        } else {
            n = ring * 6;
            r = ring * (hole_d + 1.8);
            if (r <= dia/2 - hole_d/2) {
                for (i = [0 : n-1])
                    translate([r * cos(i*360/n), r * sin(i*360/n), 0])
                        cylinder(d=hole_d, h=depth);
            }
        }
    }
}

// Standoff post
module standoff(h, id=2.5, od=5.5) {
    difference() {
        cylinder(d=od, h=h);
        translate([0, 0, -0.1])
            cylinder(d=id, h=h+0.2);
    }
}

// ============================================================
// BASE (bottom half — holds speaker, battery, boards)
// ============================================================
module base() {
    difference() {
        union() {
            // ---- Outer shell ----
            difference() {
                pillow(bw, bd, base_h, cr, er);
                // Hollow out
                translate([wall, wall, wall])
                    rbox(bw - wall*2, bd - wall*2, base_h - wall, max(cr - wall, 3));
                // Flatten top mating face
                translate([-1, -1, base_h])
                    cube([bw+2, bd+2, er+1]);
            }

            // ---- Professional stepped lip (0.8mm outer step + tongue) ----
            // Outer step: lid sits over this, hides seam line
            translate([0, 0, base_h - 0.8])
                difference() {
                    rbox_offset(bw, bd, 0.8 + 0.01, cr, wall - 0.8);
                    rbox_offset(bw, bd, 0.8 + 0.02, cr, wall);
                }
            // Inner tongue (lid groove receives this)
            translate([0, 0, base_h - 1])
                difference() {
                    rbox_offset(bw, bd, lip_h + 1, cr, wall);
                    rbox_offset(bw, bd, lip_h + 1.2, cr, wall + lip_t + 0.2);
                }

            // ---- Snap bumps on lip (4x, 0.3mm protrusion for click feel) ----
            for (i = [0:3]) {
                angle = i * 90;
                // Position bumps at midpoints of each side
                bx = (i == 0) ? bw/2 : (i == 2) ? bw/2 : (i == 1) ? bw - wall - lip_t/2 : wall + lip_t/2;
                by = (i == 1) ? bd/2 : (i == 3) ? bd/2 : (i == 0) ? wall + lip_t/2 : bd - wall - lip_t/2;
                translate([bx, by, base_h + lip_h/2])
                    sphere(r=0.3);
            }

            // ---- 4x Screw posts (corners) ----
            for (p = corner_posts())
                translate([p[0], p[1], wall])
                    standoff(base_h - wall - er - 1, post_id, post_od);

            // ---- Speaker ledge ring (clipped at split line) ----
            intersection() {
                // Clip ring to stay below base_h
                translate([-1, -1, -1])
                    cube([bw+2, bd+2, base_h + 1]);
                // Ring itself
                translate([spk_x, wall - 1, spk_z])
                    rotate([-90, 0, 0])
                        difference() {
                            cylinder(d=spk_d + 4, h=4);
                            translate([0, 0, -0.1])
                                cylinder(d=spk_d - 1, h=4.2);
                        }
            }

            // ---- Arduino Pro Mini standoffs ----
            apm_x = bw/2 + 5;
            apm_y = wall + 10;
            for (dx=[0, apm_l-3], dy=[0, apm_w-3])
                translate([apm_x + dx + 1.5, apm_y + dy + 1.5, wall])
                    standoff(4, 1.8, 4);

            // ---- DFPlayer standoffs ----
            dfp_x = apm_x;
            dfp_y = apm_y + apm_w + 5;
            for (dx=[0, dfp_l-3], dy=[0, dfp_w-3])
                translate([dfp_x + dx + 1.5, dfp_y + dy + 1.5, wall])
                    standoff(4, 1.8, 4);
        }

        // ---- CUTOUTS ----

        // Speaker grille holes (FRONT face, Y=0)
        translate([spk_x, -0.1, spk_z])
            rotate([-90, 0, 0])
                speaker_grille(spk_d - 4, 2.5, wall + 0.2);

        // LED diffuser assembly (FRONT face, 5mm from interior floor)
        // Through-hole
        translate([led_x, -0.1, led_z])
            rotate([-90, 0, 0])
                cylinder(d=led_hole, h=wall + 0.2);
        // Inner press-fit channel (from inside toward wall)
        translate([led_x, wall - led_press_depth, led_z])
            rotate([-90, 0, 0])
                cylinder(d=led_press_d, h=led_press_depth + 0.1);
        // Outer diffuser recess (from outside, for frosted dome cap)
        translate([led_x, -0.1, led_z])
            rotate([-90, 0, 0])
                cylinder(d=led_recess_d, h=led_recess_depth + 0.1);

        // USB-C port (BACK face, centered, 5mm from interior floor)
        usbc_x = bw/2 - usbc_pw/2;
        usbc_z = wall + usbc_from_floor;
        // Recessed channel (wider, for guiding cable)
        translate([usbc_x - 2, bd - wall - 0.1, usbc_z - 1.5])
            cube([usbc_pw + 4, wall + 0.2, usbc_ph + 3]);
        // Actual port hole (precise measured dimensions)
        translate([usbc_x, bd - wall - 0.1, usbc_z])
            cube([usbc_pw, wall + 0.2, usbc_ph]);

        // SD card slot (LEFT face, centered along depth, 5mm from interior floor)
        sd_y = bd/2 - sd_pw/2;
        sd_z = wall + sd_from_floor;
        translate([-0.1, sd_y, sd_z])
            cube([wall + 0.2, sd_pw, sd_ph]);

        // Slide switch slot (RIGHT face, centered along depth, 5mm from interior floor)
        sw_y = bd/2 - sw_pw/2;
        sw_z = wall + sw_from_floor;
        translate([bw - wall - 0.1, sw_y, sw_z])
            cube([wall + 0.2, sw_pw, sw_ph]);

        // Grip dimples — LEFT side (subtle indentations)
        for (r = [0:2], c = [0:3])
            translate([-0.1,
                       bd/2 + (c - 1.5) * 9,
                       base_h/2 + (r - 1) * 9])
                rotate([0, 90, 0])
                    cylinder(d=4, h=1.5);

        // Grip dimples — RIGHT side
        for (r = [0:2], c = [0:3])
            translate([bw - 1.4,
                       bd/2 + (c - 1.5) * 9,
                       base_h/2 + (r - 1) * 9])
                rotate([0, 90, 0])
                    cylinder(d=4, h=1.5);

        // Rubber foot recesses (BOTTOM)
        for (p = foot_positions())
            translate([p[0], p[1], -0.1])
                cylinder(d=10, h=1.8);
    }
}

// ============================================================
// LID (top half — holds RC522, clean top surface)
// ============================================================
module lid() {
    difference() {
        union() {
            // ---- Outer shell ----
            difference() {
                pillow(bw, bd, lid_h, cr, er);
                // Hollow
                translate([wall, wall, -0.01])
                    rbox(bw - wall*2, bd - wall*2, lid_h - top_t + 0.01, max(cr - wall, 3));
                // Flatten bottom mating face
                translate([-1, -1, -er - 0.1])
                    cube([bw+2, bd+2, er + 0.1]);
            }

            // ---- RC522 standoffs (hanging from ceiling, RC522 faces down) ----
            sh = lid_h - top_t - rc_t - 0.5;
            if (sh > 1)
                for (dx = [-rc_hl/2, rc_hl/2], dy = [-rc_hw/2, rc_hw/2])
                    translate([nfc_x + dx, nfc_y + dy, lid_h - top_t - sh])
                        standoff(sh, 1.5, 4.5);

            // ---- Steel washer centering ring (below RC522) ----
            // Washer sits BELOW RC522 (behind it from NFC perspective)
            // No metal in NFC signal path (tag → PLA floor → PLA lid → RC522)
            washer_ring_z = lid_h - top_t - rc_t - 0.5 - washer_t;
            translate([nfc_x, nfc_y, washer_ring_z - 0.5])
                difference() {
                    cylinder(d=washer_d + washer_wall*2 + tol*2, h=washer_t + 0.5);
                    translate([0, 0, -0.1])
                        cylinder(d=washer_d + tol*2, h=washer_t + 0.7);
                }
        }

        // ---- Lip groove (receives base tongue) ----
        translate([0, 0, -0.1])
            difference() {
                rbox_offset(bw, bd, lip_h + 0.2, cr, wall - tol);
                rbox_offset(bw, bd, lip_h + 0.4, cr, wall + lip_t + tol);
            }

        // ---- Outer step recess (receives 0.8mm base step, hides seam) ----
        translate([0, 0, -0.1])
            difference() {
                rbox_offset(bw, bd, 0.8 + 0.2, cr, wall - 0.8 - tol);
                rbox_offset(bw, bd, 0.8 + 0.3, cr, wall + tol);
            }

        // ---- Screw holes (countersunk from top) ----
        for (p = corner_posts()) {
            // Through hole
            translate([p[0], p[1], -0.1])
                cylinder(d=3.4, h=lid_h + 2);
            // Countersink (flush screw head)
            translate([p[0], p[1], lid_h - 2])
                cylinder(d1=3.4, d2=6.5, h=2.1);
        }

        // ---- Figurine dish (subtle concave recess on top, 56mm) ----
        translate([nfc_x, nfc_y, lid_h - nfc_dish_depth + 0.01])
            cylinder(d=nfc_dish_d, h=nfc_dish_depth + 0.1);

        // ---- Figurine alignment ring (thin groove) ----
        translate([nfc_x, nfc_y, lid_h - 0.4])
            difference() {
                cylinder(d=nfc_dish_d + 1, h=0.5);
                translate([0, 0, -0.1])
                    cylinder(d=nfc_dish_d - 1, h=0.7);
            }
    }
}

// ============================================================
// HELPER FUNCTIONS
// ============================================================

// Rounded box with inset from body edges
module rbox_offset(w, d, h, r, inset) {
    ir = max(r - inset, 2);
    translate([inset, inset, 0])
        rbox(w - inset*2, d - inset*2, h, ir);
}

// Corner post positions
function corner_posts() = [
    [cr + 1, cr + 1],
    [bw - cr - 1, cr + 1],
    [cr + 1, bd - cr - 1],
    [bw - cr - 1, bd - cr - 1]
];

// Foot positions
function foot_positions() = [
    [cr + 3, cr + 3],
    [bw - cr - 3, cr + 3],
    [cr + 3, bd - cr - 3],
    [bw - cr - 3, bd - cr - 3]
];

// ============================================================
// RENDER
// ============================================================
render_mode = "assembly";  // "assembly", "base", "lid", "print", "cross_section"

if (render_mode == "assembly") {
    color("#FF6B35") base();
    translate([0, 0, base_h + lip_h + 2])
        color("#F7B801", 0.85) lid();
}
else if (render_mode == "base") {
    base();
}
else if (render_mode == "lid") {
    // Flip for printing (top surface on build plate)
    translate([0, bd, lid_h])
        rotate([180, 0, 0])
            lid();
}
else if (render_mode == "print") {
    // Side by side, both print-ready orientation
    base();
    translate([bw + 15, 0, 0])
        translate([0, bd, lid_h])
            rotate([180, 0, 0])
                lid();
}
else if (render_mode == "cross_section") {
    // Cross-section to verify LED channel, port cutouts, washer ring
    difference() {
        union() {
            color("#FF6B35") base();
            translate([0, 0, base_h + lip_h])
                color("#F7B801", 0.85) lid();
        }
        translate([bw/2, -1, -1])
            cube([bw, bd+2, bh+2]);
    }
}

// ============================================================
echo("=== Tiki Tales v5 — Measured Ports + LED Diffuser ===");
echo(str("Outer: ", bw, " x ", bd, " x ", bh, "mm"));
echo(str("Corner R: ", cr, "mm  Edge R: ", er, "mm"));
echo(str("Wall: ", wall, "mm  Top (NFC): ", top_t, "mm"));
echo(str("Base: ", base_h, "mm  Lid: ", lid_h, "mm"));
echo(str("Speaker grille: FRONT face, ", spk_d, "mm at z=", spk_z));
echo(str("LED diffuser: FRONT face at z=", led_z, " (", led_hole, "mm hole + ", led_recess_d, "mm recess)"));
echo(str("USB-C: BACK face (", usbc_pw, " x ", usbc_ph, "mm)"));
echo(str("SD card: LEFT face (", sd_pw, " x ", sd_ph, "mm)"));
echo(str("Slide switch: RIGHT face (", sw_pw, " x ", sw_ph, "mm)"));
echo(str("NFC dish: TOP, centered, ", nfc_dish_d, "mm dia"));
echo(str("Steel washer ring: ", washer_d, "mm below RC522"));
