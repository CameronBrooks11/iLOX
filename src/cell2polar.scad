/**
 * @file cell2polar.scad
 * @brief Functions and modules for converting cell patterns into polar coordinate 3D models.
 * @author Cameron K. Brooks
 * @copyright 2024
 *
 * This library provides functions to generate 3D representations of cell pairs by rotating 2D cell patterns around an
 * axis. It includes utilities for calculating geometric properties like the apothem and central angles of regular
 * polygons, as well as modules to render and place cells in polar coordinates.
 */

/**
 * @brief Calculates the apothem of a regular polygon.
 *
 * The apothem is the distance from the center to the midpoint of one of its sides.
 *
 * @param R The radius of the circumscribed circle of the polygon.
 * @param n The number of sides of the polygon.
 * @return The apothem length.
 */
function apothem(R, n) = R * cos(180 / n);

/**
 * @brief Calculates the difference between the radius and the apothem.
 *
 * Useful for adjusting positions when converting between polar and Cartesian coordinates.
 *
 * @param R The radius of the polygon.
 * @param n The number of sides of the polygon.
 * @return The difference between the radius and the apothem.
 */
function radius_apothem_diff(R, n) = R - apothem(R, n);

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
 * @brief Renders a pair of cells in polar coordinates with optional colors.
 *
 * Takes cell pairs and optional anti-cell pairs, rotating and extruding them to create 3D models.
 *
 * @param cells An array containing cell point data: [cell_pointsA, cell_pointsB, ncell_pointsA, ncell_pointsB].
 * @param n The number of sides for the rotation (e.g., 6 for a hexagon).
 * @param radius The radius from the center to the largest x-value in the cell division.
 * @param colors (Optional) An array of colors for the cells, default is ["Green", "Blue"].
 */
module cells2polarpos(cells, n, radius, colors = [ "Green", "Blue" ])
{
    n = n;
    echo("n: ", n);
    echo("radius: ", radius);
    echo("cells[0]: ", cells[0]);
    echo("cells[1]: ", cells[1]);
    echo("cells[2]: ", cells[2]);
    echo("cells[3]: ", cells[3]);

    // Calculate the apothem
    apo = apothem(radius, n);

    // First shape ('A' cell)
    color(colors[0]) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n) difference()
    {
        polygon(points = cells[0]); // Main cell polygon
        polygon(points = cells[2]); // Optional negative polygon
    }

    // Second shape ('B' cell)
    color(colors[1]) translate([ apo * 2, 0, 0 ]) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n)
        translate([ -radius * 2, 0, 0 ]) difference()
    {
        polygon(points = cells[1]); // Main cell polygon
        polygon(points = cells[3]); // Optional negative polygon
    }
}

/**
 * @brief Renders the 'A' type cell in polar coordinates.
 *
 * Rotates and extrudes the 'A' cell polygon to create a 3D shape.
 *
 * @param cells An array containing cell point data.
 * @param n The number of sides for the rotation.
 * @param radius The radius used for positioning.
 * @param color (Optional) The color of the cell, default is "Green".
 */
module cellA2polar(cells, n, radius, color = "Green")
{
    color(color) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n) difference()
    {
        polygon(points = cells[0]); // Main cell polygon
        polygon(points = cells[2]); // Optional negative polygon
    }
}

/**
 * @brief Renders the 'B' type cell in polar coordinates.
 *
 * Rotates and extrudes the 'B' cell polygon to create a 3D shape, adjusted for positioning.
 *
 * @param cells An array containing cell point data.
 * @param n The number of sides for the rotation.
 * @param radius The radius used for positioning.
 * @param color (Optional) The color of the cell, default is "Blue".
 */
module cellB2polar(cells, n, radius, color = "Blue")
{
    color(color) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n) translate([ -radius * 2, 0, 0 ])
        difference()
    {
        polygon(points = cells[1]); // Main cell polygon
        polygon(points = cells[3]); // Optional negative polygon
    }
}

/**
 * @brief Places 'A' or 'B' type polar cells at specified positions.
 *
 * Iterates over an array of positions and places the specified cell type at each point, with optional rotation.
 *
 * @param cells An array containing cell point data.
 * @param positions An array of positions where cells will be placed, each as [x, y].
 * @param n The number of sides for the rotation.
 * @param radius The radius used for positioning.
 * @param rotate (Optional) Boolean to apply rotation, default is false.
 * @param cell_type (Optional) Type of cell to place, either "A" or "B", default is "A".
 * @param color (Optional) The color of the cells, default is "CadetBlue".
 */
module place_polar_cells(cells, positions, n, radius, rotate = false, cell_type = "A", color = "CadetBlue")
{
    // Determine rotation angle
    rot = rotate ? half_central_angle(n) : 0;
    // Iterate over positions
    for (pos = positions)
    {
        translate([ pos[0], pos[1], 0 ]) rotate([ 0, 0, rot ])
        {
            if (cell_type == "A")
            {
                cellA2polar(cells = cells, n = n, radius = radius, color = color);
            }
            else if (cell_type == "B")
            {
                cellB2polar(cells = cells, n = n, radius = radius, color = color);
            }
        }
    }
}