/**
 * @file lateral_tensile_example.scad
 * @brief Script for simulating a lateral tensile test specimen with integrated cell structures.
 *
 * This script builds upon the `workflow_example.scad` to create a 3D model of a tensile test specimen
 * as per ASTM D638 Type I dimensions, integrating the previously defined cell structures.
 */

zFite = $preview ? 0.1 : 0; // Set the z-fighting offset for preview mode

radial_tess_derender = true; ///< Flag to clear the render, can be set to any value to reset the render state.

include <../direct-workflow/tesselation_radial.scad> // Include the example workflow script for cell definitions and functions.

// Dimensions based on ASTM D638 Type I tensile test specimen
// Source:
// https://www.researchgate.net/publication/346730095/figure/fig1/AS:1083887929303061@1635430428214/Dimensions-of-the-tensile-test-specimen-ASTM-D638-type-I.jpg
connection_width = 19;   ///< Width of the narrow section (mm).
connection_length = 165; ///< Overall length of the specimen (mm).

// Determine the range of the center points for normalization
min_x = min([for (center = tess_points) center[0]]); // Minimum x-coordinate in the tessellation points.
max_x = max([for (center = tess_points) center[0]]); // Maximum x-coordinate in the tessellation points.
min_y = min([for (center = tess_points) center[1]]); // Minimum y-coordinate in the tessellation points.
max_y = max([for (center = tess_points) center[1]]); // Maximum y-coordinate in the tessellation points.

// Adjust from the center of the cells to the edge of the cells
min_y_edge = min_y - tesselation_radius;
max_y_edge = max_y + tesselation_radius;

connection_length_edge = connection_length + max_x + tesselation_radius;

cut_width = 2; // Width of the cut slots to allow bend

// Render the tensile test specimen with integrated cells
difference()
{
    // Begin rendering the tensile test specimen with integrated cells
    union()
    {

        // Translate upwards by the substrate height to position the cells correctly
        translate([ 0, 0, substrate_height ]) union()
        {
            // Place cell A instances at the filtered tessellation points with rotation
            place_rotated_cells(cells = base_ucell_cells, positions = tess_points, n = degree_n, width = width_x,
                                rotate = true, cell_type = "A", color = "Teal");

            tess_vertices = hexagons_vertices(radius = tesselation_radius, centers = tess_points, angular_offset = 30);

            // Render the substrate as solid hexagons beneath the cells
            color("Teal") translate([ 0, 0, -substrate_height ])
                generic_poly(vertices = tess_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], // Hexagon paths
                             centers = tess_points, alpha = 0.5, extrude = substrate_height);
        }

        // Extrude the tensile test specimen shape to the substrate height
        for (i = [0:1])
            mirror([ i, 0, 0 ])
            {
                color("Teal") linear_extrude(height = substrate_height) polygon(points = [
                    [ -connection_length_edge / 2, connection_width / 2 ],  // Left top corner
                    [ -connection_length_edge / 2, -connection_width / 2 ], // Left bottom corner
                    [ min_x, min_y_edge ], // Bottom corner at min_x and min_y of the cells
                    [ 0, min_y_edge ],     // Bottom corner at x = 0
                    [ 0, max_y_edge ],     // Top corner at x = 0
                    [ min_x, max_y_edge ], // Top corner at min_x and max_y of the cells
                ]);
            }
    }

    // cut slots at the min and max x positions
    for (i = [0:1])
    {
        mirror([ i, 0, 0 ]) color("Salmon")
            translate([ max_x + tesselation_radius + cut_width / 2, 0, substrate_height ])

                cube([ cut_width, max_y_edge * 2, substrate_height ], center = true);
    }
}

holder_width = 10;    // Width of the holder for the tensile specimen
holder_thickness = 2; // Thickness of the holder for the tensile specimen
cut_tol = 0.2;        // Tolerance for the cut slots

// Render the holder for the tensile specimen
translate([ 0, 0, -holder_width ]) difference()
{
    // Base rectangle for the holder
    color("DarkGrey") cube([ max_x * 2 + tesselation_radius * 2 + holder_width * 2, max_x * 2 + holder_width * 2, holder_thickness ],
         center = true);

    // cut slots at the min and max x positions
    for (i = [0:1])
    {
        mirror([ i, 0, 0 ]) color("Salmon")
            translate([ max_x + tesselation_radius + cut_width / 2, 0, holder_thickness / 2 ])
                cube([ cut_width * 2 + cut_tol, max_y_edge * 2, holder_thickness * 2 + zFite ], center = true);
    }
}