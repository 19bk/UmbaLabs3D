// Prado 2018 Radio Trim v3 — Refined from photo analysis
// OEM: Eclipse AVN-R8W  → 205.5 × 104mm face (Toyota 200mm wide format)
// New: Sony XAV-AX8500  → 178 × 50mm DIN chassis
//
// Key changes from v2:
// - Larger corner radius (~8mm) to match actual fascia opening
// - Dash angle ~12° tilt backward
// - DIN cutout positioned low (15mm from bottom)
// - Stepped edge profile on flange to match fascia recess

// ── Dimensions (mm) ──────────────────────────────────────────

// Outer = The cavity opening inside the gloss black fascia
// Using Eclipse face dimensions as proxy for what the dash accepts
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

// ── Modules ──────────────────────────────────────────────────

$fn = 60;

module rounded_rect_2d(w, h, r) {
    offset(r) offset(-r)
        square([w, h]);
}

module angled_extrude(height, angle) {
    // Extrude along a tilted axis to match dash angle
    // The trim body tilts so the front face matches the dash surface angle
    multmatrix([
        [1, 0, 0, 0],
        [0, 1, -tan(angle), 0],
        [0, 0, 1, 0]
    ])
    linear_extrude(height)
        children();
}

// ── Main Trim Body ───────────────────────────────────────────

module trim() {
    difference() {
        union() {
            // Body — fits into the dash cavity
            // Angled to match dash tilt
            rotate([dash_angle, 0, 0])
            translate([tol, tol, 0])
            linear_extrude(depth)
                rounded_rect_2d(outer_w - tol*2, outer_h - tol*2, outer_r);

            // Front flange — sits on the fascia surface
            // NOT angled (sits flat against the angled dash face)
            rotate([dash_angle, 0, 0])
            translate([-(flange_overhang - tol), -(flange_overhang - tol), -flange_t])
            linear_extrude(flange_t)
                rounded_rect_2d(
                    outer_w + flange_overhang*2 - tol*2,
                    outer_h + flange_overhang*2 - tol*2,
                    outer_r + flange_overhang
                );
        }

        // DIN cutout — all the way through body + flange
        rotate([dash_angle, 0, 0])
        translate([din_x, din_y, -flange_t - 1])
        linear_extrude(depth + flange_t + 2)
            rounded_rect_2d(din_w, din_h, din_r);

        // Hollow out the body interior (save material, reduce print time)
        // Leave walls of 'wall' thickness on all sides
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
