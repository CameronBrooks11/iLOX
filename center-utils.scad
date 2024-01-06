use <sorted.scad>

EPSILON = 1e-3;

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
