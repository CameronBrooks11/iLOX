---
title: Reference
nav_order: 3
---

# Reference

`use <iLOX/iLOX.scad>` gives the modules below. Pass arguments by name. Each
module checks its arguments before computing anything and stops with a message
naming the module, the argument and the value, such as
`ERROR: ilox_linear: grid_n must be a whole number of at least 2, ...`.

## The unit cell

Every module takes the same cell:

| Argument | Default | Meaning |
| --- | --- | --- |
| `width` | | Width of the unit cell in mm. |
| `height` | | Height of the unit cell in mm; the height of the extrusions. |
| `div` | | The division line, as at least 2 `[x, y]` points normalised to the cell, starting on its bottom edge (`y = 0`) or top edge (`y = 1`). The rest of the line is these points turned 180 degrees about the cell centre, so halves A and B are the same shape. |
| `clearance` | | Gap between the halves in mm, measured normal to the division line; `0` or more. The line is offset with mitered corners, so a feature narrower than the clearance is lost and the gap there is wider. |
| `voids` | `[]` | Voids cut from half A: a list of polygons, each at least 3 `[x, y]` points normalised to the cell. Half B gets them turned 180 degrees. Wrap a single polygon in `[ ]`. |
| `tip_clearance` | `clearance` | Gap in mm between each cell's tip and the opposite substrate, below half the cell height. |

## ilox_radial

Pins on a hexagonal lattice: A pins at the hexagon centres on one substrate, B
pins between them on the other. Each B pin faces three A pins one `width` apart,
so the gap between them is `clearance`.

| Argument | Default | Meaning |
| --- | --- | --- |
| `levels` | `2` | Rings of A pins, a whole number of at least 2. |
| `substrate_height` | `1` | Thickness of each substrate in mm. |
| `colors` | `[ "ForestGreen", "MidnightBlue" ]` | Colours of halves A and B. |
| `part` | `"both"` | `"A"`, `"B"` or `"both"`, each in its assembled position. |

## ilox_linear

Rails on a rectangular grid: A rails two cell widths apart on one substrate, B
rails midway between them on the other. The rails lock against pull-off and
across the rails, and slide along them.

| Argument | Default | Meaning |
| --- | --- | --- |
| `grid_n` | `3` | Number of A rails, along X, a whole number of at least 2. |
| `grid_m` | `2` | Number of cells along each rail, along Y, a whole number of at least 1. |
| `extension_factor` | `1` | How far each cell extends along its rail, from `0` to `1` cell width; `1` joins a rail's cells into one. |
| `substrate_height` | `1` | Thickness of each substrate in mm. |
| `colors` | `[ "ForestGreen", "MidnightBlue" ]` | Colours of halves A and B. |
| `part` | `"both"` | `"A"`, `"B"` or `"both"`, each in its assembled position. |

## ilox_cell_designer

The 2D unit cell, its halves, their voids and their points, for designing a
division line. Preview only: it mixes 2D shapes and point spheres.

| Argument | Default | Meaning |
| --- | --- | --- |
| `colors` | `[ "GreenYellow", "Aqua", "Red", "DarkRed" ]` | Cell A, cell B, voids of A, voids of B. |
| `point_d` | `0.1` | Diameter of the spheres marking the points. |
| `point_colors` | `[ "Indigo", "Violet" ]` | Points of A and of B. |
| `point_z` | `0.5` | Height of the point spheres above the cell. |
| `point_fn` | `12` | Facets of the point spheres. |

## calc_ucell

`calc_ucell(width, height, div, clearance, voids = [], tip_clearance = undef)`
returns the cell the modules above extrude: `[ A, B, [ voids of A, voids of B ] ]`,
each half a list of `[x, y]` points in mm.
