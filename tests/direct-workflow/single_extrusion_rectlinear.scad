use <../../iLOX.scad>;

// Should be kept true. Flag to derender rotational extrusions
ucell_derender = true;

include <base_unit_cell.scad>;

// rotx_derender = true;
linx_render = is_undef(rotx_derender) ? true : false;

if (linx_render)
{
    // Define the thickness of the substrate for the cells
    single_substrate_thickness = 2;

    // Define an abitrary depth for the extrusion so that the A cell isn't right on the edge
    ext_depth = 1;
    ext_height = height_y + single_substrate_thickness - ucell_top_face_tol * height_y;
    ext_loc = ucell_top_face_tol * height_y + ext_height / 2;

    // A cell
    union()
    {
        // Place cell A instances by directly accessing the ucell_linX_A() module usually called by place_linear_cells()
        // for ucell A instances this is effectively the same way how it's called in place_linear_cells()
        ucell_linX_A(cells = base_ucell_cells, width = width_x, color = "OliveDrab");

        // Give the floating A cell a subtrate to sit upon
        translate([ 0, 0, -single_substrate_thickness / 2 ]) color("OliveDrab")
            cube([ width_x * 2, width_x + ext_depth * 2, single_substrate_thickness ], center = true);
    }

    // B cell
    translate([ 0, ext_depth / 2, 0 ]) union()
    {
        // Place cell B instances by directly accessing the ucell_linX_B() module usually called by place_linear_cells()
        // for ucell B instances the cc parameter is set to true to prevent the translation to the origin such that the
        // subsequent extrusion and mirror operation across the Y-axis is performed in place to effectively "split" the
        // linear B cell into two halves across the Y-axis to interlock with either side of the A cell instance
        ucell_linX_B(cells = base_ucell_cells, width = width_x, extension = ext_depth, cc = true, color = "CadetBlue");

        // Connect the floating B cell halves using a linear extrusion
        translate([ 0, 0, height_y + single_substrate_thickness / 2 ]) color("CadetBlue")
            cube([ width_x * 2, width_x + ext_depth, single_substrate_thickness ], center = true);

        // Cover the back of the B cell with a linear extrusion
        translate([ 0, width_x / 2 + ext_depth, ext_loc ]) color("CadetBlue")
            cube([ width_x * 2, ext_depth, ext_height ], center = true);
    }
}