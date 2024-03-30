
/*
 * Title: Hexagon Pattern Generator
 * Author: [Your Name]
 * Organization: [Your Organization]
 * 
 * License: [Specify License]
 *
 * Description:
 *   This OpenSCAD script, named 'hexagons.scad', is designed to generate patterns 
 *   consisting of hexagons. The script provides functionality for creating hexagon 
 *   patterns in either a grid or a level-based arrangement. Users can specify 
 *   parameters such as radius, levels, and spacing to tailor the hexagon pattern to their needs.
 *   Additionally, an optional color gradient can be applied to the hexagons.
 *
 * Dependencies:
 *   utils_viz.scad - Used for visualization utilities.
 *   utils_points.scad - Utilized for point calculation utilities.
 *
 * Usage Notes:
 *   To utilize this script, include it in your OpenSCAD project. You can customize 
 *   the hexagon pattern by adjusting the parameters in the 'hexagons' module or 
 *   the 'hexagon_centers' function. Ensure that the 'utils_viz.scad' and 
 *   'utils_points.scad' files are located in the same directory or modify the import paths accordingly.
 *
 * Parameters:
 *   radius - Specifies the radius of the hexagons.
 *   levels - Determines the number of levels in the pattern.
 *   spacing - Sets the spacing between individual hexagons.
 *   hexagon_centers - An array of points defining the centers of the hexagons.
 *   color_scheme - An array defining the color gradient.
 *   alpha - The alpha value for color transparency.
 *
 * Revision History:
 *   [YYYY-MM-DD] - Initial version.
 *   [YYYY-MM-DD] - Subsequent updates with details.
 */


use <utils_viz.scad>;
use <utils_points.scad>;


function hexagon_centers_lvls(radius, levels) = 
    let( 
        offset_x = radius * cos(30),
        offset_y = radius + radius * sin(30),
        offset_step = 2 * offset_x,
        dx = -(levels - 1) * offset_x * 2,  //center x shift
        dy = 0,    //center y shift; illustrative, not req due to nature of generation algo
        beginning_n = 2 * levels - 1,

        hexagons_pts = function(hex_datum) 
            let(
                tx = hex_datum[0][0] + dx,
                ty = hex_datum[0][1] + dy,
                n_pts = hex_datum[1],
                offset_xs = [for(i = 0; i < n_pts; i = i + 1) i * offset_step]
            )
            [for(x = offset_xs) [x + tx, ty]],

        upper_hex_data = levels > 1 ? 
            [for(i = [1:beginning_n - levels])
                let(
                    x = offset_x * i,
                    y = offset_y * i,
                    n_upper = beginning_n - i
                ) [[x, y], n_upper]
            ] : [],
        lower_hex_data = levels > 1 ? 
            [for(hex_datum = upper_hex_data)
                [[hex_datum[0][0], -hex_datum[0][1]], hex_datum[1]]
            ] : [],
        total_hex_data = [[[0, 0], beginning_n], each upper_hex_data, each lower_hex_data],
        centers = [for(hex_datum = total_hex_data)
            let(pts = hexagons_pts(hex_datum))
            [for(pt = pts) pt]
        ]
    ) concat([for(c = centers) each c]);

function hexagon_centers_NxM(radius, n, m) = 
    let( 
        offset_x = radius * cos(30),
        offset_y = radius + radius * sin(30),
        levels = is_undef(levels) ? 0 : levels,
        offset_step = 2 * offset_x,
        generate_rectangular_points = function(n, m, offset_step, offset_y) 
        [for(i = [0:n-1], j = [0:m-1]) 
            [i * offset_step + (j % 2) * (offset_step / 2), j * offset_y]]
    ) generate_rectangular_points(n, m, offset_step, offset_y);


function octagon_centers_grid(radius, n, m, rotate=true) =
    let(
        side_length = (radius * 2) / (sqrt(4 + 2 * sqrt(2))),
        segment_length = side_length / sqrt(2),
        total_width = side_length * (1 + sqrt(2)),
        tip = rotate ? segment_length : (side_length / 2) * sqrt(2 - sqrt(2)) * 2,
        shift = rotate ? total_width : radius * 2,
        offset = shift - tip,
        
        // Function for generating grid points
        generate_grid_points = function(n, m, step) 
            [for(i = [0:n-1], j = [0:m-1]) [i * step, j * step]]
    )
    generate_grid_points(n, m, total_width);


// Module to create hexagons with optional color gradient
module hexagons(radius, spacing=0, hexagon_centers=[], levels=undef, n=undef, m=undef, color_scheme=undef, alpha=undef) {
    if (len(hexagon_centers) == 0 && !is_undef(levels)) {
        hexagon_centers = hexagon_centers_lvls(radius, levels, spacing);
    } else if (len(hexagon_centers) == 0 && !is_undef(n) && !is_undef(m)) {
        hexagon_centers = hexagon_centers_NxM(radius, n, m);
    } else if (len(hexagon_centers) == 0) {
        echo("No hexagon centers provided and 'levels' is undefined.");
    } 


    // Determine the range of the center points for normalization
    min_x = min([for(center = hexagon_centers) center[0]]);
    max_x = max([for(center = hexagon_centers) center[0]]);
    min_y = min([for(center = hexagon_centers) center[1]]);
    max_y = max([for(center = hexagon_centers) center[1]]);

    for(center = hexagon_centers) {
        normalized_x = (center[0] - min_x) / (max_x - min_x);
        normalized_y = (center[1] - min_y) / (max_y - min_y);

        color_val = get_gradient_color(normalized_x, normalized_y, color_scheme);

        // Apply color gradient only if color_scheme is specified
        if (!is_undef(color_scheme)) {
            color_val = [.9, .9, .9];
        }

        color(color_val, alpha=alpha)
        translate([center[0], center[1], 0]) {
            rotate(30) circle(radius - spacing / 2, $fn = 6);
        }
    }
}

// Module to create hexagons solid with optional color gradient
module hexagonsSolid(radius, height, spacing=0, hexagon_centers=[], levels=undef, n=undef, m=undef, color_scheme=undef, alpha=undef) {
    if (len(hexagon_centers) == 0 && !is_undef(levels)) {
        hexagon_centers = hexagon_centers_lvls(radius, levels, spacing);
    } else if (len(hexagon_centers) == 0 && !is_undef(n) && !is_undef(m)) {
        hexagon_centers = hexagon_centers_NxM(radius, n, m);
    } else if (len(hexagon_centers) == 0) {
        echo("No hexagon centers provided and 'levels' is undefined.");
    }

    // Determine the range of the center points for normalization
    min_x = min([for(center = hexagon_centers) center[0]]);
    max_x = max([for(center = hexagon_centers) center[0]]);
    min_y = min([for(center = hexagon_centers) center[1]]);
    max_y = max([for(center = hexagon_centers) center[1]]);

    for(center = hexagon_centers) {
        normalized_x = (center[0] - min_x) / (max_x - min_x);
        normalized_y = (center[1] - min_y) / (max_y - min_y);

        color_val = get_gradient_color(normalized_x, normalized_y, color_scheme);

        // Apply color gradient only if color_scheme is specified
        if (!is_undef(color_scheme)) {
            color_val = [0.9, 0.9, 0.9];
        }

        color(color_val, alpha=alpha)
        translate([center[0], center[1], 0]) {
            linear_extrude(height = height, center = false, convexity = 10, twist = 0, slices = 20, scale = 1.0) 
            rotate(30) circle(radius - spacing / 2, $fn = 6);
        }
    }
}


// Module to create octagons with optional color gradient
module octagons(radius, spacing=0, octagon_centers=[], n=undef, m=undef, rotate=true, order=1, color_scheme=undef, alpha=undef) {
    if (is_undef(octagon_centers) && !is_undef(n) && !is_undef(m)) {
        octagon_centers = octagon_centers_grid(radius, n, m, rotate);
    } else if (is_undef(octagon_centers)) {
        echo("No octagon centers provided and 'n' or 'm' is undefined.");
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
            color_val = [0.9, 0.9, 0.9];
        }

        color(color_val, alpha = alpha)
        translate([center[0], center[1], 0]) 
            rotate([0, 0, rotate ? 22.5 : 0]) circle(radius - spacing / 2, $fn = 8*order);
        
    }
}

module octagonsSolid(radius, height, spacing=0, octagon_centers=[], n=undef, m=undef, rotate=true, order=1, color_scheme=undef, alpha=undef) {
    if (is_undef(octagon_centers) && !is_undef(n) && !is_undef(m)) {
        octagon_centers = octagon_centers_grid(radius, n, m, rotate);
    } else if (is_undef(octagon_centers)) {
        echo("No octagon centers provided and 'n' or 'm' is undefined.");
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
            color_val = [0.9, 0.9, 0.9];
        }

        color(color_val, alpha = alpha)
        translate([center[0], center[1], 0]) 
            rotate([0, 0, rotate ? 22.5 : 0]) linear_extrude(height = height, center = false, convexity = 10, twist = 0, slices = 20, scale = 1.0) circle(radius - spacing / 2, $fn = 8*order);
        
    }
}