/**
 * @file multiExport.scad
 * @brief Example workflow demonstrating the use of the SnapTessSCAD OpenSCAD libraries.
 *
 * This script showcases how to use the provided functions and modules to create complex 3D models.
 * It includes defining input variables, calculating unit cells, rendering them, converting cells to polar coordinates,
 * generating tessellations, and placing cells on a substrate.
 */

renderA = false; ///< Render cell A instances, else render cell B instances

// Import utility functions for point operations
use <../../src/utils.scad>;

// Define input dimensions for the unit cell
width_x = 4;   ///< Width of the unit cell in the x-direction
height_y = 8; ///< Height of the unit cell in the y-direction

// Define division points for creating the cell's internal structure
// Each point is defined as [x, y, tolerance]
// Must form a division line 
// First point must start with 0 if defining the minor half of the ucell division
// First point must start with 1 if defining the major half of the ucell division
example_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Define negative polygon points to create voids within the cell
// Each point is defined as [x, y]
example_neg_poly = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];

// Import functions and modules for calculating and rendering unit cells
use <../../src/ucell.scad>;

// Calculate cells (A and B) using the defined dimensions and division points
example_cells = calc_ucells(width = width_x, height = height_y, div = example_div, neg_poly = example_neg_poly);

// Import functions and modules for converting cells to polar coordinates
use <../../src/cell2polar.scad>;

// Number of sides for the rotational symmetry (e.g., 6 for hexagonal)
degree_n = 6;

// Calculate the diameter based on the apothem of the polygon
ago_dia = apothem(width_x / 2, degree_n) * 2;

// Import functions and modules for generating tessellations
use <../../src/tess.scad>;

// Number of levels for the tessellation pattern
levels = 4;

// Packing factor ranging from 0.0 to 1.0
packing_factor = 0.3;

// Scale the packing factor from 1.0 to 1.5 for grid spacing
scaled_packing = 1.0 + packing_factor * 0.5;

// Calculate the grid radius based on the apothem diameter and scaled packing factor
example_gridrad = ago_dia * scaled_packing;

// Generate hexagon centers for the tessellation
tess_points = hexagon_centers_lvls(example_gridrad, levels);
echo("Unfiltered Centers:", tess_points);

no_filter = true; ///< Flag to disable filtering of points

// Define points to be filtered out from the tessellation
filter_points_levels = [
    [ -8.625, 0 ], [ 0, 0 ], [ 8.625, 0 ], [ -4.3125, 7.46947 ], [ 4.3125, 7.46947 ], [ -4.3125, -7.46947 ],
    [ 4.3125, -7.46947 ]
];

// Filter out specified centers from the tessellation points
filtered_tess_points = filter_center_points(tess_points, filter_points_levels);
echo("Filtered Centers:", filtered_tess_points);

final_tess_points = no_filter ? tess_points : filtered_tess_points;

// Height of the substrate on which cells are placed
substrate_height = 1;

if (renderA)
{
    // Place cell A instances at the filtered tessellation points with rotation
    place_polar_cells(cells = example_cells, positions = final_tess_points, n = degree_n, width = width_x,
                      rotate = true, cell_type = "A", color = "ForestGreen");

    // Render the substrate as solid hexagons beneath the cells
    color("ForestGreen") translate([ 0, 0, -substrate_height ])
        hexagonsSolid(hexagon_centers = final_tess_points, radius = example_gridrad, height = substrate_height);
}
// Generate triangulated center points for placing cell B instances
tess_points_tri = triangulated_center_points(tess_points);
echo("Filtered Centers Triangulated:", tess_points_tri);

// Filter out specified centers from the triangulated tessellation points
filtered_tess_points_tri = filter_triangulated_center_points(example_gridrad, tess_points_tri, filter_points_levels);
echo("Filtered Centers Triangulated:", final_tess_points);

final_tess_points_tri = no_filter ? tess_points_tri : filtered_tess_points_tri;

if (!renderA)
{
    // Place cell B instances at the filtered triangulated tessellation points with rotation
    place_polar_cells(cells = example_cells, positions = final_tess_points_tri, n = degree_n,
                      width = width_x, rotate = true, cell_type = "B", color = "MidnightBlue");

    // Render the substrate as solid hexagons above the cells
    color("MidnightBlue") translate([ 0, 0, height_y])
        hexagonsSolid(hexagon_centers = final_tess_points_tri, radius = example_gridrad, height = substrate_height);
}