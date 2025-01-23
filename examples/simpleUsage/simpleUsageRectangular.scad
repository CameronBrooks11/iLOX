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

// Each point is defined as [x, y, tolerance] and must form a division line
base_ucell_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

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

// Number of grid points in the X direction
grid_n = 5;
// Number of grid points in the Y direction
grid_m = 4;

// Height of substrate
substrate_height = 3;

// Extend up to a double width of the unit cell in the Y direction to decrease gaps
extension_factor = 0.5; // [0:0.1:1]

// Select whether to render the 2D unit cell to design or the final 3D radial tessellation
if (show_ucell)
    ucell_designer(width_x, height_y, base_ucell_div);
else
    linear_iLOX(width_x, height_y, base_ucell_div, base_ucell_neg_poly, grid_n, grid_m, extension_factor,
                substrate_height);