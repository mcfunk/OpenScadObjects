// ==========================================
// Two-Sided Interlocking Tape Core Label Plug - With Holes
// Fits: 3" (76.2 mm) Core x 1/2" (12.7 mm) Wide
// ==========================================

/* [Core & Roll Dimensions] */
core_id = 76.2;          // 3 inches = 76.2 mm
roll_width = 25.4;       // 1/2 inch = 12.7 mm

/* [Plug Geometry] */
face_thickness = 2.0;    // Thickness of each flat label disc (mm)
flange_overhang = 2.5;   // Lip extending onto the cardboard edge (mm)
wall_thickness = 2.0;    // Wall thickness of barrels (mm)
snap_bump = 0.45;        // Snap ridge height for locking halves together (mm)
fit_tolerance = 0.25;    // Clearance between male and female barrels (mm)
num_tabs = 6;            // Number of spring tabs on the male half
slot_width = 4.0;        // Gap between male spring tabs (mm)

/* [Holes] */
num_holes = 3;           // Number of holes through each faceplate
hole_d = 12.7;           // Hole diameter: 1/2 inch = 12.7 mm
hole_edge_inset = 10.0;  // Distance from the outer rim to the near edge of each hole (mm)
hole_barrel_gap = 1.5;   // Minimum solid face kept between a hole and the inner barrel wall (mm)
hole_angle_offset = 30;  // Rotates the hole pattern (deg); 30 centres holes between male slots

/* [Layout] */
part_spacing = 6.0;      // Gap between the two printed parts on bed (mm)

/* [Resolution] */
$fn = 120;

// Derived dimensions
face_radius = (core_id / 2) + flange_overhang;
female_outer_r = (core_id / 2) - 0.15;
female_inner_r = female_outer_r - wall_thickness;

male_outer_r = female_inner_r - fit_tolerance;
male_inner_r = male_outer_r - wall_thickness;

// Hole ring: holes sit inside the male barrel, clear of the locking walls
hole_center_r = face_radius - hole_edge_inset - hole_d / 2;
assert(hole_center_r + hole_d / 2 <= male_inner_r - hole_barrel_gap,
       "Holes would cut into the locking barrels - increase hole_edge_inset or shrink hole_d");
assert(hole_center_r - hole_d / 2 > 0, "Holes would reach the centre");

// Both barrels are slightly shorter than roll_width so flanges pull tight against the core
female_depth = roll_width - 0.8;
male_depth = roll_width - 0.8;

// Flat label faceplate with the hole ring cut through it
module label_face() {
    difference() {
        cylinder(h = face_thickness, r = face_radius);
        for (i = [0 : num_holes - 1]) {
            rotate([0, 0, hole_angle_offset + i * (360 / num_holes)])
                translate([hole_center_r, 0, -0.1])
                    cylinder(h = face_thickness + 0.2, d = hole_d, $fn = 64);
        }
    }
}

module female_cap() {
    union() {
        // Flat Label Faceplate (with holes)
        label_face();

        // Outer Sleeve Barrel
        translate([0, 0, face_thickness]) {
            difference() {
                cylinder(h = female_depth, r = female_outer_r);
                translate([0, 0, -0.1])
                    cylinder(h = female_depth + 0.2, r = female_inner_r);

                // Internal snap groove near the base to catch the male tabs
                translate([0, 0, 2.2])
                    rotate_extrude()
                        translate([female_inner_r, 0, 0])
                            circle(r = snap_bump + 0.1, $fn = 24);

                // Lead-in chamfer at mouth of female barrel
                translate([0, 0, female_depth - 1.0])
                    cylinder(h = 1.1, r1 = female_inner_r, r2 = female_inner_r + 0.7);
            }
        }
    }
}

module male_cap() {
    union() {
        // Flat Label Faceplate (with holes)
        label_face();

        // Inner Slotted Snap Barrel
        translate([0, 0, face_thickness]) {
            difference() {
                union() {
                    // Main hollow cylinder
                    difference() {
                        cylinder(h = male_depth, r = male_outer_r);
                        translate([0, 0, -0.1])
                            cylinder(h = male_depth + 0.2, r = male_inner_r);
                    }

                    // Outward snap ring near the tip to lock into female groove
                    translate([0, 0, male_depth - 2.2])
                        rotate_extrude()
                            translate([male_outer_r, 0, 0])
                                circle(r = snap_bump, $fn = 24);

                    // Lead-in chamfer at tip
                    translate([0, 0, male_depth - 1.1])
                        difference() {
                            cylinder(h = 1.1, r1 = male_outer_r + 0.2, r2 = male_outer_r - 0.7);
                            translate([0, 0, -0.1])
                                cylinder(h = 1.3, r = male_inner_r);
                        }
                }

                // Cut slots for spring flex
                for (i = [0 : num_tabs - 1]) {
                    rotate([0, 0, i * (360 / num_tabs)])
                        translate([0, -slot_width / 2, -0.1])
                            cube([face_radius + 5, slot_width, male_depth + 2]);
                }
            }
        }
    }
}

// Place both parts side-by-side for printing
translate([-(face_radius + part_spacing / 2), 0, 0])
    female_cap();

translate([face_radius + part_spacing / 2, 0, 0])
    male_cap();
