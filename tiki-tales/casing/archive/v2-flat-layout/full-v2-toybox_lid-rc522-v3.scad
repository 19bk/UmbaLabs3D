// ============================================================
// Tiki Tales — Lid + RC522 Holder (v3)
// ============================================================
// v3: ADDS a raised retention ring on the outer top around the figurine
//     dish so the figurine can't slide sideways off the lid.
//
// 1) REMOVES 4 obsolete mounting posts from full-v2-toybox_lid.stl
//    (posts at (23,25.5), (23,59.5), (77,25.5), (77,59.5),
//     Ø ~4.5mm top, ~8.8mm flared base, rise Z~0..5.1)
// 2) ADDS correctly-positioned RC522 standoffs + alignment rim.
//
// Source lid bbox: X 0..100, Y 0..85, Z 0..9.3
// PCB: 40 x 60 mm, centered on lid footprint
// Standoffs: Ø2.5 mm x 6 mm tall (PCB hole Ø3 mm → 0.25 mm clearance/side)
// Perimeter rim: 1 mm thick wall, 2 mm tall, traces 40 x 60 outline
//
// Hole positions derived from user's hand schematic (measured from
// PCB center: ±12.7/±13.15 top, ±17.55/±17.75 bottom, 23.15 above
// and 14.35/14.25 below the PCB horizontal centerline).
// ============================================================

$fn = 64;

// ---- Lid geometry (measured from STL) ----
lid_w = 100;    // X
lid_d = 85;     // Y
lid_h = 9.3;    // Z (outer top of tray rim)
floor_z = 1.6;  // Z of interior cavity floor (where old posts sat)

// ---- RC522 PCB ----
pcb_w = 40;     // along X
pcb_d = 60;     // along Y

// ---- Holder parameters ----
peg_dia      = 2.5;
peg_h        = 6.0;   // total standoff height (PCB top sits at floor+peg_h)
shoulder_dia = 4.0;   // wider base PCB rests on
shoulder_h   = 1.6;   // PCB-seat thickness — PCB rests at floor+shoulder_h
peg_embed    = 0.4;   // sink shoulder into lid for clean union
rim_t        = 1.0;   // wall thickness
rim_h        = 4.0;   // doubled — rim now captures PCB above its top surface
pcb_fit_tol  = 0.4;   // 0.2mm/side — matches peg-in-hole clearance

// ---- Placement: center PCB on lid top ----
pcb_x0 = (lid_w - pcb_w) / 2;   // = 30
pcb_y0 = (lid_d - pcb_d) / 2;   // = 12.5
pcb_z0 = floor_z;               // pegs sit on interior cavity floor

// PCB-local hole coords (origin = PCB bottom-left corner)
// Derived: centerline-offset numbers from schematic
// Top row:    TL=(20-12.7, 30+23.15), TR=(20+13.15, 30+23.15)
// Bottom row: BL=(20-17.55, 30-14.35), BR=(20+17.75, 30-14.25)
holes = [
    [ 7.30, 53.15],  // top-left
    [33.15, 53.15],  // top-right
    [ 2.45, 15.65],  // bottom-left
    [37.75, 15.75],  // bottom-right
];

// ============================================================
// Standoff: Ø shoulder_dia for shoulder_h (PCB seat) → Ø peg_dia pin
// passing through the PCB hole. PCB underside sits at Z = floor + shoulder_h,
// giving shoulder_h mm antenna-side clearance.
module pegs() {
    for (h = holes) {
        translate([pcb_x0 + h[0], pcb_y0 + h[1], pcb_z0 - peg_embed]) {
            cylinder(d = shoulder_dia, h = shoulder_h + peg_embed);
            translate([0, 0, shoulder_h + peg_embed])
                cylinder(d = peg_dia, h = peg_h - shoulder_h);
        }
    }
}

// Rim: inner cavity = PCB + pcb_fit_tol; outer = inner + 2*rim_t.
// Kept centered on the same PCB center (no peg drift).
module rim() {
    inner_w = pcb_w + pcb_fit_tol;
    inner_d = pcb_d + pcb_fit_tol;
    outer_w = inner_w + 2 * rim_t;
    outer_d = inner_d + 2 * rim_t;
    rim_x0 = pcb_x0 - pcb_fit_tol/2 - rim_t;
    rim_y0 = pcb_y0 - pcb_fit_tol/2 - rim_t;
    translate([rim_x0, rim_y0, pcb_z0 - peg_embed])
        difference() {
            cube([outer_w, outer_d, rim_h + peg_embed]);
            translate([rim_t, rim_t, -0.01])
                cube([inner_w, inner_d, rim_h + peg_embed + 0.02]);
        }
}

// ---- Dish retention ring (v3, refined) ----
// Dish opening measured at r=29.66 (Ø~59.3). Ring rises above the outer
// top (Z=0) with a chamfered top for clean insertion + print quality.
dish_ring_id      = 58.0;   // 1.3mm pinch vs dish opening → snug-ish fit
dish_ring_od      = 64.0;   // 3mm wall (sturdier, better top-layer bond)
dish_ring_h       = 2.5;    // taller = more retention
dish_ring_embed   = 0.5;    // sink into lid for clean union
dish_ring_chamfer = 0.8;    // 45° chamfer on top inside & outside edges
$fn_ring = 128;             // smooth circle at this size

module dish_ring() {
    translate([lid_w/2, lid_d/2, -dish_ring_h])
        rotate_extrude($fn = $fn_ring)
            polygon(points = [
                // (r, z) profile — bottom embedded in lid, top chamfered
                [dish_ring_id/2,                         -0.01],
                [dish_ring_od/2,                         -0.01],
                [dish_ring_od/2,                          dish_ring_h - dish_ring_chamfer],
                [dish_ring_od/2 - dish_ring_chamfer,     dish_ring_h],
                [dish_ring_id/2 + dish_ring_chamfer,     dish_ring_h],
                [dish_ring_id/2,                          dish_ring_h - dish_ring_chamfer],
            ]);
    // Bottom skirt to merge cleanly into the lid body
    translate([lid_w/2, lid_d/2, -dish_ring_embed])
        difference() {
            cylinder(d = dish_ring_od, h = dish_ring_embed + 0.01, $fn = $fn_ring);
            translate([0, 0, -0.01])
                cylinder(d = dish_ring_id, h = dish_ring_embed + 0.03, $fn = $fn_ring);
        }
}

// ---- Obsolete posts to remove (XY centers, from mesh analysis) ----
old_posts = [ [23, 25.5], [23, 59.5], [77, 25.5], [77, 59.5] ];
old_post_cut_r = 5.5;      // > flared base radius (4.38) — covers whole post
old_post_cut_z0 = 1.6;     // AT floor top — don't pierce floor
old_post_cut_z1 = 5.6;     // past post top (5.10)

module cut_old_posts() {
    for (p = old_posts)
        translate([p[0], p[1], old_post_cut_z0])
            cylinder(r = old_post_cut_r,
                     h = old_post_cut_z1 - old_post_cut_z0);
}

// ---- Assemble ----
union() {
    difference() {
        import("full-v2-toybox_lid.stl", convexity = 10);
        cut_old_posts();
    }
    pegs();
    rim();
    dish_ring();
}
