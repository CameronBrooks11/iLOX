# iLOX

_**I**nter**L**ocking **O**rthogonal e**X**trusions_

_An OpenSCAD Library for Designing Tessellated Interlocking Surface Geometry for 3D Printing_

## Table of Contents

- [iLOX](#ilox)
  - [Table of Contents](#table-of-contents)
  - [Dependencies](#dependencies)
  - [Usage](#usage)
    - [Basic Usage](#basic-usage)
    - [Direct Workflow](#direct-workflow)
    - [Tensile Specimens](#tensile-specimens)
  - [Structure](#structure)
    - [iLOX.scad](#iloxscad)
    - [ucell.scad](#ucellscad)
    - [cell2rot.scad](#cell2rotscad)
    - [cell2linear.scad](#cell2linearscad)
    - [point\_utils.scad](#point_utilsscad)
    - [sorted.scad](#sortedscad)
    - [regpoly\_utils.scad](#regpoly_utilsscad)
    - [viz\_utils.scad](#viz_utilsscad)
  - [Documentation](#documentation)
  - [License](#license)
  - [Acknowledgements](#acknowledgements)

## Dependencies

Download and place the following libraries in your OpenSCAD libraries folder:

1.  [CameronBrooks11/tessella](https://github.com/CameronBrooks11/Tessella)
    1.  Currently, this is the only explicitly required dependency!
    2.  Ensure it is placed in your OpenSCAD libraries folder.
2.  [thehans/FunctionalOpenSCAD](https://github.com/thehans/FunctionalOpenSCAD)
    1.  Not currently needed!
    2.  Will be removed in the future to increase workflow flexibility.
3.  The `sorted.scad` file is already included in the `src` directory, sourced from the [dotSCAD library](https://github.com/JustinSDK/dotSCAD), as it is required by `point_utils.scad`.
4.  [CameronBrooks11/OpenSCAD-Batch-Export](https://github.com/CameronBrooks11/OpenSCAD-Batch-Export)
    1.  _If batch exporting is required for testing or iteration._
    2.  Provides a cross-platform, user-friendly GUI for mass-exporting parametric OpenSCAD scripts to .stl files.

## Usage

### Basic Usage

The `examples/simpleUsage/` folder contains `simpleUsageRadial.scad` and `simpleUsageRectangular.scad` which demonstrate how to use high level modules of the library.

### Direct Workflow

This can be found under `tests/direct-workflow` and is a sequential set of scripts that utilize the full source of this library to demonstrate the full functionality of the library for both the rotational-radial and rectilinear-rectangular cases.

### Tensile Specimens

The `tests/tensileSpecimens` directory includes scripts that apply serve as a direct continuation of `tests/direct-workflow` to apply the final iLOX geometry to a tensile testing specimen to enable mechanical testing.

## Structure

```
D:.
│   iLOX.scad
├───src
│   │   cell2linear.scad
│   │   cell2rot.scad
│   │   ucell.scad
│   │
│   └───utils
│           point_utils.scad
│           regpoly_utils.scad
│           sorted.scad
│           viz_utils.scad
```

### iLOX.scad

The `iLOX.scad` file serves as the main entry point for the project, including essential external libraries like `FunctionalOpenSCAD` and `tessella` to handle functional of point data and tessellation tasks. It also includes the internal `src/` SCAD files such as `cell2rot.scad`, `cell2linear.scad`, and `ucell.scad` to define the key functions for unit cell creation and rendering. It also includes modular, high-level implementations of both the rotational extrusion + radial tesselation and rectilinear extrusion + rectangular tesselation cases.

### ucell.scad

This module provides essential functions and modules for defining and rendering unit cells. It includes tools for calculating the points of cells A and B based on given dimensions, handling transformations, applying tolerances, and managing optional negative polygons. Rendering capabilities are provided for visualizing the cells and their optional cutouts.

### cell2rot.scad

This module builds on `ucell.scad` to render unit cells in a rotational context. Using rotational extrusion, it enables placement of cells A and B at specified positions with options for rotation, customization of colors, and inclusion of negative polygons for subtractive features.

### cell2linear.scad

This module extends `ucell.scad` by enabling linear extrusion of unit cells. It supports placing cells A and B at designated positions with optional extensions, custom colors, and negative polygon adjustments for creating detailed features.

### point_utils.scad

This file provides utility functions for point operations such as sorting, calculating distances, and filtering points. It includes tools for generating midpoints, triangulating grids, and determining point proximity.

### sorted.scad

A helper file for implementing sorting utilities used by `point_utils.scad` for ordering points based on a specified key function. Used from [dotSCAD](https://github.com/bjnortier/dotSCAD).

### regpoly_utils.scad

This file contains functions for working with regular polygons, such as calculating the central angle, apothem, and radius. These utilities assist in positioning and rotating regular polygons.

### viz_utils.scad

This file has visualization utilities for rendering points and geometric elements, such as placing spheres at specified coordinates to help with the visual representation of data.

## Documentation

For details on the conceptual background and explanations related logic of the program, refer to the documentation in the [`docs`](docs/README.md).

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

## Acknowledgements

- Utilizes the `sorted.scad` module from the [dotSCAD library](https://github.com/bjnortier/dotSCAD).
- Based on geometric principles and algorithms for tessellation and unit cell generation, inspired by recent advances in geometric computing and mechanical metamaterials.
- Development is heavily nature-inspired by the various natural structures that allow for interconnection.
