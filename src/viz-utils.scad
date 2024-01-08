



// Function to get gradient color based on the color scheme
function get_gradient_color(normalized_x, normalized_y, color_scheme) = 
    color_scheme == "scheme1" ? [normalized_x, 1 - normalized_x, normalized_y] : // Red to Blue
    color_scheme == "scheme2" ? [1 - normalized_y, normalized_x, normalized_y] : // Green to Magenta
    color_scheme == "scheme3" ? [normalized_y, 1 - normalized_y, normalized_x] : // Blue to Yellow
    color_scheme == "scheme4" ? [1 - normalized_x, normalized_x, 1 - normalized_y] : // Cyan to Red
    color_scheme == "scheme5" ? [normalized_x, normalized_x * normalized_y, 1 - normalized_x] : // Purple to Green
    color_scheme == "scheme6" ? [1 - normalized_x * normalized_y, normalized_y, normalized_x] : // Orange to Blue
    [0.9, 0.9, 0.9]; // Default color (black) if no valid color scheme is provided

// Module to print points as text
module print_points(points, text_size=2, color=[0.1, 0.1, 0.1]) {
    for (point = points) {
        color(color)
        translate([point[0], point[1], 1]) // Translated +1 in Z-axis
        text(str("[", point[0], ", ", point[1], "]"), size=text_size, valign="center", halign="center");
    }
}

