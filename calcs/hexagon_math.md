![Regular Octagon Diagram](./octagon_dia.png)

*Courtesy of Penny Nom [1]*

To determine the key dimensions of a regular octagon, we can derive equations based on the geometric properties of right triangles and isosceles triangles formed within the octagon.

### Diagonal Length  `d`

The diagonal of the octagon, denoted as `d`, can be found by considering the right triangle `ABC`, where `AB` is the width `w`, `BC` is the side length `s`, and `AC` is the diagonal `d`. Using the Pythagorean theorem:

![Equation d^2 = s^2 + w^2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}d^{2}=s^{2}&plus;w^{2}})

### Width  `w` 

The width `w` is the distance from one side of the octagon to the opposite side, which is the length of one side `s` plus twice the length of segment `x`, the line from the midpoint of a side to the center of the octagon. Thus, `w` is expressed as:

![Equation w = s + 2x](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}w=s&plus;2x})

### Segment Length  `x` 

The segment `x` lies within isosceles right triangles, such as triangle `EBD`. Since the octagon is regular, each of these triangles has two equal sides, which are the segments `x` and the side length `s`. By the Pythagorean theorem:

![Equation s^2 = 2x^2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}s^{2}=2x^{2}})
<br>
![Equation x = s / √2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}x=\frac{s}{\sqrt{2}}}\frac{}{})

Substituting `x` into the width equation:

![Equation w = s + 2(s / √2)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}w=s&plus;2(\frac{s}{\sqrt{2}})})
<br>
![Equation w = s(1 + √2)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}w=s(1&plus;\sqrt{2})})

### AC Perpendicular Section
Now for the case of the rotated octagon we will need the length of the cord AC in the below diagram which we will refer to as `y`:

![Regular Octagon Diagram 2](./octagon_dia2.png)

Given a regular octagon, we can find the length of chord \( AC \) and the perpendicular from the midpoint of \( AC \) to \( B \) as follows:

1. **Length of Chord \( AC \):** The chord \( AC \) spans three sides of the octagon, so the angle \( \theta \) at the center of the octagon subtended by \( AC \) is \( \theta = 3 \times 45^\circ = 135^\circ \).

Using the radius \( R \) of the circumscribed circle, the length of chord \( AC \) is given by the Law of Cosines:

![AC = \sqrt{2R^2 - 2R^2\cos(135^\circ)}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{{\color{White}AC=\sqrt{2R^2&space;-&space;2R^2\cos(135^\circ)}}})

Since \( \cos(135^\circ) = -\frac{\sqrt{2}}{2} \), the expression simplifies to:

![AC = \sqrt{2R^2 + R^2\sqrt{2}}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{{\color{White}AC=\sqrt{2R^2&space;&plus;&space;R^2\sqrt{2}}}})
![AC = R\sqrt{2 + \sqrt{2}}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{{\color{White}AC=R\sqrt{2&space;&plus;&space;\sqrt{2}}}})

2. **Perpendicular from Midpoint of \( AC \) to \( B \):** Let \( M \) be the midpoint of \( AC \), and \( BM \) is the perpendicular we want to find. Triangle \( ABM \) is a right-angled triangle at \( M \) with \( AB = R \) and \( AM = \frac{AC}{2} \).

Using the Pythagorean theorem to solve for the height \( h \) (or \( BM \)):

![h^2 + (\frac{AC}{2})^2 = R^2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{{\color{White}h^2&space;&plus;&space;\left(\frac{AC}{2}\right)^2&space;=&space;R^2}})

Substituting \( AC \) from above:

![h = \sqrt{R^2 - (\frac{AC}{2})^2}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{{\color{White}h&space;=&space;\sqrt{R^2&space;-&space;\left(\frac{AC}{2}\right)^2}}})
![h = \sqrt{R^2 - \frac{R^2(2 + \sqrt{2})}{4}}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{{\color{White}h&space;=&space;\sqrt{R^2&space;-&space;\frac{R^2(2&space;&plus;&space;\sqrt{2})}{4}}}})
![h = \sqrt{\frac{2R^2 - R^2\sqrt{2}}{4}}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{{\color{White}{\color{White}h&space;=&space;\sqrt{\frac{2R^2&space;-&space;R^2\sqrt{2}}{4}}}}})
![h = \frac{R}{2}\sqrt{2 - \sqrt{2}}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{{\color{White}h&space;=&space;\frac{R}{2}\sqrt{2&space;-&space;\sqrt{2}}}})

Therefore, the length of the perpendicular from the midpoint of \( AC \) to \( B \) is \( h = \frac{R}{2}\sqrt{2 - \sqrt{2}} \).


![Equation y = d/2 √(2 + √2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}y=\frac{d}{2}\sqrt{2&plus;\sqrt{2}}})

![Equation h = d/4 √(2 - √2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}h=\frac{R}{2}\sqrt{2-\sqrt{2}}})


### Final Equations

Substituting `w` into the diagonal equation yields:

![Equation d^2 = s^2 + (s(1 + √2))^2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}d^{2}=s^{2}&plus;(s(1&plus;\sqrt{2}))^{2}})
<br>
![Equation d = s√(4 + 2√2)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{White}{\color{White}d=s\sqrt{4&plus;2\sqrt{2}}})

With these equations, we can solve for the diagonal length `d`, width `w`, and segment `x` given the side length `s` of a regular octagon.

- **Diagonal `d`:** ![Equation d = s√(4 + 2√2)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}d=s\sqrt{4&plus;2\sqrt{2}}})
- **Width `w`:** ![Equation w = s(1 + √2)](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}w=s(1&plus;\sqrt{2})})
- **Segment `x`:** ![Equation x = s / √2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}x=\frac{s}{\sqrt{2}}}\frac{}{})

## References:
[1] [mathcentral.uregina.ca 'quandaries & queries'](http://mathcentral.uregina.ca/QQ/database/QQ.09.20/h/sue2.html)
