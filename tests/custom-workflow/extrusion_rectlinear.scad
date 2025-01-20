use <../../iLOX.scad>;

ucell_derender = true;

include <base_unit_cell.scad>;

// rotx_derender = true;
linx_render = is_undef(rotx_derender) ? true : false;

if (linx_render)
{
    // Place cell A at the specified position
    place_linear_cells(cells = base_ucell_cells, positions = [[ 0, 0 ]], width = width_x, cell_type = "A",
                       color = "Green");

    // Place cell B at the specified positions
    place_linear_cells(cells = base_ucell_cells, positions = [[width_x, 0]], width = width_x, cell_type = "B",
                       color = "Blue");
}