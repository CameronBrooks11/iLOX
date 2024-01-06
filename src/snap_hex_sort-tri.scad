use <sorted.scad>
use <hexagons_tess.scad>
use <tricho_geo.scad>

EPSILON = 1e-3;

// Tricho Params
radius = 1.5;

// Constants
beta_angle = 90;
alpha_angle = 30;
omega_angle = 60;
segments = 6;

// Derived constants
beta_angle_ref = 270 - beta_angle;
beta_height = radius / 4;
alpha_angle_ref = 270 - alpha_angle;
alpha_height = radius / 3;
omega_angle_ref = 270 - omega_angle;
omega_height = radius * 2 / 3;
inter_height = radius / 10;

// Calculating radii
alpha_r1 = calculateRadFromAngle(alpha_angle_ref, radius, alpha_height);
alpha_r2 = radius;
beta_r1 = calculateRadFromAngle(beta_angle_ref, alpha_r1, beta_height);
beta_r2 = alpha_r1;
omega_r1 = radius;
omega_r2 = calculateRadFromAngle(omega_angle_ref, radius, omega_height);

// Vectors for tricho parameters
alpha_vector = [alpha_height, alpha_r1, alpha_r2];
beta_vector = [beta_height, beta_r1, beta_r2];
omega_vector = [omega_height, omega_r1, omega_r2];

// Function to sort hexagon centers
function sort_centers(centers) =
    sorted(centers, key = function(p) [p[1], p[0]]);  // Sort by y, then x

// Function to calculate row height
function calculate_row_height(sorted_centers) =
    let (
        row_heights = [
            for (i = [1 : len(sorted_centers) - 1])
                if (sorted_centers[i][1] != sorted_centers[i - 1][1])
                    abs(sorted_centers[i][1] - sorted_centers[i - 1][1])
        ]
    )
    (len(row_heights) > 0) ? row_heights[0] : undef;

// Function to calculate triangulated centers
function calculate_triangulated_centers(sorted_centers) =
    let (
        row_height = calculate_row_height(sorted_centers)
    )
    let (
        tri_centers = []
    )
    concat(  // Flatten the array and filter out empty entries
        [
            for (i = [0 : len(sorted_centers) - 2]) 
                for (j = [0 : len(sorted_centers) - 1])
                    let (
                        p1 = sorted_centers[i],
                        p2 = sorted_centers[i + 1],
                        p3 = sorted_centers[j]
                    )
                    if (abs(p1[1] - p2[1]) < EPSILON && abs(p3[1] - p1[1] - row_height) < EPSILON && p3[0] > p1[0] && p3[0] < p2[0])
                        ([(p1[0] + p2[0] + p3[0]) / 3, (p1[1] + p2[1] + p3[1]) / 3])
        ]
    );

// Place a tricho at each hexagon center
module place_trichos_at_centers(centers, alpha_vector, beta_vector, inter_height, omega_vector, segments) {
    for (center = centers) {
        translate([center[0], center[1], 0]) 
        tricho(alpha_vector, beta_vector, inter_height, omega_vector, segments);
    }
}

module main() {
    lvls = 3;
    rad = radius * 1.5;

    centers = hexagon_centers(radius=rad, levels=lvls);
    echo("centers: ", centers);
    hexagons(radius=rad, hexagon_centers=centers, alpha=0.5);
    
    place_trichos_at_centers(centers, alpha_vector, beta_vector, inter_height, omega_vector, segments);


    tri_centers = calculate_triangulated_centers(centers);
    echo("Triangulated Centers:", tri_centers);
    color("red") place_trichos_at_centers(tri_centers, alpha_vector, beta_vector, inter_height, omega_vector, segments);
}

main();