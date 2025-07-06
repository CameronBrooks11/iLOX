---
title: Library Logic
parent: Developer
nav_order: 2
---

# Library Logic

This serves as a walkthrough of the logic behind the library including the concept and math behind it.

## Conceptual Overview

The idea is that we have two surfaces and we want to connect or fasten them together by adding geomtrically interlocking geometry to all or a portion of the surfaces such that applying a force normally (perpendicular) engages (snaps) the surfaces together. A similar method of fastening can be observed in velocro. The approach to creating this geometry herein consists of three main parts:

1. Generation of the unit geometry,
2. Tesselation of the position lattice,
3. Selective positioning of geometry onto lattice.

## Unit Geometry

The unit geometry refers to how the surface is bisected from +y to -y to form the latching structure of to fix the position of the +y and -y faces. The simplest example is given in the below figure.

![](../assets/unit1.png)

Adding a tolerance on this line:

![](../assets/unit2.png)

Looking forward we can also remove the upper edge where the now separate surfaces will make initial contact during engagement:

![](../assets/unit3.png)

The surface to be bisected must consider leaving sufficient substrate on the +y and -y for each of the surfaces to remain intact during manufacturing. In the above example there is symmetry, so it is arbitrary to specify which segment will occupy the center points or the vertices but if it isn't then this detail becomes relevant how the bisection is defined with respect to +y and -y depending on the application of what occupies that space.

## Tess

_Tesselation of the position vector lattice_

**USES TESSELLA NOW**

### Why Hexagons?

For a polygon to be tessellable, it must satisfy certain conditions:

1. **Regular Polygons**: A regular polygon can tessellate if its interior angle, when multiplied by a certain number, sums up to 360 degrees. This applies to triangles, squares, and hexagons.

   - The formula for the interior angle is:
     - ![Equation (n-2) \times 180^\circ / n](<https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}(n-2)&space;\times&space;180^\circ&space;/&space;n}>)
   - For tessellation, the result must divide evenly into 360 degrees.

2. **Irregular Polygons**: Can tessellate if they can fit together without gaps or overlaps. This often requires a combination of different shapes or orientations, and in the present application hence multiple or increasingly complex geometry.

3. **Vertex Configuration**: For complex tessellations, especially with multiple polygons, each vertex configuration must be identical.

4. **Edge Compatibility**: Edges must be compatible in length and angle to fit together without gaps.

Triangles:

- 6 triangles form a hexagon, redundant; despite being more simple and elementary it makes the interation with the unit geometry

Squares:

- A technically valid solution
- No offset
  - Decreased packing density
  - Concentration of shear forces

Hexagons

- O
-

### Corresponding Triangulated Tesselation

To generate the lattice for the B unit cells, a triangulation algorithm is employed. This approach is chosen over directly modifying the base tessellation (such as by removing a level or deriving from it) because it offers greater flexibility. Specifically, it allows for the application of intermediate transformations or operations to the base tessellation without the need to replicate these changes for the corresponding B unit cell tessellation. This could include operations like scaling, rotation, or surface mapping onto complex geometries.

In the context of a hexagonal tessellation, the triangulation algorithm works by calculating the centroids of triangles formed by adjacent hexagon centers. These centroids become the positions for the B unit cells. By using triangulation, we can seamlessly generate a secondary lattice that is inherently linked to the original tessellation but can adapt to any transformations applied to it.

For example, if the base tessellation is mapped onto a curved surface, the triangulation algorithm will produce a corresponding B unit cell lattice that conforms to the same curvature. This ensures that the structural relationship between the A and B unit cells is maintained regardless of the transformations applied to the base tessellation.

## Selective Positioning

Selective positioning allows for the customization of the tessellation by filtering out specific points or vectors from the generated lattice. This process enables the creation of tailored geometries that can modify the predefined tessellation and influence the placement of unit cells and substrates downstream.

Once a vector tessellation is generated, certain points can be excluded through a comparison loop that evaluates each point against a set of criteria or a filter list. This is achieved by iterating over the vector lattice array and removing entries that match the filter conditions.

In the case of the hexagonal tessellation, removing a point from the base tessellation necessitates the removal of corresponding triangulated points. This is because the triangulated points (used for placing B unit cells) are calculated based on the positions of the base tessellation points (A unit cells). To maintain the integrity of the lattice, the triangulated points associated with the removed base points must also be excluded.

This selective filtering is crucial when designing complex structures where certain areas need to be left open or when integrating features like channels, voids, or custom patterns. By effectively removing specific points, designers can alter the distribution and connectivity of unit cells, allowing for greater control over the mechanical, thermal, or aesthetic properties of the final model.

Selective positioning enhances the versatility of the tessellation algorithms, enabling the creation of intricate and application-specific geometries without the need for extensive manual adjustments. It supports advanced design requirements by providing a programmable method to manipulate the tessellation at both the macro and micro levels.
