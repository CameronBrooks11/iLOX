/**
* octagons.scad
*
* Adapted from the hexagons module by Justin Lin, 2017
* Modifications made by Cameron K. Brooks, 2024
*
* License: https://opensource.org/licenses/lgpl-3.0.html
*
* Original hexagons module at: https://openhome.cc/eGossip/OpenSCAD/lib3x-hexagons.html
*
**/


// Function to check if two points are equal within a tolerance
function points_equal(p1, p2, tolerance=1e-3) =
    let(
        comparisons = [for(i = [0:len(p1)-1]) abs(p1[i] - p2[i]) < tolerance]
    )
    len([for(comp = comparisons) if (comp) true]) == len(comparisons);

// Function to check if any point in a list equals the given point
function is_point_in_list(point, list, tolerance=1e-3) =
    let(
        equal_points = [for(p = list) points_equal(p, point, tolerance)]
    )
    len([for(eq = equal_points) if (eq) true]) > 0;

// Function to filter out certain octagon centers
function filter_octagon_centers(centers, filter_list, tolerance=1e-3) =
    [for(center = centers) if (!is_point_in_list(center, filter_list, tolerance)) center];

// Function to calculate octagon centers for both levels and grid
function octagon_centers(radius, spacing, levels=undef, n=undef, m=undef, rotate=true) =
    let(
        // Common calculations
        side_length = (radius * 2) / (sqrt(4 + 2 * sqrt(2))),
        segment_length = side_length / sqrt(2),
        total_width = side_length * (1 + sqrt(2)),
        tip = rotate ? segment_length : (side_length / 2) * sqrt(2 - sqrt(2)) * 2,
        shift = rotate ? total_width : radius * 2,
        offset = shift - tip,

        // Function for generating points in a grid pattern
        generate_grid_points = function(n, m, offset_step) 
            [for(i = [0:n-1], j = [0:m-1]) [i * offset_step, j * offset_step]],

        // Function for generating points based on levels
        octagons_pts = function(oct_datum, offset_step, center_offset) 
            let(
                tx = oct_datum[0][0],
                ty = oct_datum[0][1],
                n_pts = oct_datum[1],
                offset_xs = [for(i = 0; i < n_pts; i = i + 1) i * offset_step + center_offset]
            )
            [for(x = offset_xs) [x + tx, ty]]
    )
    (!is_undef(n) && !is_undef(m)) ?
        // Grid pattern case
        generate_grid_points(n, m, total_width) :
        // Levels case
    let(
        beginning_n = 2 * levels - 1,
        rot = rotate ? 22.5 : 0,
        r_octagon = radius - spacing / 2,
        side_length = (radius * 2) / (sqrt(4+2*sqrt(2))),
        segment_length = side_length / sqrt(2),
        total_width = side_length*(1+sqrt(2)),
        tip = rotate ? segment_length : (side_length / 2) * sqrt(2 - sqrt(2)) * 2,
        shift = rotate ? total_width : radius * 2,
        offset = shift - tip,
        offset_step = 2 * offset,
        center_offset = -(offset * 2 * (levels - 1)),

        octagons_pts = function(oct_datum) 
            let(
                tx = oct_datum[0][0],
                ty = oct_datum[0][1],
                n = oct_datum[1],
                offset_xs = [for(i = 0; i < n; i = i + 1) i * offset_step + center_offset]
            )
            [for(x = offset_xs) [x + tx, ty]],

        upper_oct_data = levels > 1 ? 
            [for(i = [1:levels * 2])
                let(
                    x = offset * i,
                    y = offset * i,
                    n = beginning_n - i
                ) [[x, y], n]
            ] : [],

        lower_oct_data = levels > 1 ? 
            [for(oct_datum = upper_oct_data)
                [[oct_datum[0][0], -oct_datum[0][1]], oct_datum[1]]
            ] : [],

        total_oct_data = [[[0, 0], beginning_n], each upper_oct_data, each lower_oct_data],

        local_hexagon_centers = []
    )
    let(
        centers = [for(oct_datum = total_oct_data)
            let(pts = octagons_pts(oct_datum))
            [for(pt = pts) pt]
        ]
    ) concat([for(c = centers) each c]);    

    
// Module to create octagons
module octagons(radius, spacing, levels, rotate=true, order=1, octagon_centers=undef) {
    if (is_undef(octagon_centers)) {
        octagon_centers = calculate_octagon_centers(radius, spacing, levels, rotate, order);
    }

    for(center = octagon_centers) {
        translate([center[0], center[1], 0]) {
            rotate([0,0,rotate ? 22.5 : 0]) circle(radius - spacing / 2, $fn = 8*order);
        }
    }
}

// Module to print points as text
module print_points(points, text_size=2, color=[0, 0, 0]) {
    for (point = points) {
        color(color)
        translate([point[0], point[1], 1]) // Translated +1 in Z-axis
        text(str("[", point[0], ", ", point[1], "]"), size=text_size, valign="center", halign="center");
    }
}


// Define the mode: 
// 1 for levels, 
// 2 for filtered levels, 
// 3 for grid, 
// 4 for filtered grid
mode = 4; // Change this number to switch between different examples

rad = 10;
space = 1;
lvls = 4;
rotate = true; // Set true to rotate octagons, false to keep them aligned ! fix inverse

n = 7;
m = 7;

// Define your filter points for levels and grid
filter_points_levels = [
    [-78.3938, 0], [-65.3281, -13.0656], [-65.3281, 13.0656], 
    [78.3938, 0], [65.3281, -13.0656], [65.3281, 13.0656],
    [-52.2625, 0], [52.2625, 0], [-13.0656, 65.3281], [13.0656, 65.3281], 
    [0, 78.3938], [0, 52.2625], [-13.0656, -65.3281], [13.0656, -65.3281], 
    [0, -78.3938], [0, -52.2625]
];

filter_points_grid = [
    [0, 0], [110.866, 0], [0, 110.866], [110.866, 110.866],  [55.4328, 55.4328]
]; // Your filter points for grid

// Module to create octagons with color gradient
module octagonsss(radius, spacing, levels, rotate=true, order=1, octagon_centers=undef) {
    if (is_undef(octagon_centers)) {
        octagon_centers = calculate_octagon_centers(radius, spacing, levels, rotate, order);
    }

    // Determine the range of the center points for normalization
    min_x = min([for(center = octagon_centers) center[0]]);
    max_x = max([for(center = octagon_centers) center[0]]);
    min_y = min([for(center = octagon_centers) center[1]]);
    max_y = max([for(center = octagon_centers) center[1]]);

    for(center = octagon_centers) {
        // Normalize the center coordinates to [0, 1] range
        normalized_x = (center[0] - min_x) / (max_x - min_x);
        normalized_y = (center[1] - min_y) / (max_y - min_y);

        // Create a color gradient based on normalized center coordinates
        color_val = [normalized_x, 1 - normalized_x, normalized_y];
        color(color_val)
        translate([center[0], center[1], 0]) {
            rotate([0, 0, rotate ? 22.5 : 0]) circle(radius - spacing / 2, $fn = 8*order);
        }
    }
}

// Module to create octagons with optional color gradient
module octagonzzz(radius, spacing, levels, rotate=true, order=1, octagon_centers=undef, color_scheme=undef) {
    if (is_undef(octagon_centers)) {
        octagon_centers = calculate_octagon_centers(radius, spacing, levels, rotate, order);
    }

    // Determine the range of the center points for normalization
    min_x = min([for(center = octagon_centers) center[0]]);
    max_x = max([for(center = octagon_centers) center[0]]);
    min_y = min([for(center = octagon_centers) center[1]]);
    max_y = max([for(center = octagon_centers) center[1]]);

    for(center = octagon_centers) {
        normalized_x = (center[0] - min_x) / (max_x - min_x);
        normalized_y = (center[1] - min_y) / (max_y - min_y);

        color_val = get_gradient_color(normalized_x, normalized_y, color_scheme);

        // Apply color gradient only if color_scheme is specified
        if (!is_undef(color_scheme)) {
            color_val = [0, 0, 0];
        }

        color(color_val)
        translate([center[0], center[1], 0]) 
            rotate([0, 0, rotate ? 22.5 : 0]) circle(radius - spacing / 2, $fn = 8*order);
        
    }
}

// Function to get gradient color based on the color scheme
function get_gradient_color(normalized_x, normalized_y, color_scheme) = 
    color_scheme == "scheme1" ? [normalized_x, 1 - normalized_x, normalized_y] : // Red to Blue
    color_scheme == "scheme2" ? [1 - normalized_y, normalized_x, normalized_y] : // Green to Magenta
    color_scheme == "scheme3" ? [normalized_y, 1 - normalized_y, normalized_x] : // Blue to Yellow
    color_scheme == "scheme4" ? [1 - normalized_x, normalized_x, 1 - normalized_y] : // Cyan to Red
    color_scheme == "scheme5" ? [normalized_x, normalized_x * normalized_y, 1 - normalized_x] : // Purple to Green
    color_scheme == "scheme6" ? [1 - normalized_x * normalized_y, normalized_y, normalized_x] : // Orange to Blue
    [0, 0, 0]; // Default color (black) if no valid color scheme is provided


if (mode == 1) {
    centers = octagon_centers(radius=rad, spacing=space, levels=lvls, rotate=rotate);
    octagons(radius=rad, spacing=space, levels=lvls, rotate=rotate, octagon_centers=centers);
    print_points(centers, text_size=1, color="red"); // Add labels
} else if (mode == 2) {
    centers = octagon_centers(radius=rad, spacing=space, levels=lvls, rotate=rotate);
    filtered_centers = filter_octagon_centers(centers, filter_points_levels);
    octagons(radius=rad, spacing=space, levels=lvls, rotate=rotate, octagon_centers=filtered_centers);
    print_points(filtered_centers, text_size=1, color="red"); // Add labels for filtered centers
} else if (mode == 3) {
    centers_grid = octagon_centers(radius=rad, spacing=space, n=n, m=m, rotate=rotate);
    octagons(radius=rad, spacing=space, levels=undef, rotate=rotate, octagon_centers=centers_grid);
    print_points(centers_grid, text_size=1, color="red"); // Add labels for grid centers
} else if (mode == 4) {
    centers_grid = octagon_centers(radius=rad, spacing=space, n=n, m=m, rotate=rotate);
    filtered_centers_grid = filter_octagon_centers(centers_grid, filter_points_grid);
    //octagonsss(radius=rad, spacing=space, levels=undef, rotate=rotate, octagon_centers=filtered_centers_grid);
    octagonzzz(radius=rad, spacing=space, levels=undef, rotate=rotate, 
    octagon_centers=filtered_centers_grid, color_scheme="scheme2");
    print_points(filtered_centers_grid, text_size=1, color="red"); // Add labels for filtered grid centers
}