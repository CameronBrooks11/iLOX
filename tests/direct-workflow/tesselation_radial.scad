use <../../iLOX.scad>;

// Should be kept true. Flag to derender rotational extrusions
rotx_derender = true;

include <extrusion_rotational.scad>;

// Derender radial tessellation (defaults to false if undefined)
radial_tess_render = is_undef(radial_tess_derender) ? true : false;

// Number of levels for tessellation pattern
levels = 4;

// Height of substrate
substrate_height = 3;

// Packing factor
packing_factor = 0.3; // [0:0.1:1]
scaled_packing = 1.0 + packing_factor * 0.5; // Scaled packing factor for grid spacing (1.0 to 1.5)
echo("Scaled packing factor: ", scaled_packing);

// Grid radius based on apothem diameter and scaled packing factor
tesselation_radius = apothem_diameter * scaled_packing;

// Generate hexagon centers for tessellation
tess_points = hexagons_centers_radial(radius = tesselation_radius, levels = levels);

// Generate triangulated center points for cell B instances
tess_points_tri = triangulated_center_points(tess_points);

// Generate hexagon vertices for tessellation
tess_hex_vertices = hexagons_vertices(radius = tesselation_radius, centers = tess_points, angular_offset = 30);

if (radial_tess_render)
{
    // Place cell A instances at tessellation points with rotation
    place_rotated_cells(cells = base_ucell_cells, positions = tess_points, n = degree_n, width = width_x, rotate = true,
                        cell_type = "A", color = "ForestGreen");

    // Render substrate as solid hexagons beneath cells
    color("ForestGreen") translate([ 0, 0, -substrate_height ])
        generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], centers = tess_points,
                     alpha = 0.5, extrude = substrate_height);

    // Place cell B instances at triangulated tessellation points with rotation
    place_rotated_cells(cells = base_ucell_cells, positions = tess_points_tri, n = degree_n, width = width_x,
                        rotate = true, cell_type = "B", color = "MidnightBlue");

    // Render substrate as solid hexagons beneath cells
    color("MidnightBlue") translate([ 0, 0, height_y ])
        generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], centers = tess_points_tri,
                     alpha = 0.5, extrude = substrate_height);
}