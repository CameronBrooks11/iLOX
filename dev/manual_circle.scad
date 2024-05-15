// Function to generate circle points
function circle_points(radius, num_points) = [
    for (i = [0 : num_points - 1])
        let (angle = i * 360 / num_points)
        [radius * cos(angle), radius * sin(angle)]
];

// Test the function
module draw_circle(radius, num_points) {
    points = circle_points(radius, num_points);
    polygon(points);
}

// Example usage
draw_circle(10, 100);