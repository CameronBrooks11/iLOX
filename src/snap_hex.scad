use <hex-center-utils.scad>;
use <hexagons_tess.scad>;
use <tricho_geo.scad>;

// Place a tricho at each hexagon center
module place_trichos_at_centers(centers, r, beta_angle, beta_height, alpha_angle, 
            alpha_height, omega_angle, omega_height, inter_height) {
    for (center = centers) {
        translate([center[0], center[1], 0]) 
        tricho(r=r, beta=beta_angle, beta_h=beta_height, alpha=alpha_angle, 
            alpha_h=alpha_height, omega=omega_angle, omega_h=omega_height, inter_h=inter_height); 
    }
}

module main() {
    // Tricho Params
    radius = 1.5;
    lvls = 3;
    rad = radius * 1.5;

    // Angle paramters
    beta_angle = 90;
    alpha_angle = 30;
    omega_angle = 60;
    segments = 6;

    // Derived example parameters
    beta_height = radius / 4;
    alpha_height = radius / 3;
    omega_height = radius * 2 / 3;
    inter_height = radius / 10;


    centers = hexagon_centers(radius=rad, levels=lvls);
    echo("Centers: ", centers);
    hexagons(radius=rad, hexagon_centers=centers, alpha=0.5);
    
    color("blue", alpha=0.5) 
    place_trichos_at_centers(centers=centers, r=radius, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
            alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height); 

    tri_centers = calculate_triangulated_centers(centers);
    echo("Triangulated Centers:", tri_centers);
    color("red", alpha=0.5) 
    place_trichos_at_centers(centers=tri_centers, r=radius, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
            alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height); 
}

main();