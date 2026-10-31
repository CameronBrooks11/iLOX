# Tensile specimens

Strips for the test machine with an iLOX joint in the middle.

- `tensile_testing_rectangular.scad`: linear rails, from `concept/direct-workflow/tessellation_rectangular.scad`.
- `tensile_testing_radial.scad`: radial pins, from `concept/direct-workflow/tessellation_radial.scad`.
- `clamp.scad`: the clamp that holds one strip in the tester, as `part = "base"`, `"jaw"` (print two) or `"assembly"`.

Each specimen script builds one part: a strip carrying A cells, as wide as the joint (40 mm) and as long as half of ASTM D638 Type I's 165 mm plus the joint (107.5 mm for the rectangular part). Print the part twice. Turned over, the second print is the mating half: offset it by one cell width (5 mm) across the rails, or by one cell width at 30° to the strip for the radial pins, and the two engage with a gap equal to `clearance` all round.

Slots either side of the joint leave a quarter of the substrate thickness, so the strip bends there to wrap the clamp's block, joint facing away from it. The jaws hang from the plate on dovetails and press the strip's ends against the block on two M5 cap screws and nuts through the block's window; an M12 bolt and nut mount the clamp to the tester. With one clamp per half, the tester pulls the joint apart normal to it.

`tensile_ilox_holder()` in each specimen script is an earlier, unused attempt at a holder.

Record the iLOX commit with each print. The radial spacing changed in #32 and in these scripts in #40, so a radial specimen exported before #40 has a much wider gap than one exported now.
