// Inputs calc_ucell must reject. Each case must stop with an assertion, so the run exits non-zero; the cube at the
// end is reached only if the case was wrongly accepted.
//
// Run every index of `cases`:
//   for i in 0 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15; do
//     openscad -D case=$i -o out.stl tests/clearance/rejected_inputs.scad && echo "case $i was not rejected"
//   done

include <../../iLOX.scad>;

case = -1;

cases = [
    // [name, width, height, div, clearance, tip_clearance (optional)]
    [ "barb narrower than the clearance", 5, 10, [ [ 0.5, 0 ], [ 0.5, 0.4 ], [ 0.46, 0.1 ], [ 0.46, 0.45 ] ], 0.2 ],
    [ "self-crossing line", 5, 10, [ [ 0.5, 0 ], [ 0.2, 0.8 ], [ 0.8, 0.8 ] ], 0.2 ],
    [ "neck on x = 0", 5, 10, [ [ 0.5, 0 ], [ 0, 0.1 ], [ 0, 0.4 ] ], 0.2 ],
    [ "neck thinner than the clearance", 5, 10, [ [ 0.5, 0 ], [ 0.01, 0.1 ], [ 0.01, 0.4 ] ], 0.2 ],
    [ "cell A off its substrate", 5, 10, [ [ 0, 0 ], [ 0.3, 0.4 ] ], 0.2 ],
    [ "cell pinched at a point", 5, 10, [ [ 0.5, 0 ], [ 0, 0.2 ], [ 0.5, 0.5 ] ], 0 ],
    [ "flat start along the bottom edge", 10, 10, [ [ 0.3, 0 ], [ 0.5, 0 ], [ 0.5, 0.4 ] ], 0.2 ],
    [ "old [x, y, tolerance] points", 5, 10, [ [ 0.5, 0, 0.01 ], [ 0.3, 0.4, 0.01 ] ], 0.2 ],
    [ "negative clearance", 5, 10, [ [ 0.5, 0 ], [ 0.3, 0.4 ] ], -0.1 ],
    [ "start y neither 0 nor 1", 5, 10, [ [ 0.5, 0.2 ], [ 0.3, 0.4 ] ], 0.2 ],
    [ "line folding back on itself", 5, 10, [ [ 0.5, 0 ], [ 0.5, 0.3 ], [ 0.5, 0.1 ], [ 0.5, 0.45 ] ], 0.2 ],
    [ "end segment used up by the offset", 5, 10, [ [ 0.6, 0 ], [ 0.6, 0.01 ], [ 0.3, 0.01 ], [ 0.3, 0.4 ] ], 0.5 ],
    [ "stem into a finely sampled arc", 10, 10,
      concat([[ 0.5, 1 ]], shift_points(arc_points(diameter = 0.3, start_angle = 90, end_angle = -90, num_points = 60),
                                        0.5, 0.55)),
      0.2 ],
    [ "tip_clearance at half the cell height", 5, 10, [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ], 0.2, 5 ],
    [ "default tip_clearance above half the cell height", 20, 2, [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ], 1.2 ],
    [ "tip clip cutting a cell in two", 10, 10,
      [ [ 0.4, 0 ], [ 0.4, 0.3 ], [ 0.475, 0.17009618943233417 ], [ 0.475, 0.45 ], [ 0.5, 0.5 ] ], 0.5, 1 ],
];

// Top-level assignments run before module statements, so the case is checked and named here, ahead of calc_ucell
cs = assert(case >= 0 && case < len(cases), str("case must be 0 to ", len(cases) - 1))
    echo(str("case ", case, ": ", cases[case][0])) cases[case];
cells = calc_ucell(width = cs[1], height = cs[2], div = cs[3], clearance = cs[4], tip_clearance = cs[5]);
cube(1);
