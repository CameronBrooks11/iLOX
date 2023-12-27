/*!
 * Recursive Tree Library
 * Author: Your Name
 *
 * Description:
 * This library generates fractal trees with customizable parameters for static and animated rendering.
 * Users can select color palettes and adjust various aspects of the tree's appearance.
 *
 * Parameters:
 * depth: Mandatory. The recursion depth of the tree.
 * base_branch_len: Optional. The length of the base branch.
 * color_palette: Optional. The name of the color palette to use.
 * ...additional parameters documented...
 *
 * Usage:
 * tree(depth=6, base_branch_len=90, color_palette="vibrant");
 */

// --- Color Palettes ---
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

// --- Global Parameters ---
$fn = 16;
start_ang = 60;
branch_offset = 0;
ang_offset = 0;
branch_ang_lim = 9999;
ang_dec = 3;
start_r = 9;
n_branches = 3;
branch_d_factor = 0.86;
branch_len_factor = 0.95;
real_time = false;  // Set to true for animation
tree_depth = 8;     // Maximum recursion depth for static rendering
detail_level = 100;  // Lower for higher performance (less detail)

// --- Utility Functions ---
function branch_diameter(d, level) = d * pow(branch_d_factor, level);
function branch_length(l, level) = l * pow(branch_len_factor, level);

// --- Main Tree Module ---
module tree(depth, base_branch_len = 100, color_palette = "warm", 
            cur_x=0, cur_y=0, ang=start_ang, level=0, animate=false){
    
    // Determine real-time vs static rendering
    t = animate ? $t : 1;
    r = start_r * t;
    rf = floor(r);
    rmr = (r % 1) * 15;

    // Select color palette
    selected_colors = 
        color_palette == "vibrant" ? palette_vibrant :
        color_palette == "pastel" ? palette_pastel :
        color_palette == "earthy" ? palette_earthy :
        color_palette == "cool" ? palette_cool :
        palette_warm;

    // Recursion and drawing logic
    
    // Apply color cycling based on recursion level
    color_index = level % len(selected_colors);  // Determine color index based on level
    current_color = selected_colors[color_index];  // Get current color from array
    
    // Base case for recursion
    if (depth > 0 && level < detail_level) {
        color(current_color) {
            if (!real_time || (level / detail_level) < t) {
                // Draw branch components with the appropriate color
                cylinder(h=base_branch_len, d1=branch_diameter(base_branch_len, level), 
                         d2=branch_diameter(base_branch_len, level + 1), center=false);
                sphere(r=branch_diameter(base_branch_len, level) * 0.5, $fn=$fn);
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
            translate([0, 0, branch_length(base_branch_len, level)]) rotate([y_ang, x_ang, 0]) {
                // Recursive call to create the next level of branches if within limits
                if ((max(abs(cur_x), abs(cur_y)) < branch_ang_lim)) {
                    tree(
                        depth=depth - 1, 
                        base_branch_len=branch_length(base_branch_len, level + 1), 
                        color_palette=color_palette, 
                        cur_x=cur_x, 
                        cur_y=cur_y, 
                        ang=ang, 
                        level=level + 1, 
                        animate=animate
                    );
                }
            }
        }
    }
}
            }

// --- Examples ---
// Example for static rendering with 'palette_earthy'
tree(depth=tree_depth, base_branch_len=200, color_palette="earthy", animate=real_time);

// Example for animated rendering with 'palette_cool'
// tree(depth=tree_depth, base_branch_len=branch_len, color_palette="cool", animate=true);