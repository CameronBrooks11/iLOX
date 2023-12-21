![Regular Octagon Diagram](octagon_dia.png)

To determine the key dimensions of a regular octagon, we can derive equations based on the geometric properties of right triangles and isosceles triangles formed within the octagon. 

### Diagonal Length (`d`)

The diagonal of the octagon, denoted as `d`, can be found by considering the right triangle `ABC`, where `AB` is the width `w`, `BC` is the side length `s`, and `AC` is the diagonal `d`. Using the Pythagorean theorem:

```math
d^2 = s^2 + w^2
```

### Width (`w`)

The width `w` is the distance from one side of the octagon to the opposite side, which is the length of one side `s` plus twice the length of segment `x`, the line from the midpoint of a side to the center of the octagon. Thus, `w` is expressed as:

```math
w = s + 2x
```

### Segment Length (`x`)

The segment `x` lies within isosceles right triangles, such as triangle `EBD`. Since the octagon is regular, each of these triangles has two equal sides, which are the segments `x` and the side length `s`. By the Pythagorean theorem:

```math
s^2 = 2x^2
x = s / √2
```

Substituting `x` into the width equation:

```math
w = s + 2(s / √2)
w = s(1 + √2)
```

### Final Equations

Substituting `w` into the diagonal equation yields:

```math
d^2 = s^2 + (s(1 + √2))^2
d^2 = s^2 + s^2(3 + 2√2)
d = s√(4 + 2√2)
```

With these equations, we can solve for the diagonal length `d`, width `w`, and segment `x` given the side length `s` of a regular octagon.

- **Diagonal (`d`):** `d = s√(4 + 2√2)`
- **Width (`w`):** `w = s(1 + √2)`
- **Segment (`x`):** `x = s / √2`


## References:
[mathcentral.uregina.ca 'quandaries & queries'](http://mathcentral.uregina.ca/QQ/database/QQ.09.20/h/sue2.html)