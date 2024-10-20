use <line2d-dotSCAD/polyline2d.scad>;
use <utils.scad>;

// Function to transform a list of points by width and height
function transformPoints(points, width, height) = [for (p = points)[width * p[0], height *p[1]]];

// Function to subtract each point from 1
function mirrorPoints(points) = [for (p = points)[1 - p[0], 1 - p[1], p[2]]];

function reverseArray(arr) = [for (i = [0:len(arr) - 1]) arr[len(arr) - 1 - i]];

// Function to apply tolerance to x-coordinates
function applyTolerance(points, div, reverse_tolerance = false) = [for (i = [0:len(points) - 1])
        let(tolerance = (len(div[i % len(div)]) > 2
                             ? (width * div[i % len(div)][2]) / 2
                             : 0))[points[i][0] - (reverse_tolerance ? -tolerance : tolerance), points[i][1]]];

module place_spheres(points, d, color)
{
    for (p = points)
    {
        translate([ p[0], p[1], 1 ]) color(color) sphere(d); // Adjust sphere diameter if necessary
    }
}

height = 10;
width = height / 2;

// Define the x,y division with tolerance
di = [
    [ 0.5, 0, 0.01 ],
    [ 0.3, 0.1, 0.01 ],
    [ 0.3, 0.4, 0.01 ],
];

// Create mirrored division
div = concat(di, mirrorPoints(reverseArray(di)));

echo(div);

// Transform points
divA = transformPoints(div, width, height);
divB = reverseArray(divA);

// print_points(divA, text_size=0.1, color="red", pointD=0.1, point_color="DarkSlateGray");

// Apply tolerance to the first half (normal tolerance)
divAA = applyTolerance(divA, di);

// Apply tolerance to the second half (mirrored/reversed tolerance)
divBB = applyTolerance(divB, (di), true);

// Echo to see the points
echo(divAA);
echo(divBB);

// Define corners for the polygons
cornersA = [
    [ 0, height ],
    [ 0, 0 ],
];

cornersB = [
    [ width, 0 ],
    [ width, height ],
];

// Create cell points with tolerance
cell_pointsA = concat(cornersA, divAA);
cell_pointsB = concat(cornersB, divBB);

// Draw the polygons
color("MediumAquamarine") polygon(points = cell_pointsA);
color("MediumBlue") polygon(points = cell_pointsB);

// Negative
ni = [
    [ 0.7, .8 ],
    [ 0.7, 1 ],
    [ 0.3, 1 ],
];

ncell_pointsA = transformPoints(ni, width, height);
ncell_pointsB = transformPoints(mirrorPoints(ni), width, height);

color("Red") polygon(points = ncell_pointsA);
color("DarkRed") polygon(points = ncell_pointsB);

color("Green") translate([0, height*1.5, 0 ]) rotate([0,0,30]) rotate_extrude($fn=6) difference()
{
    polygon(points = cell_pointsA);
    polygon(points = ncell_pointsA);
}

color("Blue") translate([width - width * (1 - cos(30)) , height*1.5, 0 ]) rotate([0,0,30]) rotate_extrude($fn=6) translate([-width,0,0]) difference()
{
    polygon(points = cell_pointsB);
    polygon(points = ncell_pointsB);
}
