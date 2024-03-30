
use <..\src\utils_points.scad>
use <..\src\utils_viz.scad>
use <..\src\tess_hex.scad>
use <..\src\tess_oct.scad>
use <..\src\geo_tricho.scad>


// Define the mode: 
// 1 for levels, 
// 2 for filtered levels, 
// 3 for grid, 
// 4 for filtered grid
mode = 2; // Change this number to switch between different examples

rad = 10;
space = 1;
lvls = 5;

filter_points_levels = [

];

n = 6;
m = 5;

filter_points_grid = [
    [95.2628, 15], [95.2628, 45], [43.3013, 45], 
    [51.9615, 60], [34.641, 60], [34.641, 0], 
    [51.9615, 0], [43.3013, 15]
];

if (mode == 1) {
    centers = hexagon_centers(radius=rad, spacing=space, levels=lvls);
    echo("Unfiltered Centers:", centers);
    hexagons(radius=rad, spacing=space, hexagon_centers=centers, color_scheme="scheme1");
    print_points(centers, text_size=1, color="Azure");
} else if (mode == 2) {
    centers = hexagon_centers(radius=rad, spacing=space, levels=lvls);
    filtered_centers = filter_center_points(centers, filter_points_levels);
    echo("Unfiltered Centers:", centers);
    echo("Filtered Centers:", filtered_centers);
    print_points(filtered_centers, text_size=1, color="Azure");
    hexagons(radius=rad, spacing=space, hexagon_centers=filtered_centers, color_scheme="scheme2");
} else if (mode == 3) {
    centers_grid = hexagon_centers(radius=rad, spacing=space, n=n, m=m);
    echo("Unfiltered Centers Grid:", centers_grid);
    hexagons(radius=rad, spacing=space, hexagon_centers=centers_grid, color_scheme="scheme3");
    print_points(centers_grid, text_size=1, color="Azure");
} else if (mode == 4) {
    centers_grid = hexagon_centers(radius=rad, spacing=space, n=n, m=m);
    filtered_centers_grid = filter_center_points(centers_grid, filter_points_grid);
    echo("Unfiltered Centers Grid:", centers_grid);
    echo("Filtered Centers Grid:", filtered_centers_grid);
    hexagons(radius=rad, spacing=space, hexagon_centers=filtered_centers_grid, color_scheme="scheme4");
    print_points(filtered_centers_grid, text_size=1, color="Azure");
}