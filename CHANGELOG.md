# Changelog

All notable changes to iLOX, in the form of
[Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

No version has been tagged yet. Below Unreleased, the history is grouped into
dated periods reconstructed from the commits. A period marked as a candidate tag
ends at a commit that [#30] could tag retroactively.

## [Unreleased]

2026-10-16 to 2026-11-01. This becomes the first tagged release ([#30]). Each
breaking change is relative to the last candidate tag, `b859cf8`. The library
code did not change between that commit and [#22].

### Changed

- **Breaking:** the public names ([#47]). Pass arguments by name: those after
  `clearance` changed order.

  | Before | After |
  | --- | --- |
  | `radial_iLOX`, `linear_iLOX`, `ucell_designer` | `ilox_radial`, `ilox_linear`, `ilox_cell_designer` |
  | `width_x`, `height_y` | `width`, `height` |
  | `base_ucell_div` | `div` |
  | `base_ucell_neg_poly`, `neg_poly` | `voids` |
  | `cellA_color`, `cellB_color` | `colors = [A, B]` |
  | `pt_diams`, `pt_colors`, `pt_zGap`, `pt_fn` | `point_d`, `point_colors`, `point_z`, `point_fn` |
  | `neg_border` (`render_ucells`) | `void_border` |

  `levels`, `grid_n`, `grid_m` and `extension_factor` default to 2, 3, 2 and 1,
  and `voids` to `[]`.
- **Breaking:** cells A and B are separated by one `clearance` in mm, measured
  normal to the division line ([#22]). Before, each division point carried a
  tolerance `t` that shifted it along x, which gave a gap of
  `width * t * sin(theta)`: zero on horizontal faces. Division points are now
  `[x, y]`, and `clearance` follows `div` in `calc_ucell` and the three modules.
  Drop the third element of each division point and pass `clearance`. The old
  `t = 0.01` gave 0.05 mm at the examples' 5 mm width, and the examples now use
  0.2.
- **Breaking:** each cell's tip stops `tip_clearance` short of the opposite
  substrate ([#23]). It defaults to `clearance`, so cells are shorter, and the
  two halves export as two shells instead of one welded solid. Pass
  `tip_clearance = 0` for full-height cells.
- **Breaking:** in `ilox_radial` the gap between neighbouring pins is the
  clearance ([#32]). Before, it was cos 30 degrees of the clearance, widened by
  `packing_factor`: after [#22] and [#23], the radial example
  (`packing_factor = 0.3`, `clearance = 0.2`) had a 0.676 mm gap. Radial parts
  are tighter at the same clearance.
- **Breaking:** `voids` must be a list of polygons of at least 3 `[x, y]`
  points ([#45]). Wrap a single polygon in `[ ]`. It used to give no void, and
  135 warnings for a 3 x 2 linear render.
- **Breaking:** inputs that gave wrong geometry now stop with an error
  ([#22], [#23], [#45], [#47]):
  - a division line that crosses itself, does not rise off the bottom edge, or
    whose offset splits or pinches a cell;
  - a `tip_clearance` of half the cell height or more;
  - `levels` that is not a whole number of at least 2, and `grid_n` below 2;
    either gave a B half with no cells;
  - `grid_m` below 1 and `extension_factor` outside 0 to 1;
  - a non-positive `width`, `height` or `substrate_height`, and a `div` of
    fewer than 2 points.

  `colors` and `point_colors` of the wrong length are rejected too ([#47]).
- `calc_ucell` returns the voids as `[voidsA, voidsB]`, `[[], []]` when there
  are none ([#45]). An empty `neg_poly` used to give `len()` warnings in every
  extrusion, 60 for a 3 x 2 linear render.
- **Breaking:** `place_spheres` treats `d` as a diameter. It was used as a
  radius, so spheres, including `ilox_cell_designer`'s point markers, are half
  their previous size ([#45]).
- **Breaking:** `arc_points` returns `[x, y]` unless `z_val` is given; it
  returned `[x, y, 0]` ([#22]). Pass `z_val = 0` for the old points. Likewise
  `mirrorPoints` drops a third element.
- `calc_ucell_voids` has no default `poly` and returns `[voidsA, voidsB]`
  ([#45]).
- `render_ucells` no longer echoes on every call ([#45]).
- Licence: GPL-3.0 to the Mozilla Public License 2.0 ([#37]).
  `src/utils/sorted.scad`, from dotSCAD, stays under the LGPL-3.0 ([#35]).
- `tests/direct-workflow/` and `tests/complex-ucell-prototyping/` moved to
  `concept/direct-workflow/` and `concept/ucell-prototyping/`, and
  `tests/mechanical-testing/` to `specimens/tensile/` ([#41]). Four
  direct-workflow scripts were renamed for spelling: `tesselation_*` became
  `tessellation_*`, and `*rectlinear*` became `*rectilinear*` ([#36]).
- The docs site has four pages: Home, Getting started, Reference (every
  argument, with defaults and limits) and Examples ([#48], [#49]).

### Added

- `part = "A"`, `"B"` or `"both"` on `ilox_radial` and `ilox_linear` renders
  one half in its assembled position ([#23]). Print B upside down.
- `tests/run.sh` and a CI workflow that runs it on OpenSCAD 2021.01 and a 2026
  snapshot ([#34]). It runs the clearance checks, the radial gap, rejected
  inputs and exports of the examples ([#34], [#45], [#47]), the coupons ([#39])
  and the tensile specimens ([#41]).
- `specimens/pilot/`: linear and radial coupons, and a 96-coupon ladder of
  clearances and substrate thicknesses for batch export ([#39]).
- `specimens/tensile/clamp.scad`: `tensile_clamp()`, the clamp that holds a
  tensile strip in the test machine ([#42], [#44], [#50]).

### Removed

- **Breaking:** `degree_n` and `packing_factor` from the radial module ([#32]).
  The lattice was always hexagonal, and other `degree_n` values could make the
  halves interpenetrate.
- `applyTolerance`, replaced by the clearance offset ([#22]).
- The unused functions `distance`, `is_within_radius`,
  `filter_triangulated_center_points`, `radiusapo`, `radius_apothem_diff` and
  `flatten` ([#45]).
- The template docs pages, including a changelog page with a "1.0.0,
  2025-06-14" entry that no commit or tag backed ([#48]).

### Fixed

- The rotational concept and tensile scripts place their own cells, and kept
  the old radial spacing until [#40]. A radial specimen exported before [#40]
  has a much wider gap than one exported now.
- The README's tessella clone URL, and the folder name, which must be lowercase
  on case-sensitive file systems ([#35]).

## 2025-07-06 to 2026-10-07: docs site and customizer

The library code did not change in this period.

### Added

- A just-the-docs site under `docs/`, published to GitHub Pages. Most of its
  pages were template placeholders until [#48].
- Example pages for the radial and rectangular examples, with a click-to-load
  3D view and a live in-browser Customizer ([#12], [#14]).

### Fixed

- The static 3D views showed every model in one colour. Pages now renders them
  with a pinned OpenSCAD snapshot on the Manifold backend, which keeps the
  colours ([#17], [#18]).

## 2025-01-19 to 2025-06-05: high-level modules

Candidate tag for [#30]: `b859cf8`, whose examples render with tessella alone.
From 2025-01-20 until 2025-06-05 the library also needed FunctionalOpenSCAD for
`flatten`, although from 2025-01-23 the README called it unneeded.

### Added

- `radial_iLOX` and `linear_iLOX` in `iLOX.scad`: a unit cell extruded and
  tessellated into two substrates, as rotated pins on a hexagonal lattice or as
  linear rails on a rectangular grid. `ucell_designer` draws a cell and its
  division points.
- `src/cell2linear.scad`: linear extrusion of the cells (`ucell_linX_A`,
  `ucell_linX_B`, `place_linear_cells`) beside the rotational one.
- More than one void per cell: `neg_poly` takes a list of polygons in place of
  one.
- `examples/simpleUsage/`: one radial and one rectangular example, with
  Customizer parameter sets.
- `tests/direct-workflow/`, scripts that build from a unit cell to a full
  tessellation step by step, and `tests/mechanical-testing/` with radial and
  rectangular tensile specimens.

### Changed

- `src/cell2polar.scad` became `src/cell2rot.scad`. `cellA2polar`,
  `cellB2polar` and `place_polar_cells` became `ucell_rotX_A`, `ucell_rotX_B`
  and `place_rotated_cells`, and `cells2polarpos` was removed.
- `calc_ucells` became `calc_ucell`, and returns `[A, B, voids]` in place of
  `[A, B, voidA, voidB]`.
- `ucell_rotX_A` and `ucell_rotX_B` take an `angle` for a partial revolve.
- `src/utils.scad` was split into `src/utils/point_utils.scad`,
  `regpoly_utils.scad` and `viz_utils.scad`.

### Removed

- The FunctionalOpenSCAD dependency (2025-06-05). `flatten` is defined in
  `point_utils.scad`.
- The batch-export example.

## 2024-11-21 to 2025-01-18: linear cells, the tessella split and the rename to iLOX

### Added

- Prototypes of linear unit cells, later named `simple_ilox`, `rounded_ilox`
  and `semicircle_ilox`, now in `concept/ucell-prototyping/`.
- An example of batch export with the OpenSCAD Customizer's parameter sets.
- Division lines that start from the top edge of the cell (a division point
  `[x, 1]` first), and a border around voids in `render_ucells`
  (`neg_border`).
- `iLOX.scad` as the entry point (2024-12-25).
- `arc_points` and `shift_points` (2025-01-17). They were first written on
  2024-12-07, on a branch whose merge dropped them.

### Changed

- The hexagon and octagon tessellation (`src/tess.scad`), its examples, its
  geometry notes and the point helpers that went with it
  (`filter_center_points`, `print_points` and others) were removed in favour of
  [tessella](https://github.com/CameronBrooks11/tessella), a separate library
  started on 2024-12-20 (2024-12-25). `iLOX.scad` includes `tessella/tess.scad`
  from 2025-01-17. Between those dates the examples do not render.
- The library is named iLOX, InterLocking Orthogonal eXtrusions, after
  SnapTessSCAD (README, 2025-01-18).
- `cellA2polar` no longer takes `radius`, and `cellB2polar` and
  `place_polar_cells` take `width` in its place.
- `iLOX.scad` includes the FunctionalOpenSCAD library (2025-01-17).

## 2024-05-15 to 2024-10-30: unit cells

Candidate tag for [#30]: `ba8fe2c`. The workflow example and the tensile
specimens render with no other library. The tessellation examples do not: their
`use` paths stop one directory short of `src/`, and the octagon example has a
syntax error.

### Added

- `src/ucell.scad`: a 2D unit cell split by a division line into halves A and
  B, with a tolerance per division point `[x, y, t]` (2024-05-29).
  `calc_ucells`, with one optional void polygon `neg_poly`, and `render_ucells`
  (2024-10-27).
- `src/cell2polar.scad`: rotational extrusion of the cells and their placement
  on a lattice (2024-10-27).
- `examples/basicUsage/workflow_example.scad`, which walks through the method
  (2024-10-27).
- Tensile specimens to ASTM D638 Type I dimensions, built on the unit cells: a
  lateral one (2024-10-29), then a front one, both in
  `examples/tensileSpecimens/` (2024-10-30).
- A README listing the modules, and `docs/library_logic.md` (2024-10-30).

### Removed

- The tricho feature and the `snap` and `cloneSnap` modules, archived on
  2024-05-29 and deleted on 2024-10-29, along with the arrow-head snap fit kept
  for comparison.

### Fixed

- The includes of `src/tess.scad` and the tessellation examples, left broken by
  the reorganisation of 2024-05-29 (2024-10-20). Moving the examples on
  2024-10-29 broke their paths again.

## 2024-01-05 to 2024-05-14: SnapTessSCAD snap surfaces

### Added

- Snap surfaces: a tricho feature placed on hexagon centres, with the mating
  half on the centres of the triangles between them. Modules `snap` and
  `cloneSnap`, and the first parameterised surface with examples (2024-01-08).
- Numbering and colouring of grid points, and `triangulated_center_points`.
- `src/tess.scad`, one file for the hexagon and octagon tessellation
  (2024-03-30): hexagons by levels or by N x M grid, octagons by grid only.
- Test prints for lateral holding strength and snap action, and a tactile
  tester.
- A vendored copy of dotSCAD's `sorted`.

### Changed

- The `src/` and `examples/` layout (2024-01-06 and 2024-01-07), and file names
  with the prefixes `geo_`, `tess_`, `snap` and `utils_` (2024-03-04).
- `snap` no longer takes tricho's angles and heights (2024-03-31).

### Fixed

- `tricho`'s defaults tested the variable being assigned instead of the
  argument, from 2024-03-31 to 2024-05-10.

## 2023-12-21 to 2023-12-30: geometry groundwork

### Added

- The repository, as SnapTessSCAD, under the GPL-3.0.
- Hexagon and octagon tessellation with functions for the centre points,
  replacing copies of dotSCAD's modules, and notes on the geometry.
- `tricho.scad`: a stem and cap built from stacked hexagonal cylinders.

[Unreleased]: https://github.com/CameronBrooks11/iLOX/compare/b859cf8...HEAD
[#12]: https://github.com/CameronBrooks11/iLOX/pull/12
[#14]: https://github.com/CameronBrooks11/iLOX/pull/14
[#17]: https://github.com/CameronBrooks11/iLOX/pull/17
[#18]: https://github.com/CameronBrooks11/iLOX/pull/18
[#22]: https://github.com/CameronBrooks11/iLOX/pull/22
[#23]: https://github.com/CameronBrooks11/iLOX/pull/23
[#30]: https://github.com/CameronBrooks11/iLOX/issues/30
[#32]: https://github.com/CameronBrooks11/iLOX/pull/32
[#34]: https://github.com/CameronBrooks11/iLOX/pull/34
[#35]: https://github.com/CameronBrooks11/iLOX/pull/35
[#36]: https://github.com/CameronBrooks11/iLOX/pull/36
[#37]: https://github.com/CameronBrooks11/iLOX/pull/37
[#39]: https://github.com/CameronBrooks11/iLOX/pull/39
[#40]: https://github.com/CameronBrooks11/iLOX/pull/40
[#41]: https://github.com/CameronBrooks11/iLOX/pull/41
[#42]: https://github.com/CameronBrooks11/iLOX/pull/42
[#44]: https://github.com/CameronBrooks11/iLOX/pull/44
[#45]: https://github.com/CameronBrooks11/iLOX/pull/45
[#47]: https://github.com/CameronBrooks11/iLOX/pull/47
[#48]: https://github.com/CameronBrooks11/iLOX/pull/48
[#49]: https://github.com/CameronBrooks11/iLOX/pull/49
[#50]: https://github.com/CameronBrooks11/iLOX/pull/50
