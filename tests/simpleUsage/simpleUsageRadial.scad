use <../../iLOX.scad>;

// -----------------------------------
// Unit cell definition
// -----------------------------------

// Define input dimensions for the unit cell
width_x = 5;   ///< Width of the unit cell in the x-direction
height_y = 10; ///< Height of the unit cell in the y-direction

// Each point is defined as [x, y, tolerance] and must form a division line
base_ucell_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Define negative polygon points to create voids within the cell, each point is defined as [x, y]
base_ucell_neg_poly = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];

// Define color options for rendering
base_ucell_colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ];

// Calculate cells (A and B) using the defined dimensions and division points
base_ucell_cells =
    calc_ucells(width = width_x, height = height_y, div = base_ucell_div, neg_poly = base_ucell_neg_poly);

// -----------------------------------
// Rotional Extrusion & Tessellation
// -----------------------------------

// Number of sides for the rotational symmetry (e.g., 6 for hexagonal)
degree_n = 6;

// Calculate the diameter based on the apothem of the polygon
apothem_diameter = apothem(width_x / 2, degree_n) * 2;

// Number of levels for tessellation pattern
levels = 4;

// Packing factor (0.0 to 1.0)
packing_factor = 0.3;

// Scaled packing factor for grid spacing
scaled_packing = 1.0 + packing_factor * 0.5;

// Grid radius based on apothem diameter and scaled packing factor
tesselation_radius = apothem_diameter * scaled_packing;

// Generate hexagon centers for tessellation
tess_points = hexagons_centers_radial(radius = tesselation_radius, levels = levels);

// Height of substrate
substrate_height = 1;

// Generate triangulated center points for cell B instances
tess_points_tri = triangulated_center_points(tess_points);

// Separation distance along z-axis for visual clarity or animation
separation = 5;

// Generate hexagon vertices for tessellation
tess_hex_vertices = hexagons_vertices(radius = tesselation_radius, centers = tess_points, angular_offset = 30);

// Place cell A instances at tessellation points with rotation
place_rot_cells(cells = base_ucell_cells, positions = tess_points, n = degree_n, width = width_x, rotate = true,
                cell_type = "A", color = "ForestGreen");

// Render substrate as solid hexagons beneath cells
color("ForestGreen") translate([ 0, 0, -substrate_height ])
    generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], centers = tess_points, alpha = 0.5,
                 extrude = substrate_height);

// Place cell B instances at triangulated tessellation points with rotation
place_rot_cells(cells = base_ucell_cells, positions = tess_points_tri, n = degree_n, width = width_x, rotate = true,
                cell_type = "B", color = "MidnightBlue");

// Render substrate as solid hexagons beneath cells
color("MidnightBlue") translate([ 0, 0, height_y ])
    generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], centers = tess_points_tri,
                 alpha = 0.5, extrude = substrate_height);