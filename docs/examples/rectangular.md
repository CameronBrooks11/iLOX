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

The rails lock the halves against pull-off and across the rails, and slide
freely along them: the halves assemble by sliding one onto the other.

{% include openscad.html model="rectangular" live="rectangular-live" title="Rectangular iLOX Tessellation" %}

Source: [`examples/simpleUsage/simpleUsageRectangular.scad`](https://github.com/CameronBrooks11/iLOX/blob/main/examples/simpleUsage/simpleUsageRectangular.scad)

```openscad
use <../../iLOX.scad>;

// Width / height of the unit cell
width_x = 5;
height_y = 10;

// Division line as [x, y] points
base_ucell_div = [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ];

// Gap between the interlocking cells, in mm
clearance = 0.2;

// Negative polygons cut voids out of the cell
base_ucell_neg_poly = [ [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ] ];

// Grid size, substrate, and gap-closing extension
grid_n = 5;
grid_m = 4;
substrate_height = 3;
extension_factor = 0.5; // [0:0.1:1]

linear_iLOX(width_x, height_y, base_ucell_div, clearance, base_ucell_neg_poly, grid_n, grid_m,
            extension_factor, substrate_height, part = "both");
```

Key parameters:

- `clearance` — the gap between the two interlocking halves in mm, measured
  normal to the division line. A feature of the line too small for the
  clearance, such as a barb narrower than it, is lost in the offset, and the
  gap there is wider.
- `tip_clearance` — optional gap between each cell's tip and the opposite
  substrate, in mm, below half the cell height; defaults to `clearance`, and `0`
  gives full-height cells. A large value can cut a cell short of interlocking,
  and a clip just above a horizontal face can leave a thin ledge.
- `part` — `"both"` to view the joint, or `"A"` / `"B"` to export one printable
  half (print B upside down).
- `grid_n`, `grid_m` — number of grid points in X and Y; `grid_n` at least 2,
  since the B rails sit between the A rails.
- `extension_factor` — stretches cells along Y (up to one cell width) to
  reduce the gaps between rows.
- `substrate_height` — thickness of the solid backing each side of cells sits
  on.

Set `show_ucell = true` in the full example file to inspect the 2D unit cell
with `ucell_designer` before tessellating it.
