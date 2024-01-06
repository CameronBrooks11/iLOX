// Function to check if two points are equal within a tolerance
function points_equal(p1, p2, tolerance=1e-3) =
    let(
        comparisons = [for(i = [0:len(p1)-1]) abs(p1[i] - p2[i]) < tolerance]
    )
    // Manually check if all comparisons are true
    len([for(comp = comparisons) if (comp) true]) == len(comparisons);

// Function to check if any point in a list equals the given point
function is_point_in_list(point, list, tolerance=1e-3) =
    let(
        equal_points = [for(p = list) points_equal(p, point, tolerance)]
    )
    len([for(eq = equal_points) if (eq) true]) > 0;

// Function to filter out certain hexagon centers
function filter_hexagon_centers(centers, filter_list, tolerance=1e-3) =
    [for(center = centers) if (!is_point_in_list(center, filter_list, tolerance)) center];


// Function to calculate hexagon centers
function hexagon_centers(radius, levels, spacing=undef, n=undef, m=undef) =
    let(
        offset_x = radius * cos(30),
        offset_y = radius + radius * sin(30),
        levels = is_undef(levels) ? 0 : levels,
        dx = -(levels - 1) * offset_x * 2,  //center x shift
        dy = 0,    //center y shift, not req due to nature of generation algo
        offset_step = 2 * offset_x,
        generate_rectangular_points = function(n, m, offset_step, offset_y) 
            [for(i = [0:n-1], j = [0:m-1]) 
                [i * offset_step + (j % 2) * (offset_step / 2), j * offset_y]],

        hexagons_pts = function(hex_datum) 
            let(
                tx = hex_datum[0][0] + dx,
                ty = hex_datum[0][1] + dy,
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


// Function to get gradient color based on the color scheme
function get_gradient_color(normalized_x, normalized_y, color_scheme) = 
    color_scheme == "scheme1" ? [normalized_x, 1 - normalized_x, normalized_y] : // Red to Blue
    color_scheme == "scheme2" ? [1 - normalized_y, normalized_x, normalized_y] : // Green to Magenta
    color_scheme == "scheme3" ? [normalized_y, 1 - normalized_y, normalized_x] : // Blue to Yellow
    color_scheme == "scheme4" ? [1 - normalized_x, normalized_x, 1 - normalized_y] : // Cyan to Red
    color_scheme == "scheme5" ? [normalized_x, normalized_x * normalized_y, 1 - normalized_x] : // Purple to Green
    color_scheme == "scheme6" ? [1 - normalized_x * normalized_y, normalized_y, normalized_x] : // Orange to Blue
    [0.9, 0.9, 0.9]; // Default color (black) if no valid color scheme is provided

// Module to create hexagons with optional color gradient
module hexagons(radius, levels=undef, spacing=0, hexagon_centers=[], color_scheme=undef, alpha=0.5) {
    if (len(hexagon_centers) == 0 && !is_undef(levels)) {
        hexagon_centers = hexagon_centers(radius, levels, spacing);
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


// Module to print points as text
module print_points(points, text_size=2, color=[0.1, 0.1, 0.1]) {
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
mode = 2; // Change this number to switch between different examples

rad = 10;
space = 1;
lvls = 5;

filter_points_levels = [
    [-34.641, 0], [-17.3205, 0], [0.0, 0], [17.3205, 0], [34.641, 0], 
    [-25.9807, 15], [-8.6602, 15], [8.6603, 15], [25.9808, 15], 
    [-17.3205, 30], [0.0, 30], [17.3205, 30], [-25.9807, -15], [-8.6602, -15], [8.6603, -15], 
    [25.9808, -15], [-17.3205, -30], [0.0, -30], [17.3205, -30]
];

n = 6;
m = 5;

filter_points_grid = [
    [95.2628, 15], [95.2628, 45], [43.3013, 45], 
    [51.9615, 60], [34.641, 60], [34.641, 0], 
    [51.9615, 0], [43.3013, 15]
];

if (mode == 1) {
    centers = hexagon_centers(radius=rad, spacing=space, levels=lvls);
    echo("Unfiltered Centers:", centers);
    hexagons(radius=rad, spacing=space, hexagon_centers=centers, color_scheme="scheme1");
    print_points(centers, text_size=1, color="Azure");
} else if (mode == 2) {
    centers = hexagon_centers(radius=rad, spacing=space, levels=lvls);
    filtered_centers = filter_hexagon_centers(centers, filter_points_levels);
    echo("Unfiltered Centers:", centers);
    echo("Filtered Centers:", filtered_centers);
    print_points(filtered_centers, text_size=1, color="Azure");
    hexagons(radius=rad, spacing=space, hexagon_centers=filtered_centers, color_scheme="scheme2");
} else if (mode == 3) {
    centers_grid = hexagon_centers(radius=rad, spacing=space, n=n, m=m);
    echo("Unfiltered Centers Grid:", centers_grid);
    hexagons(radius=rad, spacing=space, hexagon_centers=centers_grid, color_scheme="scheme3");
    print_points(centers_grid, text_size=1, color="Azure");
} else if (mode == 4) {
    centers_grid = hexagon_centers(radius=rad, spacing=space, n=n, m=m);
    filtered_centers_grid = filter_hexagon_centers(centers_grid, filter_points_grid);
    echo("Unfiltered Centers Grid:", centers_grid);
    echo("Filtered Centers Grid:", filtered_centers_grid);
    hexagons(radius=rad, spacing=space, hexagon_centers=filtered_centers_grid, color_scheme="scheme4");
    print_points(filtered_centers_grid, text_size=1, color="Azure");
}