use <../../iLOX.scad>;

// ucell_derender = true;
ucell_render = is_undef(ucell_derender) ? true : false;

/*[ Parameters ]*/

// Define input dimensions for the unit cell
// Width of the unit cell in the x-direction
width_x = 5;
// Height of the unit cell in the y-direction
height_y = 10;

// Points are [x, y, tolerance], with the first as 0 for the minor (bottom) or 1 for the major (top) ucell division.
base_ucell_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Define a tolerance for the top face of the unit cell
ucell_top_face_tol = 0.01; // [0:0.001:0.05]

// Define points for a polygon to act as a negative to create voids within the cell, each point is defined as [x, y]
base_ucell_neg_poly_entry_corner_cut = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];

// Define points for a negative that removes a tolerance from the top edge of the cell where it will contact the
// substrate of the opposite cell
base_ucell_neg_poly_top_edge_tolerance =
    [ [ 0, 1 ], [ 1, 1 ], [ 1, 1 - ucell_top_face_tol ], [ 0, 1 - ucell_top_face_tol ] ];

// Combine all negative polygons into a single list
base_ucell_neg_polys = [ base_ucell_neg_poly_entry_corner_cut, base_ucell_neg_poly_top_edge_tolerance ];

/*[ Colors ]*/

// Define the color for the unit cells [base, cut]
base_ucell_colors = [ "MediumSlateBlue", "DarkSlateBlue" ];

// Define the color for the base unit cell points
base_ucell_point_color = ["PeachPuff"];

// Define color options for scaled unit cell rendering [ucell A, ucell B, ucell A negative, ucell B negative]
base_scaled_ucell_colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ];

// Define color options for scaled unit cell points [ucell A, ucell B]
base_scaled_ucell_point_colors = [ "Indigo", "Orange" ];

// Calculate cells (A and B) using the defined dimensions and division points
base_ucell_cells =
    calc_ucell(width = width_x, height = height_y, div = base_ucell_div, neg_poly = base_ucell_neg_polys);

// Make sure to view from the top!!!
if (ucell_render)
{
    // Base unit cell
    color(base_ucell_colors[0]) square([ 1, 1 ]);
    place_spheres(points = base_ucell_div, d = 0.04, color = base_ucell_point_color[0], zGap = 0.5, fn = 12);

    translate([ 2, 0, 0 ]) color(base_ucell_colors[1]) resize([ 1, 1, 1 ]) render_ucells(cells = base_ucell_cells);

    translate([ -width_x - 1, 0, 0 ])
    { // Render the entire unit cell with both the division and negative polygons
        render_ucells(cells = base_ucell_cells, colors = base_scaled_ucell_colors);

        // Place spheres at the points of cell A (division points)
        place_spheres(points = base_ucell_cells[0], d = 0.1, color = base_scaled_ucell_point_colors[0], zGap = 0.5,
                      fn = 12);

        // Place spheres at the points of cell B (division points)
        place_spheres(points = base_ucell_cells[1], d = 0.1, color = base_scaled_ucell_point_colors[1], zGap = 0.5,
                      fn = 12);
    }
}