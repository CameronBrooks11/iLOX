/**
* hexagons.scad
*
* Modifications made by Cameron K. Brooks, 2024
*
* Original version:
* Copyright Justin Lin, 2017
* License: https://opensource.org/licenses/lgpl-3.0.html
*
* See original version at: https://openhome.cc/eGossip/OpenSCAD/lib3x-hexagons.html
*
**/

// Function to calculate hexagon centers
function calculate_hexagon_centers(radius, spacing, levels, n=undef, m=undef) = 
    let(
        beginning_n = 2 * levels - 1,
        offset_x = radius * cos(30),
        offset_y = radius + radius * sin(30),
        offset_step = 2 * offset_x,
        center_offset = 2 * (offset_x - offset_x * levels),

        hexagons_pts = function(hex_datum) 
            let(
                tx = hex_datum[0][0],
                ty = hex_datum[0][1],
                n = hex_datum[1],
                offset_xs = [for(i = 0; i < n; i = i + 1) i * offset_step + center_offset]
            )
            [for(x = offset_xs) [x + tx, ty]],

        upper_hex_data = levels > 1 ? 
            [for(i = [1:beginning_n - levels])
                let(
                    x = offset_x * i,
                    y = offset_y * i,
                    n = beginning_n - i
                ) [[x, y], n]
            ] : [],

        lower_hex_data = levels > 1 ? 
            [for(hex_datum = upper_hex_data)
                [[hex_datum[0][0], -hex_datum[0][1]], hex_datum[1]]
            ] : [],

        total_hex_data = [[[0, 0], beginning_n], each upper_hex_data, each lower_hex_data],

        local_hexagon_centers = []
    )
    let(
        centers = [for(hex_datum = total_hex_data)
            let(pts = hexagons_pts(hex_datum))
            [for(pt = pts) pt]
        ]
    ) concat([for(c = centers) each c]);

// Module to create hexagons
module hexagons(radius, spacing, levels, hexagon_centers=[]) {
    r_hexagon = radius - spacing / 2;

    module hexagon() {
        rotate(30) 
            circle(r_hexagon, $fn = 6);     
    }

    if (len(hexagon_centers) == 0) {
        hexagon_centers = calculate_hexagon_centers(radius, spacing, levels);
    }

    for(center = hexagon_centers) {
        translate([center[0], center[1], 0]) 
            hexagon();
    }
}

// Example usage of the hexagons module without pre-calculated centers
//hexagons(radius=10, spacing=1, levels=5);

// Example usage with pre-calculated centers
rad = 10;
space = 1;
lvls = 5;
centers = hexagons_centers(radius=rad, spacing=space, levels=lvls);
hexagons(radius=rad, spacing=space, hexagon_centers=centers);

// Displaying the hexagon centers for verification
echo("Hexagon centers: ", centers); 