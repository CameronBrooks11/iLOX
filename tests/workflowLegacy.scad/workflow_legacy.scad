/**
 * @file workflow_example.scad
 * @brief Example workflow demonstrating the use of the SnapTessSCAD OpenSCAD libraries.
 *
 * This script showcases how to use the provided functions and modules to create complex 3D models.
 * It includes defining input variables, calculating unit cells, rendering them, converting cells to polar coordinates,
 * generating tessellations, and placing cells on a substrate.
 */

use <../../iLOX.scad>;

// clear_render = 1; ///< Flag to clear the render, it can be any value
// This is useful when passing to a sequetial script that uses variables from this script

masterRender = true; ///< Flag to render the entire scene or individual components
master_render = is_undef(clear_render) ? masterRender : false; // Override master_render if allow_render is false

// Define input dimensions for the unit cell
width_x = 5;   ///< Width of the unit cell in the x-direction
height_y = 10; ///< Height of the unit cell in the y-direction

// Define division points for creating the cell's internal structure
// Each point is defined as [x, y, tolerance]
// Must form a division line
// First point must start with 0 if defining the minor half of the ucell division
// First point must start with 1 if defining the major half of the ucell division
example_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Define negative polygon points to create voids within the cell
// Each point is defined as [x, y]
example_neg_poly = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];

// Define color options for rendering
example_colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ];

ucell_render = true; ///< Flag to render the unit cells or omit them

// Calculate cells (A and B) using the defined dimensions and division points
example_cells = calc_ucells(width = width_x, height = height_y, div = example_div, neg_poly = example_neg_poly);

if (ucell_render && master_render)
{
    // Rotate the entire scene for better visualization
    rotate([ 90, 0, 0 ])
    {
        // Render the entire unit cell with both the division and negative polygons
        render_ucells(cells = example_cells, colors = example_colors);

        // Place spheres at the points of cell A (division points)
        place_spheres(points = example_cells[0], d = 0.05, color = "Indigo", zGap = 0.5, fn = 12);

        // Place spheres at the points of cell B (division points)
        place_spheres(points = example_cells[1], d = 0.05, color = "Violet", zGap = 0.5, fn = 12);
    }
}

c2p_render = true; ///< Flag to render the prepositioned cells or omit them

degree_n = 6; ///< Number of sides for the rotational symmetry (e.g., 6 for hexagonal)

if (c2p_render && master_render)
{
    // Translate the position to render cells in polar coordinates
    translate([ width_x * 3, 0, 0 ])
        // Render both cells A and B in polar coordinates
        ucell_rotX_paired(cells = example_cells, n = degree_n, radius = width_x / 2);
}

c2p_placed_render = true; ///< Flag to render the placed cells or omit them

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

if (c2p_placed_render && master_render)
{
    // Translate and rotate to position the cells correctly
    translate([ width_x * 7, 0, 0 ]) rotate([ 0, 0, half_central_angle(degree_n) ])
    {
        // Place cell A at the specified position
        place_rot_cells(cells = example_cells, positions = positions_A, n = degree_n, width = width_x,
                          cell_type = "A", color = "OliveDrab");

        // Place cell B instances at the specified positions
        place_rot_cells(cells = example_cells, positions = positions_B, n = degree_n, width = width_x,
                          cell_type = "B", color = "CadetBlue");
    }
}

tesselated_render = true; ///< Flag to render the tessellated centers or omit them

levels = 4;           ///< Number of levels for the tessellation pattern
packing_factor = 0.3; ///< Packing factor ranging from 0.0 to 1.0

// Scale the packing factor from 1.0 to 1.5 for grid spacing
scaled_packing = 1.0 + packing_factor * 0.5;

// Calculate the grid radius based on the apothem diameter and scaled packing factor
example_gridrad = ago_dia * scaled_packing;

// Generate hexagon centers for the tessellation
tess_points = hexagons_centers_radial(radius = example_gridrad, levels = levels);
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
use_filter = true;    ///< Flag to use the filtered tessellation points or the original tessellation points

if (tesselated_render && master_render)
{
    // Translate to position the assembly and begin placing cells
    translate([ width_x * 18, 0, 0 ])
    {
        // Place cell A instances at the filtered tessellation points with rotation
        place_rot_cells(cells = example_cells, positions = filtered_tess_points, n = degree_n, width = width_x,
                          rotate = true, cell_type = "A", color = "ForestGreen");

        final_tess_points = use_filter ? filtered_tess_points : tess_points;
        tess_vertices = hexagons_vertices(radius = example_gridrad, centers = final_tess_points, angular_offset = 30);

        // Render the substrate as solid hexagons beneath the cells
        color("ForestGreen") translate([ 0, 0, -substrate_height ]) generic_poly(
            vertices = tess_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], // Hexagon paths
            centers = final_tess_points, alpha = 0.5, extrude = substrate_height);
    }
}

// Generate triangulated center points for placing cell B instances
tess_points_tri = triangulated_center_points(tess_points);

// Filter out specified centers from the triangulated tessellation points
filtered_tess_points_tri = filter_triangulated_center_points(example_gridrad, tess_points_tri, filter_points_levels);

echo("Filtered Centers Triangulated:", filtered_tess_points_tri);

final_tess_points_tri = use_filter ? filtered_tess_points_tri : tess_points_tri;

separation = 5; ///< Separation distance along the z-axis for visual clarity or animation

if (tesselated_render && master_render)
{
    // Translate to position the assembly for cell B instances
    translate([ width_x * 18, 0, separation ])
    {
        // Place cell B instances at the filtered triangulated tessellation points with rotation
        place_rot_cells(cells = example_cells, positions = filtered_tess_points_tri, n = degree_n, width = width_x,
                          rotate = true, cell_type = "B", color = "MidnightBlue");

        tess_vertices =
            hexagons_vertices(radius = example_gridrad, centers = final_tess_points_tri, angular_offset = 30);

        // Render the substrate as solid hexagons beneath the cells
        color("MidnightBlue") translate([ 0, 0, height_y ]) generic_poly(
            vertices = tess_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], // Hexagon paths
            centers = final_tess_points_tri, alpha = 0.5, extrude = substrate_height);
    }
}