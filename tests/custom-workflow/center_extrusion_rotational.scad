use <../../iLOX.scad>;

ucell_derender = true;

include <base_unit_cell.scad>;

// rotx_derender = true;
rotx_render = is_undef(rotx_derender) ? true : false;

split_rot = 1; // [1:6]

degree_n = 6; ///< Number of sides for the rotational symmetry (i.e. 6 for hexagonal)

// Calculate the diameter based on the apothem of the polygon
apothem_diameter = apothem(width_x / 2, degree_n) * 2;

if (rotx_render)
{
    // Place cell A instances by directly accessing the ucell_rotX_A() module usually called by place_rotated_cells()
    // for ucell A instances this is effectively the same way how it's called in place_rotated_cells()
    ucell_rotX_A(cells = base_ucell_cells, n = degree_n, color = "OliveDrab");

    // Place cell B instances by directly accessing the ucell_rotX_A() module usually called by place_rotated_cells()
    // for ucell B instances width is required to calculate the position to translate it to the origin prior for the
    // rotational extrusion, by setting it to 0 the cell is not translated and its rotated in place which essentially
    // inverts the cell
    ucell_rotX_B(cells = base_ucell_cells, width = 0, n = degree_n, color = "CadetBlue");

    translate([ width_x * 4, 0, 0 ])
    {
        // Place cell A
        ucell_rotX_A(cells = base_ucell_cells, n = degree_n, color = "OliveDrab");

        // Place cell B instances
        ucell_rotX_B(cells = base_ucell_cells, width = 0, n = degree_n, color = "CadetBlue", angle = 45);
    }
}