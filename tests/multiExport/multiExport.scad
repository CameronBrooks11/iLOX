/**
 * @file multiExport.scad
 * @brief Example workflow demonstrating the use of the SnapTessSCAD OpenSCAD libraries.
 *
 * This script showcases how to use the provided functions and modules to create complex 3D models.
 * It includes defining input variables, calculating unit cells, rendering them, converting cells to polar coordinates,
 * generating tessellations, and placing cells on a substrate.
 */
use <../../iLOX.scad>;

// clear_render = 1; ///< Flag to clear the render, it can be any value
// This is useful when passing to a sequetial script that uses variables from this script
render = "both";                                         ///< Render cell A instances, else render cell B instances
master_render = is_undef(clear_render) ? render : false; // Override master_render if allow_render is false

width_x = 4;  ///< Width of the unit cell in the x-direction
height_y = 8; ///< Height of the unit cell in the y-direction

levels = 3; // Number of levels for the tessellation pattern

substrate_height = 1; ///< Height of the substrate on which cells are placed

packing_factor = 0.3; // Packing factor ranging from 0.0 to 1.0

degree_n = 6; // Number of sides for the rotational symmetry (e.g., 6 for hexagonal)

// Define division points for creating the cell's internal structure
// Each point is defined as [x, y, tolerance] and must form a division line
div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Define negative polygon points to create voids within the cell
// Each point is defined as [x, y] and must form a closed polygon
neg_poly = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];

// Calculate cells (A and B) using the defined dimensions and division points
cells = calc_ucells(width = width_x, height = height_y, div = div,
                    neg_poly = neg_poly); // Calculate cells (A and B) using the defined dimensions and division points

ago_dia = apothem(width_x / 2, degree_n) * 2; // Calculate the diameter based on the apothem of the polygon

scaled_packing = 1.0 + packing_factor * 0.5; // Scale the packing factor from 1.0 to 1.5 for grid spacing

gridrad = ago_dia * scaled_packing; // Calculate the grid radius based on the apothem diameter and scaled packing factor

tess_points = hexagons_centers_radial(gridrad, levels); // Generate hexagon centers for the tessellation

if (master_render == "A" || master_render == "both")
{
    // Place cell A instances at the filtered tessellation points with rotation
    place_polar_cells(cells = cells, positions = tess_points, n = degree_n, width = width_x, rotate = true,
                      cell_type = "A", color = "ForestGreen");

    tess_vertices = hexagons_vertices(radius = gridrad, centers = tess_points, angular_offset = 30);

    // Render the substrate as solid hexagons beneath the cells
    color("ForestGreen") translate([ 0, 0, -substrate_height ])
        generic_poly(vertices = tess_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], // Hexagon paths
                     centers = tess_points, alpha = 0.5, extrude = substrate_height);
}

tess_points_tri =
    triangulated_center_points(tess_points); // Generate triangulated center points for placing cell B instances

if (master_render == "B" || master_render == "both")
{
    // Place cell B instances at the filtered triangulated tessellation points with rotation
    place_polar_cells(cells = cells, positions = tess_points_tri, n = degree_n, width = width_x, rotate = true,
                      cell_type = "B", color = "MidnightBlue");

    tess_vertices = hexagons_vertices(radius = gridrad, centers = tess_points_tri, angular_offset = 30);

    // Render the substrate as solid hexagons beneath the cells
    color("MidnightBlue") translate([ 0, 0, height_y ])
        generic_poly(vertices = tess_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], // Hexagon paths
                     centers = tess_points_tri, alpha = 0.5, extrude = substrate_height);
}