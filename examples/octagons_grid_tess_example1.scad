use <..\src\tess.scad>
use <..\src\utils.scad>

// Define the mode:
// 1 for grid,
// 2 for filtered grid
mode = 2; // Change this number to switch between different examples

rad = 10;
space = 1;

n = 7;
m = 7;

// Define your filter points for levels and grid
filter_points_levels = [
    [ -78.3938, 0 ], [ -65.3281, -13.0656 ], [ -65.3281, 13.0656 ], [ 78.3938, 0 ], [ 65.3281, -13.0656 ],
    [ 65.3281, 13.0656 ], [ -52.2625, 0 ], [ 52.2625, 0 ], [ -13.0656, 65.3281 ], [ 13.0656, 65.3281 ], [ 0, 78.3938 ],
    [ 0, 52.2625 ], [ -13.0656, -65.3281 ], [ 13.0656, -65.3281 ], [ 0, -78.3938 ], [ 0, -52.2625 ]
];

filter_points_grid = [
    [ 0, 0 ], [ 110.866, 0 ], [ 0, 110.866 ], [ 110.866, 110.866 ], [ 55.4328, 55.4328 ]
]; // Your filter points for grid

if (mode == 1)
{
    centers_grid = octagon_centers_grid(radius = rad, , n = n, m = m);
    octagons(radius = rad, spacing = space, octagon_centers = centers_grid, color_scheme = "scheme3", alpha = 0.5);
    print_points(centers_grid, text_size = 1, color = "Azure"); // Add labels for grid centers
}
else if (mode == 2)
{
    centers_grid = octagon_centers_grid(radius = rad, n = n, m = m);
    filtered_centers_grid = filter_center_points(centers_grid, filter_points_grid);
    octagons(radius = rad, spacing = space, octagon_centers = filtered_centers_grid, color_scheme = "scheme4",
             alpha = 0.5);
    print_points(filtered_centers_grid, text_size = 1, color = "Azure"); // Add labels for filtered grid centers
}