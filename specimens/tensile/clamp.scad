// Clamp that holds one tensile specimen strip in the test machine.
//
// The strip wraps the base's block, bending at its slots, with the joint facing away from the block. Two jaws hang from
// the plate on dovetails and press the strip's ends against the block, drawn in by two M5 screws through the block's
// window. An M12 bolt through the plate mounts the clamp. One clamp holds each half of a joint, so a pair pulls the
// joint apart normal to it.
//
// Origin: centre of the block's bottom face, where the strip's inner face sits; +z runs up to the plate.

/* [Render] */
// Part to render, in its assembled position. Print two jaws.
part = "assembly"; // [assembly, base, jaw]

$fn = $preview ? 48 : 96;

tensile_clamp(part = part);

// All dimensions in mm. The block and jaws are sized from the strip; bores and pockets include print clearance.
module tensile_clamp(part = "assembly",
                     // The strip: thickness, width, and the length that wraps the block bottom
                     strip_t = 2, strip_w = 40, wrap = 47.8, strip_fit = 0.9, side_margin = 2.5, block_h = 50,
                     // Jaws: thickness, reach below the block, radius of the rounded outer bottom edge
                     jaw_t = 22.1, jaw_overhang = 1.9, jaw_r = 26.18,
                     plate_t = 10, plate_chamfer = 2.6,
                     // Window through the block for the jaw screws
                     window_w = 27.8, window_h = 30, window_floor = 10, window_chamfer = 4,
                     // Jaw screws (M5): bore, nut across flats, head; nut pocket on +y, head pocket on -y
                     screw_bore = 5.2, screw_nut = 8.6, screw_head = 8.6, screw_spacing = 30, screw_z = 30.75,
                     screw_pocket = 14.1,
                     // Mounting bolt (M12): bore, hex across flats, hex pocket depths above the window and in the top
                     mount_bore = 12.3, mount_hex = 19, mount_ceiling_pocket = 4, mount_top_pocket = 6,
                     mount_chamfer = 0.4,
                     // Dovetails joining jaws and plate, at y = +-dt_offset
                     dt_offset = 11.25, dt_w = 14.7, dt_depth = 5.2, dt_angle = 30, dt_fit = 0.2, dt_fillet = 0.8)
{
    assert(part == "assembly" || part == "base" || part == "jaw",
           str("tensile_clamp: part must be \"assembly\", \"base\" or \"jaw\", got: ", part));
    assert(window_w < wrap, str("tensile_clamp: window_w (", window_w, ") must be < wrap (", wrap, ")"));
    assert(window_floor + window_h < block_h,
           str("tensile_clamp: window top (", window_floor + window_h, ") must be below block_h (", block_h, ")"));
    assert(abs(screw_z - window_floor - window_h / 2) + screw_bore / 2 < window_h / 2 - window_chamfer,
           str("tensile_clamp: screws at screw_z = ", screw_z, " must pass through the straight part of the window"));
    assert(screw_pocket < jaw_t, str("tensile_clamp: screw_pocket (", screw_pocket, ") must be < jaw_t (", jaw_t, ")"));
    assert(jaw_r >= jaw_t, str("tensile_clamp: jaw_r (", jaw_r, ") must be >= jaw_t (", jaw_t, ")"));
    assert(dt_offset + dt_w / 2 < strip_w / 2 + side_margin,
           str("tensile_clamp: dovetails at +-", dt_offset, " overrun the block depth"));

    block_d = strip_w + 2 * side_margin;
    jaw_x = wrap / 2 + strip_t + strip_fit; // inner face of a jaw
    plate_x = jaw_x + jaw_t;                // half the plate length
    top = block_h + plate_t;
    window_top = window_floor + window_h;

    if (part != "jaw")
        color("Silver") base();
    if (part != "base")
        for (turn = part == "jaw" ? [0] : [ 0, 180 ])
            rotate([ 0, 0, turn ]) color("SteelBlue") jaw();

    module base()
    {
        difference()
        {
            union()
            {
                translate([ -wrap / 2, -block_d / 2, 0 ]) cube([ wrap, block_d, block_h ]);
                hull()
                {
                    translate([ -plate_x, -block_d / 2, block_h ])
                        cube([ 2 * plate_x, block_d, plate_t - plate_chamfer ]);
                    translate([ -plate_x + plate_chamfer, -block_d / 2 + plate_chamfer, block_h ])
                        cube([ 2 * (plate_x - plate_chamfer), block_d - 2 * plate_chamfer, plate_t ]);
                }
            }

            // Window, front to back, its corners chamfered
            translate([ 0, 0, window_floor + window_h / 2 ]) rotate([ 90, 0, 0 ])
                linear_extrude(block_d + 2, center = true)
            {
                w = window_w / 2;
                h = window_h / 2;
                c = window_chamfer;
                polygon([
                    [ w - c, -h ], [ w, c - h ], [ w, h - c ], [ w - c, h ], [ c - w, h ], [ -w, h - c ], [ -w, c - h ],
                    [ c - w, -h ]
                ]);
            }

            // Mounting bolt: open from below into the window, a pocket above it, the bore, a pocket in the top
            translate([ 0, 0, -1 ]) hex(mount_hex, window_floor + 1);
            translate([ 0, 0, window_top - 1 ]) hex(mount_hex, mount_ceiling_pocket + 1);
            translate([ 0, 0, window_top ]) hex_mouth(mount_hex, mount_chamfer);
            translate([ 0, 0, -1 ]) cylinder(d = mount_bore, h = top + 2);
            translate([ 0, 0, top - mount_top_pocket ]) hex(mount_hex, mount_top_pocket + 1);
            translate([ 0, 0, top ]) mirror([ 0, 0, 1 ]) hex_mouth(mount_hex, mount_chamfer);

            // Jaw screws, through both block walls
            for (y = [ -1, 1 ] * screw_spacing / 2)
                translate([ 0, y, screw_z ]) rotate([ 0, 90, 0 ])
                    cylinder(d = screw_bore, h = wrap + 2, center = true);

            // Dovetail grooves in the plate underside, from each block face out past the plate end
            for (side = [ -1, 1 ])
                translate([ side * (wrap / 2 + plate_x + 1) / 2, 0, block_h ])
                    dovetails(plate_x - wrap / 2 + 1) dovetail_profile();
        }
    }

    // The jaw on the -x side
    module jaw()
    {
        round_z = sqrt(jaw_r ^ 2 - (jaw_r - jaw_t) ^ 2); // the rounded edge's arc ends at the inner bottom corner
        difference()
        {
            union()
            {
                rotate([ 90, 0, 0 ]) linear_extrude(block_d, center = true) translate([ -plate_x, -jaw_overhang ])
                    intersection()
                {
                    square([ jaw_t, jaw_overhang + block_h - dt_fit ]);
                    union()
                    {
                        translate([ jaw_r, round_z ]) circle(r = jaw_r, $fn = 256);
                        translate([ 0, round_z ]) square([ jaw_t, block_h + jaw_overhang ]);
                    }
                }

                translate([ -(jaw_x + plate_x) / 2, 0, block_h ]) dovetails(jaw_t)
                    offset(r = dt_fillet) offset(delta = -dt_fillet) offset(delta = -dt_fit) dovetail_profile();
            }

            for (side = [ -1, 1 ])
                translate([ -plate_x - 1, side * screw_spacing / 2, screw_z ]) rotate([ 0, 90, 0 ])
                {
                    cylinder(d = screw_bore, h = jaw_t + 2);
                    if (side > 0)
                        hex(screw_nut, screw_pocket + 1);
                    else
                        cylinder(d = screw_head, h = screw_pocket + 1);
                }
        }
    }

    // Dovetail cross-section in (y, z), opening at z = 0 and widening upward, with a filleted mouth; the band below the
    // mouth lets the fillet form and lies outside the plate
    module dovetail_profile()
    {
        mouth = dt_w - 2 * dt_depth * tan(dt_angle);
        offset(r = -dt_fillet) offset(delta = dt_fillet) union()
        {
            polygon([ [ -mouth / 2, 0 ], [ mouth / 2, 0 ], [ dt_w / 2, dt_depth ], [ -dt_w / 2, dt_depth ] ]);
            translate([ -dt_w / 2 - 1, -dt_depth ]) square([ dt_w + 2, dt_depth ]);
        }
    }

    // The two dovetails, run along x for length and centred on the origin, from a 2D profile child
    module dovetails(length)
    {
        for (y = [ -1, 1 ] * dt_offset)
            translate([ -length / 2, y, 0 ]) rotate([ 90, 0, 90 ]) linear_extrude(length) children();
    }
}

// Hex prism of the given across-flats size, corners on the y axis
module hex(af, h)
{
    rotate([ 0, 0, 90 ]) cylinder(d = af / cos(30), h = h, $fn = 6);
}

// Countersink opening a hex pocket's mouth at z = 0 by c, narrowing upward
module hex_mouth(af, c)
{
    rotate([ 0, 0, 90 ]) cylinder(d1 = (af + 2 * c) / cos(30), d2 = af / cos(30), h = c, $fn = 6);
}
