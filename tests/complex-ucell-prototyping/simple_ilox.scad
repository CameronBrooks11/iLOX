use <../../iLOX.scad>;  // Utility functions for point operations

// Define input dimensions for the unit cell
width_x = 5;   // Width of the unit cell in the x-direction
height_y = 10; // Height of the unit cell in the y-direction

// Define division points for creating the cell's internal structure
// Each point is defined as [x, y, tolerance]
// Must form a division line 
// First point must start with 0 if defining the minor half of the ucell division
// First point must start with 1 if defining the major half of the ucell division
example_div = [ [ 0.3, 0, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Define negative polygon points to create voids within the cell
// Each point is defined as [x, y]
example_neg_poly = [];

// Define color options for rendering
example_colors = [ "GreenYellow", "Aqua", "Red", "DarkRed" ];

ucell_render = true; // Flag to render the unit cells or omit them

// Calculate cells (A and B) using the defined dimensions and division points
example_cells =
    calc_ucell(width = width_x, height = height_y, div = example_div, neg_poly = example_neg_poly);

echo("example_cells: ", example_cells);

// Rotate the entire scene for better visualization
// rotate([ 90, 0, 0 ])
{
    // Render only the division polygons (cells A and B without the negative polygons)
    render_ucells(cells = [ example_cells[0], example_cells[1], [], [] ], colors = example_colors);

    // Render only the negative (anti-cell) portions separately
    render_ucells(cells = [ [], [], example_cells[2], example_cells[3] ], colors = example_colors);

    // Place spheres at the points of cell A (division points)
    place_spheres(points = example_cells[0], d = 0.05, color = "Indigo", fn = 12);

    // Place spheres at the points of cell B (division points)
    place_spheres(points = example_cells[1], d = 0.05, color = "Violet", fn = 12);
}