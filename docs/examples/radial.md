---
title: Radial Tessellation
parent: Examples
nav_order: 1
---

# Radial Tessellation

`radial_iLOX` places interlocking cell pairs on a hexagonal lattice with
rotational symmetry: cell A instances (green) sit on hexagon centers over one
substrate, cell B instances (blue) on the triangulated midpoints under the
other, so pressing the two substrates together engages every cell at once.

{% include openscad.html model="radial" live="radial-live" title="Radial iLOX Tessellation" %}

Source: [`examples/simpleUsage/simpleUsageRadial.scad`](https://github.com/CameronBrooks11/iLOX/blob/main/examples/simpleUsage/simpleUsageRadial.scad)

```openscad
use <../../iLOX.scad>;

// Width / height of the unit cell
width_x = 5;
height_y = 10;

// Division line as [x, y, tolerance] points
base_ucell_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Negative polygons cut voids out of the cell
base_ucell_neg_poly = [ [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ] ];

// Rotational symmetry, tessellation levels, packing
degree_n = 6;
levels = 4;
packing_factor = 0.3; // [0:1]

radial_iLOX(width_x, height_y, base_ucell_div, base_ucell_neg_poly, degree_n, levels, packing_factor);
```

Key parameters:

- `base_ucell_div` — the division line that splits the unit cell into the two
  interlocking halves; each point carries its own fit tolerance.
- `degree_n` — order of rotational symmetry for each cell (6 = hexagonal).
- `levels` — how many rings of hexagons the lattice grows outward.
- `packing_factor` — extra spacing between cells, from none (0) to half a cell
  width (1).

Set `show_ucell = true` in the full example file to inspect the 2D unit cell
with `ucell_designer` before tessellating it.
