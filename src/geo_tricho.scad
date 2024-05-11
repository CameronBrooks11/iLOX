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


use <utils_math.scad>;



module tricho(r, beta, beta_h, alpha, alpha_h, omega, omega_h, inter_h) {

    // DEFAULT DEFINITIONS
    def_beta_height = (r / 2); //stem
    def_alpha_height = (r / 3); //lower face
    def_omega_height = (r * 2 / 3); //upper face
    def_inter_height = (r / 3); //interstitial portion

    def_beta_angle = 90;
    def_alpha_angle = 30;
    def_omega_angle = 60;

    def_segments = 6;

    // Parameter switches
    beta_angle = is_undef(beta) ? def_beta_angle : beta;
    alpha_angle = is_undef(alpha) ? def_alpha_angle : alpha;
    omega_angle = is_undef(omega) ? def_omega_angle : omega;
    
    ref = 270;
    beta_angle_ref = ref - beta_angle;
    alpha_angle_ref = ref - alpha_angle;
    omega_angle_ref = ref - omega_angle;

    segments = is_undef(segments) ? def_segments : segments;
    
    beta_height = is_undef(beta_h) ? def_beta_height : beta_h;
    alpha_height = is_undef(alpha_h) ? def_alpha_height : alpha_h;
    omega_height = is_undef(omega_h) ? def_omega_height : omega_h;
    inter_height = is_undef(inter_h) ? def_inter_height : inter_h;

    // Calculating radii
    alpha_r1 = calculateRadFromAngle(alpha_angle_ref, r, alpha_height);
    alpha_r2 = r;
    beta_r1 = calculateRadFromAngle(beta_angle_ref, alpha_r1, beta_height);
    beta_r2 = alpha_r1;
    omega_r1 = r;
    omega_r2 = calculateRadFromAngle(omega_angle_ref, r, omega_height);

    // Vectors for parameters
    alpha_vector = [alpha_height, alpha_r1, alpha_r2];
    beta_vector = [beta_height, beta_r1, beta_r2];
    omega_vector = [omega_height, omega_r1, omega_r2];

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