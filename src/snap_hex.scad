use <viz-utils.scad>;
use <point-utils.scad>;
use <hexagons_tess.scad>;
use <tricho_geo.scad>;

module main() {



    
    overlap = 0.2;
    // Tricho Params
    radius = 1.5;
    lvls = 3;
    rad = radius * sqrt(3) - overlap;

    // Angle paramters
    beta_angle = 90;
    alpha_angle = 30;
    omega_angle = 60;
    segments = 6;

    // Derived example parameters
    beta_height = radius / 2;
    alpha_height = radius / 3;
    omega_height = radius * 2 / 3;
    inter_height = radius / 10;


    offset_x = radius * cos(30);
    offset_y = radius + radius * sin(30);

centers = hexagon_centers(radius=rad, levels=lvls);

union(){
    echo("Centers: ", centers);
    hexagons(radius=rad, hexagon_centers=centers, alpha=0.5);
    
    color("blue", alpha=0.5) 
    place_trichos_at_centers(centers=centers, r=radius, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
            alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height); 
}
    
tri_centers = triangulated_center_points(centers);

translate([radius*lvls*5,0,0]) union(){
    echo("Triangulated Centers:", tri_centers);
    hexagons(radius=rad, hexagon_centers=tri_centers, alpha=0.5);
    color("red", alpha=0.5) 
    place_trichos_at_centers(centers=tri_centers, r=radius, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
            alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height); 
}
}

main();