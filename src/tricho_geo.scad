/*
 * Title: Tricho Geometric Structure Generator
 * Author: [Your Name]
 * Organization: [Your Organization]
 *
 * License: [Specify License]
 *
 * Description:
 *   This OpenSCAD script, named 'tricho.scad', is designed to generate a complex geometric 
 *   structure called 'tricho'. The structure is composed of various cylindrical segments 
 *   (alpha, beta, omega, and interstitial segments), each defined by specific radii, heights, 
 *   and angles. The script provides a modular approach to constructing these segments and 
 *   assembling them into the complete 'tricho' structure. Additionally, it allows placing 
 *   multiple 'tricho' structures at specified center points, enabling the creation of intricate 
 *   geometric patterns.
 *
 * Dependencies:
 *   math-utils.scad - Required for mathematical operations and calculations.
 *
 * Usage Notes:
 *   - Include this script in your OpenSCAD project to generate 'tricho' structures.
 *   - Customize the 'tricho' by adjusting the radius, angle, height, and segment parameters.
 *   - The 'place_trichos_at_centers' module can be used to replicate the 'tricho' structure 
 *     at various points in a design.
 *   - Ensure that 'math-utils.scad' is accessible in your project directory.
 *
 * Parameters:
 *   r - Base radius for the 'tricho' structure.
 *   beta, alpha, omega - Angles for the respective segments.
 *   beta_h, alpha_h, omega_h - Heights for the respective segments.
 *   inter_h - Height of the interstitial segment.
 *   segments - Number of facets for the cylinders.
 *
 * Revision History:
 *   [YYYY-MM-DD] - Initial version.
 *   [YYYY-MM-DD] - Subsequent updates with details.
 */


use <math-utils.scad>;


module tricho(r, beta, beta_h, alpha, alpha_h, omega, omega_h, inter_h) {

    ref = 270;

    beta_angle = beta;
    beta_angle_ref = ref - beta_angle;
    beta_height = beta_h;   // by default it is radius / 4;

    alpha_angle = alpha;
    alpha_angle_ref = ref - alpha_angle;
    alpha_height = alpha_h; //  by default it is radius / 3

    omega_angle = omega;
    omega_angle_ref = ref - omega_angle;
    omega_height = omega_h; //  by default it is radius * 2 / 3;
    inter_height = inter_h; //  by default it is radius / 10;

    segments = 6;

    // Calculating radii
    alpha_r1 = calculateRadFromAngle(alpha_angle_ref, r, alpha_height);
    alpha_r2 = r;
    beta_r1 = calculateRadFromAngle(beta_angle_ref, alpha_r1, beta_height);
    beta_r2 = alpha_r1;
    omega_r1 = r;
    omega_r2 = calculateRadFromAngle(omega_angle_ref, radius, omega_height);

    // Vectors for parameters
    alpha_vector = [alpha_height, alpha_r1, alpha_r2];
    beta_vector = [beta_height, beta_r1, beta_r2];
    omega_vector = [omega_height, omega_r1, omega_r2];


    //echo("Section: Beta, Radius 1:", beta_vector[1], "Radius 2:", beta_vector[2], "Height:", beta_vector[0], "Angle:", beta_angle);
    //echo("Section: Alpha, Radius 1:", alpha_vector[1], "Radius 2:", alpha_vector[2], "Height:", alpha_vector[0], "Angle:", alpha_angle);
    //echo("Section: Interstitial, Radius 1:", alpha_vector[2], "Radius 2:", omega_vector[1], "Height:", inter_height, "Angle: -");
    //echo("Section: Omega, Radius 1:", omega_vector[1], "Radius 2:", omega_vector[2], "Height:", omega_vector[0], "Angle:", omega_angle);


    tricho_geo(alpha_vector, beta_vector, inter_height, omega_vector, segments);
}

// Function to construct the tricho model
module tricho_geo(alpha_vec, beta_vec, inter_h, omega_vec, segs) {
    // Beta segment
    translate([0, 0, 0])
        cylinder(h = beta_vec[0], r1 = beta_vec[1], r2 = beta_vec[2], $fn = segs);

    // Alpha segment
    translate([0, 0, beta_vec[0]])
        cylinder(h = alpha_vec[0], r1 = alpha_vec[1], r2 = alpha_vec[2], $fn = segs);

    // Interstitial segment
    translate([0, 0, beta_vec[0] + alpha_vec[0]])
        cylinder(h = inter_h, r1 = alpha_vec[2], r2 = omega_vec[1], $fn = segs);

    // Omega segment
    translate([0, 0, beta_vec[0] + alpha_vec[0] + inter_h])
        cylinder(h = omega_vec[0], r1 = omega_vec[1], r2 = omega_vec[2], $fn = segs);
} 



// Place a tricho at each hexagon center
module place_trichos_at_centers(centers, r, beta_angle, beta_height, alpha_angle, 
            alpha_height, omega_angle, omega_height, inter_height) {
    for (center = centers) {
        translate([center[0], center[1], 0]) 
        tricho(r=r, beta=beta_angle, beta_h=beta_height, alpha=alpha_angle, 
            alpha_h=alpha_height, omega=omega_angle, omega_h=omega_height, inter_h=inter_height); 
    }
}


// Tricho Params
radius = 1.5;

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


tricho(r=radius, beta=beta_angle, beta_h=beta_height, alpha=alpha_angle, alpha_h=alpha_height, omega=omega_angle, omega_h=omega_height, inter_h=inter_height); 