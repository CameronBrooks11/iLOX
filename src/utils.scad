/*
 * Title: Point Calculation Utilities
 * Author: [Your Name]
 * Organization: [Your Organization]
 * 
 * License: [Specify License]
 *
 * Description:
 *   This OpenSCAD script, named 'point-calculation-utils.scad', includes a collection 
 *   of functions designed for calculating and manipulating points. The script offers 
 *   functionalities such as sorting points, calculating row heights, generating 
 *   triangulated center points, and filtering points. These utilities are essential 
 *   for geometric manipulations and can be used in a variety of design and modeling contexts.
 *
 * Dependencies:
 *   sorted-nop\sorted.scad - Required for sorting functionality.
 *
 * Usage Notes:
 *   To use these functions, include this script in your OpenSCAD project. You can 
 *   apply these functions to manipulate point data in your models, such as sorting 
 *   points, finding unique points, or filtering based on specific criteria. Ensure 
 *   that 'sorted-nop\sorted.scad' is accessible in your project directory.
 *
 * Parameters:
 *   centers - Array of point coordinates.
 *   sorted_centers - Array of sorted point coordinates.
 *   point - A single point coordinate.
 *   list - A list of points for comparison or filtering.
 *   tolerance - A small value to account for numerical precision issues.
 *
 * Revision History:
 *   [YYYY-MM-DD] - Initial version.
 *   [YYYY-MM-DD] - Subsequent updates with details.
 */


use <sorted-NopSCADlib\sorted.scad>

/*

This script is for functions related to point calculations

*/


EPSILON = 1e-3;

// Function to sort  centers
function sort_centers(centers) =
    sorted(centers, key = function(p) [p[1], p[0]]);  // Sort by y, then x

// Function to calculate the point row's height
function point_row_height(sorted_centers) =
    let (
        row_heights = [
            for (i = [1 : len(sorted_centers) - 1])
                if (sorted_centers[i][1] != sorted_centers[i - 1][1])
                    abs(sorted_centers[i][1] - sorted_centers[i - 1][1])
        ]
    )
    (len(row_heights) > 0) ? row_heights[0] : undef;

// Function to calculate triangulated centers
function triangulated_center_points(centers) =
    let (
        sorted_centers = sort_centers(centers),
        row_height = point_row_height(sorted_centers)
    )
    let (
        tri_centers = []
    )
    concat(  // Flatten the array and filter out empty entries
        [
            for (i = [0 : len(sorted_centers) - 2]) 
                for (j = [0 : len(sorted_centers) - 1])
                    let (
                        p1 = sorted_centers[i],
                        p2 = sorted_centers[i + 1],
                        p3 = sorted_centers[j]
                    )
                    if (abs(p1[1] - p2[1]) < EPSILON && abs(p3[1] - p1[1] - row_height) < EPSILON && p3[0] > p1[0] && p3[0] < p2[0])
                        ([(p1[0] + p2[0] + p3[0]) / 3, (p1[1] + p2[1] + p3[1]) / 3])
        ]
    );

// Function to check if two points are equal within a tolerance
function points_equal(p1, p2, tolerance=EPSILON) =
    let(
        comparisons = [for(i = [0:len(p1)-1]) abs(p1[i] - p2[i]) < tolerance]
    )
    // Manually check if all comparisons are true
    len([for(comp = comparisons) if (comp) true]) == len(comparisons);

// Function to check if any point in a list equals the given point
function is_point_in_list(point, list, tolerance=EPSILON) =
    let(
        equal_points = [for(p = list) points_equal(p, point, tolerance)]
    )
    len([for(eq = equal_points) if (eq) true]) > 0;

// Function to filter out certain centers
function filter_center_points(centers, filter_list, tolerance=EPSILON) =
    [for(center = centers) if (!is_point_in_list(center, filter_list, tolerance)) center];

// Function to calculate the distance between two points
function distance(p1, p2) = sqrt(pow(p2[0] - p1[0], 2) + pow(p2[1] - p1[1], 2));

// Function to check if a point is within a certain radius of any point in a given array
function is_within_radius(point, radius, removal_points) =
  let(
    n = len(removal_points)
  )
  [for(i = [0:n-1])
    if (distance(point, removal_points[i]) < radius)
      true
  ][0];

// Main function to remove points
function filter_triangulated_center_points(r, centers, filter_list) = 
  let(
    n = len(centers)
  )
  [for(i = [0:n-1])
    if (!is_within_radius(centers[i], r, filter_list))
      centers[i]
  ];



// Function to get gradient color based on the color scheme
function get_gradient_color(normalized_x, normalized_y, color_scheme) = 
    color_scheme == "scheme1" ? [normalized_x, 1 - normalized_x, normalized_y] : // Red to Blue
    color_scheme == "scheme2" ? [1 - normalized_y, normalized_x, normalized_y] : // Green to Magenta
    color_scheme == "scheme3" ? [normalized_y, 1 - normalized_y, normalized_x] : // Blue to Yellow
    color_scheme == "scheme4" ? [1 - normalized_x, normalized_x, 1 - normalized_y] : // Cyan to Red
    color_scheme == "scheme5" ? [normalized_x, normalized_x * normalized_y, 1 - normalized_x] : // Purple to Green
    color_scheme == "scheme6" ? [1 - normalized_x * normalized_y, normalized_y, normalized_x] : // Orange to Blue
    [0.9, 0.9, 0.9]; // Default color (black) if no valid color scheme is provided

// Module to print points as text
module print_points(points, text_size=1, color=[0.1, 0.1, 0.1], pointD=undef, point_color=[0.1, 0.1, 0.1], fn=8) {
    for (point = points) {
        translate([point[0], point[1], 1]) // Translated +1 in Z-axis
        
            color(color) text(str("[", point[0], ", ", point[1], "]"), size=text_size, valign="center", halign="center");
            if (pointD != undef) {
                color(point_color)
                translate([point[0], point[1], 1]) // Translated +1 in Z-axis
                sphere(pointD, $fn=fn);
            }
    }
    }