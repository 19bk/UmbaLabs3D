// ============================================================
// Tiki Tales — Universal Figurine Base (v4.3)
// ============================================================
// Clean, printable design. Uniform 2mm walls/floor.
// Single plain cavity — tag and magnet hot-glued in place.
// Lid lip is thick-walled tube (not solid) for clean printing.
//
// LOCK TYPES: "bayonet", "annular", "ribs", "thread"
//
// STACK (cup_h=11, floor=2):
//   Z=0   → flat bottom (bed)
//   Z=2   → floor top / cavity starts
//   Z=9.2 → tag(4) + magnet(3.2) top
//   Z=8.5 → lid lip bottom (11 - 2.5)
//   ... lid lip is hollow, stack passes through center
//   Z=11  → cup top / lid seated
//   Z=14  → lid top
// ============================================================

$fn = 80;

// ---- LOCK SELECTION ----
lock_type = "bayonet";

// ---- DIMENSIONS ----
base_dia    = 46;
wall        = 2.0;
floor_h     = 2.0;
cup_h       = 11;
lid_h       = 3.0;
lid_lip     = 2.5;
lip_tol     = 0.2;
lip_wall    = 2.0;

// ---- DERIVED ----
inner_dia   = base_dia - wall * 2;      // 42mm
cavity_h    = cup_h - floor_h;          // 9mm
lip_od      = inner_dia - lip_tol * 2;  // 41.6mm
lip_id      = lip_od - lip_wall * 2;    // 37.6mm
lip_r       = lip_od / 2;              // 20.8mm

// ============================================================
// LOCK PARAMETERS
// ============================================================

// Bayonet (push + twist 30°)
bayo_n       = 3;
bayo_w       = 3.0;
bayo_tol     = 0.35;    // tightened from test (was 0.5, user wants ~1mm less wiggle)
bayo_d       = 0.8;     // shorter tab (was 1.0) — less friction
bayo_drop    = 2.5;
bayo_sweep   = 30;
bayo_ch      = 2.0;     // taller channel for clearance
bayo_detent  = 0.12;    // softer click (was 0.15)
bayo_notch   = 1.5;     // alignment notch depth on cup rim

// Annular ridge (push snap)
ann_ridge_h  = 0.35;
ann_ridge_w  = 0.8;
ann_pos      = 1.2;

// Crush ribs (friction)
rib_n        = 8;
rib_d        = 0.3;
rib_w        = 1.2;

// Thread (screw 3/4 turn)
thr_pitch    = 3.0;
thr_depth    = 0.5;
thr_turns    = 0.75;
thr_w        = 1.5;
thr_tol      = 0.15;

// ============================================================
// THREAD HELIX HELPER
// ============================================================
module thread_helix(r, pitch, turns, w, d, inward=false, segs=36) {
    total = floor(turns * segs);
    da = 360 / segs;
    dz = pitch / segs;
    for (i = [0 : total - 1]) {
        hull() {
            rotate([0, 0, i * da])
                translate([inward ? r - d : r, -w/2, i * dz])
                    cube([d, w, 0.01]);
            rotate([0, 0, (i + 1) * da])
                translate([inward ? r - d : r, -w/2, (i + 1) * dz])
                    cube([d, w, 0.01]);
        }
    }
    hull() {
        rotate([0, 0, 0])
            translate([inward ? r - 0.01 : r, -w/2, 0])
                cube([0.01, w, 0.01]);
        rotate([0, 0, da])
            translate([inward ? r - d : r, -w/2, dz])
                cube([d, w, 0.01]);
    }
}

// ============================================================
// CUP — plain cavity, uniform walls
// ============================================================
module cup() {
    difference() {
        union() {
            cylinder(d=base_dia, h=cup_h);

            if (lock_type == "ribs")
                for (a = [0 : 360/rib_n : 359])
                    rotate([0, 0, a])
                        translate([inner_dia/2 - 0.01, -rib_w/2,
                                   cup_h - lid_lip - 0.5])
                            cube([rib_d + 0.01, rib_w, lid_lip + 0.5]);

            if (lock_type == "thread")
                translate([0, 0, cup_h - lid_lip])
                    thread_helix(inner_dia/2, thr_pitch, thr_turns,
                                 thr_w + thr_tol*2, thr_depth + thr_tol,
                                 inward=true);
        }

        // Single plain cavity
        translate([0, 0, floor_h])
            cylinder(d=inner_dia, h=cavity_h + 0.01);


        if (lock_type == "bayonet")
            for (a = [0 : 360/bayo_n : 359])
                rotate([0, 0, a])
                    _bayonet_slot();

        if (lock_type == "annular")
            _annular_groove();
    }
}

// ============================================================
// LID — thick-walled lip tube (not solid)
// ============================================================
module lid() {
    cylinder(d=base_dia, h=lid_h);

    // Lip is a tube — prints cleaner, cools properly
    translate([0, 0, -lid_lip])
        difference() {
            cylinder(d=lip_od, h=lid_lip);
            translate([0, 0, -0.01])
                cylinder(d=lip_id, h=lid_lip + 0.02);
        }

    if (lock_type == "bayonet")
        for (a = [0 : 360/bayo_n : 359])
            rotate([0, 0, a])
                _bayonet_tab();

    if (lock_type == "annular")
        _annular_ridge();

    if (lock_type == "thread")
        translate([0, 0, -lid_lip])
            thread_helix(lip_r, thr_pitch, thr_turns,
                         thr_w, thr_depth, inward=false);
}

// ============================================================
// BAYONET GEOMETRY
// ============================================================
module _bayonet_slot() {
    sw = bayo_w + bayo_tol * 2;   // 4.0mm wide slot
    sd = bayo_d + 0.5;            // 1.3mm deep (was +0.3, now +0.5)
    r  = inner_dia / 2;

    // Vertical entry slot
    translate([r - 0.01, -sw/2, cup_h - bayo_drop])
        cube([sd + 0.02, sw, bayo_drop + 0.01]);

    // Horizontal channel (arc)
    for (deg = [0 : 3 : bayo_sweep - 3]) {
        hull() {
            rotate([0, 0, deg])
                translate([r - 0.01, -sw/2, cup_h - bayo_drop])
                    cube([sd + 0.02, sw, bayo_ch]);
            rotate([0, 0, deg + 3])
                translate([r - 0.01, -sw/2, cup_h - bayo_drop])
                    cube([sd + 0.02, sw, bayo_ch]);
        }
    }

}

module _bayonet_tab() {
    // Position tab at bottom of lip — aligns with channel bottom when seated
    // Global check: lid at cup_h(11), tab_z = -2.4
    //   Tab bottom: 11 - 2.4 = 8.6  |  Channel bottom: 11 - 2.5 = 8.5  ✓
    //   Tab top:    8.6 + 1.5 = 10.1 |  Channel top:    8.5 + 2.0 = 10.5 ✓
    //   Clearance:  0.4mm above, 0.1mm below  ✓
    tab_z = -lid_lip + 0.1;
    tab_h = bayo_ch - 0.5;   // 1.5mm tab in 2.0mm channel

    translate([lip_r - 0.01, -bayo_w/2, tab_z])
        hull() {
            cube([0.01, bayo_w, tab_h]);
            translate([bayo_d * 0.7, 0, 0.1])
                cube([0.01, bayo_w, tab_h - 0.2]);
        }

    // Softer detent bump
    rotate([0, 0, bayo_sweep - 2])
        translate([lip_r + bayo_d * 0.4, 0, tab_z + tab_h/2])
            sphere(r=bayo_detent);
}

// ============================================================
// ANNULAR GEOMETRY
// ============================================================
module _annular_ridge() {
    ridge_z = -lid_lip + ann_pos;
    translate([0, 0, ridge_z])
        rotate_extrude()
            translate([lip_r - 0.01, 0])
                polygon([
                    [0, 0],
                    [ann_ridge_h + 0.01, ann_ridge_w * 0.4],
                    [ann_ridge_h + 0.01, ann_ridge_w * 0.6],
                    [0, ann_ridge_w]
                ]);
}

module _annular_groove() {
    groove_z = cup_h - lid_lip + ann_pos - 0.1;
    groove_d = ann_ridge_h + 0.15;
    groove_w = ann_ridge_w + 0.3;
    translate([0, 0, groove_z])
        rotate_extrude()
            translate([inner_dia/2 - groove_d, 0])
                square([groove_d + 0.01, groove_w]);
}

// ============================================================
// RENDER
// ============================================================
mode = "print_plate";

if (mode == "cup") {
    cup();
}
else if (mode == "lid") {
    lid();
}
else if (mode == "cup_cross") {
    difference() {
        cup();
        translate([-50, -50, -1])
            cube([50, 100, 50]);
    }
}
else if (mode == "assembly") {
    cup();
    translate([0, 0, cup_h])
        lid();
}
else if (mode == "print_plate") {
    translate([-28, 0, 0])
        cup();
    translate([28, 0, lid_h])
        mirror([0, 0, 1])
            lid();
}

// ============================================================
echo(str("=== Figurine Base v4.3 — Lock: ", lock_type, " ==="));
echo(str("Outer: ", base_dia, "mm x ", cup_h + lid_h, "mm total"));
echo(str("Wall: ", wall, "mm  Floor: ", floor_h, "mm"));
echo(str("Cavity: ", inner_dia, "mm x ", cavity_h, "mm (plain, no steps)"));
echo(str("Lip: ", lip_od, "mm OD, ", lip_wall, "mm wall tube, ", lid_lip, "mm deep"));
