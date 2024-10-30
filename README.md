![SnapTessCAD Logo](docs/assets/logo_strip_v1.png)

*An OpenSCAD Library for Designing Tessellated Interlocking Surface Geometry for 3D Printing*

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Usage](#usage)
  - [Basic Usage](#basic-usage)
  - [Advanced Tessellation Usage](#advanced-tessellation-usage)
  - [Tensile Specimens](#tensile-specimens)
- [Modules](#modules)
  - [ucell.scad](#ucellscad)
  - [cell2polar.scad](#cell2polarscad)
  - [tess.scad](#tessscad)
  - [utils.scad](#utilsscad)
- [Documentation](#documentation)
- [License](#license)
- [Acknowledgements](#acknowledgements)

## Features

- **Unit Cell Generation**: Calculate and render unit cells with customizable dimensions and division points.
- **Polar Coordinate Conversion**: Convert 2D cell patterns into 3D models using polar coordinates.
- **Complex Tessellations**: Generate intricate tessellations, including hexagonal and octagonal grids.
- **Advanced Point Operations**: Perform operations like sorting centers, filtering points, and calculating triangulated centers.
- **Selective Positioning**: Customize tessellation patterns by filtering and manipulating specific points.

## Installation

1. **Clone the Repository**:
    ```git clone https://github.com/uwo-fast/SnapTessSCAD.git```

2. **Include Library Files**: Incorporate the library files from the `src` directory into your OpenSCAD project.

3. **Dependencies**: There are no external dependencies, `sorted.scad` file is already included in the `src` used from the [dotSCAD library](https://github.com/JustinSDK/dotSCAD), as it is required by `utils.scad`.

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

### Advanced Tessellation Usage

The `examples/tessUsage` directory contains scripts showcasing advanced usage of the tessellation library. These scripts demonstrate:

- Generating and manipulating tessellation patterns.
- Utilization of visualization tools.
- Applying transformations and mappings to tessellations.
- Customizing tessellation geometries through selective positioning and filtering.

### Tensile Specimens

The `examples/tensileSpecimens` directory includes scripts that apply the workflow to create tensile testing specimens. These models integrate unit cells and tessellation patterns into the geometry of a tensile test specimen for load testing simulations.

## Modules

### ucell.scad

Provides functions and modules for calculating and rendering unit cells based on given dimensions and division points. Key features include:

- Transforming and mirroring points.
- Applying tolerances to division points.
- Rendering cells with optional negative polygons.
- Placing spheres at specified points.

### cell2polar.scad

Contains functions and modules for converting 2D cell patterns into 3D models using polar coordinates. Features include:

- Calculating geometric properties like apothem and central angles.
- Rendering cells in polar coordinates with rotational symmetry.
- Placing cells at specified positions with optional rotation.

### tess.scad

Offers functions and modules for generating tessellation patterns and rendering shapes. Capabilities include:

- Generating center points for hexagonal and octagonal grids.
- Creating hexagons and octagons with optional color gradients.
- Rendering shapes as 2D outlines or extruded 3D solids.
- Supporting selective positioning and customization of tessellation patterns.

### utils.scad

Provides utility functions for point operations, such as:

- Sorting centers by coordinates.
- Calculating distances and checking point equality within a tolerance.
- Filtering points based on proximity or matching criteria.
- Generating triangulated center points.

## Documentation

For detailed geometric calculations and explanations related to hexagons and octagons, refer to the following documents in the `docs` directory:

- [`library_logic.md`](docs/library_logic.md): Explains in-depth the logic of the library.
- [`hexagons_math.md`](docs/hexagons_math.md): Geometric math for chords and other relations of hexagons.
- [`octagons_math.md`](docs/octagon_math.md): Geometric math for chords and other relations of octagons.

## License

This project is licensed under the [GNU General Public License v3.0](LICENSE).

## Acknowledgements

- Utilizes the `sorted.scad` module from the [dotSCAD library](https://github.com/bjnortier/dotSCAD).
- Based on geometric principles and algorithms for tessellation and unit cell generation, inspired by recent advances in geometric computing and mechanical metamaterials.
- Development is heavily nature-inspired by the various natural structures that allow for interconnection.