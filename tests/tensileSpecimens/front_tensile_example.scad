/**
 * @file front_tensile_example.scad
 * @brief Script for simulating a front tensile test specimen with integrated cell structures.
 *
 * This script builds upon the `workflow_example.scad` to create a 3D model of a tensile test specimen
 * as per ASTM D638 Type I dimensions, integrating the previously defined cell structures.
 */

clear_render = true; ///< Flag to clear the render, can be set to any value to reset the render state.

include <../multiExport/multiExport.scad> // Include the example workflow script for cell definitions and functions.

// Dimensions based on ASTM D638 Type I tensile test specimen
// Source:
// https://www.researchgate.net/publication/346730095/figure/fig1/AS:1083887929303061@1635430428214/Dimensions-of-the-tensile-test-specimen-ASTM-D638-type-I.jpg
connection_width = 19;   ///< Width of the narrow section (mm).
connection_length = 165; ///< Overall length of the specimen (mm).

// Determine the range of the center points for normalization
min_x = min([for (center = tess_points) center[0]]); ///< Minimum x-coordinate among filtered tessellation points.
max_x = max([for (center = tess_points) center[0]]); ///< Maximum x-coordinate among filtered tessellation points.
min_y = min([for (center = tess_points) center[1]]); ///< Minimum y-coordinate among filtered tessellation points.
max_y = max([for (center = tess_points) center[1]]); ///< Maximum y-coordinate among filtered tessellation points.

// Begin rendering the tensile test specimen with integrated cells
union()
{
    // Translate upwards by the substrate height to position the cells correctly
    translate([ substrate_height, 0, 0 ]) rotate([ 0, 90, 0 ]) union()
    {
        // Place cell A instances at the filtered tessellation points with rotation
        place_polar_cells(cells = cells, positions = tess_points, n = degree_n, width = width_x, rotate = true,
                          cell_type = "A", color = "ForestGreen");

        tess_vertices = hexagons_vertices(radius = gridrad, centers = tess_points, angular_offset = 30);

        // Render the substrate as solid hexagons beneath the cells
        color("Orange") translate([ 0, 0, -substrate_height ])
            generic_poly(vertices = tess_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], // Hexagon paths
                         centers = tess_points, alpha = 0.5, extrude = substrate_height);
    }
    for (i = [0:1]) ///< Loop through twice and mirror the second extrusion to create the full specimen
    {
        // Extrude the tensile test specimen shape to the substrate height
        color("Orange") mirror([ 0, 0, i ]) linear_extrude(height = max_x / 2, scale = 0) polygon(points = [
            [ -connection_length / 2, connection_width / 2 ],  // Left top corner
            [ -connection_length / 2, -connection_width / 2 ], // Left bottom corner
            [ min_x, min_y ],                                  // Bottom corner at min_x and min_y of the cells
            [ 0, min_y ],                                      // Bottom corner at x = 0
            [ 0, max_y ],                                      // Top corner at x = 0
            [ min_x, max_y ],                                  // Top corner at min_x and max_y of the cells
        ]);
    }
}