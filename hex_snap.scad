use <hexagons_tess.scad>

// Example usage with pre-calculated centers in a grid pattern for hexagons
rad = 10;
space = 1;
lvls = 5;
filter_points = [
    [121.244, 0], [34.641, 0], [51.9615, 0], [69.282, 0], [86.6025, 0], [103.923, 0], [121.244, 0], 
    [43.3013, 15], [60.6218, 15], [77.9423, 15], [95.2628, 15], [112.583, 15], [129.904, 15], 
    [51.9615, 30], [69.282, 30], [86.6025, 30], [43.3013, -15], [60.6218, -15], 
    [77.9423, -15], [95.2628, -15], [112.583, -15], [129.904, -15], 
    [51.9615, -30], [69.282, -30], [86.6025, -30]];
 
centers = hexagon_centers(radius=rad, spacing=space, levels=lvls);
filtered_centers = filter_hexagon_centers(centers, filter_points);

echo(filtered_centers);
echo(centers);

hexagons(radius=rad, spacing=space, levels=lvls, hexagon_centers=filtered_centers);
//hexagons(radius=rad, spacing=space, levels=lvls, hexagon_centers=centers);