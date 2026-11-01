# iLOX

_**I**nter**L**ocking **O**rthogonal e**X**trusions_

_An OpenSCAD Library for Designing Tessellated Interlocking Surface Geometry for 3D Printing_

## Table of Contents

- [iLOX](#ilox)
  - [Table of Contents](#table-of-contents)
  - [Dependencies](#dependencies)
  - [Usage](#usage)
    - [Basic Usage](#basic-usage)
    - [Tests](#tests)
    - [Concept](#concept)
    - [Specimens](#specimens)
  - [Library Structure](#library-structure)
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

iLOX needs [tessella](https://github.com/CameronBrooks11/tessella) 0.1.0, as `include <tessella/tess.scad>`. Clone it into your OpenSCAD libraries folder, keeping the folder name lowercase:

```
git clone --branch v0.1.0 https://github.com/CameronBrooks11/tessella.git
```

CI tests against the tessella ref in `.github/workflows/test.yml`.

For batch exports of parameter sets, [scadbatch](https://github.com/CameronBrooks11/scadbatch) is optional.

## Usage

### Basic Usage

The `examples/simpleUsage/` folder contains `simpleUsageRadial.scad` and `simpleUsageRectangular.scad` which demonstrate how to use high level modules of the library.

### Tests

`tests/run.sh` runs the checks in `tests/clearance`, exports each example, each tensile specimen and each coupon in `specimens/pilot/ladder.csv`, exiting non-zero on any failure; `OPENSCAD` picks the binary. CI runs it on every pull request with OpenSCAD 2021.01 and a 2026 snapshot.

### Concept

`concept/` shows how the library's pieces build up to a joint. `concept/direct-workflow` is a sequence of scripts, from the unit cell through single extrusions to full tessellations, for both the rotational-radial and rectilinear-rectangular cases; later scripts include earlier ones. `concept/ucell-prototyping` holds experiments with other unit cell shapes.

### Specimens

`specimens/` holds the parts for physical testing:

- `specimens/tensile`: strips for the test machine with a joint in the middle, built on `concept/direct-workflow`, and the clamp that holds them. See [specimens/tensile/README.md](specimens/tensile/README.md).
- `specimens/pilot`: small linear and radial coupons, one half or both in place, with a ladder of clearances and substrate thicknesses to export with scadbatch. See [specimens/pilot/README.md](specimens/pilot/README.md).

## Library Structure

```
iLOX.scad
src/
    cell2linear.scad
    cell2rot.scad
    ucell.scad
    utils/
        point_utils.scad
        regpoly_utils.scad
        sorted.scad
        viz_utils.scad
examples/
concept/
specimens/
    pilot/
    tensile/
tests/
docs/
```

### iLOX.scad

The `iLOX.scad` file serves as the main entry point for the project, including the external `tessella` library for tessellation. It also includes the internal `src/` SCAD files such as `cell2rot.scad`, `cell2linear.scad`, and `ucell.scad` to define the key functions for unit cell creation and rendering. It also includes modular, high-level implementations of both the rotational extrusion + radial tessellation and rectilinear extrusion + rectangular tessellation cases.

### ucell.scad

This module provides essential functions and modules for defining and rendering unit cells. It includes tools for calculating the points of cells A and B based on given dimensions, handling transformations, applying a clearance between the cells, and managing optional negative polygons. Rendering capabilities are provided for visualizing the cells and their optional cutouts.

### cell2rot.scad

This module builds on `ucell.scad` to render unit cells in a rotational context. Using rotational extrusion, it enables placement of cells A and B at specified positions with options for rotation, customization of colors, and inclusion of negative polygons for subtractive features.

### cell2linear.scad

This module extends `ucell.scad` by enabling linear extrusion of unit cells. It supports placing cells A and B at designated positions with optional extensions, custom colors, and negative polygon adjustments for creating detailed features.

### point_utils.scad

This file provides utility functions for point operations: sorting grid centers, placing points midway between them or at the centres of their triangles, and generating and shifting arcs of points.

### sorted.scad

A helper file for implementing sorting utilities used by `point_utils.scad` for ordering points based on a specified key function. From dotSCAD; see [License](#license).

### regpoly_utils.scad

This file contains functions for working with regular polygons: the central angle, half of it, and the apothem. These utilities assist in positioning and rotating regular polygons.

### viz_utils.scad

This file has visualization utilities for rendering points and geometric elements, such as placing spheres at specified coordinates to help with the visual representation of data.

## Documentation

The documentation site, built from `docs/`, is at <https://cameronbrooks11.github.io/iLOX/>: install, a first render, a reference for the modules, and the examples with live 3D views.

## License

This project is licensed under the [Mozilla Public License 2.0](LICENSE).

Third-party code:

- `src/utils/sorted.scad` is from Justin Lin's [dotSCAD](https://github.com/JustinSDK/dotSCAD), under the [GNU Lesser General Public License v3.0](src/utils/LICENSE.LGPL-3.0).
- The docs site under `docs/` started from the [just-the-docs template](https://github.com/just-the-docs/just-the-docs-template), under the [MIT License](docs/LICENSE).

## Acknowledgements

- Based on geometric principles and algorithms for tessellation and unit cell generation, inspired by recent advances in geometric computing and mechanical metamaterials.
- Development is heavily nature-inspired by the various natural structures that allow for interconnection.
