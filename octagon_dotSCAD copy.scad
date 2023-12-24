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


// Function to calculate octagon centers
function calculate_octagon_centers(radius, spacing, levels, rotate=true, order=1) = 
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
        center_offset = (offset - offset * levels),

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

// Example usage of the octagons module without pre-calculated centers
//octagons(radius = 10, spacing = 0.5, levels = 5, rotate=true, order=1);

// Example usage with pre-calculated centers
centers = calculate_octagon_centers(radius = 10, spacing = 0.5, levels = 5, rotate=true, order=1);
octagons(radius = 10, spacing = 0.5, levels = 5, rotate=true, order=1,octagon_centers=centers);

// Displaying the octagon centers for verification
echo("Octagon centers: ", centers);
