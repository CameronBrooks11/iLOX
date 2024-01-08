/*
 * Title: Vizualization Utilities
 * Author: [Your Name]
 * Organization: [Your Organization]
 *
 * License: [Specify License]
 *
 * Description:
 *   This OpenSCAD script offers visualization utility functions for color manipulation and visual representation of points.
 *   The 'get_gradient_color' function generates gradient colors based on normalized coordinates and predefined
 *   color schemes. It supports multiple schemes, allowing for a variety of color transitions. The 'print_points'
 *   module is designed to visually represent points in a 3D space by printing their coordinates as text, which
 *   is useful for debugging and visualizing point data.
 *
 * Usage Notes:
 *   - Use 'get_gradient_color' to obtain gradient colors for visualizations, animations, or any graphical representation.
 *   - 'print_points' can be utilized to display the coordinates of points in 3D models for debugging or presentation purposes.
 *   - Customize the 'print_points' module by adjusting the text size and color as needed.
 *
 * Parameters:
 *   - For 'get_gradient_color':
 *       normalized_x, normalized_y: Normalized x and y values (0 to 1).
 *       color_scheme: Predefined color schemes for gradient generation.
 *   - For 'print_points':
 *       points: Array of points to be printed.
 *       text_size: Size of the text for printed points.
 *       color: Color of the text.
 *
 * Revision History:
 *   [YYYY-MM-DD] - Initial version.
 *   [YYYY-MM-DD] - Subsequent updates with details.
 */



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
module print_points(points, text_size=1, color=[0.1, 0.1, 0.1]) {
    for (point = points) {
        color(color)
        translate([point[0], point[1], 1]) // Translated +1 in Z-axis
        text(str("[", point[0], ", ", point[1], "]"), size=text_size, valign="center", halign="center");
    }
}

