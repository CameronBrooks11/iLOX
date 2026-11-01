---
title: Home
layout: home
nav_order: 1
---

# {{ site.title }}

[![Build Status](https://img.shields.io/github/actions/workflow/status/CameronBrooks11/iLOX/pages.yml?branch=main)](https://github.com/CameronBrooks11/iLOX/actions)
[![License](https://img.shields.io/github/license/CameronBrooks11/iLOX?branch=main)](https://github.com/CameronBrooks11/iLOX/blob/main/LICENSE)

iLOX is an OpenSCAD library for joints that print as two separate parts and
interlock. A 2D unit cell is split along a division line into two halves, A and
B, a clearance apart. The halves are extruded and repeated across two
substrates: as rails with `ilox_linear`, which slide together, or as pins with
`ilox_radial`, which press together.

- [Getting started]({% link getting-started.md %}): install, a first render, printing the halves.
- [Reference]({% link reference/index.md %}): the modules and their arguments.
- [Examples]({% link examples/index.md %}): the two examples, with live 3D views.
- [Changelog](https://github.com/CameronBrooks11/iLOX/blob/main/CHANGELOG.md): what changed, and what a caller must change.

Source and issues are on [GitHub](https://github.com/CameronBrooks11/iLOX).
