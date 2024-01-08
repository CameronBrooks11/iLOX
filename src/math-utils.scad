/*
 * Title: math-utils.scad
 * Author: [Your Name]
 * Organization: [Your Organization]
 *
 * Description:
 *   This function calculates the radius at a given angle, taking into account the initial radius 
 *   and height. It is designed to work with angles in a 2D plane and adjusts the radius based 
 *   on the tangent of the angle. The function handles angles within the first and second quadrants 
 *   (0-180 degrees) by normalizing them to 0-90 degrees.
 *
 * Parameters:
 *   angle - The angle at which the radius is to be calculated, in degrees.
 *   r - The initial radius before any height adjustment.
 *   height - The height at which the radius is to be adjusted.
 *
 * Returns:
 *   The adjusted radius based on the given angle, initial radius, and height.
 *
 * Usage Notes:
 *   - The angle should be provided in degrees.
 *   - The function is particularly useful in calculations involving conical shapes or spiral calculations.
 *   - This function assumes a linear relationship between the height and the radius change.
 *
 * Example:
 *   calculateRadFromAngle(45, 10, 5) // Calculate the radius at a 45-degree angle, with an initial radius of 10 and a height of 5.
 *
 * Revision History:
 *   [YYYY-MM-DD] - Initial version.
 *   [YYYY-MM-DD] - Subsequent updates with details.
 */


// Function to calculate radius based on angle, initial radius, and height
function calculateRadFromAngle(angle, r, height) = 
    let(norm_angle = angle % 90)
    (angle < 90)
        ? r + tan((abs(90 - norm_angle))) * height
        : r - tan((norm_angle)) * height;