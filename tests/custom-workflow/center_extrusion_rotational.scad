use <../../iLOX.scad>;

ucell_derender = true;

include <base_unit_cell.scad>;

// rotx_derender = true;
rotx_render = is_undef(rotx_derender) ? true : false;

split_rot = 1; // [1:6]

degree_n = 6; ///< Number of sides for the rotational symmetry (e.g., 6 for hexagonal)
// Calculate the diameter based on the apothem of the polygon
apothem_diameter = apothem(width_x / 2, degree_n) * 2;

if (rotx_render)
{
    // Place cell A at the specified position
    ucell_rotX_A(cells = base_ucell_cells, n = degree_n, color = "OliveDrab");

    // Place cell B instances at the specified positions
    ucell_rotX_B(cells = base_ucell_cells, width = 0, n = degree_n, color = "CadetBlue");

    translate([ width_x*4, 0, 0 ])
    {
        // Place cell A at the specified position
        ucell_rotX_A(cells = base_ucell_cells, n = degree_n, color = "OliveDrab");

        // Place cell B instances at the specified positions
        ucell_rotX_B(cells = base_ucell_cells, width = 0, n = degree_n, color = "CadetBlue", angle = 45);
    }
}

