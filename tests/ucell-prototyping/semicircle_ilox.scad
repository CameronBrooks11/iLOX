use <../../iLOX.scad>; // Utility functions for point operations

inputdiv_render = true;     ///< Flag to render the input division points or omit them
inputnegpoly_render = true; ///< Flag to render the input negative polygon points or omit them
ucell_render = true;       ///< Flag to render the unit cells or omit them
ucell_points = true;       ///< Flag to render the division points or omit them

// Define input dimensions for the unit cell
width_x = 10;  ///< Width of the unit cell in the x-direction
height_y = 10; ///< Height of the unit cell in the y-direction

// Variables for arc parameters
arc_diameter = 0.5;
arc_start_angle = 90;
arc_end_angle = -90;
arc_num_points = 15;
arc_tolerance = 0.01;

// Generate the arc points
arc_points_list = arc_points(diameter = arc_diameter, start_angle = arc_start_angle, end_angle = arc_end_angle,
                             num_points = arc_num_points, z_val = arc_tolerance);

arc_shift_x = 0.5;
arc_shift_y = 0.5;

shifted_arc_points_list =
    shift_points(points = arc_points_list, shift_x = arc_shift_x, shift_y = arc_shift_y + arc_diameter / 2);

// Echo the resulting arc points
echo("shifted arc points:", shifted_arc_points_list);

transformed_arc_points_list = transformPoints(shifted_arc_points_list, width_x, height_y);

// Define division points for creating the cell's internal structure
// Each point is defined as [x, y, tolerance]
// Must form a division line
// First point must start with 0 if defining the minor half of the ucell division
// First point must start with 1 if defining the major half of the ucell division
// example_div = [ [ 1 - 0.3, 1 - 0, 0.01 ], [ 1 - 0.3, 1 - 0.4, 0.01 ] ];
example_div = shifted_arc_points_list;

if (inputdiv_render)
{
    // Place spheres at the generated arc points
    place_spheres(points = example_div,
                  d = 0.01,       // Diameter of each sphere
                  color = "Blue", // Color of the spheres
                  fn = 12         // Number of facets for sphere smoothness
    );
    translate([ 0, 0, -1 ]) scale([ 1, width_x / height_y, 1 ]) cube([ 1, 1, 1 ]);
}

// Define negative polygon points to create voids within the cell
// Each point is defined as [x, y]
example_neg_poly = [];

if (inputnegpoly_render)
{
    // Place spheres at the generated arc points
    place_spheres(points = example_neg_poly,
                  d = 0.05,      // Diameter of each sphere
                  color = "Red", // Color of the spheres
                  fn = 12        // Number of facets for sphere smoothness
    );
}

// Define color options for rendering
example_colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ];

// Calculate cells (A and B) using the defined dimensions and division points
example_cells = calc_ucells(width = width_x, height = height_y, div = example_div, neg_poly = example_neg_poly);

echo("example_cells: ", example_cells);

// Rotate the entire scene for better visualization
// rotate([ 90, 0, 0 ])
translate([ width_x / 2, 0, 0 ])
{
    if (ucell_render)
    {
        // Render only the division polygons (cells A and B without the negative polygons)
        render_ucells(cells = [ example_cells[0], example_cells[1], [], [] ], colors = example_colors);

        // Render only the negative (anti-cell) portions separately
        render_ucells(cells = [ [], [], example_cells[2], example_cells[3] ], colors = example_colors);
    }
    if (ucell_points)
    {
        // Place spheres at the points of cell A (division points)
        place_spheres(points = example_cells[0], d = 0.05, color = "Indigo", fn = 12);

        // Place spheres at the points of cell B (division points)
        place_spheres(points = example_cells[1], d = 0.05, color = "Violet", fn = 12);
    }
}

degree_n = 6; ///< Number of sides for the rotational symmetry (e.g., 6 for hexagonal)

// Calculate the diameter based on the apothem of the polygon
ago_dia = apothem(width_x / 2, degree_n) * 2;

// Define positions for placing one cell A and three cell B instances
positions_A = [[ 0, 0 ]]; ///< Position for cell A

positions_B = [  ///< Positions for cell B instances
    [ago_dia, 0],
    [
        -ago_dia * sin(half_central_angle(degree_n)),
        -ago_dia * cos(half_central_angle(degree_n))
    ],
    [
        -ago_dia * sin(half_central_angle(degree_n)),
        ago_dia * cos(half_central_angle(degree_n))
    ]
];

// Translate and rotate to position the cells correctly
translate([ width_x * 3, 0, 0 ])
{
    // Place cell A at the specified position
    place_rot_cells(cells = example_cells, positions = positions_A, n = degree_n, width = width_x, cell_type = "A",
                      color = "OliveDrab");

    // Place cell B instances at the specified positions
    place_rot_cells(cells = example_cells, positions = positions_B, n = degree_n, width = width_x, cell_type = "B",
                      color = "CadetBlue");
}

// Translate and rotate to position the cells correctly
translate([ -width_x * 3, 0, 0 ])
{
    // Place cell A at the specified position
    place_rot_cells(cells = example_cells, positions = positions_A, n = 4, width = width_x, cell_type = "A",
                      color = "OliveDrab");
}