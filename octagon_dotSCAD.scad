module octagons(radius, spacing, levels, rotate=true, order=1) {
    beginning_n = 2 * levels - 1;
    rot = rotate ? 22.5 : 0;
    tips = rotate ? 22.5 : 0;
    // Adjusting for octagon geometry
    r_octagon = radius - spacing / 2;
    side_length = radius * sin(22.5);
    side_length_adjacent = side_length / sqrt(2) * 2;
    offset_x = radius * cos(tips) + side_length;
    offset_y = radius * cos(tips) * 2 - side_length_adjacent;
    echo(side_length);

    echo(side_length_adjacent);
    offset_step = 2 * offset_x;
    center_offset = (offset_x - offset_x * levels);

    module octagon() {
        rotate([0,0,rot]) circle(r_octagon, $fn = 8*order);
    }

    function octagons_pts(oct_datum) =
        let(
            tx = oct_datum[0][0],
            ty = oct_datum[0][1],
            n = oct_datum[1],
            offset_xs = [for(i = 0; i < n; i = i + 1) i * offset_step + center_offset] 
        )
        [
            for(x = offset_xs) [x + tx, ty]
        ];

    module line_octagons(oct_datum) {
        tx = oct_datum[0][0];
        ty = oct_datum[0][1];
        n = oct_datum[1]; 

        offset_xs = [for(i = 0; i < n; i = i + 1) i * offset_step + center_offset];
        for(x = offset_xs) {
            translate([x + tx, ty, 0]) 
                octagon();
        }
    }
    
    // Calculate the upper octagons, excluding the central line
    upper_oct_data = levels > 1 ? [
        for(i = [1:levels * 2])
            let(
                x = offset_x * i,
                y = offset_y * i,
                n = beginning_n - i
            ) [[x, y], n]
    ] : [];

    // Calculate the lower octagons by mirroring the upper octagons on the Y-axis
    lower_oct_data = levels > 1 ? [
        for(oct_datum = upper_oct_data)
        [[oct_datum[0][0], -oct_datum[0][1]], oct_datum[1]]
    ] : [];


    // Combine central, upper, and lower octagons data
    total_oct_data = [[[0, 0], beginning_n], each upper_oct_data, each lower_oct_data];

    // Generate points for all octagons
    pts_all_lines = [
        for(oct_datum = total_oct_data)
            octagons_pts(oct_datum)
    ];

    // Draw all octagons using the generated points
    for(pts_one_line = pts_all_lines, pt = pts_one_line) {
        translate(pt) 
            octagon();
    }

    // This function is for testing each octagon placement; override it as needed
    test_each_octagon(r_octagon, pts_all_lines);
}

// override it to test
module test_each_octagon(oct_r, pts_all_lines) {
    // Uncomment to visualize the points for each octagon
    // for(pts_one_line = pts_all_lines) for(pt = pts_one_line) translate(pt) octagon();
}

// Example usage of the octagons module
octagons(radius = 10, spacing = 0, levels = 5, rotate=false, order=1);
