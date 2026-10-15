// Regression check for the A/B clearance (iLOX#21).
//
// For each division line and clearance below, cells A and B must be separated by the clearance: every vertex of either
// division edge lies at least `clearance` from the other edge, and the midpoint of every segment at least `clearance`
// from the cell's top and bottom edges lies exactly `clearance` from it. The gap is wider in two places by design:
// along the bisector of a bend (clearance / cos(half the bend), as for any sharp-cornered fit), and next to the top or
// bottom edge where the line runs within `clearance` of it, because the opposite side is cut off by the edge.
// Fails on an assertion; prints PASS otherwise.
//
// Run: openscad -o clearance.echo tests/clearance/clearance_check.scad

include <../../iLOX.scad>;

eps = 1e-6;

cases = [
    // [name, width, height, div]
    [ "vertical", 5, 10, [ [ 0.3, 0 ], [ 0.3, 0.4 ] ] ],
    [ "t-slot", 10, 10, [ [ 0.3, 0 ], [ 0.3, 0.4 ], [ 0.5, 0.4 ], [ 0.5, 0.5 ] ] ],
    [ "slanted", 5, 10, [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ] ],
    [ "arc-major", 10, 10, shift_points(arc_points(diameter = 0.5, start_angle = 90, end_angle = -90, num_points = 15),
                                        0.5, 0.75) ],
];

clearances = [ 0, 0.2, 0.5 ];

function seg_dist(p, a, b) = let(ab = b - a, t = max(0, min(1, (p - a) * ab / (ab * ab)))) norm(p - (a + ab * t));

function edge_dist(p, edge) = min([for (i = [0:len(edge) - 2]) seg_dist(p, edge[i], edge[i + 1])]);

// Division edge of a cell: its points after the two outer corners.
function edge(cell) = [for (i = [2:len(cell) - 1]) cell[i]];

for (cs = cases, c = clearances)
{
    h = cs[2];
    cells = calc_ucell(width = cs[1], height = h, div = cs[3], clearance = c);
    a = edge(cells[0]);
    b = edge(cells[1]);
    // Both edges must span the cell: A runs bottom to top, B top to bottom.
    assert(abs(a[0][1]) < eps && abs(a[len(a) - 1][1] - h) < eps && abs(b[0][1] - h) < eps &&
               abs(b[len(b) - 1][1]) < eps,
           str("FAIL ", cs[0], " clearance=", c, ": a division edge does not reach the cell's top and bottom edges"));
    for (pair = [ [ a, b ], [ b, a ] ])
    {
        for (p = pair[0])
        {
            d = edge_dist(p, pair[1]);
            assert(d > c - eps,
                   str("FAIL ", cs[0], " clearance=", c, ": vertex ", p, " is ", d, " from the other cell"));
        }
        for (i = [0:len(pair[0]) - 2])
        {
            m = (pair[0][i] + pair[0][i + 1]) / 2;
            d = edge_dist(m, pair[1]);
            assert(min(m[1], h - m[1]) < c || abs(d - c) < eps,
                   str("FAIL ", cs[0], " clearance=", c, ": segment midpoint ", m, " is ", d, " from the other cell"));
        }
    }
}

echo("PASS");
