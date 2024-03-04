/*
 * Title: Octagon Pattern Generator
 * Author: Cameron K. Brooks
 * Organization: FAST Research
 * 
 * License: LGPL 3.0 or later
 *
 * Description:
 *   This OpenSCAD script, named 'octagons.scad', generates patterns of octagons. 
 *   It provides functionality to create both grid-based and level-based octagon layouts.
 *   Users can specify various parameters such as radius, levels, spacing, and rotation
 *   to customize the octagon pattern. Additionally, a color gradient can be applied to the octagons.
 *
 * Dependencies:
 *   utils_viz.scad - Visualisation utilities
 *   utils_points.scad - Point calculation utilities
 *
 * Usage Notes:
 *   To use this script, include it in your OpenSCAD project. Customize the octagon pattern 
 *   by modifying the parameters of the 'octagons' module or the 'octagon_centers' function.
 *   Ensure that 'utils_viz.scad' and 'utils_points.scad' are in the same directory or adjust the import paths.
 *
 * Parameters:
 *   radius - Radius of the octagons.
 *   levels - Number of levels in the pattern.
 *   spacing - Spacing between each octagon.
 *   rotate - Boolean value to rotate octagons.
 *   order - Determines the fineness of the circle approximation for octagons.
 *   color_scheme - Array defining color gradient.
 *   alpha - Alpha value for color transparency.
 *
 * Revision History:
 *   2024-01-07 - Initial version inspired by Justin Lin's hexagon module (2017).
 *   [YYYY-MM-DD] - Subsequent updates with details.
 */


use <utils_viz.scad>;
use <utils_points.scad>;


    
// Function to calculate octagon centers for both levels and grid
function octagon_centers(radius, levels, spacing=undef, n=undef, m=undef, rotate=true) =
    let(
        side_length = (radius * 2) / (sqrt(4 + 2 * sqrt(2))),
        segment_length = side_length / sqrt(2),
        total_width = side_length * (1 + sqrt(2)),
        tip = rotate ? segment_length : (side_length / 2) * sqrt(2 - sqrt(2)) * 2,
        shift = rotate ? total_width : radius * 2,
        offset = shift - tip,
        
        // Function for generating grid points
        generate_grid_points = function(n, m, step) 
            [for(i = [0:n-1], j = [0:m-1]) [i * step, j * step]],

        // Function for generating points based on levels
        generate_level_points = function(levels, step, center_offset, beginning_n) 
            let(
                upper_points = [for(i = [1:levels * 2]) 
                    let(n = beginning_n - i) 
                    [for(j = [0:n-1]) [(i + j) * step + center_offset, i * step]]
                ],
                lower_points = [for(pts = upper_points) [for(pt = pts) [pt[0], -pt[1]]]]
            )
            concat(upper_points, lower_points)
    )
    // Determine which pattern to use
    (!is_undef(n) && !is_undef(m)) ?
        generate_grid_points(n, m, total_width) :
        let(
            beginning_n = 2 * levels - 1,
            center_offset = -(offset * (levels - 1))
        )
        generate_level_points(levels, offset, center_offset, beginning_n);


// Module to create octagons with optional color gradient
module octagons(radius,levels,  spacing=0, rotate=true, order=1, octagon_centers=undef, color_scheme=undef, alpha=undef) {
    if (is_undef(octagon_centers)) {
        octagon_centers = calculate_octagon_centers(radius, levels, spacing, rotate, order);
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

