/**
 * @file ucell.scad
 * @brief Functions and modules for calculating and rendering unit cells.
 * @author Cameron K. Brooks
 * @copyright 2024
 *
 * This library provides functions to calculate the points of unit cells (cells A and B) based on given dimensions and
 * division points. It includes utilities for transforming and manipulating points, applying tolerances, and handling
 * optional negative polygons. Modules are provided to render these cells and to place spheres at specified points.
 */

/**
 * @brief Transforms a list of normalized points by scaling with width and height.
 *
 * Multiplies each point's x-coordinate by the given width and y-coordinate by the given height.
 *
 * @param points Array of points to be transformed, each point as [x, y].
 * @param width The scaling factor for the x-coordinate.
 * @param height The scaling factor for the y-coordinate.
 * @return An array of transformed points.
 */
function transformPoints(points, width, height) = [for (p = points)[width * p[0], height *p[1]]];

/**
 * @brief Transforms a list of normalized points by scaling with width and height.
 *
 * Multiplies each point's x-coordinate by the given width and y-coordinate by the given height.
 *
 * @param points Array of points to be transformed, each point as [x, y].
 * @param width The scaling factor for the x-coordinate.
 * @param height The scaling factor for the y-coordinate.
 * @return An array of transformed points.
 */
function transformPointsList(points, width, height) = [for (p = points) transformPoints(p, width, height)];

/**
 * @brief Mirrors a list of points across the lines x = 1 and y = 1.
 *
 * Subtracts each point's x and y coordinates from 1. If a third element exists (e.g., tolerance), it is preserved.
 *
 * @param points Array of points to be mirrored, each point as [x, y] or [x, y, z].
 * @return An array of mirrored points.
 */
function mirrorPoints(points) = [for (p = points)[1 - p[0], 1 - p[1], p[2]]];

/**
 * @brief Mirrors a list of points across the lines x = 1 and y = 1.
 *
 * Subtracts each point's x and y coordinates from 1. If a third element exists (e.g., tolerance), it is preserved.
 *
 * @param points Array of points to be mirrored, each point as [x, y] or [x, y, z].
 * @return An array of mirrored points.
 */
function mirrorPointsList(points) = [for (p = points) mirrorPoints(p)];

/**
 * @brief Reverses the order of elements in an array.
 *
 * @param arr The array to be reversed.
 * @return The reversed array.
 */
function reverseArray(arr) = [for (i = [0:len(arr) - 1]) arr[len(arr) - 1 - i]];

/**
 * @brief Removes consecutive duplicate points from a polyline.
 *
 * @param points Array of points, each as [x, y].
 * @return The polyline without zero-length segments.
 */
function dedupePolyline(points) =
    [for (i = [0:len(points) - 1]) if (i == 0 || norm(points[i] - points[i - 1]) > 1e-9) points[i]];

/**
 * @brief Starts a polyline on the line y = 0.
 *
 * If the polyline starts inside (y >= 0), its first segment is extended back to y = 0. If it starts below, it is cut
 * where it first crosses y = 0.
 *
 * @param pts Polyline, each point as [x, y], rising through y = 0 near its start.
 * @return The polyline starting on y = 0.
 */
function clipToBottom(pts) =
    let(n = len(pts),
        // First segment that crosses y = 0 upward (only used when the polyline starts below)
        j = [for (i = [0:n - 2]) if (pts[i][1] < 0 && pts[i + 1][1] >= 0) i][0],
        u = pts[1] - pts[0])
    pts[0][1] >= 0
        ? assert(u[1] > 1e-9, "iLOX: the division line must rise off the cell's bottom and top edges")
              concat([pts[0] - u * pts[0][1] / u[1]], [for (i = [1:n - 1]) pts[i]])
        : assert(!is_undef(j), "iLOX: clearance is too large for this division line")
              let(s = pts[j + 1] - pts[j])
                  dedupePolyline(concat([pts[j] - s * pts[j][1] / s[1]], [for (i = [j + 1:n - 1]) pts[i]]));

/**
 * @brief Offsets a division line sideways by a fixed distance.
 *
 * Every segment moves by d along its left-hand normal (right-hand for negative d), so each offset segment is parallel
 * to the original at exactly |d|. Interior vertices take the miter of their two segments. The ends are then trimmed or
 * extended to the cell's bottom (y = 0) and top (y = height) edges, so where the line meets an edge at a shallow angle
 * the gap there widens to |d| / sin(angle), as a true offset does.
 *
 * @param points Division line from the bottom edge to the top edge, each point as [x, y], no repeated points.
 * @param d Offset distance; positive moves toward cell A (left of the line).
 * @param height The height of the unit cell.
 * @return The offset division line, running from the bottom edge to the top edge.
 */
function offsetDivision(points, d, height) =
    let(n = len(points),
        dirs = [for (i = [0:n - 2])(points[i + 1] - points[i]) / norm(points[i + 1] - points[i])],
        normals = [for (u = dirs)[-u[1], u[0]]],
        // Ends move straight out; interior vertices take the miter of their two segments
        miter = function(i) let(m = normals[i - 1] + normals[i], k = 1 + normals[i - 1] * normals[i])
            assert(k > 1e-9, "iLOX: the division line cannot fold back on itself") m / k,
        raw = [for (i = [0:n - 1]) points[i] + d * (i == 0 ? normals[0] : i == n - 1 ? normals[n - 2] : miter(i))],
        // A segment that reverses (a notch narrower than the clearance) is only allowed if clipping removes it
        inverted = [for (i = [0:n - 2]) if ((raw[i + 1] - raw[i]) * dirs[i] <= 0) i],
        inside = function(p) p[1] >= 0 && p[1] <= height,
        // Reverse and mirror top-to-bottom, so clipToBottom can clip the top end too
        flip = function(pts)[for (i = [len(pts) - 1:-1:0])[pts[i][0], height - pts[i][1]]])
        assert(len([for (i = inverted) if (inside(raw[i]) || inside(raw[i + 1])) i]) == 0,
               "iLOX: clearance is too large for a short division segment; reduce clearance or simplify the line")
            flip(clipToBottom(flip(clipToBottom(raw))));

/**
 * @brief Calculates the points for unit cells A and B based on dimensions and division points.
 *
 * Generates the points for two unit cells by creating polygons from the division points, separating them by the
 * clearance, and handling optional negative polygons.
 *
 * The subdivision is determined automatically based on the y-values of the division points:
 * - If the first division point's y-value is in the range [0, 0.5], subdiv = 0.
 * - If the first division point's y-value is in the range [0.5, 1], subdiv = 1.
 * - If not in either range, an error is thrown.
 *
 * @param width The width of the unit cell.
 * @param height The height of the unit cell.
 * @param div Array of division points, each point as [x, y] in cell-normalised coordinates.
 * @param clearance Gap between cells A and B, in model units (mm), measured normal to the division line. Each cell
 * gives up half. 0 makes the cells touch.
 * @param neg_poly (Optional) Array of negative polygon points, each point as [x, y].
 * @return An array containing:
 *         - cell_pointsA: Points for cell A.
 *         - cell_pointsB: Points for cell B.
 *         - ncell_pointsA: Points for negative polygon of cell A (if neg_poly is provided).
 *         - ncell_pointsB: Points for negative polygon of cell B (if neg_poly is provided).
 */
function calc_ucell(width, height, div, clearance, neg_poly = []) =
    assert(is_num(clearance) && clearance >= 0, "iLOX: clearance must be a number >= 0 (mm)")
    assert(len([for (p = div) if (len(p) != 2) p]) == 0,
           "iLOX: division points are [x, y]; the per-point tolerance was replaced by the clearance argument (mm)")
    let(y_val = div[0][1],
        subdiv = (y_val == 0)   ? 0                                                                 // minor
                 : (y_val == 1) ? 1                                                                 // major
                                : assert(undef, "ERROR: Div start must be 0 (minor) or 1 (major)"), // error
        cornersA = [ [ 0, height ], [ 0, 0 ] ],   // A side: bottom left, top left
        cornersB = [[width, 0], [width, height]], // B side: top right, bottom right
        div_mirrored =
            subdiv ? concat(mirrorPoints(div), reverseArray(div)) : concat(div, mirrorPoints(reverseArray(div))),
        div_line = dedupePolyline(transformPoints(div_mirrored, width, height)),    // full line, bottom to top
        div_polyA = offsetDivision(div_line, clearance / 2, height),                // cell A side of the gap
        div_polyB = reverseArray(offsetDivision(div_line, -clearance / 2, height)), // cell B side, top to bottom
        cell_pointsA = concat(cornersA, div_polyA),                                 // cell A points
        cell_pointsB = concat(cornersB, div_polyB),                                 // cell B points
        ncell_points = len(neg_poly) > 0 ? calc_ucell_voids(width, height, neg_poly) : []) // negative polygons

        [cell_pointsA, cell_pointsB, flatten(ncell_points)];

/**
 * @brief Calculates the points for negative polygons of unit cells A and B based on dimensions and division points.
 *
 * Generates the points for two negative polygons by creating polygons from the division points, applying tolerances,
 * and handling optional negative polygons.
 *
 * The subdivision is determined automatically based on the y-values of the division points:
 * - If the first division point's y-value is in the range [0, 0.5], subdiv = 0.
 * - If the first division point's y-value is in the range [0.5, 1], subdiv = 1.
 * - If not in either range, an error is thrown.
 *
 * @param width The width of the unit cell.
 * @param height The height of the unit cell.
 * @param poly Array of negative polygon points, each point as [x, y].
 * @return An array containing:
 *         - ncell_pointsA: Points for negative polygon of cell A.
 *         - ncell_pointsB: Points for negative polygon of cell B.
 */
function calc_ucell_voids(width, height, poly = [[]]) =
    let(ncell_pointsA = len(poly) > 0 ? transformPointsList(poly, width, height) : [],
        ncell_pointsB = len(poly) > 0 ? transformPointsList(mirrorPointsList(poly), width, height) : [])
        [[ncell_pointsA], [ncell_pointsB]];

/**
 * @brief Renders unit cells with optional negative border offset.
 *
 * Draws the main cell polygons and, if provided, negative polygons. The negative polygons
 * are modified by applying an offset to produce a border cutout. This turns a simple
 * rectangle into a rectangle with a rectangular hole inside.
 *
 * @param cells An array of cell polygons: [cell_pointsA, cell_pointsB, ncell_pointsA, ncell_pointsB].
 * @param colors An array of colors to use for the polygons:
 *               0 -> cell_pointsA,
 *               1 -> cell_pointsB,
 *               2 -> ncell_pointsA,
 *               3 -> ncell_pointsB.
 * @param neg_border The width of the border offset to apply to negative polygons. Defaults to 0.1.
 */
module render_ucells(cells, colors = [ "GreenYellow", "Aqua", "ForestGreen", "Navy" ], neg_border = 0.05)
{
    // Unpack calculated cell points
    cell_pointsA = cells[0];
    cell_pointsB = cells[1];
    ncell_pointsA = cells[2][0];
    ncell_pointsB = cells[2][1];

    echo("ncell_pointsA new: ", ncell_pointsA);
    echo("ncell_pointsB new: ", ncell_pointsB);

    // Draw the main cell polygons
    color(colors[0]) polygon(points = cell_pointsA);
    color(colors[1]) polygon(points = cell_pointsB);

    // Draw the negative polygons if they exist
    translate([ 0, 0, 0.005 ]) if (!is_undef(ncell_pointsA))
    {
        for (i = [0:len(ncell_pointsA) - 1])
        {
            // negative cell points A
            color(colors[2]) difference()
            { // Create a bordered negative shape by cutting out an offset portion inside it
                intersection()
                {
                    polygon(points = ncell_pointsA[i]);
                    polygon(points = cell_pointsA);
                }

                offset(r = -neg_border) intersection()
                {
                    polygon(points = ncell_pointsA[i]);
                    polygon(points = cell_pointsA);
                }
            }

            // negative cell points B
            color(colors[3]) difference()
            {
                intersection()
                {
                    polygon(points = ncell_pointsB[i]);
                    polygon(points = cell_pointsB);
                }

                offset(r = -neg_border) intersection()
                {
                    polygon(points = ncell_pointsB[i]);
                    polygon(points = cell_pointsB);
                }
            }
        }
    }
}