// Prado 2018 Radio Trim v5 — TEST FIT with L-shape fill
// Corrected from real test fit measurements (2026-03-11)
//
// Key corrections from v4 test fit:
// - Fascia opening: 200 × 100mm (not 205 × 104)
// - Body width: ~180mm (channel behind fascia is standard DIN width)
// - L-shaped side wings hug the Sony bracket (asymmetric left/right)
// - Body depth: max 15mm (before cavity widens)
// - din_y = 15mm (confirmed perfect)
// - Dash angle = 24° (measured, but kept flat for test fit)
//
// Print: flange face DOWN, 2 perimeters, 10% infill, ~30-40min

// ── Fascia Opening Dimensions ────────────────────────────────

// The actual opening in the gloss black fascia
fascia_w = 200;       // Confirmed: Aerpro FP9105 = 201mm, client = 20cm
fascia_h = 100;       // Confirmed: Aerpro FP9105 = 101mm, client = ~10cm

// Corner radius on fascia opening
fascia_r = 6;         // Reduced from 8mm — smaller opening means tighter radius

// ── DIN Cutout (Sony chassis hole) ───────────────────────────

din_w = 179;          // Sony 178mm + 1mm clearance
din_h = 51;           // Sony 50mm + 1mm clearance
din_r = 2;

// DIN position (measured from bottom-left of fascia opening)
din_x = (fascia_w - din_w) / 2;   // ~10.5mm centered
din_y = 15;                        // Confirmed perfect from test fit

// ── L-Shaped Side Fill (hugs Sony bracket) ───────────────────
// These fill the step between the narrow DIN area and the wide fascia opening
// Measured at the car — ASYMMETRIC left vs right

// Left side L-shape
l_shelf_w = 22;       // Horizontal shelf width (mm)
l_shelf_d = 15;       // Vertical depth of the shelf (mm)

// Right side L-shape
r_shelf_w = 23;       // Horizontal shelf width (mm)
r_shelf_d = 17;       // Vertical depth of the shelf (mm)

// ── Body Dimensions ──────────────────────────────────────────

body_depth = 15;      // Max depth before cavity widens (measured 1.5cm)
flange_overhang = 3;  // Reduced — fascia opening is tighter
flange_t = 2;         // Flange thickness (test fit = thin)

wall = 1.5;           // Thin walls for test fit
tol = 0.3;            // Tighter tolerance for better fit test

// ── Modules ──────────────────────────────────────────────────

$fn = 50;

module rounded_rect_2d(w, h, r) {
    offset(r) offset(-r)
        square([w, h]);
}

// ── Main Trim ────────────────────────────────────────────────

module trim_v5() {

    // Calculate inner body width (channel behind fascia)
    // The body that slides in is narrower than the fascia opening
    // It matches the space between the L-shelf inner edges
    body_w = fascia_w - l_shelf_w - r_shelf_w;  // 200 - 22 - 23 = 155mm
    body_h = fascia_h;  // Full height for now

    // Body X offset (left shelf pushes body to the right)
    body_x = l_shelf_w;

    difference() {
        union() {
            // ── 1. Front flange (sits on fascia surface) ──
            translate([-(flange_overhang - tol), -(flange_overhang - tol), 0])
            linear_extrude(flange_t)
                rounded_rect_2d(
                    fascia_w + flange_overhang*2 - tol*2,
                    fascia_h + flange_overhang*2 - tol*2,
                    fascia_r + flange_overhang
                );

            // ── 2. Face plate (fills the fascia opening) ──
            // This is the visible front face, full fascia width
            translate([tol, tol, flange_t])
            linear_extrude(wall)  // Just one wall thickness deep
                rounded_rect_2d(fascia_w - tol*2, fascia_h - tol*2, fascia_r);

            // ── 3. Narrow body (slides into the channel) ──
            // Only the narrow center section goes deep
            translate([body_x + tol, tol, flange_t])
            linear_extrude(body_depth)
                rounded_rect_2d(body_w - tol*2, body_h - tol*2, 2);

            // ── 4. Left L-shaped wing ──
            // Horizontal shelf: extends from body left edge toward fascia left edge
            // Depth: l_shelf_d (15mm)
            translate([tol, tol, flange_t])
            linear_extrude(l_shelf_d)
                rounded_rect_2d(l_shelf_w + body_w/2, fascia_h - tol*2, fascia_r);

            // ── 5. Right L-shaped wing ──
            // Horizontal shelf: extends from body right edge toward fascia right edge
            // Depth: r_shelf_d (17mm)
            translate([body_x + body_w/2 + tol, tol, flange_t])
            linear_extrude(r_shelf_d)
                rounded_rect_2d(r_shelf_w + body_w/2 - tol, fascia_h - tol*2, fascia_r);
        }

        // ── DIN cutout (all the way through) ──
        translate([din_x, din_y, -1])
        linear_extrude(body_depth + flange_t + 2)
            rounded_rect_2d(din_w, din_h, din_r);

        // ── Hollow out to save material ──
        // Hollow the face plate area (above and below DIN)
        // Above DIN
        translate([wall + tol, din_y + din_h + wall, flange_t + wall])
        linear_extrude(body_depth + 1)
            square([fascia_w - wall*2 - tol*2, fascia_h - din_y - din_h - wall*2]);

        // Below DIN (if there's enough space)
        if (din_y > wall * 3) {
            translate([wall + tol, wall + tol, flange_t + wall])
            linear_extrude(body_depth + 1)
                square([fascia_w - wall*2 - tol*2, din_y - wall*2]);
        }

        // Left side hollow (between DIN and left wall, behind the L-shelf)
        translate([wall + tol, wall + tol, flange_t + max(l_shelf_d, r_shelf_d) + wall])
        linear_extrude(body_depth + 1)
            square([din_x - wall*2, fascia_h - wall*2 - tol*2]);

        // Right side hollow
        translate([din_x + din_w + wall, wall + tol, flange_t + max(l_shelf_d, r_shelf_d) + wall])
        linear_extrude(body_depth + 1)
            square([fascia_w - din_x - din_w - wall*2 - tol, fascia_h - wall*2 - tol*2]);
    }
}

trim_v5();
