use <../../iLOX.scad>;

ucell_derender = true;

include <base_unit_cell.scad>;

// rotx_derender = true;
linx_render = is_undef(rotx_derender) ? true : false;

if (linx_render)
{
    // Place cell A at the specified position
    ucell_linX_A(cells = base_ucell_cells, width = width_x, color = "OliveDrab");

    // Place cell B instances at the specified positions
    ucell_linX_B(cells = base_ucell_cells, width = width_x, color = "CadetBlue", cc = true);
}