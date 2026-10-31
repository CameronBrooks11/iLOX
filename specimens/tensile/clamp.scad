/**
 * @file clamp.scad
 * @brief Clamp that holds one tensile specimen strip in the test machine.
 *
 * The strip wraps the base's block, bending at its slots, with the joint facing away from the block. Two jaws hang
 * from the plate on dovetails and press the strip's ends against the block, drawn in by two screws through the
 * block's window. A bolt through the plate mounts the clamp to the machine. One clamp holds each half of a joint,
 * so a pair pulls the joint apart normal to it.
 *
 * Origin: centre of the block's bottom face, where the strip's inner face sits. +z runs up to the plate.
 */

/* [Render] */
// Part to render, in its assembled position. Print two jaws.
part = "assembly"; // [assembly, base, jaw]

$fn = $preview ? 48 : 96;

tensile_clamp(part = part);

// --- hardware ---------------------------------------------------------------------------------------------------
// Each row is [ name, bore, nut_across_flats, head_diameter ], with print clearance included.
CLAMP_M5 = [ "M5", 5.2, 8.6, 8.6 ];
CLAMP_M12 = [ "M12", 12.3, 19, 19 ];

function clamp_hw_name(hw) = hw[0];
function clamp_hw_bore(hw) = hw[1];
function clamp_hw_nut_af(hw) = hw[2];
function clamp_hw_head_d(hw) = hw[3];

/**
 * Draw the clamp, or one of its parts, in its assembled position.
 *
 * @param part           "assembly", "base" or "jaw" (the jaw on the -x side; the other is it turned 180 about z)
 * @param strip          [ thickness, width, wrap ]: the specimen strip and the length of it that wraps the block
 * @param strip_fit      gap between jaw and strip before the screws are tightened
 * @param side_margin    block depth beyond the strip on each side
 * @param block_height   height of the block from its bottom face to the plate
 * @param jaw            [ thickness, overhang, round_radius ]: overhang is how far the jaws reach below the block;
 *                       the outer bottom edge is rounded at round_radius, the arc ending at the inner bottom corner
 * @param plate          [ thickness, chamfer ]
 * @param window         [ width, height, floor, chamfer ]: the opening through the block for the screws
 * @param screw          hardware row for the jaw screws
 * @param screw_spacing  distance between the two jaw screws, along y
 * @param screw_height   height of the jaw screws above the block bottom
 * @param screw_pocket   depth of the head and nut pockets in each jaw
 * @param mount          hardware row for the mounting bolt
 * @param mount_pockets  [ ceiling, top ]: depths of the hex pockets above the window and in the plate top
 * @param dovetail       [ offset, width, depth, half_angle, fit, fillet ]: two per jaw at y = +-offset
 * @param edge_chamfer   chamfer on the mouths of the mounting-bolt hex pockets
 */
module tensile_clamp(part = "assembly", strip = [ 2, 40, 47.8 ], strip_fit = 0.9, side_margin = 2.5,
                     block_height = 50, jaw = [ 22.1, 1.9, 26.18 ], plate = [ 10, 2.6 ], window = [ 27.8, 30, 10, 4 ],
                     screw = CLAMP_M5, screw_spacing = 30, screw_height = 30.75, screw_pocket = 14.1,
                     mount = CLAMP_M12, mount_pockets = [ 4, 6 ], dovetail = [ 11.25, 14.7, 5.2, 30, 0.2, 0.8 ],
                     edge_chamfer = 0.4)
{
    assert(part == "assembly" || part == "base" || part == "jaw",
           str("tensile_clamp: part must be \"assembly\", \"base\" or \"jaw\", got: ", part));
    assert(len(strip) == 3 && min(strip) > 0, str("tensile_clamp: strip must be 3 positive numbers, got: ", strip));
    assert(strip_fit >= 0, str("tensile_clamp: strip_fit must be >= 0, got: ", strip_fit));
    assert(window[0] < strip[2], str("tensile_clamp: window width (", window[0], ") must be < the block width (",
                                     strip[2], ")"));
    assert(window[2] + window[1] < block_height,
           str("tensile_clamp: window top (", window[2] + window[1], ") must be below the plate (", block_height, ")"));
    assert(abs(screw_height - window[2] - window[1] / 2) + clamp_hw_bore(screw) / 2 < window[1] / 2 - window[3],
           str("tensile_clamp: screws at height ", screw_height, " must pass through the straight part of the window"));
    assert(screw_pocket < jaw[0], str("tensile_clamp: screw_pocket (", screw_pocket, ") must be < the jaw thickness (",
                                      jaw[0], ")"));
    assert(jaw[2] >= jaw[0], str("tensile_clamp: jaw round_radius (", jaw[2], ") must be >= the jaw thickness (",
                                 jaw[0], ")"));
    assert(dovetail[0] + dovetail[1] / 2 < strip[1] / 2 + side_margin,
           str("tensile_clamp: dovetails at +-", dovetail[0], " overrun the block depth"));

    block = [ strip[2], strip[1] + 2 * side_margin, block_height ];
    jaw_x = block[0] / 2 + strip[0] + strip_fit; // inner face of a jaw
    plate_x = jaw_x + jaw[0];                    // half the plate length

    if (part != "jaw")
        color("Silver") _clamp_base(block, plate_x, plate, window, screw, screw_spacing, screw_height, mount,
                                    mount_pockets, dovetail, edge_chamfer);
    if (part != "base")
        for (turn = part == "jaw" ? [0] : [ 0, 180 ])
            rotate([ 0, 0, turn ]) color("SteelBlue")
                _clamp_jaw(block, jaw_x, jaw, screw, screw_spacing, screw_height, screw_pocket, dovetail);
}

module _clamp_base(block, plate_x, plate, window, screw, screw_spacing, screw_height, mount, mount_pockets, dovetail,
                   edge_chamfer)
{
    top = block[2] + plate[0];
    window_top = window[2] + window[1];
    af = clamp_hw_nut_af(mount);

    difference()
    {
        union()
        {
            translate([ -block[0] / 2, -block[1] / 2, 0 ]) cube(block);
            translate([ 0, 0, block[2] ]) _chamfered_slab([ 2 * plate_x, block[1], plate[0] ], plate[1]);
        }

        // Window, front to back
        translate([ 0, 0, window[2] + window[1] / 2 ]) rotate([ 90, 0, 0 ])
            linear_extrude(block[1] + 2, center = true) _chamfered_rect([ window[0], window[1] ], window[3]);

        // Mounting bolt: open from below into the window, a pocket above it, the bore, and a pocket in the plate top
        translate([ 0, 0, -1 ]) _hex_prism(af, window[2] + 1);
        translate([ 0, 0, window_top - 1 ]) _hex_prism(af, mount_pockets[0] + 1);
        translate([ 0, 0, window_top ]) _hex_chamfer(af, edge_chamfer);
        translate([ 0, 0, -1 ]) cylinder(d = clamp_hw_bore(mount), h = top + 2);
        translate([ 0, 0, top - mount_pockets[1] ]) _hex_prism(af, mount_pockets[1] + 1);
        translate([ 0, 0, top ]) mirror([ 0, 0, 1 ]) _hex_chamfer(af, edge_chamfer);

        // Jaw screws, through both block walls
        for (y = [ -1, 1 ] * screw_spacing / 2)
            translate([ 0, y, screw_height ]) rotate([ 0, 90, 0 ])
                cylinder(d = clamp_hw_bore(screw), h = block[0] + 2, center = true);

        // Dovetail grooves in the plate underside, from each block face out past the plate end
        for (side = [ -1, 1 ])
            translate([ side * (block[0] / 2 + plate_x + 1) / 2, 0, block[2] ])
                _dovetail_run(plate_x - block[0] / 2 + 1, dovetail) _dovetail_profile(dovetail);
    }
}

// The jaw on the -x side
module _clamp_jaw(block, jaw_x, jaw, screw, screw_spacing, screw_height, screw_pocket, dovetail)
{
    thickness = jaw[0];
    overhang = jaw[1];
    r = jaw[2];
    plate_x = jaw_x + thickness;
    fit = dovetail[4];
    // Centre height of the rounded edge, so the arc meets the inner bottom corner
    round_z = sqrt(r ^ 2 - (r - thickness) ^ 2);

    difference()
    {
        union()
        {
            rotate([ 90, 0, 0 ]) linear_extrude(block[1], center = true) translate([ -plate_x, -overhang ])
                intersection()
            {
                square([ thickness, overhang + block[2] - fit ]);
                union()
                {
                    translate([ r, round_z ]) circle(r = r, $fn = 256);
                    translate([ 0, round_z ]) square([ thickness, block[2] + overhang ]);
                }
            }

            translate([ -(jaw_x + plate_x) / 2, 0, block[2] ]) _dovetail_run(thickness, dovetail)
                offset(r = dovetail[5]) offset(delta = -dovetail[5]) offset(delta = -fit) _dovetail_profile(dovetail);
        }

        // Screw bores, with the nut pocket on +y and the head pocket on -y; the other jaw is turned, so each screw
        // has its head on one jaw and its nut on the other
        for (side = [ -1, 1 ])
            translate([ -plate_x - 1, side * screw_spacing / 2, screw_height ]) rotate([ 0, 90, 0 ])
            {
                cylinder(d = clamp_hw_bore(screw), h = thickness + 2);
                if (side > 0)
                    _hex_prism(clamp_hw_nut_af(screw), screw_pocket + 1);
                else
                    cylinder(d = clamp_hw_head_d(screw), h = screw_pocket + 1);
            }
    }
}

// Dovetail cross-section in (y, z), opening at z = 0 and widening upward, with a filleted mouth. The band below the
// mouth lets the fillet form; it lies outside the plate.
module _dovetail_profile(dovetail)
{
    width = dovetail[1];
    depth = dovetail[2];
    mouth = width - 2 * depth * tan(dovetail[3]);
    fillet = dovetail[5];

    offset(r = -fillet) offset(delta = fillet) union()
    {
        polygon([ [ -mouth / 2, 0 ], [ mouth / 2, 0 ], [ width / 2, depth ], [ -width / 2, depth ] ]);
        translate([ -width / 2 - 1, -depth ]) square([ width + 2, depth ]);
    }
}

// The pair of dovetails, run along x for length, centred on the origin, from a 2D profile child
module _dovetail_run(length, dovetail)
{
    for (y = [ -1, 1 ] * dovetail[0])
        translate([ -length / 2, y, 0 ]) rotate([ 90, 0, 90 ]) linear_extrude(length) children();
}

// Rectangle centred on the origin, corners cut at 45 degrees by chamfer
module _chamfered_rect(size, chamfer)
{
    w = size[0] / 2;
    h = size[1] / 2;
    c = chamfer;
    polygon([ [ w - c, -h ], [ w, c - h ], [ w, h - c ], [ w - c, h ], [ c - w, h ], [ -w, h - c ], [ -w, c - h ],
              [ c - w, -h ] ]);
}

// Slab centred on the origin in x and y, standing on z = 0, its top edges chamfered at 45 degrees
module _chamfered_slab(size, chamfer)
{
    hull()
    {
        translate([ -size[0] / 2, -size[1] / 2, 0 ]) cube([ size[0], size[1], size[2] - chamfer ]);
        translate([ -size[0] / 2 + chamfer, -size[1] / 2 + chamfer, 0 ])
            cube([ size[0] - 2 * chamfer, size[1] - 2 * chamfer, size[2] ]);
    }
}

// Hex prism of the given across-flats size, corners on the y axis
module _hex_prism(af, h)
{
    rotate([ 0, 0, 90 ]) cylinder(d = af / cos(30), h = h, $fn = 6);
}

// Countersink opening a hex pocket's mouth at z = 0 by chamfer, narrowing upward
module _hex_chamfer(af, chamfer)
{
    rotate([ 0, 0, 90 ]) cylinder(d1 = (af + 2 * chamfer) / cos(30), d2 = af / cos(30), h = chamfer, $fn = 6);
}
