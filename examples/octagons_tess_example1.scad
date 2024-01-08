use <..\src\viz-utils.scad>
use <..\src\point-utils.scad>
use <..\src\hexagons_tess.scad>
use <..\src\octagons_tess.scad>
use <..\src\tricho_geo.scad>



// Define the mode: 
// 1 for levels, 
// 2 for filtered levels, 
// 3 for grid, 
// 4 for filtered grid
mode = 4; // Change this number to switch between different examples

rad = 10;
space = 1;
lvls = 4;
rotate = true; // Set true to rotate octagons, false to keep them aligned ! fix inverse

n = 7;
m = 7;

// Define your filter points for levels and grid
filter_points_levels = [
    [-78.3938, 0], [-65.3281, -13.0656], [-65.3281, 13.0656], 
    [78.3938, 0], [65.3281, -13.0656], [65.3281, 13.0656],
    [-52.2625, 0], [52.2625, 0], [-13.0656, 65.3281], [13.0656, 65.3281], 
    [0, 78.3938], [0, 52.2625], [-13.0656, -65.3281], [13.0656, -65.3281], 
    [0, -78.3938], [0, -52.2625]
];

filter_points_grid = [
    [0, 0], [110.866, 0], [0, 110.866], [110.866, 110.866],  [55.4328, 55.4328]
]; // Your filter points for grid


if (mode == 1) {
    centers = octagon_centers(radius=rad, spacing=space, levels=lvls, rotate=rotate);
    octagons(radius=rad, spacing=space, levels=undef, rotate=rotate, octagon_centers=centers, color_scheme="scheme1", alpha = 0.5);
    print_points(centers, text_size=1, color="Azure"); // Add labels
} else if (mode == 2) {
    centers = octagon_centers(radius=rad, spacing=space, levels=lvls, rotate=rotate);
    filtered_centers = filter_center_points(centers, filter_points_levels);
    octagons(radius=rad, spacing=space, levels=undef, rotate=rotate, octagon_centers=filtered_centers, color_scheme="scheme2", alpha = 0.5);
    print_points(filtered_centers, text_size=1, color="Azure"); // Add labels for filtered centers
} else if (mode == 3) {
    centers_grid = octagon_centers(radius=rad, spacing=space, n=n, m=m, rotate=rotate);
    octagons(radius=rad, spacing=space, levels=undef, rotate=rotate, octagon_centers=centers_grid, color_scheme="scheme3", alpha = 0.5);
    print_points(centers_grid, text_size=1, color="Azure"); // Add labels for grid centers
} else if (mode == 4) {
    centers_grid = octagon_centers(radius=rad, spacing=space, n=n, m=m, rotate=rotate);
    filtered_centers_grid = filter_center_points(centers_grid, filter_points_grid);
    octagons(radius=rad, spacing=space, levels=undef, rotate=rotate, octagon_centers=filtered_centers_grid, color_scheme="scheme4", alpha = 0.5);
    print_points(filtered_centers_grid, text_size=1, color="Azure"); // Add labels for filtered grid centers
}