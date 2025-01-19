use <../../iLOX.scad>;

// -----------------------------------
// Parameters
// -----------------------------------

// Flag to render the entire scene or individual components
// Should always be false for exporting the final design
show_ucell = false; ///< Flag to render the unit cell or omit it

// Define input dimensions for the unit cell
width_x = 5;   ///< Width of the unit cell in the x-direction
height_y = 10; ///< Height of the unit cell in the y-direction

// Each point is defined as [x, y, tolerance] and must form a division line
base_ucell_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Define negative polygon points to create voids within the cell, each point is defined as [x, y]
base_ucell_neg_poly = [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ];

// Number of sides for the rotational symmetry (e.g., 6 for hexagonal)
degree_n = 6;

// Number of levels for tessellation pattern
levels = 4;

// Packing factor
packing_factor = 0.3; // [0:1]

// Select whether to render the 2D unit cell to design or the final 3D radial tessellation
if (show_ucell)
    ucell_designer(width_x, height_y, base_ucell_div);
else
    radial_iLOX(width_x, height_y, base_ucell_div, base_ucell_neg_poly, degree_n, levels, packing_factor);