// Clamp for the tensile specimens. The strip wraps the block, bending at its slots, and the jaws press its ends
// against the block on two M5 cap screws through the window. An M12 bolt through the plate mounts it to the tester.
// The joint faces away from the plate, so two clamps, one per half, pull it apart.

// Part to render, in its assembled position
part = "assembly"; // [assembly, base, jaw]

// Specimen substrate thickness, and the extra gap between jaw and block
strip = 2;
strip_fit = 0.9;

// Block [width, depth, height]
block = [ 47.8, 45, 50 ];
// Jaw thickness, and the height of the block bottom above the jaw bottom
jaw_t = 22.1;
block_z = 1.9;
// Radius of the rounded outer bottom edge of each jaw
jaw_round_r = 26.18;

plate_t = 10;
plate_chamfer = 2.6;

// Window through the block for the screws: [width, height], height of its floor, corner chamfer
window = [ 27.8, 30 ];
window_z = 10;
window_chamfer = 4;

// M12 mounting bolt: bore, hex pockets across flats, pocket depths above the window and in the plate top
m12_bore = 12.3;
m12_hex = 19;
m12_ceiling_depth = 4;
m12_top_depth = 6;
pocket_chamfer = 0.4;

// M5 cap screws through jaws and block: bore, nut and head pockets, pocket depth, y offset, height above block bottom
m5_bore = 5.2;
m5_nut = 8.6;
m5_head = 8.6;
m5_pocket_depth = 14.1;
m5_y = 15;
m5_z = 30.75;

// Dovetails joining the jaws to the plate: y offset, width at the top, depth, half angle, fit, fillet radius
dt_y = 11.25;
dt_w = 14.7;
dt_depth = 5.2;
dt_angle = 30;
dt_fit = 0.2;
dt_fillet = 0.8;

$fn = 64;

jaw_x = block[0] / 2 + strip + strip_fit; // inner face of a jaw
plate_x = jaw_x + jaw_t;                  // plate half length
plate_z = block_z + block[2];             // plate underside

assert(m5_z - m5_bore / 2 > window_z && m5_z + m5_bore / 2 < window_z + window[1], "ERROR: M5 screws miss the window");

// Dovetail cross-section in (y, z) about y = 0, from the plate underside up, with a filleted mouth
module dovetail2d()
{
    bottom = dt_w - 2 * dt_depth * tan(dt_angle);
    offset(r = -dt_fillet) offset(delta = dt_fillet) union()
    {
        polygon([ [ -bottom / 2, 0 ], [ bottom / 2, 0 ], [ dt_w / 2, dt_depth ], [ -dt_w / 2, dt_depth ] ]);
        translate([ -dt_w / 2 - 1, -dt_depth ]) square([ dt_w + 2, dt_depth ]);
    }
}

module dovetails(x0, x1)
{
    for (s = [ -1, 1 ])
        translate([ x0, s * dt_y, plate_z ]) rotate([ 90, 0, 90 ]) linear_extrude(x1 - x0) children();
}

// Corners on ±y
module hex_pocket(af, depth)
{
    rotate([ 0, 0, 90 ]) cylinder(d = af / cos(30), h = depth, $fn = 6);
}

// Opening the mouth of a hex pocket by pocket_chamfer
module hex_chamfer(af)
{
    rotate([ 0, 0, 90 ])
        cylinder(d1 = (af + 2 * pocket_chamfer) / cos(30), d2 = af / cos(30), h = pocket_chamfer, $fn = 6);
}

module base()
{
    difference()
    {
        union()
        {
            translate([ -block[0] / 2, -block[1] / 2, block_z ]) cube([ block[0], block[1], block[2] ]);
            hull()
            {
                translate([ -plate_x, -block[1] / 2, plate_z ])
                    cube([ 2 * plate_x, block[1], plate_t - plate_chamfer ]);
                translate([ -plate_x + plate_chamfer, -block[1] / 2 + plate_chamfer, plate_z ])
                    cube([ 2 * (plate_x - plate_chamfer), block[1] - 2 * plate_chamfer, plate_t ]);
            }
        }
        // Window
        translate([ 0, 0, block_z + window_z + window[1] / 2 ]) rotate([ 90, 0, 0 ])
            linear_extrude(block[1] + 1, center = true)
        {
            w = window[0] / 2;
            h = window[1] / 2;
            c = window_chamfer;
            polygon([
                [ w - c, -h ], [ w, c - h ], [ w, h - c ], [ w - c, h ], [ c - w, h ], [ -w, h - c ], [ -w, c - h ],
                [ c - w, -h ]
            ]);
        }
        // M12: open from below into the window, a pocket above it, the bore, and a pocket in the plate top
        translate([ 0, 0, block_z - 1 ]) hex_pocket(m12_hex, window_z + 1);
        translate([ 0, 0, block_z + window_z + window[1] - 1 ]) hex_pocket(m12_hex, m12_ceiling_depth + 1);
        translate([ 0, 0, block_z + window_z + window[1] ]) hex_chamfer(m12_hex);
        cylinder(d = m12_bore, h = plate_z + plate_t + 1);
        translate([ 0, 0, plate_z + plate_t - m12_top_depth ]) hex_pocket(m12_hex, m12_top_depth + 1);
        translate([ 0, 0, plate_z + plate_t ]) mirror([ 0, 0, 1 ]) hex_chamfer(m12_hex);
        // M5 through the block walls
        for (s = [ -1, 1 ])
            translate([ 0, s * m5_y, block_z + m5_z ]) rotate([ 0, 90, 0 ])
                cylinder(d = m5_bore, h = block[0] + 1, center = true);
        // Dovetail grooves in the plate underside, from the block outward
        for (s = [ -1, 1 ])
            dovetails(s > 0 ? block[0] / 2 : -plate_x - 1, s > 0 ? plate_x + 1 : -block[0] / 2) dovetail2d();
    }
}

// The jaw on the -x side
module jaw()
{
    cz = sqrt(jaw_round_r ^ 2 - (jaw_round_r - jaw_t) ^ 2); // round centre height: arc meets the inner bottom corner
    difference()
    {
        union()
        {
            translate([ 0, block[1] / 2, 0 ]) rotate([ 90, 0, 0 ]) linear_extrude(block[1]) intersection()
            {
                translate([ -plate_x, 0 ]) square([ jaw_t, plate_z - dt_fit ]);
                union()
                {
                    translate([ -plate_x + jaw_round_r, cz ]) circle(r = jaw_round_r, $fn = 256);
                    translate([ -plate_x, cz ]) square([ jaw_t, plate_z ]);
                }
            }
            dovetails(-plate_x, -jaw_x) offset(r = dt_fillet) offset(delta = -dt_fillet) offset(delta = -dt_fit)
                dovetail2d();
        }
        for (s = [ -1, 1 ])
            translate([ -plate_x - 1, s * m5_y, block_z + m5_z ]) rotate([ 0, 90, 0 ])
            {
                cylinder(d = m5_bore, h = jaw_t + 2);
                if (s > 0)
                    hex_pocket(m5_nut, m5_pocket_depth + 1);
                else
                    cylinder(d = m5_head, h = m5_pocket_depth + 1);
            }
    }
}

if (part == "base")
    base();
else if (part == "jaw")
    jaw();
else if (part == "assembly")
{
    color("Silver") base();
    color("SteelBlue") jaw();
    color("SteelBlue") rotate([ 0, 0, 180 ]) jaw();
}
