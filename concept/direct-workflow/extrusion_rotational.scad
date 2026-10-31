use <../../iLOX.scad>;

// Should be kept true. Flag to derender rotational extrusions
ucell_derender = true;

include <base_unit_cell.scad>;

// rotx_derender = true;
rotx_render = is_undef(rotx_derender) ? true : false;

// The extrusions are hexagonal, $fn = 6, and face their neighbours across a flat side. Widening them by 1 / cos(30)
// puts each flat side at the profile's x, so a section between neighbours one cell width apart is the unit cell and the
// gap is the clearance. Positions are scaled down to cancel the widening.
widen = [ 1 / cos(30), 1 / cos(30), 1 ];

if (rotx_render) scale(widen)
{
    // Place cell A at the specified position
    place_rotated_cells(cells = base_ucell_cells, positions = [[ 0, 0 ]], n = 6, width = width_x, cell_type = "A",
                        color = "OliveDrab");

    // Place cell B one cell width away
    place_rotated_cells(cells = base_ucell_cells, positions = [[width_x * cos(30), 0]], n = 6, width = width_x,
                        cell_type = "B", color = "CadetBlue");
}
