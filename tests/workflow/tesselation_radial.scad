use <../../iLOX.scad>;

// Flag to derender rotational extrusions
rotx_derender = true;

include <extrusion_rotational.scad>;

// Derender radial tessellation (defaults to false if undefined)
radial_tess_render = is_undef(radial_tess_derender) ? true : false;

// Flag to render tessellated centers
tesselated_render = true;

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

if (radial_tess_render)
{
    // Place cell A instances at tessellation points with rotation
    place_rot_cells(cells = base_ucell_cells, positions = tess_points, n = degree_n, width = width_x, rotate = true,
                    cell_type = "A", color = "ForestGreen");

    // Render substrate as solid hexagons beneath cells
    color("ForestGreen") translate([ 0, 0, -substrate_height ])
        generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], centers = tess_points,
                     alpha = 0.5, extrude = substrate_height);

    // Place cell B instances at triangulated tessellation points with rotation
    place_rot_cells(cells = base_ucell_cells, positions = tess_points_tri, n = degree_n, width = width_x, rotate = true,
                    cell_type = "B", color = "MidnightBlue");

    // Render substrate as solid hexagons beneath cells
    color("MidnightBlue") translate([ 0, 0, height_y ])
        generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]], centers = tess_points_tri,
                     alpha = 0.5, extrude = substrate_height);
}