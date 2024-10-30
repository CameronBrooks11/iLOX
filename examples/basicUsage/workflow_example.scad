/**
 * @file workflow_example.scad
 * @brief Example workflow demonstrating the use of the SnapTessSCAD OpenSCAD libraries.
 *
 * This script showcases how to use the provided functions and modules to create complex 3D models.
 * It includes defining input variables, calculating unit cells, rendering them, converting cells to polar coordinates,
 * generating tessellations, and placing cells on a substrate.
 */

use <../../src/utils.scad>; // Utility functions for point operations

// Define input dimensions for the unit cell
width_x = 5;   ///< Width of the unit cell in the x-direction
height_y = 10; ///< Height of the unit cell in the y-direction

// Define division points for creating the cell's internal structure
// Each point is defined as [x, y, tolerance]
// Must form a division line <= 0.5 * height_y
example_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Calculate the radius based on the maximum x-value from division points (without tolerance)
example_radius = max_x(example_div, width_x);

// Define negative polygon points to create voids within the cell
// Each point is defined as [x, y]
example_neg_poly = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];

// Define color options for rendering
example_colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ];

use <../../src/ucell.scad>; // Functions and modules for calculating and rendering unit cells

// Calculate cells (A and B) using the defined dimensions and division points
example_cells = calc_ucells(width = width_x, height = height_y, div = example_div, neg_poly = example_neg_poly);

// Rotate the entire scene for better visualization
rotate([ 90, 0, 0 ])
{
    // Render only the division polygons (cells A and B without the negative polygons)
    render_ucells(cells = [ example_cells[0], example_cells[1], [], [] ], colors = example_colors);

    // Render only the negative (anti-cell) portions separately
    render_ucells(cells = [ [], [], example_cells[2], example_cells[3] ], colors = example_colors);

    // Place spheres at the points of cell A (division points)
    place_spheres(points = example_cells[0], d = 0.05, color = "Indigo", fn = 12);

    // Place spheres at the points of cell B (division points)
    place_spheres(points = example_cells[1], d = 0.05, color = "Violet", fn = 12);
}

use <../../src/cell2polar.scad>; // Functions and modules for converting cells to polar coordinates

degree_n = 6; ///< Number of sides for the rotational symmetry (e.g., 6 for hexagonal)

// Translate the position to render cells in polar coordinates
translate([ width_x * 2, height_y / 2, 0 ])
    // Render both cells A and B in polar coordinates
    cells2polarpos(cells = example_cells, n = degree_n, radius = example_radius);

// Calculate the diameter based on the apothem of the polygon
ago_dia = apothem(example_radius, degree_n) * 2;

// Translate to a new position to render cells individually
translate([ width_x * 5, height_y / 2, 0 ])
{
    // Render cell A in polar coordinates
    cellA2polar(cells = example_cells, n = degree_n, radius = example_radius, color = "LightGreen");

    // Render cell B in polar coordinates at a position shifted by the apothem diameter
    translate([ ago_dia, 0, 0 ])
        cellB2polar(cells = example_cells, n = degree_n, radius = example_radius, color = "LightBlue");

    // Render additional cell B instances rotated and positioned around cell A
    translate([ -ago_dia * sin(half_central_angle(degree_n)), -ago_dia * cos(half_central_angle(degree_n)), 0 ])
        rotate([ 0, 0, central_angle(degree_n) ])
            cellB2polar(cells = example_cells, n = degree_n, radius = example_radius, color = "LightBlue");

    translate([ -ago_dia * sin(half_central_angle(degree_n)), ago_dia * cos(half_central_angle(degree_n)), 0 ])
        rotate([ 0, 0, central_angle(degree_n) ])
            cellB2polar(cells = example_cells, n = degree_n, radius = example_radius, color = "LightBlue");
}

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
translate([ width_x * 8, height_y / 2, 0 ]) rotate([ 0, 0, half_central_angle(degree_n) ])
{
    // Place cell A at the specified position
    place_polar_cells(cells = example_cells, positions = positions_A, n = degree_n, radius = example_radius,
                      cell_type = "A", color = "OliveDrab");

    // Place cell B instances at the specified positions
    place_polar_cells(cells = example_cells, positions = positions_B, n = degree_n, radius = example_radius,
                      cell_type = "B", color = "CadetBlue");
}

use <../../src/tess.scad>; // Functions and modules for generating tessellations

levels = 5;           ///< Number of levels for the tessellation pattern
packing_factor = 0.3; ///< Packing factor ranging from 0.0 to 1.0

// Scale the packing factor from 1.0 to 1.5 for grid spacing
scaled_packing = 1.0 + packing_factor * 0.5;

// Calculate the grid radius based on the apothem diameter and scaled packing factor
example_gridrad = ago_dia * scaled_packing;

// Generate hexagon centers for the tessellation
tess_points = hexagon_centers_lvls(example_gridrad, levels);
echo("Unfiltered Centers:", tess_points);

// Define points to be filtered out from the tessellation
filter_points_levels = [
    [ -8.625, 0 ], [ 0, 0 ], [ 8.625, 0 ], [ -4.3125, 7.46947 ], [ 4.3125, 7.46947 ], [ -4.3125, -7.46947 ],
    [ 4.3125, -7.46947 ]
];

// Filter out specified centers from the tessellation points
filtered_tess_points = filter_center_points(tess_points, filter_points_levels);
echo("Filtered Centers:", filtered_tess_points);

substrate_height = 1; ///< Height of the substrate on which cells are placed

// Translate to position the assembly and begin placing cells
translate([ -width_x * 11, height_y / 2, 0 ])
{
    // Place cell A instances at the filtered tessellation points with rotation
    place_polar_cells(cells = example_cells, positions = filtered_tess_points, n = degree_n, radius = example_radius,
                      rotate = true, cell_type = "A", color = "OliveDrab");

    // Render the substrate as solid hexagons beneath the cells
    translate([ 0, 0, -substrate_height ])
        hexagonsSolid(hexagon_centers = filtered_tess_points, radius = example_gridrad, height = substrate_height);

    // Optionally print the positions of the centers as text labels
    print_points(filtered_tess_points, text_size = 0.5, color = "Azure");
}

// Generate triangulated center points for placing cell B instances
tess_points_tri = triangulated_center_points(tess_points);

// Filter out specified centers from the triangulated tessellation points
filtered_tess_points_tri = filter_triangulated_center_points(example_gridrad, tess_points_tri, filter_points_levels);

echo("Filtered Centers Triangulated:", filtered_tess_points_tri);

separation = 5; ///< Separation distance along the z-axis for layering

// Translate to position the assembly for cell B instances
translate([ -width_x * 11, height_y / 2, separation ])
{
    // Place cell B instances at the filtered triangulated tessellation points with rotation
    place_polar_cells(cells = example_cells, positions = filtered_tess_points_tri, n = degree_n,
                      radius = example_radius, rotate = true, cell_type = "B", color = "CadetBlue");

    // Render the substrate as solid hexagons above the cells
    translate([ 0, 0, height_y ])
        hexagonsSolid(hexagon_centers = filtered_tess_points_tri, radius = example_gridrad, height = substrate_height);
}