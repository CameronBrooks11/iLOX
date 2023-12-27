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
function points_equal(p1, p2, tolerance=1e-4) =
    let(
        comparisons = [for(i = [0:len(p1)-1]) abs(p1[i] - p2[i]) < tolerance]
    )
    len([for(comp = comparisons) if (comp) true]) == len(comparisons);

// Function to check if any point in a list equals the given point
function is_point_in_list(point, list, tolerance=1e-4) =
    let(
        equal_points = [for(p = list) points_equal(p, point, tolerance)]
    )
    len([for(eq = equal_points) if (eq) true]) > 0;

// Function to filter out certain octagon centers
function filter_octagon_centers(centers, filter_list, tolerance=1e-4) =
    [for(center = centers) if (!is_point_in_list(center, filter_list, tolerance)) center];


// Function to calculate octagon centers
function calculate_octagon_centers_levels(radius, spacing, levels=1, rotate=true) = 
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

// Function to calculate octagon centers in a grid pattern
function calculate_octagon_centers_grid(radius, spacing, n, m, rotate=true) =
    let(
        side_length = (radius * 2) / (sqrt(4+2*sqrt(2))),
        segment_length = side_length / sqrt(2),
        total_width = side_length*(1+sqrt(2)),
        tip = rotate ? segment_length : (side_length / 2) * sqrt(2 - sqrt(2)) * 2,
        shift = rotate ? total_width : radius * 2,
        offset_step = rotate ? total_width : shift,
        grid_points = [for(i = [0:n-1], j = [0:m-1])
            let(
                offset_x = i * offset_step,
                offset_y = j * offset_step
            )
            [offset_x, offset_y]]
    )
    grid_points;

    
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

// Example usage with pre-calculated centers in a grid pattern
// rad = 10;
// space = 0;
// n = 6;
// m = 6;
// rot = false;
// centers_grid = calculate_octagon_centers_grid(radius=rad, spacing=space, n=n, m=m, rotate=rot);
// filter_list = [[0, 0]]; // Filtering out the center at [0, 0]
// filtered_centers_grid = filter_octagon_centers(centers_grid, filter_list);
// octagons(radius = rad, spacing = space, levels = undef, rotate=rot, order=1, octagon_centers=filtered_centers_grid);

// Example usage of the octagons module with levels (commented out)
// centers_levels = calculate_octagon_centers_levels(radius=rad, spacing=space, levels=lvls, rotate=rot);
// filtered_centers_levels = filter_octagon_centers(centers_levels, filter_list);
// octagons(radius = rad, spacing = space, levels = lvls, rotate=rot, order=1, octagon_centers=filtered_centers_levels);

// Displaying the octagon centers for verification
// echo("Octagon centers with levels: ", centers_levels);
// echo("Filtered Octagon centers with levels: ", filtered_centers_levels);
// echo("Octagon centers with grid: ", centers_grid);
// echo("Filtered Octagon centers with grid: ", filtered_centers_grid);