// Checks the A/B clearance (#21): both cells stay inside the unit cell without crossing themselves or each other,
// every vertex of one is at least `clearance` from the other, and the cut sides more than `clearance` from the cell's
// edges lie exactly `clearance` / 2 from the division line. Prints PASS.
//
// Run: openscad -o clearance.echo tests/clearance/clearance_check.scad

include <../../iLOX.scad>;

eps = 1e-6;

cases = [
    // [name, width, height, div]
    [ "vertical", 5, 10, [ [ 0.3, 0 ], [ 0.3, 0.4 ] ] ],
    [ "t-slot", 10, 10, [ [ 0.3, 0 ], [ 0.3, 0.4 ], [ 0.5, 0.4 ], [ 0.5, 0.5 ] ] ],
    [ "slanted", 5, 10, [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ] ],
    [ "flat-start", 10, 10, [ [ 0.3, 0 ], [ 0.5, 0 ], [ 0.5, 0.4 ] ] ],
    [ "near-bottom", 5, 10, [ [ 0.2, 0 ], [ 0.2, 0.1 ], [ 0.4, 0.1 ], [ 0.4, 0.01 ], [ 0.6, 0.01 ], [ 0.6, 0.4 ] ] ],
    [ "arc", 10, 10, shift_points(arc_points(diameter = 0.5, start_angle = 90, end_angle = -90, num_points = 15), 0.5,
                                  0.75) ],
    [ "arc-fine", 10, 10, shift_points(arc_points(diameter = 0.5, start_angle = 90, end_angle = -90, num_points = 60),
                                       0.5, 0.75) ],
];

clearances = [ 0, 0.2, 0.5 ];

function seg_dist(p, a, b) = let(ab = b - a, t = max(0, min(1, (p - a) * ab / (ab * ab)))) norm(p - (a + ab * t));

// Segments of a cell that are not on the unit cell's edges: the sides facing the other cell
function cut_segments(poly, w, h) = [for (i = [0:len(poly) - 1]) let(a = poly[i], b = poly[(i + 1) % len(poly)])
        if (!(abs(a[0]) < eps && abs(b[0]) < eps || abs(a[0] - w) < eps && abs(b[0] - w) < eps ||
              abs(a[1]) < eps && abs(b[1]) < eps || abs(a[1] - h) < eps && abs(b[1] - h) < eps))[a, b]];

function dist(p, segs) = min([for (s = segs) seg_dist(p, s[0], s[1])]);

function unit(v) = v / norm(v);

function side(a, b, p) = let(v = (b - a)[0] * (p - a)[1] - (b - a)[1] * (p - a)[0]) abs(v) < eps ? 0 : sign(v);

// Segments a-b and c-d cross at a point inside both
function crosses(a, b, c, d) = side(a, b, c) * side(a, b, d) < 0 && side(c, d, a) * side(c, d, b) < 0;

function crossings(p, q) = [for (i = [0:len(p) - 1], j = [0:len(q) - 1])
        let(a = p[i], b = p[(i + 1) % len(p)], c = q[j], d = q[(j + 1) % len(q)]) if (crosses(a, b, c, d))[i, j]];

for (cs = cases, c = clearances)
{
    w = cs[1];
    h = cs[2];
    cells = calc_ucell(width = w, height = h, div = cs[3], clearance = c);
    zero = calc_ucell(width = w, height = h, div = cs[3], clearance = 0)[0];
    line = cut_segments(zero, w, h);
    tag = str("FAIL ", cs[0], " clearance=", c, ": ");
    for (k = [0:1])
    {
        poly = cells[k];
        other = cut_segments(cells[1 - k], w, h);
        for (p = poly)
        {
            assert(p[0] > -eps && p[0] < w + eps && p[1] > -eps && p[1] < h + eps, str(tag, p, " is outside the cell"));
            assert(dist(p, other) > c - eps, str(tag, p, " is ", dist(p, other), " from the other cell"));
        }
        for (s = cut_segments(poly, w, h))
        {
            m = (s[0] + s[1]) / 2;
            assert(min(m[0], m[1], w - m[0], h - m[1]) < c + eps || abs(dist(m, line) - c / 2) < eps,
                   str(tag, "midpoint ", m, " is ", dist(m, line), " from the division line"));
            assert(len([for (i = [0:len(zero) - 1]) let(t = zero[(i + 1) % len(zero)] - zero[i])
                            if (norm(t) > eps && side([ 0, 0 ], unit(s[1] - s[0]), unit(t)) == 0) 1]) > 0,
                   str(tag, "side ", s, " is not parallel to the division line"));
        }
        assert(len(crossings(poly, poly)) == 0, str(tag, "a cell crosses itself"));
    }
    assert(len(crossings(cells[0], cells[1])) == 0, str(tag, "the cells cross"));
}

echo("PASS");
