/**
 * @file ucell.scad
 * @brief Functions and modules for calculating and rendering unit cells.
 * @author Cameron K. Brooks
 * @copyright 2024
 *
 * This library provides functions to calculate the points of unit cells (cells A and B) based on given dimensions and
 * division points. It includes utilities for transforming and manipulating points, separating the cells by a
 * clearance, and handling optional negative polygons. Modules are provided to render these cells and to place spheres
 * at specified points.
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
 * Subtracts each point's x and y coordinates from 1.
 *
 * @param points Array of points to be mirrored, each point as [x, y].
 * @return An array of mirrored points.
 */
function mirrorPoints(points) = [for (p = points)[1 - p[0], 1 - p[1]]];

/**
 * @brief Mirrors a list of points across the lines x = 1 and y = 1.
 *
 * Subtracts each point's x and y coordinates from 1.
 *
 * @param points Array of points to be mirrored, each point as [x, y].
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
 * @brief Offsets a polyline sideways by a fixed distance.
 *
 * Moves each segment by d along its left-hand normal (right-hand for negative d), mitering interior vertices.
 *
 * @param points Polyline, each point as [x, y], no repeated points.
 * @param d Offset distance.
 * @return The offset polyline, with the same number of points.
 */
function offsetPolyline(points, d) =
    let(n = len(points),
        dirs = [for (i = [0:n - 2])(points[i + 1] - points[i]) / norm(points[i + 1] - points[i])],
        normals = [for (u = dirs)[-u[1], u[0]]])
    [for (i = [0:n - 1])
        let(m = i == 0 ? normals[0] : i == n - 1 ? normals[n - 2] : normals[i - 1] + normals[i],
            k = i == 0 || i == n - 1 ? 1 : 1 + normals[i - 1] * normals[i])
        assert(k > 1e-9, "ERROR: Div line folds back on itself") points[i] + m * d / k];

/**
 * @brief Clips a polygon to one side of an axis-aligned line (one Sutherland-Hodgman step).
 *
 * @param poly Polygon, each point as [x, y].
 * @param axis 0 for a vertical line x = bound, 1 for a horizontal line y = bound.
 * @param bound Position of the line.
 * @param side 1 keeps points at or above the bound, -1 at or below it.
 * @return The clipped polygon.
 */
function clipToAxis(poly, axis, bound, side) =
    let(n = len(poly), s = [for (p = poly) side * (p[axis] - bound)])
    [for (i = [0:n - 1]) let(j = (i + 1) % n) each concat(
        s[i] >= 0 ? [poly[i]] : [],
        (s[i] >= 0) != (s[j] >= 0) ? [poly[i] + (poly[j] - poly[i]) * s[i] / (s[i] - s[j])] : [])];

/**
 * @brief Calculates the part of the unit cell left of a division line, a distance d clear of it.
 *
 * Offsets the line by d, extends both ends far past the cell, closes the shape counter-clockwise around the cell and
 * clips it to the cell.
 *
 * @param line Division line from the bottom edge to the top edge, each point as [x, y], no repeated points.
 * @param d Distance between the part and the line.
 * @param width The width of the unit cell.
 * @param height The height of the unit cell.
 * @return The part's points.
 */
function cellLeftOf(line, d, width, height) =
    assert(line[1][1] > 1e-9, "ERROR: Div line must rise off the bottom edge")
    let(o = offsetPolyline(line, d),
        n = len(o),
        center = [ width, height ] / 2,
        r = 2 * norm([ width, height ]) + d, // far enough that the closing arc stays clear of the cell
        start = o[0] + (o[0] - o[1]) / norm(o[0] - o[1]) * r,
        end = o[n - 1] + (o[n - 1] - o[n - 2]) / norm(o[n - 1] - o[n - 2]) * r,
        a0 = atan2(end[1] - center[1], end[0] - center[0]),
        a1 = atan2(start[1] - center[1], start[0] - center[0]),
        arc = [for (a = [a0:10:a1 < a0 ? a1 + 360 : a1]) center + r * [ cos(a), sin(a) ]],
        shape = concat([start], o, [end], arc),
        part = clipToAxis(clipToAxis(clipToAxis(clipToAxis(shape, 0, 0, 1), 0, width, -1), 1, 0, 1), 1, height, -1))
        // The end segments set the extensions, so the offset must not shorten them to nothing or turn them round
        assert((o[1] - o[0]) * (line[1] - line[0]) > 1e-9 && (o[n - 1] - o[n - 2]) * (line[n - 1] - line[n - 2]) > 1e-9,
               "ERROR: clearance too large for the div line")
        assert(len(part) >= 3, "ERROR: clearance too large for the div line") dropCollinear(part);

/**
 * @brief Gives the side of the line through a and b that p lies on: 1 left, -1 right, 0 on the line.
 */
function turn(a, b, p) = let(v = (b - a)[0] * (p - a)[1] - (b - a)[1] * (p - a)[0]) abs(v) < 1e-9 ? 0 : sign(v);

/**
 * @brief Tests whether segments a-b and c-d cross at a point inside both.
 */
function segmentsCross(a, b, c, d) = turn(a, b, c) * turn(a, b, d) < 0 && turn(c, d, a) * turn(c, d, b) < 0;

/**
 * @brief Tests whether segments a-b and c-d lie on one line and overlap by more than a point.
 */
function segmentsOverlap(a, b, c, d) =
    turn(a, b, c) == 0 && turn(a, b, d) == 0 &&
    (let(u = (b - a) / norm(b - a), s = [ (c - a) * u, (d - a) * u ]) min(max(s), norm(b - a)) - max(min(s), 0) > 1e-9);

/**
 * @brief Removes polygon vertices that lie on the line through their neighbours, including duplicates and the
 * zero-area spikes clipping leaves along the cell's edges.
 */
function dropCollinear(poly) =
    let(n = len(poly),
        d = [for (i = [0:n - 1]) if (norm(poly[i] - poly[(i + 1) % n]) > 1e-9) poly[i]], // repeats first
        m = len(d),
        keep = [for (i = [0:m - 1]) if (turn(d[(i + m - 1) % m], d[i], d[(i + 1) % m]) != 0) d[i]])
        len(keep) == n ? poly : dropCollinear(keep);

/**
 * @brief Calculates the distance from p to the segment a-b.
 */
function segmentDistance(p, a, b) = let(ab = b - a, t = max(0, min(1, (p - a) * ab / (ab * ab)))) norm(p - a - ab * t);

/**
 * @brief Tests whether p lies on the segment a-b.
 */
function onSegment(p, a, b) = turn(a, b, p) == 0 && (p - a) * (b - a) >= -1e-9 && (p - b) * (a - b) >= -1e-9;

/**
 * @brief Lists a polygon's edges, each as [start, end].
 */
function polygonEdges(poly) = [for (i = [0:len(poly) - 1])[poly[i], poly[(i + 1) % len(poly)]]];

/**
 * @brief Gives the bounding box of a segment as [xmin, xmax, ymin, ymax].
 */
function segmentBox(e) = [ min(e[0][0], e[1][0]), max(e[0][0], e[1][0]), min(e[0][1], e[1][1]), max(e[0][1], e[1][1]) ];

/**
 * @brief Tests whether two bounding boxes come within m of each other.
 */
function boxesNear(a, b, m) = a[0] <= b[1] + m && b[0] <= a[1] + m && a[2] <= b[3] + m && b[2] <= a[3] + m;

/**
 * @brief Calculates the points for unit cells A and B based on dimensions and division points.
 *
 * Generates the points for two unit cells by creating polygons from the division points, separating them by the
 * clearance, and handling optional negative polygons.
 *
 * The subdivision is determined by the first division point's y-value: 0 for the minor half (subdiv = 0), 1 for the
 * major half (subdiv = 1); anything else is an error.
 *
 * @param width The width of the unit cell.
 * @param height The height of the unit cell.
 * @param div Array of division points, each point as [x, y].
 * @param clearance Gap between cells A and B in mm, measured normal to the division line.
 * @param neg_poly (Optional) Array of negative polygon points, each point as [x, y].
 * @param tip_clearance (Optional) Gap in mm between each cell's tip and the opposite substrate; defaults to clearance.
 * @return An array containing:
 *         - cell_pointsA: Points for cell A.
 *         - cell_pointsB: Points for cell B.
 *         - [ncell_pointsA, ncell_pointsB]: Negative polygons of cells A and B (empty if neg_poly is not provided).
 */
function calc_ucell(width, height, div, clearance, neg_poly = [], tip_clearance = undef) =
    assert(is_num(clearance) && clearance >= 0, "ERROR: clearance must be a number >= 0")
    assert(is_undef(tip_clearance) || is_num(tip_clearance) && tip_clearance >= 0 && tip_clearance < height,
           "ERROR: tip_clearance must be a number >= 0 and below the cell height")
    assert(len([for (p = div) if (len(p) != 2) p]) == 0, "ERROR: Div points must be [x, y]")
    let(y_val = div[0][1],
        subdiv = (y_val == 0)   ? 0                                                                 // minor
                 : (y_val == 1) ? 1                                                                 // major
                                : assert(undef, "ERROR: Div start must be 0 (minor) or 1 (major)"), // error
        div_mirrored =
            subdiv ? concat(mirrorPoints(div), reverseArray(div)) : concat(div, mirrorPoints(reverseArray(div))),
        div_line = dedupePolyline(transformPoints(div_mirrored, width, height)), // full line, bottom to top
        tip = is_undef(tip_clearance) ? clearance : tip_clearance,
        cell_pointsA =
            dropCollinear(clipToAxis(cellLeftOf(div_line, clearance / 2, width, height), 1, height - tip, -1)),
        cell_pointsB = [for (p = cell_pointsA)[width - p[0], height - p[1]]],    // cell A turned 180 degrees
        ncell_points = len(neg_poly) > 0 ? calc_ucell_voids(width, height, neg_poly) : [], // negative polygons
        // Cell B is cell A turned 180 degrees, so checking A covers both
        edgesA = polygonEdges(cell_pointsA),
        edgesB = polygonEdges(cell_pointsB),
        boxA = [for (e = edgesA) segmentBox(e)],
        boxB = [for (e = edgesB) segmentBox(e)],
        n = len(edgesA),
        gaps = [for (p = cell_pointsA, k = [0:n - 1]) if (boxesNear([ p[0], p[0], p[1], p[1] ], boxB[k], clearance))
                segmentDistance(p, edgesB[k][0], edgesB[k][1])])
        // A split cell shows up as edges doubling back along the unit cell's border, or touching at a point
        assert(len([for (i = [0:n - 1], j = [i + 1:1:n - 1]) let(e = edgesA[i], f = edgesA[j])
                   if (boxesNear(boxA[i], boxA[j], 1e-9) &&
                       (segmentsCross(e[0], e[1], f[0], f[1]) || segmentsOverlap(e[0], e[1], f[0], f[1]) ||
                        j != i + 1 && !(i == 0 && j == n - 1) &&
                            (onSegment(f[0], e[0], e[1]) || onSegment(f[1], e[0], e[1]) ||
                             onSegment(e[0], f[0], f[1]) || onSegment(e[1], f[0], f[1])))) 1]) == 0,
               "ERROR: Div line folds or splits the cells at this clearance")
        assert(len([for (e = edgesA) if (abs(e[0][1]) < 1e-9 && abs(e[1][1]) < 1e-9 && norm(e[1] - e[0]) > 1e-9) 1]),
               "ERROR: Div line leaves cell A off its substrate")
        assert(len([for (i = [0:n - 1], k = [0:n - 1]) let(e = edgesA[i], f = edgesB[k])
                       if (boxesNear(boxA[i], boxB[k], 1e-9) && segmentsCross(e[0], e[1], f[0], f[1])) 1]) == 0 &&
                   (len(gaps) == 0 || min(gaps) > clearance - 1e-6),
               "ERROR: Div line brings the cells closer than the clearance")

            [cell_pointsA, cell_pointsB, flatten(ncell_points)];

/**
 * @brief Calculates the points for negative polygons of unit cells A and B based on dimensions and division points.
 *
 * Generates the points for two negative polygons by creating polygons from the division points and handling optional
 * negative polygons.
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