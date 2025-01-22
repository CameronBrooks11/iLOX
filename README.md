# iLOX

_**I**nter**L**ocking **O**rthogonal e**X**trusions_

_An OpenSCAD Library for Designing Tessellated Interlocking Surface Geometry for 3D Printing_

## Table of Contents

- [iLOX](#ilox)
  - [Table of Contents](#table-of-contents)
  - [Overview](#overview)
  - [Usage](#usage)
    - [Basic Usage](#basic-usage)
    - [Tensile Specimens](#tensile-specimens)
  - [Modules](#modules)
    - [ucell.scad](#ucellscad)
    - [cell2rot.scad](#cell2rotscad)
  - [Documentation](#documentation)
  - [License](#license)
  - [Acknowledgements](#acknowledgements)

## Overview

**Dependencies**: Download and place the following libraries in your OpenSCAD libraries folder:

1.  [thehans/FunctionalOpenSCAD](https://github.com/thehans/FunctionalOpenSCAD)
2.  [CameronBrooks11/tessella](https://github.com/CameronBrooks11/Tessella)
3.  `sorted.scad` file is already included in the `src` used from the [dotSCAD library](https://github.com/JustinSDK/dotSCAD), as it is required by `point_utils.scad`.
4.  [CameronBrooks11/OpenSCAD-Batch-Export](https://github.com/CameronBrooks11/OpenSCAD-Batch-Export) _if batch exporting is required for testing / iteration_

## Usage

### Basic Usage

The `examples/basicUsage/workflow_example.scad` script demonstrates how to use the library to:

- Define unit cell dimensions and division points.
- Calculate unit cells (cells A and B) with optional negative polygons.
- Render cells and place spheres at division points.
- Convert cells into polar coordinates and create 3D models.
- Generate tessellation patterns and place cells accordingly.

To run the example:

1. Open `workflow_example.scad` in OpenSCAD.
2. Render the model to visualize the unit cells and tessellations.

### Tensile Specimens

The `examples/tensileSpecimens` directory includes scripts that apply the workflow to create tensile testing specimens. These models integrate unit cells and tessellation patterns into the geometry of a tensile test specimen for load testing simulations.

## Modules

### ucell.scad

Provides functions and modules for calculating and rendering unit cells based on given dimensions and division points. Key features include:

- Transforming and mirroring points.
- Applying tolerances to division points.
- Rendering cells with optional negative polygons.
- Placing spheres at specified points.

### cell2rot.scad

Contains functions and modules for converting 2D cell patterns into 3D models using polar coordinates. Features include:

- Calculating geometric properties like apothem and central angles.
- Rendering cells in polar coordinates with rotational symmetry.
- Placing cells at specified positions with optional rotation.

## Documentation

For detailed geometric calculations and explanations related to hexagons and octagons, refer to the following documents in the [`docs`](docs/README.md).

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

## Acknowledgements

- Utilizes the `sorted.scad` module from the [dotSCAD library](https://github.com/bjnortier/dotSCAD).
- Based on geometric principles and algorithms for tessellation and unit cell generation, inspired by recent advances in geometric computing and mechanical metamaterials.
- Development is heavily nature-inspired by the various natural structures that allow for interconnection.
