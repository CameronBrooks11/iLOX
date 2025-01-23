/**
 * @file lateral_tensile_example.scad
 * @brief Script for simulating a lateral tensile test specimen with integrated cell structures.
 *
 * This script builds upon the `workflow_example.scad` to create a 3D model of a tensile test specimen
 * as per ASTM D638 Type I dimensions, integrating the previously defined cell structures.
 */

zFite = $preview ? 0.1 : 0; // Set the z-fighting offset for preview mode

// Should be kept true. Flag to clear the render, can be set to any value to reset the render state.
rectlinear_tess_derender = true;

include <../direct-workflow/tesselation_rectangular.scad> // Include the final stage in the direct workflow

// Dimensions based on ASTM D638 Type I tensile test specimen. Source:
// https://www.researchgate.net/publication/346730095/figure/fig1/AS:1083887929303061@1635430428214/Dimensions-of-the-tensile-test-specimen-ASTM-D638-type-I.jpg
// Width of a tensile specimen in mm as per ASTM D638 Type I.
standard_tensile_specimen_width = 19;
// Overall length of a tensile specimen in mm as per ASTM D638 Type I.
standard_tensile_specimen_length = 165;
// Extra width for the connection to the cells, adds to standard_tensile_specimen_width
extra_width_tensile_connector = 0;
// Extra length for the connection to the cells, adds to standard_tensile_specimen_length
extra_length_tensile_connector = 0;

connection_width = standard_tensile_specimen_width + extra_width_tensile_connector;    // Width of the narrow section
connection_length = standard_tensile_specimen_length + extra_length_tensile_connector; // Overall length of the specimen

// Determine the range of the center points for normalization
// Messy workaround to get the min and max values of the tessellation points centered at the origin
pmax_x = max([for (center = tess_points) center[0]]); // Maximum x-coordinate in the tessellation points.
pmax_y = max([for (center = tess_points) center[1]]); // Maximum y-coordinate in the tessellation points.
shifted_tess_points = shift_points(tess_points, -pmax_x / 2, -pmax_y / 2); // Shift tessellation points to the origin

min_x = min([for (center = shifted_tess_points) center[0]]); // Minimum x-coordinate in the tessellation points.
max_x = max([for (center = shifted_tess_points) center[0]]); // Maximum x-coordinate in the tessellation points.
min_y = min([for (center = shifted_tess_points) center[1]]); // Minimum y-coordinate in the tessellation points.
max_y = max([for (center = shifted_tess_points) center[1]]); // Maximum y-coordinate in the tessellation points.

// Adjust from the center of the cells to the edge of the cells
min_y_edge = min_y - tesselation_width;
max_y_edge = max_y + tesselation_width;
// Width of the cut slots to allow bend, depth is automatically set to the half the substrate height
cut_width = 2;

// Holder dimensions for the tensile test specimen
// Amount added to each side of the holder width for the tensile specimen
holder_extra_width = 10;
// Thickness of the holder for the tensile specimen
holder_thickness = 2;
// Tolerance for the cut slots
cut_tol = 0.2;

tensile_ilox_holder();
tensile_ilox_specimen();

// Render the tensile test specimen with integrated cells
module tensile_ilox_specimen()
{
    connection_length_edge = connection_length + max_x + tesselation_width;

    difference()
    {
        // Begin rendering the tensile test specimen with integrated cells
        union()
        {
            // Translate upwards by the substrate height to position the cells correctly
            translate([ 0, 0, substrate_height ])
                // Place cell A instances at tessellation points with rotation
                place_linear_cells(cells = base_ucell_cells, positions = shifted_tess_points, width = width_x,
                                   cell_type = "A", color = "Teal", extension = extension);

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
                translate([ max_x + tesselation_width + cut_width / 2, 0, substrate_height ])

                    cube([ cut_width, max_y_edge * 2, substrate_height ], center = true);
        }
    }
}

// Render the holder for the tensile specimen
module tensile_ilox_holder()
{
    translate([ 0, 0, -holder_extra_width ]) difference()
    {
        // Base rectangle for the holder
        color("DarkGrey") cube(
            [
                max_x * 2 + tesselation_width * 2 + holder_extra_width * 2, max_x * 2 + holder_extra_width * 2,
                holder_thickness
            ],
            center = true);

        // cut slots at the min and max x positions
        for (i = [0:1])
        {
            mirror([ i, 0, 0 ]) color("Salmon")
                translate([ max_x + tesselation_width + cut_width / 2, 0, holder_thickness / 2 ])
                    cube([ cut_width * 2 + cut_tol, max_y_edge * 2, holder_thickness * 2 + zFite ], center = true);
        }
    }
}