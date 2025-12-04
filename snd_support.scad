// FiiO K11 R2R Support Frame with Douk Mini A5 Top Support

// Douk Mini A5 parameters
top_plate_thickness = 4;   // thickness of top support plate
top_device_length = 130;  // mm (longer dimension)
top_device_width = 102;   // mm (shorter dimension)
top_vent_hole_length = 86; // central ventilation hole length
top_vent_hole_width = 65;  // central ventilation hole width
footpad_offset = 15;       // distance from edge to center of foot pads

// FiiO K11 dimensions
device_length = 133;  // mm
device_width = 133;   // mm

// Support frame parameters
frame_height = 4;     // height of support frame (mm)
clearance = 1;        // clearance around devices per side (mm)

// Central (custom) octogonal cutout for the FiiO heating pad
parallel_length = 62;  // sides parallel to device borders
half_diagonal = 32;  // angled corner sides

// Ventilation holes
vent_hole_diameter = 4;
vent_hole_spacing = 12;

// Foot parameters
foot_diameter = 12;
foot_height = 8;

// Support structure parameters
pillar_height = 32;        // height from top of base frame to bottom of top support
pillar_thickness = 4;      // thickness of support pillars

// Calculate total dimensions
total_length = device_length + 2*pillar_thickness + 2*clearance;
total_width = device_width + 2*clearance;

module custom_octagon(h) {
    half_parallel = parallel_length / 2;  // sides parallel to device borders
    offset_x = 21;  // horizontal offset for angled sides
    offset_y = 21;  // vertical offset for angled sides

    points = [
        // Starting from top, going clockwise
        [-half_parallel, half_parallel + offset_y],
        [half_parallel, half_parallel + offset_y],
        [half_parallel + offset_x, half_parallel],
        [half_parallel + offset_x, -half_parallel],
        [half_parallel, -half_parallel - offset_y],
        [-half_parallel, -half_parallel - offset_y],
        [-half_parallel - offset_x, -half_parallel],
        [-half_parallel - offset_x, half_parallel]
    ];

    linear_extrude(height = h) {
        polygon(points);
    }
}

module support_frame(rad = 20) {
    rad = min(rad, total_length/2 - 0.1, total_width/2 - 0.1);

    difference() {
        // Main outer frame with rounded corners
        linear_extrude(height = frame_height)
            offset(r = rad)
                translate([rad, rad])
                    square([total_length - 2*rad, total_width - 2*rad], center = false);

        // Central octogonal cutout for heating pad
        translate([total_length/2, total_width/2, -1]) {
            custom_octagon(frame_height + 2);
        }
    }
}

module rubber_feet() {
    // Add rubber feet locations - 25mm diagonal offset from corners
    diagonal_offset = 25 * sqrt(2) / 2;
    foot_positions = [
        [diagonal_offset, diagonal_offset],
        [total_length - diagonal_offset, diagonal_offset],
        [diagonal_offset, total_width - diagonal_offset],
        [total_length - diagonal_offset, total_width - diagonal_offset]
    ];

    for (pos = foot_positions) {
        difference() {
            // Full printed foot
            translate([pos[0], pos[1], -foot_height]) {
                cylinder(h = foot_height, d = foot_diameter);
            }

            // Recess for (10mm) rubber pad
            translate([pos[0], pos[1], -foot_height - 0.1]) {
                cylinder(h = 1, d = 10.1);   // 10.1mm circle, 1mm deep
            }
        }
    }
}

module support_pillars() {
    // Left pillar
    // Remove 20mm from front&rear of the pillar
    translate([0, 20, frame_height])
        cube([pillar_thickness, total_width-40, pillar_height]);

    // Right pillar
    // Remove 20mm from front&rear of the pillar
    translate([total_length - pillar_thickness, 20, frame_height])
        cube([pillar_thickness, total_width-40, pillar_height]);
}

module top_support() {
    // Calculate positioning for Douk Mini A5 (centered on top plate)
    x_offset = (total_length - top_device_length)/2;
    y_offset = (total_width - top_device_width)/2;

    difference() {
        // Main plate
        translate([0, 20, 0]) // Remove 20mm from the up&down of the top plate
            cube([total_length, total_width-40, top_plate_thickness]);

        // Central ventilation hole
        translate([
            (total_length - top_vent_hole_length)/2,
            (total_width - top_vent_hole_width)/2,
            -1
        ]) {
            cube([top_vent_hole_length, top_vent_hole_width, top_plate_thickness + 2]);
        }

        // Cutouts for mounting pads (4 locations relative to A5 device edges that I have measured)
        pad_positions = [
            [x_offset + 15, y_offset + top_device_width - 15],
            [x_offset + top_device_length - 17, y_offset + top_device_width - 14],
            [x_offset + top_device_length - 16, y_offset + 16],
            [x_offset + 16, y_offset + 15]
        ];

        for (pos = pad_positions) {
            translate([pos[0], pos[1], -1]) {
                cylinder(h = top_plate_thickness + 2, d = 12);
            }
        }

        // Ventilation holes in the device area
        device_center_x = x_offset + top_device_length/2;
        device_center_y = y_offset + top_device_width/2;

        // Create ventilation holes in the device area
        for (x = [device_center_x - 48 : vent_hole_spacing : device_center_x + 48]) {
            for (y = [device_center_y - 36 : vent_hole_spacing : device_center_y + 36]) {
                // Only create holes within the device area bounds
                in_device_bounds = (x >= x_offset + 10 &&
                                  x <= x_offset + top_device_length - 10 &&
                                  y >= y_offset + 10 &&
                                  y <= y_offset + top_device_width - 10);

                // Avoid the central ventilation hole area
                outside_central_vent = (x < (total_length - top_vent_hole_length)/2 ||
                                      x > (total_length + top_vent_hole_length)/2 ||
                                      y < (total_width - top_vent_hole_width)/2 ||
                                      y > (total_width + top_vent_hole_width)/2);

                // Check distance to each pad position
                pad1_dist = sqrt(pow(x - (x_offset + 16), 2) + pow(y - (y_offset + top_device_width - 13), 2));
                pad2_dist = sqrt(pow(x - (x_offset + top_device_length - 16), 2) + pow(y - (y_offset + top_device_width - 11), 2));
                pad3_dist = sqrt(pow(x - (x_offset + top_device_length - 15), 2) + pow(y - (y_offset + 13), 2));
                pad4_dist = sqrt(pow(x - (x_offset + 15), 2) + pow(y - (y_offset + 15), 2));
                
                // Only create hole if far enough from all pads
                far_from_pads = (pad1_dist >= 12 && pad2_dist >= 12 && pad3_dist >= 12 && pad4_dist >= 12);

                if (in_device_bounds && outside_central_vent && far_from_pads) {
                    translate([x, y, -1]) {
                        cylinder(h = top_plate_thickness + 2, d = vent_hole_diameter);
                    }
                }
            }
        }
    }
}

// Main assembly
difference() {
    union() {
        support_frame();
        rubber_feet();
        support_pillars();
        // Position top support above pillars
        translate([0, 0, frame_height + pillar_height])
            top_support();
    }
}
