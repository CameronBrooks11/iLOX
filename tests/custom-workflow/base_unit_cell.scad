use <../../iLOX.scad>;

// ucell_derender = true;
ucell_render = is_undef(ucell_derender) ? true : false;

// Define input dimensions for the unit cell
width_x = 5;   ///< Width of the unit cell in the x-direction
height_y = 10; ///< Height of the unit cell in the y-direction

// Each point is defined as [x, y, tolerance] and must form a division line
// First point must start with 0 if defining the minor (starting from bottom) half of the ucell division
// First point must start with 1 if defining the major (starting from top) half of the ucell division
base_ucell_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Define negative polygon points to create voids within the cell
// Each point is defined as [x, y]
base_ucell_neg_poly1 = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];
base_ucell_neg_poly2 = [ [ 0, 1 ], [ 0.5, 1 ], [ 1, 0.95 ], [ 0, 0.95 ] ];
// base_ucell_neg_poly3 = [ [ 0.7, 0.8 ], [ 0.7, 0.9 ], [ 0.6, 0.9 ], [ 0.6, 0.8 ] ];
base_ucell_neg_polys = [ base_ucell_neg_poly1, base_ucell_neg_poly2 ];

// Define color options for rendering
base_ucell_colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ];

// Calculate cells (A and B) using the defined dimensions and division points
base_ucell_cells =
    calc_ucell(width = width_x, height = height_y, div = base_ucell_div, neg_poly = base_ucell_neg_polys);

// Make sure to view from the top!!!
if (ucell_render)
{
    // Render the entire unit cell with both the division and negative polygons
    render_ucells(cells = base_ucell_cells, colors = base_ucell_colors);

    // Place spheres at the points of cell A (division points)
    place_spheres(points = base_ucell_cells[0], d = 0.1, color = "Indigo", zGap = 0.5, fn = 12);

    // Place spheres at the points of cell B (division points)
    place_spheres(points = base_ucell_cells[1], d = 0.1, color = "Violet", zGap = 0.5, fn = 12);
}