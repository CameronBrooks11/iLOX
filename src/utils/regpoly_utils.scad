/**
 * @file regpoly_utils.scad
 * @brief Utility functions for regular polygon geometry in OpenSCAD.
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains helper functions for working with regular polygons, specifically calculation of the apothem and
 * central angle of a polygon based on the number of sides. These functions are useful for positioning and rotation.
 *
 */

/**
 * @brief Calculates the central angle of a regular polygon.
 *
 * The central angle is the angle between two adjacent vertices from the center.
 *
 * @param n The number of sides of the polygon.
 * @return The central angle in degrees.
 */
function central_angle(n) = 360 / n;

/**
 * @brief Calculates half of the central angle of a regular polygon.
 *
 * Useful for aligning the polygon with the x-axis when rotating.
 *
 * @param n The number of sides of the polygon.
 * @return Half of the central angle in degrees.
 */
function half_central_angle(n) = central_angle(n) / 2;
/**
 * @brief Calculates the apothem of a regular polygon.
 *
 * The apothem is the distance from the center to the midpoint of one of its sides.
 *
 * @param R The radius of the circumscribed circle of the polygon.
 * @param n The number of sides of the polygon.
 * @return The apothem length.
 */
function apothem(R, n) = R * cos(half_central_angle(n));

/**
 * @brief Calculates the difference between the radius and the apothem.
 *
 * Useful for adjusting positions when working with regular polygons.
 *
 * @param R The radius of the polygon.
 * @param n The number of sides of the polygon.
 * @return The difference between the radius and the apothem.
 */
function radius_apothem_diff(R, n) = R - apothem(R, n);