use <..\..\src\tess.scad>
use <..\..\src\utils.scad>

// Define the mode:
// 1 for levels,
// 2 for filtered levels
mode = 1; // Change this number to switch between different levels examples

rad = 10;
space = 0;
lvls = 3;

filter_points_levels = [
    // Define your filtering points here
];

// Levels Examples
if (mode == 1)
{
    centers = hexagon_centers_lvls(radius = rad, levels = lvls);
    echo("Unfiltered Centers:", centers);
    hexagons(radius = rad, spacing = space, hexagon_centers = centers, color_scheme = "scheme1");
    print_points(centers, text_size = 1, color = "Azure");
}
else if (mode == 2)
{
    centers = hexagon_centers_lvls(radius = rad, levels = lvls);
    filtered_centers = filter_center_points(centers, filter_points_levels);
    echo("Unfiltered Centers:", centers);
    echo("Filtered Centers:", filtered_centers);
    print_points(filtered_centers, text_size = 1, color = "Azure");
    hexagons(radius = rad, spacing = space, hexagon_centers = filtered_centers, color_scheme = "scheme2");
}