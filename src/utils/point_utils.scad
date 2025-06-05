/**
 * @file point_utils.scad
 * @brief Utility functions for point operations in OpenSCAD.
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains helper functions for specific point operations,
 * such as sorting centers, calculating distances, checking point equality within
 * a tolerance, and filtering points based on certain criteria.
 *
 */

use <sorted.scad>

EPSILON = 1e-3; // Tolerance value used for floating-point comparisons.

/**
 * @brief Sorts an array of centers by their y-coordinate, then by x-coordinate.
 *
 * @param centers An array of points (centers) to be sorted, each as [x, y].
 * @return A sorted array of centers.
 */
function sort_centers(centers) = sorted(centers, key=function(p) [p[1], p[0]]); // Sort by y, then x

/**
 * @brief Flattens a nested array of arrays into a single array.
 *
 * This function takes an array of arrays and returns a single array containing all elements.
 *
 * @param nested_arrays A nested array to be flattened.
 * @return A single-level array containing all elements from the nested arrays.
 */
function flatten(nested_arrays) = [ for (subarray = nested_arrays) for (element = subarray) element ];

/**
 * @brief Calculates the height between rows of points in a sorted array.
 *
 * @param sorted_centers An array of centers sorted by y and x coordinates.
 * @return The height difference between rows, or undef if not applicable.
 */
function point_row_height(sorted_centers) =
  let (
    row_heights = [
      for (i = [1:len(sorted_centers) - 1]) if (sorted_centers[i][1] != sorted_centers[i - 1][1]) abs(sorted_centers[i][1] - sorted_centers[i - 1][1]),
    ]
  ) (len(row_heights) > 0) ? row_heights[0]
  : undef;

/**
 * @brief Finds the midpoints between adjacent points in each row and returns the new points.
 *
 * This function checks for points that are adjacent horizontally (same y but different x),
 * and places a new point exactly halfway between them.
 *
 * @param centers An array of points forming a grid with some horizontal gaps.
 * @return An array of new points placed between adjacent points in each row.
 */
function square_midpoints(centers) =
  let (sorted_centers = sort_centers(centers)) let (tri_centers = []) concat(
    // Flatten the array and filter out empty entries
    [
      for (i = [0:len(sorted_centers) - 2]) // for loop i
      let (p1 = sorted_centers[i], p2 = sorted_centers[i + 1]) // end let
      if (
        abs(p1[1] - p2[1]) < EPSILON && // p1 and p2 are in the same row
        p2[0] > p1[0] // p2 x-coordinate is greater than p1
      ) // end if
      (
        [
          (p1[0] + p2[0]) / 2, // x-coordinate of midpoint center
          (p1[1] + p2[1]) / 2, // y-coordinate of midpoint center
        ]
      ),
    ]
  );

/**
 * @brief Calculates the centers of triangles formed by adjacent points.
 *
 * Generates triangulated center points based on provided centers, useful for creating a triangulated grid or pattern.
 *
 * @param centers An array of points (centers) to be triangulated.
 * @return An array of triangulated center points.
 */
function triangulated_center_points(centers) =
  let (
    sorted_centers = sort_centers(centers),
    row_height = point_row_height(sorted_centers)
  ) let (tri_centers = []) concat(
    // Flatten the array and filter out empty entries
    [
      for (i = [0:len(sorted_centers) - 2]) // for loop i
      for (j = [0:len(sorted_centers) - 1]) // for loop j
      let (
        p1 = sorted_centers[i],
        p2 = sorted_centers[i + 1],
        p3 = sorted_centers[j]
      ) // end let
      if (
        abs(p1[1] - p2[1]) < EPSILON && // p1 and p2 are in the same row
        abs(p3[1] - p1[1] - row_height) < EPSILON && // p3 is in the next row
        p3[0] > p1[0] && // p3 x-coordinate is greater than p1
        p3[0] < p2[0] // p3 x-coordinate is less than p2
      ) // end if
      (
        [
          (p1[0] + p2[0] + p3[0]) / 3, // x-coordinate of triangle center
          (p1[1] + p2[1] + p3[1]) / 3, // y-coordinate of triangle center
        ]
      ),
    ]
  );

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
function filter_triangulated_center_points(r, centers, filter_list, tolerance = EPSILON) =
  let (
    n = len(centers)
  ) [for (i = [0:n - 1]) if (!is_within_radius(centers[i], r + tolerance, filter_list)) centers[i]];

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
  let (n = len(removal_points)) [for (i = [0:n - 1]) if (distance(point, removal_points[i]) < radius) true][0];

// ----------------------------------------------------------------------
// REPLACE WITH FUNCTIONALOPENSCAD LIBRARY
// ----------------------------------------------------------------------
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
function arc_points(diameter, start_angle, end_angle, num_points, z_val = 0) =
  let (
    radius = diameter / 2
  ) [
      for (i = [0:num_points]) [
        radius * cos(start_angle + (end_angle - start_angle) * i / num_points),
        radius * sin(start_angle + (end_angle - start_angle) * i / num_points),
        z_val,
      ],
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
    for (p = points) (len(p) == 3) ? [p[0] + shift_x, p[1] + shift_y, p[2] + shift_z]
    : [p[0] + shift_x, p[1] + shift_y],
  ];
