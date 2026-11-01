use <../../iLOX.scad>;

// -----------------------------------
// Parameters
// -----------------------------------

// Flag to render the entire scene or individual components
// Should always be false for exporting the final design
show_ucell = false; // Flag to render the unit cell or omit it

// Width of the unit cell in mm
width = 5;
// Height of the unit cell in mm
height = 10;

// Each point is defined as [x, y] and must form a division line
div = [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ];

// Gap between cells A and B in mm
clearance = 0.2;

// Half to render: both to view the joint, A or B to export one printable half (print B upside down)
part = "both"; // [both, A, B]

// Voids cut from the cell: a list of polygons, each point defined as [x, y]
voids = [
    [
        [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] // cut corner of the cell
    ],
    //...more polygons can be added here:
    // [
    // [ x1, y1 ], [ x2, y2  ], [ x3, y3  ]
    // ], ...
];

// Number of levels for tessellation pattern
levels = 4;

// Select whether to render the 2D unit cell to design or the final 3D radial tessellation
if (show_ucell)
    ilox_cell_designer(width = width, height = height, div = div, clearance = clearance, voids = voids);
else
    ilox_radial(width = width, height = height, div = div, clearance = clearance, voids = voids, levels = levels,
                part = part);
