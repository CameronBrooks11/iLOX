// iLOX: interlocking orthogonal extrusions. The public modules are ilox_radial(), ilox_linear() and
// ilox_cell_designer(); calc_ucell() in src/ucell.scad computes the unit cell they share. Pass arguments by name.

// External libraries
include <tessella/tess.scad>;

// Internal functions and modules
include <src/cell2linear.scad>;
include <src/cell2rot.scad>;
include <src/ucell.scad>;
include <src/utils/point_utils.scad>;
include <src/utils/regpoly_utils.scad>;
include <src/utils/viz_utils.scad>;

/**
 * @brief Renders the 2D unit cell, its two halves, their voids and their points, to design a division line.
 * @param width Width of the unit cell in mm
 * @param height Height of the unit cell in mm
 * @param div Division line as [x, y] points normalised to the cell, starting at y = 0 (minor half) or y = 1 (major
 * half)
 * @param clearance Gap between cells A and B in mm, measured normal to the division line
 * @param voids (Optional) Voids cut from the cell: a list of polygons, each a list of [x, y] points normalised to the
 * cell
 * @param tip_clearance (Optional) Gap in mm between each cell's tip and the opposite substrate; defaults to clearance,
 * below half the cell height; that alone does not keep the halves overlapping or interlocked
 * @param colors [ cell A, cell B, voids of A, voids of B ]
 * @param point_d Diameter of the spheres marking the cells' points
 * @param point_colors [ points of A, points of B ]
 * @param point_z Height of the point spheres above the cell
 * @param point_fn Facets of the point spheres
 */
module ilox_cell_designer(width, height, div, clearance, voids = [], tip_clearance = undef,
                          colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ], point_d = 0.1,
                          point_colors = [ "Indigo", "Violet" ], point_z = 0.5, point_fn = 12)
{
    checked = assert(is_list(colors) && len(colors) == 4,
                     str("ERROR: ilox_cell_designer: colors must be 4 colors, got: ", colors))
        assert(is_list(point_colors) && len(point_colors) == 2,
               str("ERROR: ilox_cell_designer: point_colors must be 2 colors, got: ", point_colors))
            assert(is_num(point_d) && point_d > 0,
                   str("ERROR: ilox_cell_designer: point_d must be a number > 0, got: ", point_d)) true;

    cells = calc_ucell(width = width, height = height, div = div, clearance = clearance, voids = voids,
                       tip_clearance = tip_clearance);

    render_ucells(cells = cells, colors = colors);
    for (k = [0:1])
        place_spheres(points = cells[k], d = point_d, color = point_colors[k], zGap = point_z, fn = point_fn);
}

/**
 * @brief Renders a radial tessellation of cells A and B: pins on a hexagonal lattice.
 * @param width Width of the unit cell in mm
 * @param height Height of the unit cell in mm
 * @param div Division line as [x, y] points normalised to the cell, starting at y = 0 (minor half) or y = 1 (major
 * half)
 * @param clearance Gap between cells A and B in mm, measured normal to the division line
 * @param voids (Optional) Voids cut from the cell: a list of polygons, each a list of [x, y] points normalised to the
 * cell
 * @param tip_clearance (Optional) Gap in mm between each cell's tip and the opposite substrate; defaults to clearance,
 * below half the cell height; that alone does not keep the halves overlapping or interlocked
 * @param levels Number of rings of A cells, a whole number of at least 2: B cells sit between the A cells
 * @param substrate_height Thickness of each half's substrate in mm
 * @param colors [ half A, half B ]
 * @param part "A", "B" or "both": which half to render, in its assembled position (turn B over to print it)
 */
module ilox_radial(width, height, div, clearance, voids = [], tip_clearance = undef, levels = 2, substrate_height = 1,
                   colors = [ "ForestGreen", "MidnightBlue" ], part = "both")
{
    halves_checked = _ilox_check_halves("ilox_radial", substrate_height, colors, part);
    levels_checked =
        assert(_ilox_is_count(levels, 2),
               str("ERROR: ilox_radial: levels must be a whole number of at least 2, so B cells sit between the ",
                   "A cells, got: ", levels)) true;

    cells = calc_ucell(width = width, height = height, div = div, clearance = clearance, voids = voids,
                       tip_clearance = tip_clearance);

    // Each B cell faces three A cells, one cell width away, across a flat side of their hexagonal extrusions. Widening
    // the extrusions by 1 / cos(30) puts each flat side at the profile's x, so a section between neighbours is the
    // unit cell and the gap is the clearance. Positions are scaled down to cancel the widening.
    widen = [ 1 / cos(30), 1 / cos(30), 1 ];

    // A cells at the hexagon centres, B cells at the centres of the triangles between them
    tess_points = hexagons_centers_radial(radius = width, levels = levels);
    tess_points_tri = triangulated_center_points(tess_points);
    tess_hex_vertices = hexagons_vertices(radius = width, centers = tess_points, angular_offset = 30);

    for (k = [0:1])
        if (part == "both" || part == (k == 0 ? "A" : "B"))
            color(colors[k])
            {
                scale(widen)
                    place_rotated_cells(cells = cells, positions = (k == 0 ? tess_points : tess_points_tri) * cos(30),
                                        n = 6, width = width, rotate = true, cell_type = k == 0 ? "A" : "B",
                                        color = colors[k]);

                // Substrate: solid hexagons beneath the A cells, above the B cells
                translate([ 0, 0, k == 0 ? -substrate_height : height ])
                    generic_poly(vertices = tess_hex_vertices, paths = [[ 0, 1, 2, 3, 4, 5, 0 ]],
                                 centers = k == 0 ? tess_points : tess_points_tri, alpha = 0.5,
                                 extrude = substrate_height);
            }
}

/**
 * @brief Renders a linear tessellation of cells A and B: rails on a rectangular grid.
 *
 * The rails lock against pull-off and across the rails, and slide freely along them: halves assemble by sliding.
 * @param width Width of the unit cell in mm
 * @param height Height of the unit cell in mm
 * @param div Division line as [x, y] points normalised to the cell, starting at y = 0 (minor half) or y = 1 (major
 * half)
 * @param clearance Gap between cells A and B in mm, measured normal to the division line
 * @param voids (Optional) Voids cut from the cell: a list of polygons, each a list of [x, y] points normalised to the
 * cell
 * @param tip_clearance (Optional) Gap in mm between each cell's tip and the opposite substrate; defaults to clearance,
 * below half the cell height; that alone does not keep the halves overlapping or interlocked
 * @param grid_n Number of A rails, along X, a whole number of at least 2: B rails sit between them
 * @param grid_m Number of cells along each rail, along Y, a whole number of at least 1
 * @param extension_factor How far each cell extends along its rail, from 0 to 1 cell width; 1 joins a rail's cells
 * @param substrate_height Thickness of each half's substrate in mm
 * @param colors [ half A, half B ]
 * @param part "A", "B" or "both": which half to render, in its assembled position (turn B over to print it)
 */
module ilox_linear(width, height, div, clearance, voids = [], tip_clearance = undef, grid_n = 3, grid_m = 2,
                   extension_factor = 1, substrate_height = 1, colors = [ "ForestGreen", "MidnightBlue" ],
                   part = "both")
{
    halves_checked = _ilox_check_halves("ilox_linear", substrate_height, colors, part);
    grid_checked = assert(_ilox_is_count(grid_n, 2), str("ERROR: ilox_linear: grid_n must be a whole number of at ",
                                                         "least 2, so B rails sit between the A rails, got: ", grid_n))
        assert(_ilox_is_count(grid_m, 1),
               str("ERROR: ilox_linear: grid_m must be a whole number of at least 1, got: ", grid_m))
            assert(is_num(extension_factor) && extension_factor >= 0 && extension_factor <= 1,
                   str("ERROR: ilox_linear: extension_factor must be from 0 to 1, got: ", extension_factor)) true;

    cells = calc_ucell(width = width, height = height, div = div, clearance = clearance, voids = voids,
                       tip_clearance = tip_clearance);

    // A rails two cell widths apart on a square grid, with a B rail midway between each pair
    tessellation_width = width * 2;
    tess_points = squares_centers_rect(side = tessellation_width, n = grid_n, m = grid_m);
    tess_points_midp = square_midpoints(tess_points);
    tess_sq_vertices = squares_vertices(side = tessellation_width, centers = tess_points);

    for (k = [0:1])
        if (part == "both" || part == (k == 0 ? "A" : "B"))
        {
            place_linear_cells(cells = cells, positions = k == 0 ? tess_points : tess_points_midp, width = width,
                               cell_type = k == 0 ? "A" : "B", color = colors[k],
                               extension = extension_factor * width);

            // Substrate: solid squares beneath the A cells, above the B cells
            color(colors[k]) translate([ 0, 0, k == 0 ? -substrate_height : height ])
                generic_poly(vertices = tess_sq_vertices, paths = [[ 0, 1, 2, 3, 0 ]],
                             centers = k == 0 ? tess_points : tess_points_midp, alpha = 0.5,
                             extrude = substrate_height);
        }
}

// True for a whole number of at least least
function _ilox_is_count(n, least) = is_num(n) && n == round(n) && n >= least;

// Checks the arguments ilox_radial() and ilox_linear() share. Called as an assignment, ahead of the cells, so it stops
// a bad call before any geometry is computed.
function _ilox_check_halves(name, substrate_height, colors, part) =
    assert(is_num(substrate_height) && substrate_height > 0,
           str("ERROR: ", name, ": substrate_height must be a number > 0, got: ", substrate_height))
        assert(is_list(colors) && len(colors) == 2, str("ERROR: ", name, ": colors must be [ A, B ], got: ", colors))
            assert(part == "A" || part == "B" || part == "both",
                   str("ERROR: ", name, ": part must be \"A\", \"B\" or \"both\", got: ", part)) true;
