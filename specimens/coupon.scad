// Pilot coupon: one half, or both halves in place, of a small linear or radial iLOX joint, laid out to print.
// ladder.csv lists every coupon of the clearance ladder for scadbatch; see README.md.

use <../iLOX.scad>;

// -----------------------------------
// Parameters
// -----------------------------------

// Extrusion mode: linear rails or radial pins
set = "linear"; // [linear, radial]

// Half to print: A substrate down, B flipped substrate down, or both assembled in place
part = "A"; // [A, B, both]

// Gap between cells A and B in mm, measured normal to the division line
clearance = 0.2;

// Gap in mm between each cell's tip and the opposite substrate
tip_clearance = 0.2;

// Thickness of each half's substrate in mm
substrate_height = 1;

// Width of the unit cell in the x-direction
width_x = 5;
// Height of the unit cell in the y-direction
height_y = 10;

// The cell of examples/simpleUsage: a neck and a head, with the corner cut
base_ucell_div = [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ];
base_ucell_neg_poly = [[[ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ]]];

// Linear: rails along Y, grid_m cells long; grid_n = 3 gives three A rails and two B rails
grid_n = 3;
grid_m = 2;
// 1 joins each rail's cells into one continuous rail
extension_factor = 1; // [0:0.1:1]

// Radial: rings of pins around the centre
levels = 2;

// Engrave set, part, clearance and substrate on a tab beside each half
label = true;
// Tab size in mm, outside the substrate
tab_size = [ 24, 6 ];
// Text height and engraving depth in mm
label_size = 3;
label_depth = 0.4;

// -----------------------------------
// Coupon
// -----------------------------------

// Footprint of the substrate in the assembled frame: [x centre, y min, y max]
footprint = set == "linear"
                ? [ width_x * (grid_n - 1), -width_x, width_x * (2 * grid_m - 1) ]
                : [ 0, -width_x * (1.5 * levels - 0.5), width_x * (1.5 * levels - 0.5) ];

assert(set == "linear" || set == "radial", "ERROR: set must be \"linear\" or \"radial\"");
assert(part == "A" || part == "B" || part == "both", "ERROR: part must be \"A\", \"B\" or \"both\"");

module half(which)
{
    if (set == "linear")
        linear_iLOX(width_x, height_y, base_ucell_div, clearance, base_ucell_neg_poly, grid_n, grid_m, extension_factor,
                    substrate_height, tip_clearance = tip_clearance, part = which);
    else
        radial_iLOX(width_x, height_y, base_ucell_div, clearance, base_ucell_neg_poly, levels, substrate_height,
                    tip_clearance = tip_clearance, part = which);
}

// A tab on the bed, reaching out in -y from the substrate edge at y_edge, engraved on its top face. It overlaps one
// cell width into the substrate, under the cells, to join it.
module tab(y_edge, txt)
{
    difference()
    {
        translate([ footprint[0] - tab_size[0] / 2, y_edge - tab_size[1], 0 ])
            cube([ tab_size[0], tab_size[1] + width_x, substrate_height ]);
        translate([ footprint[0], y_edge - tab_size[1] / 2, substrate_height - label_depth ])
            linear_extrude(label_depth + 0.01) text(txt, size = label_size, font = "Liberation Sans:style=Bold",
                                                   halign = "center", valign = "center");
    }
}

name = str(set == "linear" ? "L" : "R", part == "both" ? "" : str("-", part), " ", clearance, "/", substrate_height);

if (part == "A" || part == "both")
{
    translate([ 0, 0, substrate_height ]) half(part);
    if (label)
        tab(footprint[1], name);
}
else
{
    // Turned over about X, so the assembled +y edge lies at -footprint[2]
    translate([ 0, 0, height_y + substrate_height ]) rotate([ 180, 0, 0 ]) half("B");
    if (label)
        tab(-footprint[2], name);
}
