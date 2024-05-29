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