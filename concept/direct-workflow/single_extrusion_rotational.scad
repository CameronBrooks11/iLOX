use <../../iLOX.scad>;

// Should be kept true. Flag to derender rotational extrusions
ucell_derender = true;

include <base_unit_cell.scad>;

// rotx_derender = true;
rotx_render = is_undef(rotx_derender) ? true : false;

// The extrusions are hexagonal, $fn = 6. Widening them by 1 / cos(30) puts each flat side at the profile's x, so a
// section through a flat side is the unit cell and the gap is the clearance.
widen = [ 1 / cos(30), 1 / cos(30), 1 ];

if (rotx_render) scale(widen)
{
    // Define the thickness of the substrate for the cells
    single_substrate_thickness = 2;

    substrate_width = width_x * 2;

    // Place cell A instances by directly accessing the ucell_rotX_A() module usually called by place_rotated_cells()
    // for ucell A instances this is effectively the same way how it's called in place_rotated_cells()
    ucell_rotX_A(cells = base_ucell_cells, n = 6, color = "OliveDrab");

    // Give the floating A cell a substrate to sit upon
    translate([ 0, 0, -single_substrate_thickness / 2 ]) color("OliveDrab") rotate([ 0, 0, 30 ])
        cylinder(d = substrate_width, h = single_substrate_thickness, center = true, $fn = 6);

    // Place cell B instances split over rotated 3 rotational extrusions
    for (i = [0:2])
        rotate([ 0, 0, i * 120 ])
        {
            // Place cell B instances by directly accessing the ucell_rotX_A() module usually called by
            // place_rotated_cells() for ucell B instances width is required to calculate the position to translate it
            // to the origin prior for the rotational extrusion, by setting it to 0 the cell is not translated and its
            // rotated in place which essentially inverts the cell. The optional angle parameter is set to 60 to
            // rotate the cell by the appropriate angle to align with a single facet of the A cell instance which is
            // rotate by two times the same angle in order to create 3 B cell instances that interlock with the A cell
            // on alternating sides
            rotate([ 0, 0, -60 ])
                ucell_rotX_B(cells = base_ucell_cells, width = 0, n = 6, color = "CadetBlue", angle = 60);
        }

    // Connect the floating B cell halves using a cylindrical extrusion
    translate([ 0, 0, height_y + single_substrate_thickness / 2 ]) color("CadetBlue") rotate([ 0, 0, 30 ])
        cylinder(d = substrate_width, h = single_substrate_thickness, center = true, $fn = 6);
}
