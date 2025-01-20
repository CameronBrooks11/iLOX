/**
 * @file cell2rot.scad
 * @brief Functions and modules for rendering rotated unit cells.
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains modules for placing 'A' or 'B' type rotated cells at specified positions. The cells are rendered
 * using rotational extrusion, with optional rotation and color parameters. The cells are defined by an array of points,
 * with optional negative polygons for subtraction as defined in 'ucell.scad'.
 *
 */

use <utils/regpoly_utils.scad>;

/**
 * @brief Places 'A' or 'B' type rotated cells at specified positions.
 *
 * Iterates over an array of positions and places the specified cell type at each point, with optional rotation.
 *
 * @param cells An array containing cell point data.
 * @param positions An array of positions where cells will be placed, each as [x, y].
 * @param n The number of sides for the rotation.
 * @param width The width used for positioning.
 * @param rotate (Optional) Boolean to apply rotation, default is false.
 * @param cell_type (Optional) Type of cell to place, either "A" or "B", default is "A".
 * @param color (Optional) The color of the cells, default is "CadetBlue".
 */
module place_rotated_cells(cells, positions, n, width, rotate = false, cell_type = "A", color = "CadetBlue")
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
                ucell_rotX_A(cells = cells, n = n, color = color);
            }
            else if (cell_type == "B")
            {
                ucell_rotX_B(cells = cells, n = n, width = width, color = color);
            }
        }
    }
}

/**
 * @brief Renders the 'A' type cell in using a rotational extrusion.
 *
 * Rotates and extrudes the 'A' cell polygon to create a 3D shape.
 *
 * @param cells An array containing cell point data.
 * @param n The number of sides for the rotation.
 * @param color (Optional) The color of the cell, default is "Green".
 */
module ucell_rotX_A(cells, n, color = "Green")
{
    color(color) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n) difference()
    {
        polygon(points = cells[0]); // Main cell polygon
        polygon(points = cells[2]); // Optional negative polygon
    }
}

/**
 * @brief Renders the 'B' type cell in using a rotational extrusion.
 *
 * Rotates and extrudes the 'B' cell polygon to create a 3D shape, adjusted for positioning.
 *
 * @param cells An array containing cell point data.
 * @param n The number of sides for the rotation.
 * @param width The width used for positioning.
 * @param color (Optional) The color of the cell, default is "Blue".
 */
module ucell_rotX_B(cells, n, width, color = "Blue")
{
    color(color) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n) translate([ -width, 0, 0 ])
        difference()
    {
        polygon(points = cells[1]); // Main cell polygon
        polygon(points = cells[3]); // Optional negative polygon
    }
}