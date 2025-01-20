/**
 * @file cell2linear.scad
 * @brief Functions and modules for rendering linear unit cells.
 * @author Cameron K. Brooks
 * @copyright 2025
 *
 * This file contains modules for placing 'A' or 'B' type linear cells at specified positions. The cells are rendered
 * using linear extrusion, with optional rotation and color parameters. The cells are defined by an array of points,
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
module place_linear_cells(cells, positions, width, cell_type = "A", color = "CadetBlue", fullex = 0)
{
    // Iterate over positions
    for (pos = positions)
    {
        translate([ pos[0], pos[1], 0 ])
        {
            if (cell_type == "A")
            {
                ucell_linX_A(cells = cells, width = width, color = color, fullex = fullex);
            }
            else if (cell_type == "B")
            {
                ucell_linX_B(cells = cells, width = width, color = color, fullex = fullex);
            }
        }
    }
}

/**
 * @brief Renders a linear 'A' type cell.
 *
 * Renders a linear 'A' type cell using linear extrusion with the specified color.
 *
 * @param cells An array containing cell point data.
 * @param n The number of sides for the rotation.
 * @param color The color of the cell.
 */
module ucell_linX_A(cells, width, color, fullex = 0)
{
    exwidth = fullex ? width + fullex  : width;

    for (i = [0:1])
    {
        mirror([ i, 0, 0 ]) color(color) translate([ 0, exwidth / 2, 0 ]) rotate([ 90, 0, 0 ]) linear_extrude(exwidth)
            difference()
        {
            polygon(points = cells[0]); // Main cell polygon
            polygon(points = cells[2]); // Optional negative polygon
        }
    }
}

/**
 * @brief Renders a linear 'B' type cell.
 *
 * Renders a linear 'B' type cell using linear extrusion with the specified color.
 *
 * @param cells An array containing cell point data.
 * @param n The number of sides for the rotation.
 * @param width The width used for positioning.
 * @param color The color of the cell.
 */

module ucell_linX_B(cells, width, color, fullex = 0)
{
    exwidth = fullex ? width + fullex : width;
    for (i = [0:1])
    {
        mirror([ i, 0, 0 ]) color(color) translate([ -width, exwidth / 2, 0 ]) rotate([ 90, 0, 0 ])
            linear_extrude(exwidth) difference()
        {
            polygon(points = cells[1]); // Main cell polygon
            polygon(points = cells[3]); // Optional negative polygon
        }
    }
}