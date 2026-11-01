---
title: Getting started
nav_order: 2
---

# Getting started

## Install

iLOX is tested with OpenSCAD 2021.01 and a 2026 development snapshot. It needs
[tessella](https://github.com/CameronBrooks11/tessella) 0.1.0. Clone both into
your OpenSCAD libraries folder (**File > Show Library Folder** in OpenSCAD),
keeping the folder names as they clone:

```
git clone https://github.com/CameronBrooks11/iLOX.git
git clone --branch v0.1.0 https://github.com/CameronBrooks11/tessella.git
```

## First render

```openscad
use <iLOX/iLOX.scad>;

ilox_radial(width = 5, height = 10, clearance = 0.2,
            div = [ [ 0.5, 0 ], [ 0.3, 0.1 ], [ 0.3, 0.4 ] ]);
```

This renders both halves of a 26 x 25 mm radial joint in their assembled
position. [`examples/simpleUsage`](https://github.com/CameronBrooks11/iLOX/tree/main/examples/simpleUsage)
has a radial and a linear example with every argument set; the
[Reference]({% link reference/index.md %}) lists them all.

## Print

Export each half on its own with `part = "A"` or `part = "B"`. Half A prints as
rendered, substrate down. Half B is rendered in its assembled position, above A,
so turn it over to print it substrate down.

Linear halves slide together along the rails. Radial halves press together while
the substrates flex.

`clearance` is the gap your printer has to hold open between the halves. How
small it can go depends on the printer and material; the coupons in
[`specimens/pilot`](https://github.com/CameronBrooks11/iLOX/tree/main/specimens/pilot)
print a ladder of clearances and substrate thicknesses to find it.
