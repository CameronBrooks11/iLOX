use <..\hexagons_tess.scad>

// Example usage with pre-calculated centers in a grid pattern for hexagons
rad_hex = 10;
space_hex = 0;
n_hex = 6;
m_hex = 6;
lvls_hex = 4;

// Example usage of the hexagons module with n x m grid placement
centers_grid_hex = calculate_hexagon_centers_grid(radius=rad_hex, spacing=space_hex, n=n_hex, m=m_hex);
filter_list_grid_hex = [[17.3205, 30]]; // Filtering out the center at [0, 0] for hexagons
filtered_centers_grid_hex = filter_hexagon_centers(centers_grid_hex, filter_list_grid_hex);
translate([0,0,0]) hexagons(radius=rad_hex, spacing=space_hex, hexagon_centers=filtered_centers_grid_hex);
