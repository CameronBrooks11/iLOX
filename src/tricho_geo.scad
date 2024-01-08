// Function to calculate radius based on angle, initial radius, and height
function calculateRadFromAngle(angle, r, height) = 
    let(norm_angle = angle % 90)
    (angle < 90)
        ? r + tan((abs(90 - norm_angle))) * height
        : r - tan((norm_angle)) * height;


module tricho(r, beta, beta_h, alpha, alpha_h, omega, omega_h, inter_h) {

    // Constants
    radius = r;

    beta_angle = beta;
    beta_angle_ref = 270 - beta_angle;
    beta_height = beta_h;   // radius / 4;

    alpha_angle = alpha;
    alpha_angle_ref = 270 - alpha_angle;
    alpha_height = alpha_h; // radius / 3

    omega_angle = omega;
    omega_angle_ref = 270 - omega_angle;
    omega_height = omega_h; // radius * 2 / 3;
    inter_height = inter_h; // radius / 10;
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

    echo("Section: Beta, Radius 1:", beta_vector[1], "Radius 2:", beta_vector[2], "Height:", beta_vector[0], "Angle:", beta_angle);
    echo("Section: Alpha, Radius 1:", alpha_vector[1], "Radius 2:", alpha_vector[2], "Height:", alpha_vector[0], "Angle:", alpha_angle);
    echo("Section: Interstitial, Radius 1:", alpha_vector[2], "Radius 2:", omega_vector[1], "Height:", inter_height, "Angle: -");
    echo("Section: Omega, Radius 1:", omega_vector[1], "Radius 2:", omega_vector[2], "Height:", omega_vector[0], "Angle:", omega_angle);


    tricho_geo(alpha_vector, beta_vector, inter_height, omega_vector, segments);
}

// Function to construct the tricho model
module tricho_geo(alpha_vec, beta_vec, inter_h, omega_vec, segs) {
    alpha_h = alpha_vec[0];
    alpha_r1 = alpha_vec[1];
    alpha_r2 = alpha_vec[2];
    beta_h = beta_vec[0];
    beta_r1 = beta_vec[1];
    beta_r2 = beta_vec[2];
    omega_h = omega_vec[0];
    omega_r1 = omega_vec[1];
    omega_r2 = omega_vec[2];

    // Beta segment
    translate([0, 0, 0])
        cylinder(h = beta_h, r1 = beta_r1, r2 = beta_r2, $fn = segs);

    // Alpha segment
    translate([0, 0, beta_h])
        cylinder(h = alpha_h, r1 = alpha_r1, r2 = alpha_r2, $fn = segs);
    
    // Interstitial segment
    translate([0, 0, beta_h + alpha_h])
        cylinder(h = inter_h, r1 = alpha_r2, r2 = omega_r1, $fn = segs);

    // Omega segment
    translate([0, 0, beta_h + alpha_h + inter_h])
        cylinder(h = omega_h, r1 = omega_r1, r2 = omega_r2, $fn = segs);
}


// Place a tricho at each hexagon center
module place_trichos_at_centers(centers, alpha_vector, beta_vector, inter_height, omega_vector, segments) {
    for (center = centers) {
        translate([center[0], center[1], 0]) 
        tricho(alpha_vector, beta_vector, inter_height, omega_vector, segments);
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