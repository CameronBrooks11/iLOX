// Function to check if two points are equal within a tolerance
function points_equal(p1, p2, tolerance=1e-4) =
    let(
        comparisons = [for(i = [0:len(p1)-1]) abs(p1[i] - p2[i]) < tolerance]
    )
    // Manually check if all comparisons are true
    len([for(comp = comparisons) if (comp) true]) == len(comparisons);

// Function to check if any point in a list equals the given point
function is_point_in_list(point, list, tolerance=1e-4) =
    let(
        equal_points = [for(p = list) points_equal(p, point, tolerance)]
    )
    len([for(eq = equal_points) if (eq) true]) > 0;

// Function to filter out certain hexagon centers
function filter_hexagon_centers(centers, filter_list, tolerance=1e-4) =
    [for(center = centers) if (!is_point_in_list(center, filter_list, tolerance)) center];

// Function to calculate hexagon centers
function calculate_hexagon_centers_levels(radius, spacing, levels, n=undef, m=undef) =
    let(
        offset_x = radius * cos(30),
        offset_y = radius + radius * sin(30),
        offset_step = 2 * offset_x,
        generate_rectangular_points = function(n, m, offset_step, offset_y) 
            [for(i = [0:n-1], j = [0:m-1]) 
                [i * offset_step + (j % 2) * (offset_step / 2), j * offset_y]],

        hexagons_pts = function(hex_datum) 
            let(
                tx = hex_datum[0][0],
                ty = hex_datum[0][1],
                n_pts = hex_datum[1],
                offset_xs = [for(i = 0; i < n_pts; i = i + 1) i * offset_step]
            )
            [for(x = offset_xs) [x + tx, ty]]
    )
    (!is_undef(n) && !is_undef(m)) ?
        generate_rectangular_points(n, m, offset_step, offset_y) : 
        let(
            beginning_n = 2 * levels - 1,
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
            total_hex_data = [[[0, 0], beginning_n], each upper_hex_data, each lower_hex_data]
        )
        let(
            centers = [for(hex_datum = total_hex_data)
                let(pts = hexagons_pts(hex_datum))
                [for(pt = pts) pt]
            ]
        ) concat([for(c = centers) each c]);


// Function to calculate hexagon centers in a grid pattern
function calculate_hexagon_centers_grid(radius, spacing, n, m) =
    let(
        offset_x = radius * cos(30),
        offset_y = radius + radius * sin(30),
        offset_step_x = 2 * offset_x,
        offset_step_y = offset_y
    )
    [for(i = [0:n-1], j = [0:m-1]) 
        [i * offset_step_x + (j % 2) * (offset_step_x / 2), j * offset_step_y]];

// Module to create hexagons
module hexagons(radius, spacing, levels=undef, hexagon_centers=[]) {
    r_hexagon = radius - spacing / 2;

    module hexagon() {
        rotate(30) circle(r_hexagon, $fn = 6);     
    }

    if (len(hexagon_centers) == 0 && !is_undef(levels)) {
        hexagon_centers = calculate_hexagon_centers_levels(radius, spacing, levels);
    } else if (len(hexagon_centers) == 0) {
        echo("No hexagon centers provided and 'levels' is undefined.");
    }

    for(center = hexagon_centers) {
        translate([center[0], center[1], 0]) hexagon();
    }
}

// Example usage of the hexagons module with levels
rad = 10;
space = 1;
lvls = 5;
// centers_levels = calculate_hexagon_centers_levels(radius=rad, spacing=space, levels=lvls);
// filtered_centers_levels = filter_hexagon_centers(centers_levels, [[0, 0]]);
// hexagons(radius=rad, spacing=space, levels=lvls, hexagon_centers=filtered_centers_levels);

// Example usage of the hexagons module with n x m grid placement
n = 6;
m = 6;
centers_grid = calculate_hexagon_centers_grid(radius=rad, spacing=space, n=n, m=m);
filtered_centers_grid = filter_hexagon_centers(centers_grid, [[0, 0]]);
hexagons(radius=rad, spacing=space, hexagon_centers=filtered_centers_grid);

// Displaying the hexagon centers for verification
// echo("Filtered Hexagon centers with levels: ", filtered_centers_levels);
echo("Filtered Hexagon centers with n x m grid: ", filtered_centers_grid);