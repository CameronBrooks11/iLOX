# Library Walkthrough
This serves as a walkthrough of the library including the concept and math behind it.

## Conceptual Overview
The idea is that we have two surfaces and we want to connect or fasten them together by adding geomtrically interlocking geometry to all or a portion of the surfaces such that applying a force normally (perpendicular) engages (snaps) the surfaces together. A similar method of fastening can be observed in velocro. The approach to creating this geometry herein consists of three main parts:
1. Tesselation of the position lattice,
2. Generation of the unit geometry,
3. Selective positioning of geometry onto lattice.

## Tess
*Tesselation of the position vector lattice*

The script is designed to calculate centers of hexagons and generate hexagonal patterns, optionally applying a color gradient. The mathematical logic and formulae involved are explained below.

**Hexagon Center Calculation**:
   - At the heart of the tesselation script is the calculation for the centers of the hexagons which make up the tesselation pattern. It supports generating hexagons using two different approaches:
     - rectilinear grid  
     - "levels" based approach where hexagons are added in concentric levels around a central hexagon.
The result is a list of 3D points where each datum represents the center point of a single hexagon: [[x0,y0,z0],[x1,y1,z1]...[xk-1,yk-1,zk-1]]. The value of `n` is the number of points in the list, for the rectilinear case this is straight forward as it is simply the value of `n * m` of the input grid. The concentric case is given by `H(L) = 3L^2 - 3L + 1`, the derivation for which is given in [Growth Rate of Hexagonal Pattern](#growth-rate) section below.
   - The key parameters for hexagon center calculation include the `radius` of the hexagon, `levels` for concentric hexagon generation, and optional `spacing` and grid dimensions `(n, m)` for rectangular arrangements.

1. **Mathematical Relations**:
   - **Offset Calculation**:
     - The offsets for x and y coordinates (`offset_x` and `offset_y`) are calculated using trigonometric functions based on the hexagon's radius.
       ![Equation offset_x = radius \cdot cos(30^\circ)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}offset_x&space;=&space;radius&space;\cdot&space;cos(30^\circ)})
       ![Equation offset_y = radius + radius \cdot sin(30^\circ)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}offset_y&space;=&space;radius&space;&plus;&space;radius&space;\cdot&space;sin(30^\circ)})
     - These offsets are used to position the hexagons correctly in a grid, ensuring that each hexagon is placed with edges touching but not overlapping.

   - **Center Shift for Levels**:
     - For generating hexagons in levels around a central point, the script calculates a shift in the x-axis (`dx`) to center the hexagons. This shift is based on the number of levels and the x-offset.
       ![Equation dx = -(levels - 1) \cdot offset_x \cdot 2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}dx&space;=&space;-(levels&space;-&space;1)&space;\cdot&space;offset_x&space;\cdot&space;2})


2. **Color Gradient**:
   - Optionally, a color gradient can be applied to the hexagons based on their normalized position within the pattern. This involves calculating the minimum and maximum x and y coordinates of the centers to normalize each center's position.
   - The normalized positions are then used to determine the color of each hexagon if a color scheme is provided, allowing for a gradient effect across the pattern.

### Why Hexagons?
For a polygon to be tessellable, it must satisfy certain conditions:

1. **Regular Polygons**: A regular polygon can tessellate if its interior angle, when multiplied by a certain number, sums up to 360 degrees. This applies to triangles, squares, and hexagons.

   - The formula for the interior angle is: 
     - ![Equation (n-2) \times 180^\circ / n](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}(n-2)&space;\times&space;180^\circ&space;/&space;n})
   - For tessellation, the result must divide evenly into 360 degrees.

2. **Irregular Polygons**: Can tessellate if they can fit together without gaps or overlaps. This often requires a combination of different shapes or orientations, and in the present application hence multiple or increasingly complex geometry.

3. **Vertex Configuration**: For complex tessellations, especially with multiple polygons, each vertex configuration must be identical.

4. **Edge Compatibility**: Edges must be compatible in length and angle to fit together without gaps.


Triangles:
- 6 triangles form a hexagon, redundant; despite being more simple and elementary it makes the interation with the unit geometry

Squares:
- A technically valid solution
- No offset
  - Decreased oacking density
  - Concentration of shear forces

Hexagons:
- 

### Growth Rate of Hexagonal Pattern {#growth-rate}

The growth rate of the hexagonal pattern in the concentric case is defined by the number of hexagons added at each new level. Let \( L \) be the level number, with \( L = 1 \) representing the central hexagon. Let \( H(L) \) be the total number of hexagons at level \( L \).

For the first level:

![Equation H(1) = 1](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}H(1)&space;=&space;1})

For each subsequent level, 6 more hexagons are added for each side of the hexagon formed in the previous level:

![Equation H_{added}(L) = 6(L - 1)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}H_{\text{added}}(L)&space;=&space;6(L&space;-&space;1)})

The total number of hexagons at any level \( L \) is the sum of hexagons up to that level:

![Equation H(L) = 1 + \sum_{i=2}^{L} 6(i - 1)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}H(L)&space;=&space;1&space;&plus;&space;\sum_{i=2}^{L}&space;6(i&space;-&space;1)})

Simplifying the sum using the formula for the sum of the first \( n \) natural numbers:

![Equation \sum_{i=1}^{n} i = n(n + 1) / 2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}\sum_{i=1}^{n}&space;i&space;=&space;\frac{n(n&space;&plus;&space;1)}{2}})

We apply this to our sum:

![Equation H(L) = 1 + 6 \left( \frac{(L-1)L}{2} \right)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}H(L)&space;=&space;1&space;&plus;&space;6&space;\left(&space;\frac{(L-1)L}{2}&space;\right)})

Expanding the equation:

![Equation H(L) = 1 + 3L(L - 1)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}H(L)&space;=&space;1&space;&plus;&space;3L(L&space;-&space;1)})

Finally, we get the quadratic formula representing the total number of hexagons at level \( L \):

![Equation H(L) = 3L^2 - 3L + 1](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}H(L)&space;=&space;3L^2&space;-&space;3L&space;&plus;&space;1})

This formula indicates a quadratic growth rate with respect to the number of levels.

## Geo


## Snap
