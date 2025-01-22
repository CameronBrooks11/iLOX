use <../../iLOX.scad>;

div_pts_dia = 0.01;

inputdiv_render = true;       // Flag to render the input division points or omit them
scaledinputdiv_render = true; // Flag to render the scaled input division points or omit them
inputnegpoly_render = true;   // Flag to render the input negative polygon points or omit them

// Define input dimensions for the unit cell
width_x = 10; // Width of the unit cell in the x-direction
height_y = 8; // Height of the unit cell in the y-direction

// Variables for arc parameters
arc1_diameter = 0.2;
arc1_start_angle = 90;
arc1_end_angle = 0;
arc1_num_points = 15;
arc1_tolerance = 0.01;

// Generate the arc points
arc1_points_list = arc_points(diameter = arc1_diameter, start_angle = arc1_start_angle, end_angle = arc1_end_angle,
                              num_points = arc1_num_points, z_val = arc1_tolerance);

arc1_shift_x = 0.5;
arc1_shift_y = 1 - arc1_diameter;

shifted_arc1_points_list =
    shift_points(points = arc1_points_list, shift_x = arc1_shift_x, shift_y = arc1_shift_y + arc1_diameter / 2);

// Echo the resulting arc points
echo("shifted arc points:", shifted_arc1_points_list);

arc2_diameter = arc1_diameter;
arc2_start_angle = 0;
arc2_end_angle = -90;
arc2_num_points = arc1_num_points;
arc2_tolerance = arc1_tolerance;

// Generate the arc points
arc2_points_list = arc_points(diameter = arc2_diameter, start_angle = arc2_start_angle, end_angle = arc2_end_angle,
                              num_points = arc2_num_points, z_val = arc2_tolerance);
gap = 0.1;
arc2_shift_x = arc1_shift_x;
arc2_shift_y = arc1_shift_y - gap;

shifted_arc2_points_list =
    shift_points(points = arc2_points_list, shift_x = arc2_shift_x, shift_y = arc2_shift_y + arc2_diameter / 2);

// Echo the resulting arc points
echo("shifted arc points:", shifted_arc2_points_list);

// Concatenate the two arc points lists
shifted_arc_points_list = concat(shifted_arc1_points_list, shifted_arc2_points_list);

stem_pts = [ [ 0.2, 0.7, arc1_tolerance ], [ 0.2, 0.6, arc1_tolerance ] ];

input_pts = concat(shifted_arc_points_list, stem_pts);

if (inputdiv_render)
{
    // Place spheres at the generated arc points
    place_spheres(points = input_pts,
                  d = div_pts_dia, // Diameter of each sphere
                  color = "Pink",  // Color of the spheres
                  fn = 12          // Number of facets for sphere smoothness
    );
    cube([ 1, 1, div_pts_dia / 2 ]);
}

// transformed_arc1_points_list = transformPoints(shifted_arc1_points_list, width_x, height_y);

scaled_arc_points_list =
    transformPoints(points = shifted_arc_points_list, width = width_x / width_x, height = height_y / width_x);

// Define division points for creating the cell's internal structure
// Each point is defined as [x, y, tolerance]
// Must form a division line
// First point must start with 0 if defining the minor half of the ucell division
// First point must start with 1 if defining the major half of the ucell division
// example_div = [ [ 1 - 0.3, 1 - 0, 0.01 ], [ 1 - 0.3, 1 - 0.4, 0.01 ] ];
translate([ 2, 0, 0 ]) if (scaledinputdiv_render)
{
    // Place spheres at the generated arc points
    place_spheres(points = scaled_arc_points_list,
                  d = div_pts_dia, // Diameter of each sphere
                  color = "Blue",  // Color of the spheres
                  fn = 12          // Number of facets for sphere smoothness
    );
    scale([ width_x / width_x, height_y / width_x, 1 ]) cube([ 1, 1, div_pts_dia / 2 ]);
}

example_div = input_pts;

// Define negative polygon points to create voids within the cell
// Each point is defined as [x, y]
add_neg_poly = [
    [ 0.2, 0 ],
    [ 1, 0 ],
    [ 1, 0.7 ],
];
example_neg_poly1 = shift_points(stem_pts, -arc1_tolerance, 0);
example_neg_poly2 = shift_points(add_neg_poly, -arc1_tolerance, 0);
example_neg_poly = [ example_neg_poly1, example_neg_poly2 ];

if (inputnegpoly_render)
{
    // Place spheres at the generated arc points
    place_spheres(points = example_neg_poly1,
                  d = div_pts_dia, // Diameter of each sphere
                  color = "Red",   // Color of the spheres
                  fn = 12          // Number of facets for sphere smoothness
    );
    place_spheres(points = example_neg_poly2,
                  d = div_pts_dia,   // Diameter of each sphere
                  color = "DarkRed", // Color of the spheres
                  fn = 12            // Number of facets for sphere smoothness
    );
}

ucell_render = true; // Flag to render the unit cells or omit them
ucell_points = true; // Flag to render the division points or omit them
tests_render = true; // Flag to render the test points or omit them

// Calculate cells (A and B) using the defined dimensions and division points
example_cells = (ucell_render || ucell_points)
                    ? calc_ucell(width = width_x, height = height_y, div = example_div, neg_poly = example_neg_poly)
                    : [];

echo("example_cells: ", example_cells);

// Rotate the entire scene for better visualization
// rotate([ 90, 0, 0 ])
translate([ width_x / 2, 0, 0 ])
{

    if (ucell_render)
    {
        // Render only the division polygons (cells A and B without the negative polygons)
        render_ucells(cells = [ example_cells[0], example_cells[1], [], [] ]);

        // Render only the negative (anti-cell) portions separately
        translate([ 0, 0, 0.1 ]) render_ucells(cells = [ [], [], example_cells[2], example_cells[3] ]);
    }
    if (ucell_points)
    {
        // Place spheres at the points of cell A (division points)
        place_spheres(points = example_cells[0], d = 0.05, color = "Indigo", fn = 12);

        // Place spheres at the points of cell B (division points)
        place_spheres(points = example_cells[1], d = 0.05, color = "Violet", fn = 12);
    }
}

if (tests_render)
{

    degree_n = 6; // Number of sides for the rotational symmetry (e.g., 6 for hexagonal)

    // Calculate the diameter based on the apothem of the polygon
    ago_dia = apothem(width_x / 2, degree_n) * 2;

    // Translate and rotate to position the cells correctly
    translate([ width_x * 3, 0, 0 ])
    {
        // Place cell A at the specified position
        place_rotated_cells(cells = example_cells, positions = [[ 0, 0 ]], n = 4, width = width_x, cell_type = "A",
                            color = "OliveDrab");
    }
}