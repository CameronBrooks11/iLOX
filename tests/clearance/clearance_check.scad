// Checks the A/B clearance (#21): both cells stay inside the unit cell without crossing themselves or each other,
// every vertex of one is at least `clearance` from the other, and every cut side is a division segment moved
// `clearance` / 2 sideways: parallel to it, at that distance, and overlapping it. Prints PASS.
//
// Run: openscad --hardwarnings -o clearance.stl tests/clearance/clearance_check.scad
// It exits non-zero on a failure: the cube at the end, the only geometry, is reached only when every check passed.
// tests/clearance/rejected_inputs.scad covers the inputs calc_ucell must reject.

include <../../iLOX.scad>;

eps = 1e-6;

cases = [
    // [name, width, height, div, clearances (optional; default below)]
    [ "vertical", 5, 10, [ [ 0.3, 0 ], [ 0.3, 0.4 ] ] ],
    [ "t-slot", 10, 10, [ [ 0.3, 0 ], [ 0.3, 0.4 ], [ 0.5, 0.4 ], [ 0.5, 0.5 ] ] ],
    [ "slanted", 5, 10, [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ] ],
    [ "leaning-right", 5, 10, [ [ 0.3, 0 ], [ 0.5, 0.1 ], [ 0.5, 0.4 ] ] ],
    [ "zig-zag", 10, 10, [ [ 0.4, 0 ], [ 0.4, 0.3 ], [ 0.475, 0.17009618943233417 ], [ 0.475, 0.45 ], [ 0.5, 0.5 ] ] ],
    // A 0.18 mm step: its miter corners lie past the step's ends; at clearance 0.5 the step is too narrow
    [ "t-slot-step", 10, 10, [ [ 0.482, 0 ], [ 0.482, 0.3 ], [ 0.5, 0.3 ], [ 0.5, 0.5 ] ], [ 0, 0.2 ] ],
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

// The division line built from div itself (div plus its copy turned 180 degrees about the cell centre), as segments
function division_line(div, w, h) =
    let(turned = [for (i = [len(div) - 1:-1:0])[1 - div[i][0], 1 - div[i][1]]],
        pts = div[0][1] == 0 ? concat(div, turned) : concat([for (i = [len(turned) - 1:-1:0]) turned[i]],
                                                            [for (i = [len(div) - 1:-1:0]) div[i]]))
        [for (i = [0:len(pts) - 2]) if (norm(pts[i + 1] - pts[i]) > eps)
                [[ w * pts[i][0], h * pts[i][1] ], [ w * pts[i + 1][0], h * pts[i + 1][1] ]]];

function unit(v) = v / norm(v);

// Segment a-b is segment c-d moved sideways by dist: parallel, at that distance, and overlapping it along its length
function offset_of(a, b, c, d, dist) =
    let(u = unit(d - c), s = [ (a - c) * u, (b - c) * u ])
        abs(u[0] * unit(b - a)[1] - u[1] * unit(b - a)[0]) < eps &&
        abs(abs(u[0] * (a - c)[1] - u[1] * (a - c)[0]) - dist) < eps && min(max(s), norm(d - c)) - max(min(s), 0) > eps;

function side(a, b, p) = let(v = (b - a)[0] * (p - a)[1] - (b - a)[1] * (p - a)[0]) abs(v) < eps ? 0 : sign(v);

// Segments a-b and c-d cross at a point inside both
function crosses(a, b, c, d) = side(a, b, c) * side(a, b, d) < 0 && side(c, d, a) * side(c, d, b) < 0;

function crossings(p, q) = [for (i = [0:len(p) - 1], j = [0:len(q) - 1])
        let(a = p[i], b = p[(i + 1) % len(p)], c = q[j], d = q[(j + 1) % len(q)]) if (crosses(a, b, c, d))[i, j]];

for (cs = cases, c = is_undef(cs[4]) ? clearances : cs[4])
{
    w = cs[1];
    h = cs[2];
    cells = calc_ucell(width = w, height = h, div = cs[3], clearance = c);
    line = division_line(cs[3], w, h);
    tag = str("FAIL ", cs[0], " clearance=", c, ": ");
    for (k = [0:1])
    {
        poly = cells[k];
        assert(len(poly) >= 3, str(tag, "cell ", k, " is empty"));
        other = cut_segments(cells[1 - k], w, h);
        for (p = poly)
        {
            assert(p[0] > -eps && p[0] < w + eps && p[1] > -eps && p[1] < h + eps, str(tag, p, " is outside the cell"));
            assert(dist(p, other) > c - eps, str(tag, p, " is ", dist(p, other), " from the other cell"));
        }
        for (s = cut_segments(poly, w, h))
            assert([for (t = line) if (offset_of(s[0], s[1], t[0], t[1], c / 2)) 1] != [],
                   str(tag, "side ", s, " is not a division segment moved clearance / 2 sideways"));
        assert(len(crossings(poly, poly)) == 0, str(tag, "a cell crosses itself"));
    }
    assert(len(crossings(cells[0], cells[1])) == 0, str(tag, "the cells cross"));
}

echo("PASS");
cube(1);
