// Define parameters
$fn = 16;
start_ang = 60;
branch_offset = 0;
ang_offset = 0;
branch_len = 100;
branch_ang_lim = 9999;
ang_dec = 3;
start_r = 9;
n_branches = 3;

// Optional variables for transient rendering and animation
// Define default values for static rendering
real_time = false;  // Set to true for animation
tree_depth = 5;     // Maximum recursion depth for static rendering

// Time-based variables for animation or static rendering
t = real_time ? $t : 1; // Use $t for animation, 1 for static rendering
r = start_r * t;
rf = floor(r);
rmr = (r % 1) * 15;

// Viewport settings
$vpr = [75, 0, 360 * t];
$vpt = [0, 0, 50 * t];
start_dist = 800;
end_dist = 3000;
$vpd = start_dist + (end_dist - start_dist) * t;

// Recursive tree module
module tree(r=rf, cur_x=0, cur_y=0, n_branches=n_branches, 
            branch_len=branch_len, branch_d=branch_len * 0.4, 
            ang=start_ang, i=360, depth=tree_depth) {
    
    // Base case for recursion
    if (depth > 0) {
        let(step = max(min(r, rf), rmr)) {
            if (!real_time || (i / 360) < step) {
                cylinder(h=branch_len, d1=branch_d, d2=branch_d * pow(0.86, 3), center=false);
                sphere(r=branch_d * 0.5, $fn=$fn);
            }
        }

        for (i=[0 : (360 / n_branches) : (360 - 1)]) {
            x_offset = rands(min_value=-branch_offset, max_value=branch_offset, value_count=1)[0];
            y_offset = rands(min_value=-branch_offset, max_value=branch_offset, value_count=1)[0];
            ang = ang - ang_dec;
            x_ang = sin(i + x_offset) * ang;
            y_ang = cos(i + y_offset) * ang;
            cur_x = cur_x + x_ang;
            cur_y = cur_y + y_ang;
            
            translate([0, 0, branch_len]) rotate([y_ang, x_ang, 0]) {
                if ((max(abs(cur_x), abs(cur_y)) < branch_ang_lim)) {
                        tree(r - 1, cur_x, cur_y, n_branches=n_branches, 
                             branch_len=branch_len * pow(0.95, 3), 
                             ang=ang, branch_d=branch_d * pow(0.86, 3),
                             depth=depth-1); // Decrement depth
                }
            }
        }
    }
}

// Initialize the tree with a specified depth for static rendering
tree(depth=tree_depth);
