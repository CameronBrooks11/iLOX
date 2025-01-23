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
 * @brief Applies tolerance to the x-coordinates of a list of points.
 *
 * Adjusts the x-coordinate of each point by subtracting the corresponding tolerance value. If reverse_tolerance is
 * true, the tolerance is added instead.
 *
 * @param width The width used to scale the tolerance.
 * @param points Array of points to apply tolerance to, each point as [x, y].
 * @param div Array of division points, each with optional tolerance as [x, y, tolerance].
 * @param reverse_tolerance Boolean flag to reverse the direction of tolerance application.
 * @return An array of points with adjusted x-coordinates.
 */
function applyTolerance(width, points, div, reverse_tolerance = false) = [for (i = [0:len(points) - 1])
        let(tolerance = (len(div[i % len(div)]) > 2
                             ? (width * div[i % len(div)][2]) / 2
                             : 0))[points[i][0] -
                                       (reverse_tolerance ? -tolerance : tolerance), // Adjust x-coordinate by tolerance
                                   points[i][1]                                      // y-coordinate remains the same
]];

/**
 * @brief Calculates the points for unit cells A and B based on dimensions and division points.
 *
 * Generates the points for two unit cells by creating polygons from the division points, applying tolerances, and
 * handling optional negative polygons.
 *
 * The subdivision is determined automatically based on the y-values of the division points:
 * - If the first division point's y-value is in the range [0, 0.5], subdiv = 0.
 * - If the first division point's y-value is in the range [0.5, 1], subdiv = 1.
 * - If not in either range, an error is thrown.
 *
 * @param width The width of the unit cell.
 * @param height The height of the unit cell.
 * @param div Array of division points, each point as [x, y, optional tolerance].
 * @param neg_poly (Optional) Array of negative polygon points, each point as [x, y].
 * @return An array containing:
 *         - cell_pointsA: Points for cell A.
 *         - cell_pointsB: Points for cell B.
 *         - ncell_pointsA: Points for negative polygon of cell A (if neg_poly is provided).
 *         - ncell_pointsB: Points for negative polygon of cell B (if neg_poly is provided).
 */
function calc_ucell(width, height, div, neg_poly = []) = let(
    y_val = div[0][1],
    subdiv = (y_val == 0)   ? 0                                                                 // minor
             : (y_val == 1) ? 1                                                                 // major
                            : assert(undef, "ERROR: Div start must be 0 (minor) or 1 (major)"), // error
    cornersA = [ [ 0, height ], [ 0, 0 ] ],   // A side: bottom left, top left
    cornersB = [[width, 0], [width, height]], // B side: top right, bottom right
    div_mirrored = subdiv ? concat(mirrorPoints(div), reverseArray(div)) : concat(div, mirrorPoints(reverseArray(div))),
    div_polyA = transformPoints(div_mirrored, width, height),    // transform division points for cell A
    div_polyB = reverseArray(div_polyA),                         // reverse division points to create cell B
    div_polyA_tol = applyTolerance(width, div_polyA, div),       // apply tolerance to div_polyA
    div_polyB_tol = applyTolerance(width, div_polyB, div, true), // apply tolerance to div_polyB
    cell_pointsA = concat(cornersA, div_polyA_tol),              // cell A points
    cell_pointsB = concat(cornersB, div_polyB_tol),              // cell B points
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