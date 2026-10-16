use <../../iLOX.scad>;

// -----------------------------------
// Parameters
// -----------------------------------

// Flag to render the entire scene or individual components
// Should always be false for exporting the final design
show_ucell = false; // Flag to render the unit cell or omit it

// Width of the unit cell in the x-direction
width_x = 5;
// Height of the unit cell in the y-direction
height_y = 10;

// Each point is defined as [x, y] and must form a division line
base_ucell_div = [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ];

// Gap between cells A and B in mm
clearance = 0.2;

// Half to render: both to view the joint, A or B to export one printable half (print B upside down)
part = "both"; // [both, A, B]

// Define negative polygon points to create voids within the cell, each point is defined as [x, y]
base_ucell_neg_poly = [
    [
        [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] // cut corner of the cell
    ],
    //...more polygons can be added here:
    // [
    // [ x1, y1 ], [ x2, y2  ], [ x3, y3  ]
    // ], ...
];

// Number of sides for the rotational symmetry (e.g., 6 for hexagonal)
degree_n = 6;

// Number of levels for tessellation pattern
levels = 4;

// Packing factor
packing_factor = 0.3; // [0:1]

// Select whether to render the 2D unit cell to design or the final 3D radial tessellation
if (show_ucell)
    ucell_designer(width_x, height_y, base_ucell_div, clearance);
else
    radial_iLOX(width_x, height_y, base_ucell_div, clearance, base_ucell_neg_poly, degree_n, levels, packing_factor,
                part = part);