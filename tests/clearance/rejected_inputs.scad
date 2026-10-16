// Inputs calc_ucell must reject. Each case must stop with an assertion, so the run exits non-zero; the cube at the
// end is reached only if the case was wrongly accepted.
//
// Run every index of `cases`:
//   for i in 0 1 2 3 4 5 6 7 8 9; do
//     openscad -D case=$i -o out.stl tests/clearance/rejected_inputs.scad && echo "case $i was not rejected"
//   done

include <../../iLOX.scad>;

case = -1;

cases = [
    // [name, width, height, div, clearance]
    [ "barb narrower than the clearance", 5, 10, [ [ 0.5, 0 ], [ 0.5, 0.4 ], [ 0.46, 0.1 ], [ 0.46, 0.45 ] ], 0.2 ],
    [ "barbs swallowed by the offset", 10, 5, [ [ 0.5, 0 ], [ 0.7, 0.2 ], [ 0.4, 0.5 ] ], 1.0 ],
    [ "self-crossing line", 5, 10, [ [ 0.5, 0 ], [ 0.2, 0.8 ], [ 0.8, 0.8 ] ], 0.2 ],
    [ "neck on x = 0", 5, 10, [ [ 0.5, 0 ], [ 0, 0.1 ], [ 0, 0.4 ] ], 0.2 ],
    [ "neck thinner than the clearance", 5, 10, [ [ 0.5, 0 ], [ 0.01, 0.1 ], [ 0.01, 0.4 ] ], 0.2 ],
    [ "cell A off its substrate", 5, 10, [ [ 0, 0 ], [ 0.3, 0.4 ] ], 0.2 ],
    [ "cell pinched at a point", 5, 10, [ [ 0.5, 0 ], [ 0, 0.2 ], [ 0.5, 0.5 ] ], 0 ],
    [ "flat start along the bottom edge", 10, 10, [ [ 0.3, 0 ], [ 0.5, 0 ], [ 0.5, 0.4 ] ], 0.2 ],
    [ "old [x, y, tolerance] points", 5, 10, [ [ 0.5, 0, 0.01 ], [ 0.3, 0.4, 0.01 ] ], 0.2 ],
    [ "negative clearance", 5, 10, [ [ 0.5, 0 ], [ 0.3, 0.4 ] ], -0.1 ],
];

assert(case >= 0 && case < len(cases), str("case must be 0 to ", len(cases) - 1));
cs = cases[case];
echo(str("case ", case, ": ", cs[0]));
cells = calc_ucell(width = cs[1], height = cs[2], div = cs[3], clearance = cs[4]);
cube(1);
