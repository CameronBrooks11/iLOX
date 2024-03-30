use <..\src\utils_points.scad>
use <..\src\utils_viz.scad>
use <..\src\tess.scad>
use <..\src\geo_tricho.scad>

// Define the mode: 
// 1 for N x M, 
// 2 for filtered N x M
mode = 1; // Change this number to switch between different NxM examples

rad = 10;
space = 1;
n = 6;
m = 5;

filter_points_grid = [
    [95.2628, 15], [95.2628, 45], [43.3013, 45], 
    [51.9615, 60], [34.641, 60], [34.641, 0], 
    [51.9615, 0], [43.3013, 15]
];

// NxM Examples
if (mode == 1) {
    centers_grid = hexagon_centers_NxM(radius=rad, n=n, m=m);
    echo("Unfiltered Centers Grid:", centers_grid);
    hexagons(radius=rad, spacing=space, hexagon_centers=centers_grid, color_scheme="scheme3");
    print_points(centers_grid, text_size=1, color="Azure");
} else if (mode == 2) {
    centers_grid = hexagon_centers_NxM(radius=rad, n=n, m=m);
    filtered_centers_grid = filter_center_points(centers_grid, filter_points_grid);
    echo("Unfiltered Centers Grid:", centers_grid);
    echo("Filtered Centers Grid:", filtered_centers_grid);
    hexagons(radius=rad, spacing=space, hexagon_centers=filtered_centers_grid, color_scheme="scheme4");
    print_points(filtered_centers_grid, text_size=1, color="Azure");
}
