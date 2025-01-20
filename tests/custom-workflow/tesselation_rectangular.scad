use <../../iLOX.scad>;

// Flag to derender rotational extrusions
rotx_derender = true;

include <extrusion_rectlinear.scad>;

// Derender radial tessellation (defaults to false if undefined)
rectlinear_tess_render = is_undef(rectlinear_tess_derender) ? true : false;

// Flag to render tessellated centers
tesselated_render = true;

// Number of levels for tessellation pattern
grid_n = 8;
grid_m = 4;

// Height of substrate
substrate_height = 1;

// Extend up to a double width of the unit cell in the Y direction to decrease gaps
extension_factor = 0.5; // [0:0.1:1]
fullex = extension_factor * width_x;

// Grid radius based on apothem diameter and scaled packing factor
tesselation_width = width_x * 2;

// Generate hexagon centers for tessellation
tess_points = squares_centers_rect(side = tesselation_width, n = grid_n, m = grid_m);

// Generate triangulated center points for cell B instances
tess_points_midp = square_midpoints(tess_points);

// Generate hexagon vertices for tessellation
tess_sq_vertices = squares_vertices(side = tesselation_width, centers = tess_points);

if (rectlinear_tess_render)
{
    // Place cell A instances at tessellation points with rotation
    place_linear_cells(cells = base_ucell_cells, positions = tess_points, width = width_x, cell_type = "A",
                       color = "ForestGreen", fullex = fullex);

    // Render substrate as solid hexagons beneath cells
    color("ForestGreen") translate([ 0, 0, -substrate_height ])
        generic_poly(vertices = tess_sq_vertices, paths = [[ 0, 1, 2, 3, 0 ]], centers = tess_points, alpha = 0.5,
                     extrude = substrate_height);

    // Place cell B instances at triangulated tessellation points with rotation
    place_linear_cells(cells = base_ucell_cells, positions = tess_points_midp, width = width_x, cell_type = "B",
                       color = "MidnightBlue", fullex = fullex);

    // Render substrate as solid hexagons beneath cells
    color("MidnightBlue") translate([ 0, 0, height_y ])
        generic_poly(vertices = tess_sq_vertices, paths = [[ 0, 1, 2, 3, 0 ]], centers = tess_points_midp, alpha = 0.5,
                     extrude = substrate_height);
}