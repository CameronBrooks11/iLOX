use <hexagons_tess.scad>
use <tricho_geo.scad>

// Place a tricho at each hexagon center
module place_trichos_at_centers(centers, alpha_vector, beta_vector, inter_height, omega_vector, segments) {
    for (center = centers) {
        translate([center[0], center[1], 0]) 
        tricho(alpha_vector, beta_vector, inter_height, omega_vector, segments);
    }
}

// Tricho Params
radius = 1.5;

// Grid Params
lvls = 3;
rad = radius *1.5;
centers = hexagon_centers(radius=rad, levels=lvls);

// Constants
beta_angle = 90;
beta_angle_ref = 270 - beta_angle;
beta_height = radius / 4;

alpha_angle = 30;
alpha_angle_ref = 270 - alpha_angle;
alpha_height = radius / 3;

omega_angle = 60;
omega_angle_ref = 270 - omega_angle;
omega_height = radius * 2 / 3;
inter_height = radius / 10;
segments = 6;

// Calculating radii
alpha_r1 = calculateRadFromAngle(alpha_angle_ref, radius, alpha_height);
alpha_r2 = radius;
beta_r1 = calculateRadFromAngle(beta_angle_ref, alpha_r1, beta_height);
beta_r2 = alpha_r1;
omega_r1 = radius;
omega_r2 = calculateRadFromAngle(omega_angle_ref, radius, omega_height);

// Vectors for parameters
alpha_vector = [alpha_height, alpha_r1, alpha_r2];
beta_vector = [beta_height, beta_r1, beta_r2];
omega_vector = [omega_height, omega_r1, omega_r2];

echo("Unfiltered Centers:", centers);
hexagons(radius=rad, hexagon_centers=centers, alpha=0.5);

place_trichos_at_centers(centers, alpha_vector, beta_vector, inter_height, omega_vector, segments);

offset_x = radius * cos(30);
offset_y = radius + radius * sin(30);

/*
color(c = "red", alpha=.75) 
translate([offset_x*2, offset_y/2, 0]) 
tricho(alpha_vec = alpha_vector, beta_vec = beta_vector, inter_h = inter_height, omega_vec = omega_vector, segs = segments);
*/

