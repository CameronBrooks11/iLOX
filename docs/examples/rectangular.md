---
title: Rectangular Tessellation
parent: Examples
nav_order: 2
---

# Rectangular Tessellation

`linear_iLOX` places interlocking cell pairs on a rectangular grid: cell A
instances (green) on the grid points over one substrate, cell B instances
(blue) on the grid midpoints under the other. An extension factor stretches
cells along Y to close the gaps a square lattice would otherwise leave.

{% include openscad.html model="rectangular" title="Rectangular iLOX Tessellation" %}

Source: [`examples/simpleUsage/simpleUsageRectangular.scad`](https://github.com/CameronBrooks11/iLOX/blob/main/examples/simpleUsage/simpleUsageRectangular.scad)

```openscad
use <../../iLOX.scad>;

// Width / height of the unit cell
width_x = 5;
height_y = 10;

// Division line as [x, y, tolerance] points
base_ucell_div = [ [ 0.5, 0, 0.01 ], [ 0.3, 0.1, 0.01 ], [ 0.3, 0.4, 0.01 ] ];

// Negative polygons cut voids out of the cell
base_ucell_neg_poly = [ [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ] ];

// Grid size, substrate, and gap-closing extension
grid_n = 5;
grid_m = 4;
substrate_height = 3;
extension_factor = 0.5; // [0:0.1:1]

linear_iLOX(width_x, height_y, base_ucell_div, base_ucell_neg_poly, grid_n, grid_m, extension_factor,
            substrate_height);
```

Key parameters:

- `grid_n`, `grid_m` — number of grid points in X and Y.
- `extension_factor` — stretches cells along Y (up to one cell width) to
  reduce the gaps between rows.
- `substrate_height` — thickness of the solid backing each side of cells sits
  on.

Set `show_ucell = true` in the full example file to inspect the 2D unit cell
with `ucell_designer` before tessellating it.
