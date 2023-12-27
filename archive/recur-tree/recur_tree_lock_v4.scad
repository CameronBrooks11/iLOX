// Define color palettes
palette_vibrant = ["Red", "DeepSkyBlue", "LimeGreen", "Fuchsia", "Gold", 
                   "MediumSlateBlue", "HotPink", "OrangeRed", "MediumSpringGreen", "DodgerBlue"];

palette_pastel = ["LavenderBlush", "Honeydew", "MintCream", "AliceBlue", "Seashell", 
                  "LemonChiffon", "Azure", "LightCyan", "PaleTurquoise", "MistyRose"];

palette_earthy = ["SandyBrown", "Goldenrod", "Peru", "OliveDrab", "Khaki", 
                  "DarkKhaki", "Tan", "DarkOliveGreen", "BurlyWood", "Wheat"];

palette_cool = ["Indigo", "SlateBlue", "CadetBlue", "DarkSlateBlue", "Teal", 
                "DarkCyan", "SteelBlue", "MediumSlateBlue", "LightSeaGreen", "MidnightBlue"];

palette_warm = ["Chocolate", "Sienna", "Maroon", "FireBrick", "Brown", 
                "DarkRed", "Crimson", "DarkOrange", "Tomato", "OrangeRed"];

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
branch_d_factor = 0.86;
branch_len_factor = 0.95;

// Optional variables for transient rendering and animation
real_time = false;  // Set to true for animation
tree_depth = 6;     // Maximum recursion depth for static rendering
detail_level = 10;  // Lower for higher performance (less detail)

// Function to calculate branch diameter
function branch_diameter(d, level) = d * pow(branch_d_factor, level);

// Function to calculate branch length
function branch_length(l, level) = l * pow(branch_len_factor, level);

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
            ang=start_ang, depth=tree_depth, level=0, color_palette=0){
    
    // Select color palette based on color_palette variable
    selected_colors = 
        color_palette == 1 ? palette_vibrant :
        color_palette == 2 ? palette_pastel :
        color_palette == 3 ? palette_earthy :
        color_palette == 4 ? palette_cool :
        palette_warm; // Default or when color_palette == 5
    
    // Apply color cycling based on recursion level
    color_index = level % len(selected_colors);  // Determine color index based on level
    current_color = selected_colors[color_index];  // Get current color from array
    
    // Base case for recursion
    if (depth > 0 && level < detail_level) {
        color(current_color) {
            if (!real_time || (level / detail_level) < t) {
                // Draw branch components with the appropriate color
                cylinder(h=branch_len, d1=branch_d, d2=branch_diameter(branch_d, level), center=false);
                sphere(r=branch_diameter(branch_d, level) * 0.5, $fn=$fn);
            }
        }

        // Create branches at the current level
        for (i=[0 : (360 / n_branches) : (359)]) {
            let (
                x_offset = rands(min_value=-branch_offset, max_value=branch_offset, value_count=1)[0],
                y_offset = rands(min_value=-branch_offset, max_value=branch_offset, value_count=1)[0],
                ang = ang - ang_dec,
                x_ang = sin(i + x_offset) * ang,
                y_ang = cos(i + y_offset) * ang,
                cur_x = cur_x + x_ang,
                cur_y = cur_y + y_ang
            ) {
                // Position and orient the next level of branches
                translate([0, 0, branch_len]) rotate([y_ang, x_ang, 0]) {
                    // Recursive call to create the next level of branches if within limits
                    if ((max(abs(cur_x), abs(cur_y)) < branch_ang_lim)) {
                        tree(r - 1, cur_x, cur_y, n_branches=n_branches, 
                             branch_len=branch_length(branch_len, level + 1), 
                             branch_d=branch_diameter(branch_d, level + 1),
                             ang=ang, depth=depth - 1, level=level + 1, color_palette=color_palette);
                    }
                }
            }
        }
    }
}

// Initialize the tree with a specified depth for static rendering and palette_earthy
tree(depth=tree_depth, color_palette=3);
