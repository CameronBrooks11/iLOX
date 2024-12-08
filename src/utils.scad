/**
 * @file utils.scad
 * @brief Utility functions for point operations in OpenSCAD.
 * @author Cameron K. Brooks
 * @copyright 2024
 *
 * This file contains helper functions and modules for various point operations,
 * such as sorting centers, calculating distances, checking point equality within
 * a tolerance, and filtering points based on certain criteria. These utilities are
 * useful for geometric computations and manipulations in OpenSCAD scripts.
 */

use <sorted.scad>

EPSILON = 1e-3; ///< Tolerance value used for floating-point comparisons.

/**
 * @brief Sorts an array of centers by their y-coordinate, then by x-coordinate.
 *
 * @param centers An array of points (centers) to be sorted, each as [x, y].
 * @return A sorted array of centers.
 */
function sort_centers(centers) = sorted(centers, key = function(p)[p[1], p[0]]); // Sort by y, then x

/**
 * @brief Calculates the height between rows of points in a sorted array.
 *
 * @param sorted_centers An array of centers sorted by y and x coordinates.
 * @return The height difference between rows, or undef if not applicable.
 */
function point_row_height(sorted_centers) =
    let(row_heights = [for (i = [1:len(sorted_centers) - 1]) if (sorted_centers[i][1] != sorted_centers[i - 1][1])
                abs(sorted_centers[i][1] - sorted_centers[i - 1][1])])(len(row_heights) > 0)
        ? row_heights[0]
        : undef;

/**
 * @brief Checks if two points are equal within a specified tolerance.
 *
 * @param p1 First point as [x, y].
 * @param p2 Second point as [x, y].
 * @param tolerance (Optional) Tolerance value for comparison; default is EPSILON.
 * @return True if points are equal within tolerance, false otherwise.
 */
function points_equal(p1, p2, tolerance = EPSILON) = let(comparisons = [for (i = [0:len(p1) - 1]) abs(p1[i] - p2[i]) <
                                                             tolerance])
                                                     // Check if all comparisons are true
                                                     len([for (comp = comparisons) if (comp) true]) == len(comparisons);

/**
 * @brief Calculates the Euclidean distance between two points.
 *
 * @param p1 First point as [x, y].
 * @param p2 Second point as [x, y].
 * @return The distance between p1 and p2.
 */
function distance(p1, p2) = sqrt(pow(p2[0] - p1[0], 2) + pow(p2[1] - p1[1], 2));

/**
 * @brief Checks if a point is within a certain radius of any point in a given array.
 *
 * @param point The point to check, as [x, y].
 * @param radius The radius within which to check for proximity.
 * @param removal_points Array of points to compare against.
 * @return True if the point is within radius of any point in removal_points, false otherwise.
 */
function is_within_radius(point, radius, removal_points) =
    let(n = len(removal_points))[for (i = [0:n - 1]) if (distance(point, removal_points[i]) < radius) true][0];

/**
 * @brief Calculates the centers of triangles formed by adjacent points.
 *
 * Generates triangulated center points based on provided centers, useful for creating a triangulated grid or pattern.
 *
 * @param centers An array of points (centers) to be triangulated.
 * @return An array of triangulated center points.
 */
function triangulated_center_points(centers) = let(sorted_centers = sort_centers(centers),
                                                   row_height = point_row_height(sorted_centers)) let(tri_centers = [])
    concat( // Flatten the array and filter out empty entries
        [for (i = [0:len(sorted_centers) - 2]) for (j = [0:len(sorted_centers) - 1])
                let(p1 = sorted_centers[i], p2 = sorted_centers[i + 1],
                    p3 = sorted_centers[j]) if (abs(p1[1] - p2[1]) < EPSILON && // p1 and p2 are in the same row
                                                abs(p3[1] - p1[1] - row_height) < EPSILON && // p3 is in the next row
                                                p3[0] > p1[0] && // p3 x-coordinate is greater than p1
                                                p3[0] < p2[0]    // p3 x-coordinate is less than p2
                                                )([
                    (p1[0] + p2[0] + p3[0]) / 3, // x-coordinate of triangle center
                    (p1[1] + p2[1] + p3[1]) / 3  // y-coordinate of triangle center
                ])]);

/**
 * @brief Checks if a point exists within a list of points, within a specified tolerance.
 *
 * @param point The point to check, as [x, y].
 * @param list The list of points to search within.
 * @param tolerance (Optional) Tolerance value for comparison; default is EPSILON.
 * @return True if the point exists in the list within tolerance, false otherwise.
 */
function is_point_in_list(point, list,
                          tolerance = EPSILON) = let(equal_points = [for (p = list) points_equal(p, point, tolerance)])
                                                     len([for (eq = equal_points) if (eq) true]) > 0;

/**
 * @brief Filters out centers that are present in a filter list.
 *
 * Removes centers from the provided list that match any in the filter_list, within a specified tolerance.
 *
 * @param centers An array of centers to be filtered.
 * @param filter_list An array of centers to filter out.
 * @param tolerance (Optional) Tolerance value for comparison; default is EPSILON.
 * @return A filtered array of centers.
 */
function filter_center_points(centers, filter_list, tolerance = EPSILON) =
    [for (center = centers) if (!is_point_in_list(center, filter_list, tolerance)) center];

/**
 * @brief Filters out points from centers that are within a radius of points in the filter list.
 *
 * Useful for removing points that are too close to certain areas or features.
 *
 * @param r The radius within which to filter out points.
 * @param centers An array of centers to be filtered.
 * @param filter_list An array of points to filter against.
 * @param tolerance (Optional) Tolerance value for comparison; default is EPSILON.
 * @return A filtered array of centers.
 */
function filter_triangulated_center_points(r, centers, filter_list, tolerance = EPSILON) = let(
    n = len(centers))[for (i = [0:n - 1]) if (!is_within_radius(centers[i], r + tolerance, filter_list)) centers[i]];

/**
 * @brief Renders points as text labels and optional spheres in the 3D space.
 *
 * Displays each point's coordinates as text at its location and optionally places a sphere at the point.
 *
 * @param points An array of points to display, each as [x, y].
 * @param text_size (Optional) Size of the text labels; default is 1.
 * @param color (Optional) Color of the text labels; default is [0.1, 0.1, 0.1].
 * @param pointD (Optional) Diameter of the sphere to place at each point; if undef, no sphere is placed.
 * @param point_color (Optional) Color of the spheres; default is [0.1, 0.1, 0.1].
 * @param fn (Optional) Number of facets for the spheres; default is 8.
 */
module print_points(points, text_size = 1, color = [ 0.1, 0.1, 0.1 ], pointD = undef, point_color = [ 0.1, 0.1, 0.1 ],
                    fn = 8)
{
    for (point = points)
    {
        // Translate +1 in Z-axis to avoid z-fighting with the surface
        translate([ point[0], point[1], 1 ]) color(color)
            text(str("[", point[0], ", ", point[1], "]"), size = text_size, valign = "center", halign = "center");
        if (pointD != undef)
        {
            // Place a sphere at the point if pointD is specified
            color(point_color) translate([ point[0], point[1], 1 ]) sphere(pointD, $fn = fn);
        }
    }
}

/**
 * @brief Places spheres at specified points.
 *
 * Renders spheres at given points with specified diameter and color. If zGap is undef, 
 * it will use the point's z-value if provided, otherwise 0. If zGap is defined, it 
 * overrides any z-value in the points.
 *
 * @param points Array of points where spheres will be placed, each point as [x, y] or [x, y, z].
 * @param d Diameter of the spheres.
 * @param color Color of the spheres.
 * @param zGap (Optional) Height offset for the spheres along the z-axis. Defaults to undef.
 *             If undef and the point has a z-value, that is used. If undef and the point 
 *             has no z-value, 0 is used.
 * @param fn Number of facets used to render the sphere.
 */
module place_spheres(points, d, color, zGap = undef, fn = 6)
{
    for (p = points) {
        translate([
            p[0],
            p[1],
            (zGap == undef)
                ? (len(p) == 3 ? p[2] : 0)
                : zGap
        ]) color(color) sphere(d, $fn = fn);
    }
}

/**
 * @brief Generates a series of points defining an arc.
 *
 * Returns a list of (x,y) coordinates forming an arc specified by a start angle, end angle, and number of points.
 * The arc is determined by the radius derived from the given diameter.
 *
 * @param diameter The diameter of the arc's circle.
 * @param start_angle The starting angle of the arc (in degrees).
 * @param end_angle The ending angle of the arc (in degrees).
 * @param num_points The number of points along the arc, defining its resolution.
 * @param z_val The z-coordinate value for the arc points.
 *
 * @return A list of [x, y] points representing the arc.
 */
function arc_points(diameter, start_angle, end_angle, num_points, z_val=0) =
    let(radius = diameter / 2)
    [
        for (i = [0 : num_points]) 
            [ 
                radius * cos(start_angle + (end_angle - start_angle) * i / num_points), 
                radius * sin(start_angle + (end_angle - start_angle) * i / num_points),
                z_val
            ]
    ];

/**
 * @brief Shifts a list of points by a given offset.
 *
 * Returns a new list of points, each adjusted by the specified shift amount in the x and y directions,
 * and optionally in the z direction if the points contain a z-coordinate.
 *
 * If a point contains [x, y], it will be shifted by [shift_x, shift_y].
 * If a point contains [x, y, z], it will be shifted by [shift_x, shift_y, shift_z].
 *
 * @param points An array of points, each as [x, y] or [x, y, z].
 * @param shift_x The amount to shift in the x-direction.
 * @param shift_y The amount to shift in the y-direction.
 * @param shift_z (Optional) The amount to shift in the z-direction. Defaults to 0.
 * @return A new array of points, each shifted by the specified amounts.
 */
function shift_points(points, shift_x, shift_y, shift_z = 0) =
    [
        for (p = points) 
            (len(p) == 3)
            ? [p[0] + shift_x, p[1] + shift_y, p[2] + shift_z]
            : [p[0] + shift_x, p[1] + shift_y]
    ];
