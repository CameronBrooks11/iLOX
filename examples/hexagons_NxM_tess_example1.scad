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


// NxM Examples
if (mode == 1) {
    centers_grid = hexagon_centers_NxM(radius=rad, n=n, m=m);
    echo("Unfiltered Centers Grid:", centers_grid);
    hexagons(radius=rad, spacing=space, hexagon_centers=centers_grid, color_scheme="scheme3");
    print_points(centers_grid, text_size=1, color="Azure");
} else if (mode == 2) {
    centers_grid = hexagon_centers_NxM(radius=rad, n=n, m=m);
    echo("Unfiltered Centers Grid:", centers_grid);
    echo("Filtered Centers Grid:", centers_grid);
    hexagons(radius=rad, spacing=space, hexagon_centers=centers_grid, color_scheme="scheme4");
    print_points(centers_grid, text_size=1, color="Azure");
}
