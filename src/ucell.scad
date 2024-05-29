use <line2d-dotSCAD/polyline2d.scad>;

// Function to transform a list of points by width and height
function transformPoints(points, width, height) = 
    [for (p = points) [width * p[0], height * p[1]]];

// Function to subtract each point from 1
function mirrorPoints(points) = [for (p = points) [1 - p[0], 1 - p[1]]];

function reverseArray(arr) =
    [for (i = [0:len(arr)-1]) arr[len(arr)-1 - i]];

// Function to apply tolerance to x-coordinates
function applyTolerance(points, div) =
    [for (i = [0:len(points)-1]) [points[i][0] - (len(div[i % len(div)]) > 2 ? width * div[i % len(div)][2] : 0), points[i][1]]];

height = 15;
width = 10;

// Define the division with tolerance
di = [
    [0.25, 0, 0.01], 
    [0.2, 1/4, 0.01],
    [0.25, 1/3, 0.01], 
    [0.5, 1/2, 0.01]
];

div = concat(di, mirrorPoints(reverseArray(di)));

divA = transformPoints(div, width, height);

divB = reverseArray(divA);

echo(divA);
echo(divB);

// Apply tolerances
divAA = applyTolerance(divA, div);
divBB = applyTolerance(divB, -((div)));

echo(divAA);
echo(divBB);

cornersA = [
    [0, height],
    [0, 0],
];

cornersB = [
    [width, 0],
    [width, height],
];

cell_pointsA = concat(cornersA, divAA);
cell_pointsB = concat(cornersB, divBB);

color("MediumAquamarine") polygon(points = cell_pointsA);
color("MediumBlue") polygon(points = cell_pointsB);

