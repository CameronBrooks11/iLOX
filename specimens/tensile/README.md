# Tensile specimens

Strips for the test machine with an iLOX joint in the middle, pulled apart in the plane of the strip, so the joint is loaded in shear.

- `tensile_testing_rectangular.scad`: linear rails, from `concept/direct-workflow/tessellation_rectangular.scad`.
- `tensile_testing_radial.scad`: radial pins, from `concept/direct-workflow/tessellation_radial.scad`.

Each script builds one part: a strip carrying A cells, as wide as the joint (40 mm) and as long as half of ASTM D638 Type I's 165 mm plus the joint (107.5 mm for the rectangular part). Print the part twice. Turned over, the second print is the mating half: offset it by one cell width (5 mm) across the rails, or by one cell width at 30° to the strip for the radial pins, and the two engage with a gap equal to `clearance` all round. Slots either side of the joint leave a quarter of the substrate thickness to let the strip bend.

The clamp that holds the strips in the tester is still to be added here. `tensile_ilox_holder()` in each script is an earlier, unused attempt.

Record the iLOX commit with each print. The radial spacing changed in #32 and in these scripts in #40, so a radial specimen exported before #40 has a much wider gap than one exported now.
