// Gap between the halves of radial_iLOX. Half B is moved by `shift` mm towards one of its A neighbours, along the
// normal of their facing flat sides, and only the overlap of the two halves is kept. With the gap equal to the
// clearance, nothing overlaps below the clearance and something does above it:
//
//   openscad -D shift=0.19 -o out.stl tests/clearance/radial_gap.scad   # must fail: the top level object is empty
//   openscad -D shift=0.21 -o out.stl tests/clearance/radial_gap.scad   # must succeed

include <../../iLOX.scad>;

shift = 0;
clearance = 0.2;
void = [[[ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ]]];

intersection()
{
    radial_iLOX(5, 10, [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ], clearance, void, 2, part = "A");
    translate(shift * [ -cos(30), -sin(30), 0 ])
        radial_iLOX(5, 10, [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ], clearance, void, 2, part = "B");
}
