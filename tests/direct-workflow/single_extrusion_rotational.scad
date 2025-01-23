use <../../iLOX.scad>;

// Should be kept true. Flag to derender rotational extrusions
ucell_derender = true;

include <base_unit_cell.scad>;

// rotx_derender = true;
rotx_render = is_undef(rotx_derender) ? true : false;

// Number of sides for the rotational symmetry (i.e. 6 for hexagonal)
degree_n = 6;

if (rotx_render)
{
    // Define the thickness of the substrate for the cells
    single_substrate_thickness = 2;

    // Define a radial separation distance between the cells for adjustment
    radial_separation_distance = 0.5;

    subtrate_width = width_x * 2 + radiusapo(radial_separation_distance, degree_n) * 2;

    // Place cell A instances by directly accessing the ucell_rotX_A() module usually called by place_rotated_cells()
    // for ucell A instances this is effectively the same way how it's called in place_rotated_cells()
    ucell_rotX_A(cells = base_ucell_cells, n = degree_n, color = "OliveDrab");

    // Give the floating A cell a subtrate to sit upon
    translate([ 0, 0, -single_substrate_thickness / 2 ]) color("OliveDrab") rotate([ 0, 0, 360 / (degree_n * 2) ])
        cylinder(d = subtrate_width, h = single_substrate_thickness, center = true, $fn = degree_n);

    // Place cell B instances split over rotated 3 rotational extrusions
    for (i = [0:degree_n / 2 - 1])
        rotate([ 0, 0, i * 360 / (degree_n / 2) ])
        {
            // Place cell B instances by directly accessing the ucell_rotX_A() module usually called by
            // place_rotated_cells() for ucell B instances width is required to calculate the position to translate it
            // to the origin prior for the rotational extrusion, by setting it to 0 the cell is not translated and its
            // rotated in place which essentially inverts the cell. The optional angle parameter is set to 360 /
            // degree_n to rotate the cell by the appropriate angle to align with a single facet of the A cell instance
            // which is rotate by two times the same angle in order to create 3 B cell instances that interlock with the
            // A cell on alternating sides
            translate([ radial_separation_distance, 0, 0 ]) rotate([ 0, 0, -360 / degree_n ]) ucell_rotX_B(
                cells = base_ucell_cells, width = 0, n = degree_n, color = "CadetBlue", angle = 360 / degree_n);
        }

    // Connect the floating B cell halves using a cylindrical extrusion
    translate([ 0, 0, height_y + single_substrate_thickness / 2 ]) color("CadetBlue")
        rotate([ 0, 0, 360 / (degree_n * 2) ])
            cylinder(d = subtrate_width, h = single_substrate_thickness, center = true, $fn = degree_n);
}