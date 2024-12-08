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
 * @brief Mirrors a list of points across the lines x = 1 and y = 1.
 *
 * Subtracts each point's x and y coordinates from 1. If a third element exists (e.g., tolerance), it is preserved.
 *
 * @param points Array of points to be mirrored, each point as [x, y] or [x, y, z].
 * @return An array of mirrored points.
 */
function mirrorPoints(points) = [for (p = points)[1 - p[0], 1 - p[1], p[2]]];

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
function calc_ucells(width, height, div, neg_poly = []) = let(
    y_val = div[0][1],
    subdiv = (y_val == 0) ? 0 :
             ((y_val == 1) ? 1 :
              assert(undef, "ERROR: Division point starting point y-val must be 0 (minor definition) or 1 (major definition).")),
    cornersA = [ [ 0, height ], [ 0, 0 ] ],
    cornersB = [ [ width, 0 ], [ width, height ] ],
    div_mirrored = subdiv ? concat(mirrorPoints(div), reverseArray(div))
                          : concat(div, mirrorPoints(reverseArray(div))),
    div_polyA = transformPoints(div_mirrored, width, height),
    div_polyB = reverseArray(div_polyA),
    div_polyA_tol = applyTolerance(width, div_polyA, div),
    div_polyB_tol = applyTolerance(width, div_polyB, div, true),
    cell_pointsA = concat(cornersA, div_polyA_tol),
    cell_pointsB = concat(cornersB, div_polyB_tol),
    ncell_pointsA = len(neg_poly) > 0 ? transformPoints(neg_poly, width, height) : [],
    ncell_pointsB = len(neg_poly) > 0 ? transformPoints(mirrorPoints(neg_poly), width, height) : []
)[cell_pointsA, cell_pointsB, ncell_pointsA, ncell_pointsB];


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
    ncell_pointsA = cells[2];
    ncell_pointsB = cells[3];

    // Draw the main cell polygons
    color(colors[0]) polygon(points = cell_pointsA);
    color(colors[1]) polygon(points = cell_pointsB);

    // Draw the negative polygons if they exist
    if (len(ncell_pointsA) > 0)
    {
        // Create a bordered negative shape by cutting out an offset portion inside it
        color(colors[2])
        difference() {
            polygon(points = ncell_pointsA);
            offset(r = -neg_border) polygon(points = ncell_pointsA);
        }

        color(colors[3])
        difference() {
            polygon(points = ncell_pointsB);
            offset(r = -neg_border) polygon(points = ncell_pointsB);
        }
    }
}