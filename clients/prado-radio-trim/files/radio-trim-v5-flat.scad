// Prado 2018 Radio Trim v5 — Flat fitment revision
// Built from 2026-03-11 physical test-fit notes
//
// Intent:
// - Ignore dash angle for now
// - Reduce the rear insert size slightly because the last print was a few mm too large
// - Limit insertion depth to the measured 15mm allowance behind the fascia
// - Preserve the "good" 18mm bottom datum
// - Pull the top edge down to a 7mm visible gap above the Sony chassis opening
// - Add lower L-shape relief around the Sony opening from the hand sketch
//
// This is a fitment shell, not the final retention design.
// No clips or hooks yet — the goal is to validate the front geometry first.

// ── Core dimensions from latest fitment ─────────────────────

sony_w = 179;             // Sony DIN chassis opening clearance
sony_h = 51;

bottom_gap = 18;          // Measured "good" distance from lower cutout edge
top_gap = 7;              // Needed visible fill above Sony opening

left_top_fill = 22;       // Width from opening edge to left outer face (top section)
right_top_fill = 23;      // Width from opening edge to right outer face (top section)
left_lower_fill = 15;     // Width from opening edge to left outer face at lower notch
right_lower_fill = 17;    // Width from opening edge to right outer face at lower notch

lower_relief_h = 14;      // Assumption: lower L-shape relief height, kept explicit for easy tuning

// Derived front bezel dimensions
bezel_w = sony_w + left_top_fill + right_top_fill;
bezel_h = sony_h + bottom_gap + top_gap;

// Rear insert body
body_w = 202.5;           // Reduced a few mm from prior 205mm shell
body_h = 101.5;           // Reduced a few mm from prior 104mm shell
body_r = 7;
body_depth = 14.5;        // Stay within measured 15mm allowance

bezel_t = 2.2;
wall = 2.0;
fit_clearance = 0.8;      // Slightly looser than the prior shell
face_corner_r = 6;
sony_r = 2;

// Align the bezel to the bottom datum that already fit well.
body_x = (bezel_w - body_w) / 2;
body_y = 0;

// Sony opening position inside the bezel
sony_x = left_top_fill;
sony_y = bottom_gap;

// Lower notch relief widths needed versus the top opening width.
left_relief = left_top_fill - left_lower_fill;
right_relief = right_top_fill - right_lower_fill;

$fn = 64;

module rounded_rect_2d(w, h, r) {
    offset(r) offset(-r)
        square([w, h]);
}

module sony_opening_profile() {
    union() {
        translate([sony_x, sony_y])
            rounded_rect_2d(sony_w, sony_h, sony_r);

        // Lower L-shape clearance from the hand sketch.
        if (left_relief > 0)
            translate([sony_x - left_relief, sony_y])
                square([left_relief, lower_relief_h]);

        if (right_relief > 0)
            translate([sony_x + sony_w, sony_y])
                square([right_relief, lower_relief_h]);
    }
}

module trim_v5_flat() {
    difference() {
        union() {
            // Visible front bezel driven by the latest sketch measurements.
            linear_extrude(bezel_t)
                rounded_rect_2d(bezel_w, bezel_h, face_corner_r);

            // Rear insert body used only for cavity fit validation.
            translate([body_x + fit_clearance/2, body_y + fit_clearance/2, bezel_t])
            linear_extrude(body_depth)
                rounded_rect_2d(
                    body_w - fit_clearance,
                    body_h - fit_clearance,
                    body_r
                );
        }

        // Main pass-through opening for the Sony chassis plus lower relief.
        translate([0, 0, -1])
        linear_extrude(bezel_t + body_depth + 2)
            sony_opening_profile();

        // Hollow the rear body to keep this as a fast, low-risk fitment print.
        translate([body_x + wall, body_y + wall, bezel_t + wall])
        linear_extrude(body_depth + 1)
            rounded_rect_2d(
                body_w - wall * 2,
                body_h - wall * 2,
                max(body_r - wall, 1)
            );
    }
}

trim_v5_flat();
