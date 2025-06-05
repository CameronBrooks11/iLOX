// External libraries
include <tessella/tess.scad>;

// Internal functions and modules
include <src/cell2linear.scad>;
include <src/cell2rot.scad>;
include <src/ucell.scad>;
include <src/utils/point_utils.scad>;
include <src/utils/regpoly_utils.scad>;
include <src/utils/viz_utils.scad>;

/**
 * @brief Renders a unit cell with division points and negative polygons
 * @param width_x Width of the unit cell in the x-direction
 * @param height_y Height of the unit cell in the y-direction
 * @param div Points are [x, y, tolerance], with the first as 0 for the minor (bottom) or 1 for the major (top) ucell
 * division.
 * @param neg_poly Define points for a polygon to act as a negative to create voids within the cell, each point is
 * defined as [x, y]
 * @param colors Array of colors for the cell and negative polygon
 * @param pt_diams Diameter of the points
 * @param pt_colors Array of colors for the points
 * @param pt_zGap Height offset for the points along the z-axis
 * @param pt_fn Number of facets used to render the points
 */
module ucell_designer(width_x, height_y, div, neg_poly = [], colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ],
                      pt_diams = 0.1, pt_colors = [ "Indigo", "Violet" ], pt_zGap = 0.5, pt_fn = 12)
{
    base_ucell_cells = calc_ucell(width = width_x, height = height_y, div = div, neg_poly = neg_poly);
    // Render the entire unit cell with both the division and negative polygons
    render_ucells(cells = base_ucell_cells, colors = colors);

    // Place spheres at the points of cell A (division points)
    place_spheres(points = base_ucell_cells[0], d = pt_diams, color = pt_colors[0], zGap = pt_zGap, fn = pt_fn);

    // Place spheres at the points of cell B (division points)
    place_spheres(points = base_ucell_cells[1], d = pt_diams, color = pt_colors[1], zGap = pt_zGap, fn = pt_fn);
}

/**
 * @brief Renders a radial tessellation of cells A and B
 * @param width_x Width of the unit cell in the x-direction
 * @param height_y Height of the unit cell in the y-direction
 * @param base_ucell_div Points are [x, y, tolerance], with the first as 0 for the minor (bottom) or 1 for the major
 * (top) ucell division.
 * @param base_ucell_neg_poly Define points for a polygon to act as a negative to create voids within the cell, each
 * point is defined as [x, y]
 * @param degree_n Number of sides for the rotational symmetry (e.g., 6 for hexagonal)
 * @param levels Number of levels for tessellation pattern
 * @param packing_factor Packing factor
 * @param substrate_height Height of the substrate
 * @param cellA_color Color for cell A
 * @param cellB_color Color for cell B
 */
module radial_iLOX(width_x, height_y, base_ucell_div, base_ucell_neg_poly, degree_n, levels, packing_factor,
                   substrate_height = 1, cellA_color = "ForestGreen", cellB_color = "MidnightBlue")
{
    // Calculate cells (A and B) using the defined dimensions and division points
    base_ucell_cells =
        calc_ucell(width = width_x, height = height_y, div = base_ucell_div, neg_poly = base_ucell_neg_poly);

    // Calculate the diameter based on the apothem of the polygon
    apothem_diameter = apothem(width_x / 2, degree_n) * 2;

    // Scaled packing factor for grid spacing (1.0 to 1.5)
    // This means the user can decide between no spacing up to 50% of their unit cells width of spacing
    scaled_packing = 1.0 + packing_factor * 0.5;

    // Grid radius based on apothem diameter and scaled packing factor
    tesselation_radius = apothem_diameter * scaled_packing;

    // Generate hexagon centers for tessellation
    tess_points = hexagons_centers_radial(radius = tesselation_radius, levels = levels);

    // Generate triangulated center points for cell B instances
    tess_points_tri = triangulated_center_points(tess_points);

    // Generate hexagon vertices for tessellation
    tess_hex_vertices = hexagons_vertices(radius = tesselation_radius, centers = tess_points, angular_offset = 30);
    color(cellA_color) union()
    { // Place cell A instances at tessellation points with rotation
        place_rotated_cells(cells = base_ucell_cells, positions = tess_points, n = degree_n, width = width_x,
                            rotate = true, cell_type = "A");

        // Render substrate as solid hexagons beneath cells
        translate([ 0, 0, -substrate_height ])
            generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], centers = tess_points,
                         alpha = 0.5, extrude = substrate_height);
    }
    // Place cell B instances at triangulated tessellation points with rotation
    color(cellB_color) union()
    {
        // Place cell B instances at triangulated tessellation points with rotation
        place_rotated_cells(cells = base_ucell_cells, positions = tess_points_tri, n = degree_n, width = width_x,
                            rotate = true, cell_type = "B");

        // Render substrate as solid hexagons beneath cells
        translate([ 0, 0, height_y ]) generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]],
                                                   centers = tess_points_tri, alpha = 0.5, extrude = substrate_height);
    }
}

/**
 * @brief Renders a linear tessellation of cells A and B
 * @param width_x Width of the unit cell in the x-direction
 * @param height_y Height of the unit cell in the y-direction
 * @param base_ucell_div Points are [x, y, tolerance], with the first as 0 for the minor (bottom) or 1 for the major
 * (top) ucell division.
 * @param base_ucell_neg_poly Define points for a polygon to act as a negative to create voids within the cell, each
 * point is defined as [x, y]
 * @param grid_n Number of grid points in the X direction
 * @param grid_m Number of grid points in the Y direction
 * @param extension_factor Factor to extend the cells in the x-direction
 * @param substrate_height Height of the substrate
 * @param cellA_color Color for cell A
 * @param cellB_color Color for cell B
 */
module linear_iLOX(width_x, height_y, base_ucell_div, base_ucell_neg_poly, grid_n, grid_m, extension_factor,
                   substrate_height = 1, cellA_color = "ForestGreen", cellB_color = "MidnightBlue")
{
    // Calculate cells (A and B) using the defined dimensions and division points
    base_ucell_cells =
        calc_ucell(width = width_x, height = height_y, div = base_ucell_div, neg_poly = base_ucell_neg_poly);

    extension = extension_factor * width_x;

    // Grid radius based on apothem diameter and scaled packing factor
    tesselation_width = width_x * 2;

    // Generate hexagon centers for tessellation
    tess_points = squares_centers_rect(side = tesselation_width, n = grid_n, m = grid_m);

    // Generate triangulated center points for cell B instances
    tess_points_midp = square_midpoints(tess_points);

    // Generate hexagon vertices for tessellation
    tess_sq_vertices = squares_vertices(side = tesselation_width, centers = tess_points);

    // Place cell A instances at tessellation points with rotation
    place_linear_cells(cells = base_ucell_cells, positions = tess_points, width = width_x, cell_type = "A",
                       color = cellA_color, extension = extension);

    // Render substrate as solid hexagons beneath cells
    color(cellA_color) translate([ 0, 0, -substrate_height ])
        generic_poly(vertices = tess_sq_vertices, paths = [[ 0, 1, 2, 3, 0 ]], centers = tess_points, alpha = 0.5,
                     extrude = substrate_height);

    // Place cell B instances at triangulated tessellation points with rotation
    place_linear_cells(cells = base_ucell_cells, positions = tess_points_midp, width = width_x, cell_type = "B",
                       color = cellB_color, extension = extension);

    // Render substrate as solid hexagons beneath cells
    color(cellB_color) translate([ 0, 0, height_y ])
        generic_poly(vertices = tess_sq_vertices, paths = [[ 0, 1, 2, 3, 0 ]], centers = tess_points_midp, alpha = 0.5,
                     extrude = substrate_height);
}