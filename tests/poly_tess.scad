use <..\octagons_tess.scad>
use <..\hexagons_tess.scad>

sep1 = 175;
sep2 = 125;

// Example usage with pre-calculated centers in a grid pattern for octagons
rad_oct = 10;
space_oct = 0;
n_oct = 6;
m_oct = 6;
rot_oct = true;
centers_grid_oct = calculate_octagon_centers_grid(radius=rad_oct, spacing=space_oct, n=n_oct, m=m_oct, rotate=rot_oct);
filter_list_grid_oct = [[0, 0], [0, 60]]; // Filtering out specific centers for octagons
filtered_centers_grid_oct = filter_octagon_centers(centers_grid_oct, filter_list_grid_oct);
octagons(radius = rad_oct, spacing = space_oct, levels = undef, rotate=rot_oct, order=1, octagon_centers=filtered_centers_grid_oct);

lvls_oct = 4;

// Example usage of the octagons module with levels
filter_list_levels_oct = [[0, 0], [-42.4264, 14.1421]]; // Filtering out specific centers for octagons
centers_levels_oct = calculate_octagon_centers_levels(radius=rad_oct, spacing=space_oct, levels=lvls_oct, rotate=rot_oct);
filtered_centers_levels_oct = filter_octagon_centers(centers_levels_oct, filter_list_levels_oct);
translate([-sep2,0,0]) octagons(radius = rad_oct, spacing = space_oct, levels = lvls_oct, rotate=rot_oct, order=1, octagon_centers=filtered_centers_levels_oct);

// Displaying the octagon centers for verification
echo("Octagon centers with levels: ", centers_levels_oct);
echo("Filtered Octagon centers with levels: ", filtered_centers_levels_oct);
echo("Octagon centers with grid: ", centers_grid_oct);
echo("Filtered Octagon centers with grid: ", filtered_centers_grid_oct);



// Example usage with pre-calculated centers in a grid pattern for hexagons
rad_hex = 10;
space_hex = 0;
n_hex = 6;
m_hex = 6;
lvls_hex = 4;

// Example usage of the hexagons module with levels
filter_list_levels_hex = [[34.641, 0]]; // Filtering out the center at [0, 0] for hexagons
centers_levels_hex = calculate_hexagon_centers_levels(radius=rad_hex, spacing=space_hex, levels=lvls_hex);
filtered_centers_levels_hex = filter_hexagon_centers(centers_levels_hex, filter_list_levels_hex);
translate([0,sep1,0]) hexagons(radius=rad_hex, spacing=space_hex, levels=lvls_hex, hexagon_centers=filtered_centers_levels_hex);

// Example usage of the hexagons module with n x m grid placement
centers_grid_hex = calculate_hexagon_centers_grid(radius=rad_hex, spacing=space_hex, n=n_hex, m=m_hex);
filter_list_grid_hex = [[17.3205, 30]]; // Filtering out the center at [0, 0] for hexagons
filtered_centers_grid_hex = filter_hexagon_centers(centers_grid_hex, filter_list_grid_hex);
translate([-sep1,sep2,0]) hexagons(radius=rad_hex, spacing=space_hex, hexagon_centers=filtered_centers_grid_hex);

// Displaying the hexagon centers for verification
echo("Filtered Hexagon centers with levels: ", filtered_centers_levels_hex);
echo("Filtered Hexagon centers with n x m grid: ", filtered_centers_grid_hex);
