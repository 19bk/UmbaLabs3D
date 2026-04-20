// ============================================================
// Tiki Tales — Modified Tonuino Box
// ============================================================
// Based on Sash131's Tonuino V2 compact enclosure
// Modifications:
//   - 3 tactile button holes FILLED (right side of front panel)
//   - 1 power button hole FILLED (top-right of front panel)
//   - Speaker grille replaced with dot-pattern (no screw mounts)
//   - Parts 1, 3, 5 unchanged
//
// PARTS:
//   part="front_panel"  — modified Part 2 (buttons filled)
//   part="speaker_grille" — new dot-pattern grille (replaces Part 4)
//   part="body"         — Part 1 unchanged (for reference)
// ============================================================

$fn = 40;

part = "front_panel";

// Original STL paths
orig_dir = "tonuino-original/";
part1_file = str(orig_dir, "Tonuino V2 - Part 1 (2).stl");
part2_file = str(orig_dir, "Tonuino V2 - Part 2 (1).stl");
part4_file = str(orig_dir, "Tonuino V2 - Part 4 (1).stl");

// ============================================================
// Button hole positions (measured from Part 2 geometry)
// Part 2 is centered at origin, thin in Y (~3.6mm, from Y=-1 to Y=2.6)
// Button holes are on the RIGHT side (positive X)
// ============================================================

// 3 tactile button holes (12x12x7.3mm buttons, ~13mm holes)
btn_d = 13.5;   // fill diameter (slightly larger than holes)
btn_positions = [
    [33, 0, 18],    // top button
    [33, 0, 0],     // middle button
    [33, 0, -18],   // bottom button
];

// Power button hole (13mm self-locking button)
pwr_d = 14.5;
pwr_pos = [38, 0, 28];  // top-right area

// ============================================================
// DOT-PATTERN SPEAKER GRILLE (replaces Part 4)
// ============================================================
// Part 4 dimensions: 66.1 x 1.8 x 66.1mm (circular with tabs)
// Speaker opening in Part 2: ~60mm diameter
// Grille must fit inside the speaker opening

grille_d = 64;      // grille outer diameter
grille_t = 1.8;     // thickness (match original)
hole_d = 2.5;       // dot hole diameter
tab_w = 6;          // mounting tab width
tab_l = 4;          // tab extension beyond grille

module speaker_grille_dots(dia, hole_d, thick) {
    difference() {
        // Solid disc
        cylinder(d=dia, h=thick);
        // Dot pattern holes
        n_rings = floor(dia / (hole_d * 2.5));
        for (ring = [0 : n_rings]) {
            if (ring == 0) {
                translate([0, 0, -0.1])
                    cylinder(d=hole_d, h=thick + 0.2);
            } else {
                n = ring * 6;
                r = ring * (hole_d + 1.8);
                if (r <= dia/2 - hole_d/2 - 1) {
                    for (i = [0 : n-1])
                        translate([r * cos(i*360/n), r * sin(i*360/n), -0.1])
                            cylinder(d=hole_d, h=thick + 0.2);
                }
            }
        }
    }
}

module new_speaker_grille() {
    // Main grille disc with dot pattern
    speaker_grille_dots(grille_d, hole_d, grille_t);

    // 4 mounting tabs (press-fit into speaker opening, no screws)
    for (a = [45, 135, 225, 315])
        rotate([0, 0, a])
            translate([grille_d/2 - 1, -tab_w/2, 0])
                cube([tab_l + 1, tab_w, grille_t]);
}

// ============================================================
// MODIFIED FRONT PANEL (Part 2 with buttons filled)
// ============================================================
module modified_front_panel() {
    union() {
        // Original panel
        import(part2_file, convexity=10);

        // Fill 3 tactile button holes
        for (pos = btn_positions)
            translate(pos)
                rotate([90, 0, 0])
                    cylinder(d=btn_d, h=4, center=true);

        // Power button hole KEPT — user wants it maintained
    }
}

// ============================================================
// EXPORT
// ============================================================

if (part == "front_panel") {
    modified_front_panel();
}
else if (part == "speaker_grille") {
    // Oriented flat for printing
    new_speaker_grille();
}
else if (part == "body") {
    import(part1_file, convexity=10);
}
else if (part == "assembly") {
    // All parts together for visual check
    color("#FF6B35") import(part1_file, convexity=10);
    color("#F7B801") modified_front_panel();
    color("#00D9C0")
        translate([0, -1, 0])
            rotate([90, 0, 0])
                new_speaker_grille();
}
