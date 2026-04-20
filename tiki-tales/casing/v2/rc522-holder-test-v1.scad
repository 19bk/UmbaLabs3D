// ============================================================
// RC522 Holder — Standalone Test Print v1
// ============================================================
// Minimal fit-test for the RC522 mounting features.
// Same pegs + rim as the lid integration, on a thin baseplate.
// Prints in ~10 min on a Bambu A1, <5g filament.
// ============================================================

$fn = 64;

// ---- RC522 PCB ----
pcb_w = 40;     // along X
pcb_d = 60;     // along Y

// ---- Holder parameters (match lid design) ----
peg_dia      = 2.5;
peg_h        = 6.0;
shoulder_dia = 4.0;
shoulder_h   = 1.6;
rim_t        = 1.0;
rim_h        = 2.0;
pcb_fit_tol  = 0.4;   // 0.2mm/side

// ---- Baseplate (just larger than rim outer) ----
base_margin = 2.0;    // extra flat flange around rim
base_t      = 1.6;    // thickness

// ---- Derived ----
inner_w = pcb_w + pcb_fit_tol;        // 40.4
inner_d = pcb_d + pcb_fit_tol;        // 60.4
outer_w = inner_w + 2 * rim_t;        // 42.4
outer_d = inner_d + 2 * rim_t;        // 62.4
base_w  = outer_w + 2 * base_margin;  // 46.4
base_d  = outer_d + 2 * base_margin;  // 66.4

// ---- PCB-local hole coords (origin = PCB BL corner inside cavity) ----
holes = [
    [ 7.30, 53.15],  // top-left
    [33.15, 53.15],  // top-right
    [ 2.45, 15.65],  // bottom-left
    [37.75, 15.75],  // bottom-right
];

// PCB bottom-left inside baseplate frame (baseplate centered on origin)
pcb_x0 = -pcb_w/2;
pcb_y0 = -pcb_d/2;

module baseplate() {
    translate([-base_w/2, -base_d/2, 0])
        cube([base_w, base_d, base_t]);
}

ov = 0.01;  // tiny overlap for clean union

module rim() {
    translate([-outer_w/2, -outer_d/2, base_t - ov])
        difference() {
            cube([outer_w, outer_d, rim_h + ov]);
            translate([rim_t, rim_t, -ov])
                cube([inner_w, inner_d, rim_h + ov*3]);
        }
}

module pegs() {
    for (h = holes) {
        translate([pcb_x0 + h[0], pcb_y0 + h[1], base_t - ov]) {
            cylinder(d = shoulder_dia, h = shoulder_h + ov);
            translate([0, 0, shoulder_h])
                cylinder(d = peg_dia, h = peg_h - shoulder_h + ov);
        }
    }
}

// ---- Assemble ----
union() {
    baseplate();
    rim();
    pegs();
}
