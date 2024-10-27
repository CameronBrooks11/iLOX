use <utils.scad>;

// Function to transform a list of points by width and height
function transformPoints(points, width, height) = [for (p = points)[width * p[0], height *p[1]]];

// Function to subtract each point from 1
function mirrorPoints(points) = [for (p = points)[1 - p[0], 1 - p[1], p[2]]];

function reverseArray(arr) = [for (i = [0:len(arr) - 1]) arr[len(arr) - 1 - i]];

// Function to apply tolerance to x-coordinates
function applyTolerance(width, points, div, reverse_tolerance = false) = [for (i = [0:len(points) - 1])
        let(tolerance = (len(div[i % len(div)]) > 2
                             ? (width * div[i % len(div)][2]) / 2
                             : 0))[points[i][0] - (reverse_tolerance ? -tolerance : tolerance), points[i][1]]];

module place_spheres(points, d, color, zGap = 1, fn = 6)
{
    for (p = points)
    {
        translate([ p[0], p[1], zGap ]) color(color) sphere(d, $fn = fn); // Adjust sphere diameter if necessary
    }
}

// Function to calculate the cell points based on given dimensions and points
function calc_ucells(width, height, div, neg_poly = []) =
    let(cornersA = [ [ 0, height ], [ 0, 0 ] ], cornersB = [[width, 0], [width, height]],
        // Create mirrored division
        div_mirrored = concat(div, mirrorPoints(reverseArray(div))),
        // Transform points
        div_polyA = transformPoints(div_mirrored, width, height), div_polyB = reverseArray(div_polyA),
        // Apply tolerance to the first half (normal tolerance)
        div_polyA_tol = applyTolerance(width, div_polyA, div),
        // Apply tolerance to the second half (mirrored/reversed tolerance)
        div_polyB_tol = applyTolerance(width, div_polyB, div, true),
        // Create cell points with tolerance
        cell_pointsA = concat(cornersA, div_polyA_tol), cell_pointsB = concat(cornersB, div_polyB_tol),
        // Calculate negative cell points if neg_poly is provided
        ncell_pointsA = len(neg_poly) > 0 ? transformPoints(neg_poly, width, height) : [],
        ncell_pointsB = len(neg_poly) > 0 ? transformPoints(mirrorPoints(neg_poly), width, height)
                                          : [])[cell_pointsA, cell_pointsB, ncell_pointsA, ncell_pointsB];

// Module to render the polygons with optional coloring
module render_ucells(cells, colors = [ "MediumAquamarine", "MediumBlue", "Red", "DarkRed" ])
{
    // Unpack calculated cell points
    cell_pointsA = cells[0];
    cell_pointsB = cells[1];
    ncell_pointsA = cells[2];
    ncell_pointsB = cells[3];

    // Draw the main polygons
    color(colors[0]) polygon(points = cell_pointsA);
    color(colors[1]) polygon(points = cell_pointsB);

    // Draw the negative polygons if they exist
    if (len(ncell_pointsA) > 0)
    {
        color(colors[2]) polygon(points = ncell_pointsA);
        color(colors[3]) polygon(points = ncell_pointsB);
    }
}