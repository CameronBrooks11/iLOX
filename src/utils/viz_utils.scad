/**
 * @file viz_utils.scad
 * @brief Utility functions to help with visualizing data in OpenSCAD.
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains helper functions for working with regular polygons, specifically calculation of the apothem and
 * central angle of a polygon based on the number of sides. These functions are useful for positioning and rotation.
 *
 */

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
module place_spheres(points, d, color = "DarkGrey", zGap = undef, fn = 6)
{
    for (p = points)
    {
        translate([ p[0], p[1], (zGap == undef) ? (len(p) == 3 ? p[2] : 0) : zGap ]) color(color) sphere(d, $fn = fn);
    }
}