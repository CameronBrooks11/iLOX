use <../src/utils.scad>;

// Define input variables
width_x = 5;
height_y = 10;

// Division points array
// Each point is defined as [x, y, tolerance]
// must form a division line <= 0.5*height_y
example_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

example_radius = max_x(example_div, width_x); // this is without tolerance

// Negative polygon points array
// Each point is defined as [x, y]
example_neg_poly = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];

// Color options
example_colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ];

use <../src/ucell.scad>;

// Calculate cells using the defined variables
example_cells = calc_ucells(width = width_x, height = height_y, div = example_div, neg_poly = example_neg_poly);

rotate([ 90, 0, 0 ])
{
    // Render the cells with the calculated points and specified colors
    // render_ucells(cells=example_cells, colors=example_colors);

    // Render only the division polygons (without the negative polygons)
    render_ucells(cells = [ example_cells[0], example_cells[1], [], [] ], colors = example_colors);

    // Render only the anti-cell portion
    render_ucells(cells = [ [], [], example_cells[2], example_cells[3] ], colors = example_colors);

    // Place spheres at the division points
    place_spheres(points = example_cells[0], d = 0.05, color = "Indigo", fn = 12);
    place_spheres(points = example_cells[1], d = 0.05, color = "Violet", fn = 12);
}

use <../src/cell2polar.scad>;

degree_n = 6;

translate([ width_x * 2, height_y / 2, 0 ])
    cells2polarpos(cells = example_cells, n = degree_n, radius = example_radius);

example_translation = example_radius * 2 - radius_apothem_diff(example_radius, degree_n) * 2;

translate([ width_x * 5, height_y / 2, 0 ])
{
    cellA2polar(cells = example_cells, n = degree_n, radius = example_radius, color = "LightGreen");
    translate([ example_translation, 0, 0 ])
        cellB2polar(cells = example_cells, n = degree_n, radius = example_radius, color = "LightBlue");
    translate([
        -(example_translation)*sin(half_central_angle(degree_n)),
        -(example_translation)*cos(half_central_angle(degree_n)), 0
    ]) rotate([ 0, 0, central_angle(degree_n) ])
        cellB2polar(cells = example_cells, n = degree_n, radius = example_radius, color = "LightBlue");

    translate([
        -(example_translation)*sin(half_central_angle(degree_n)),
        (example_translation)*cos(half_central_angle(degree_n)), 0
    ]) rotate([ 0, 0, central_angle(degree_n) ])
        cellB2polar(cells = example_cells, n = degree_n, radius = example_radius, color = "LightBlue");
}

// Define the example positions for one A cell and three B cells
positions_A = [
    [0, 0]
];

positions_B = [
    [example_translation, 0],
    [
        -example_translation * sin(half_central_angle(degree_n)),
        -example_translation * cos(half_central_angle(degree_n))
    ],
    [
        -example_translation * sin(half_central_angle(degree_n)),
        example_translation * cos(half_central_angle(degree_n))
    ]
];

// Apply translation and place the cells
translate([width_x * 8, height_y / 2, 0]) {
    // Place cell A at the specified position
    place_polar_cells(cells = example_cells, positions = positions_A, n = degree_n, radius = example_radius, cell_type="A", color="OliveDrab");

    // Place cell B at the specified positions
    place_polar_cells(cells = example_cells, positions = positions_B, n = degree_n, radius = example_radius, cell_type="B", color="CadetBlue");
}


use <../src/tess.scad>;

tess_points = hexagon_centers_lvls(example_radius*2*sqrt(3), 4);

// Apply translation and place the cells
translate([-width_x * 11, height_y / 2, 0]) {
    // Place cell A at the specified position
    place_polar_cells(cells = example_cells, positions = tess_points, n = degree_n, radius = example_radius, cell_type="A", color="OliveDrab");

    // Place cell B at the specified positions
    //place_polar_cells(cells = example_cells, positions = positions_B, n = degree_n, radius = example_radius, cell_type="B", color="CadetBlue");
}
