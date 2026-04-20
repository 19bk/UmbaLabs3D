// Prado 2018 Radio Trim v2 — Based purely on radio dimensions
// OEM: Eclipse AVN-R8W  → 205.5 × 104mm face
// New: Sony XAV-AX8500  → 178 × 50mm DIN chassis
//
// The trim adapts the Eclipse-sized opening to the Sony DIN slot.
// Sony's floating screen (269×167mm) sits in front — not our concern.

// ── Dimensions (mm) ──────────────────────────────────────────

// Outer = OEM Eclipse face size (what the dash opening fits)
outer_w = 205.5;
outer_h = 104;

// Inner cutout = Sony DIN chassis
din_w = 178;
din_h = 50;

// Depth of the trim (how far it extends into the dash)
depth = 20;          // enough to grip, not too deep to interfere

// Front flange
flange = 3;          // lip that sits against dash face, prevents push-through
flange_t = 2;        // flange thickness

// Wall thickness
wall = 2.5;

// Corner radii
outer_r = 4;
din_r = 2;

// Tolerances
tol = 0.3;           // slight clearance on outer for snug fit

// DIN cutout position (NOT centered — Sony cage sits low in the opening)
// Measured: 15mm from bottom, ~39mm gap above
din_x = (outer_w - din_w) / 2;   // = 13.75mm (centered horizontally)
din_y = 15;                        // 15mm from bottom (matches client measurement)

// ── Build ────────────────────────────────────────────────────

$fn = 50;

module rounded_box(w, h, d, r) {
    linear_extrude(d)
        offset(r) offset(-r)
            square([w, h]);
}

difference() {
    union() {
        // Main body — fits into the dash opening
        rounded_box(outer_w - tol*2, outer_h - tol*2, depth, outer_r);

        // Front flange — overlaps the dash opening edge
        translate([-(flange - tol), -(flange - tol), depth - flange_t])
            rounded_box(outer_w + flange*2 - tol*2, outer_h + flange*2 - tol*2, flange_t, outer_r + flange);
    }

    // DIN cutout — goes all the way through
    translate([din_x, din_y, -1])
        rounded_box(din_w, din_h, depth + flange_t + 2, din_r);
}
