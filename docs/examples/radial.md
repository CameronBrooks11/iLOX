---
title: Radial Tessellation
parent: Examples
nav_order: 1
---

# Radial Tessellation

`ilox_radial` places interlocking cell pairs on a hexagonal lattice with
rotational symmetry: cell A instances (green) sit on hexagon centers over one
substrate, cell B instances (blue) on the triangulated midpoints under the
other, so pressing the two substrates together engages every cell at once.

{% include openscad.html model="radial" live="radial-live" title="Radial iLOX Tessellation" %}

Source: [`examples/simpleUsage/simpleUsageRadial.scad`](https://github.com/CameronBrooks11/iLOX/blob/main/examples/simpleUsage/simpleUsageRadial.scad)

```openscad
use <../../iLOX.scad>;

// Width / height of the unit cell
width = 5;
height = 10;

// Division line as [x, y] points
div = [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ];

// Gap between the interlocking cells, in mm
clearance = 0.2;

// Voids cut out of the cell: a list of polygons
voids = [ [ [ 0.7, 0.8 ], [ 0.7, 1 ], [ 0.3, 1 ] ] ];

// Rings of hexagons in the lattice
levels = 4;

ilox_radial(width = width, height = height, div = div, clearance = clearance, voids = voids, levels = levels,
            part = "both");
```

Key parameters:

- `div` — the division line that splits the unit cell into the two
  interlocking halves.
- `clearance` — the gap between the two halves in mm, measured normal to the
  division line. A feature of the line too small for the clearance, such as a
  barb narrower than it, is lost in the offset, and the gap there is wider.
- `tip_clearance` — optional gap between each cell's tip and the opposite
  substrate, in mm, below half the cell height; defaults to `clearance`, and `0`
  gives full-height cells. A large value can cut a cell short of interlocking,
  and a clip just above a horizontal face can leave a thin ledge.
- `part` — `"both"` to view the joint, or `"A"` / `"B"` to export one printable
  half (print B upside down).
- `levels` — how many rings of hexagons the lattice grows outward; at least 2,
  since the B cells sit between the A cells.

Each cell is a hexagonal extrusion of its half of the unit cell, and each B
cell faces three A cells one `width` apart, across flat sides, so the gap
between them is `clearance` as in the 2D cell. Cells of the same half sit corner
to corner, √3 × `width` apart, so a cell whose profile reaches past 0.75 ×
`width` merges with its neighbours into one web.

Set `show_ucell = true` in the full example file to inspect the 2D unit cell
with `ilox_cell_designer` before tessellating it.
