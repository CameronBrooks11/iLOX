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

Using the side length \( s \) of the octagon, the length of chord \( AC \) is given by the Law of Cosines:

![AC = \sqrt{s^2 + s^2 - 2s^2\cos(135^\circ)}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{AC=\sqrt{s^2&space;&plus;&space;s^2&space;-&space;2s^2\cos(135^\circ)}})

Since \( \cos(135^\circ) = -\frac{\sqrt{2}}{2} \), we can substitute this value into the equation:

![AC = \sqrt{2s^2 + 2s^2(-\frac{\sqrt{2}}{2})}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{AC=\sqrt{2s^2&space;&plus;&space;2s^2\left(-\frac{\sqrt{2}}{2}\right)}})

This simplifies to:

![AC = s\sqrt{2 - \sqrt{2}}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{AC=s\sqrt{2&space;-&space;\sqrt{2}}})

2. **Perpendicular from Midpoint of \( AC \) to \( B \):** Let \( M \) be the midpoint of \( AC \), and \( BM \) is the perpendicular we want to find. Triangle \( ABM \) is an isosceles triangle with two sides of length \( s \) (the side length of the octagon) and base \( AC \). The perpendicular \( BM \) will bisect \( AC \) and create two right-angled triangles within \( ABM \).

Using the Pythagorean theorem in one of these right-angled triangles, where \( BM \) is the height \( h \), \( AM \) is half the base, and \( AB \) is the hypotenuse:

![h^2 + (AM)^2 = s^2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{h^2&space;&plus;&space;(AM)^2&space;=&space;s^2})

Since \( AM \) is half of \( AC \), we have:

![AM = \frac{AC}{2} = \frac{s\sqrt{2 - \sqrt{2}}}{2}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{AM&space;=&space;\frac{AC}{2}&space;=&space;\frac{s\sqrt{2&space;-&space;\sqrt{2}}}{2}})

Now we can find \( h \) by substituting \( AM \) into the Pythagorean theorem:

![h = \sqrt{s^2 - (AM)^2}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{h&space;=&space;\sqrt{s^2&space;-&space;(AM)^2}})

Substituting \( AM \) from above, we get:

![h = \sqrt{s^2 - (\frac{s\sqrt{2 - \sqrt{2}}}{2})^2}](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{h&space;=&space;\sqrt{s^2&space;-&space;\left(\frac{s\sqrt{2&space;-&space;\sqrt{2}}}{2}\right)^2}})

Solving for \( h \) gives us the length of the perpendicular from the midpoint of \( AC \) to \( B \).


Therefore, the length segment AC and that of the perpendicular from the midpoint of \( AC \) to \( B \) is:


![Equation y = d/2 √(2 + √2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}y=\frac{d}{2}\sqrt{2&plus;\sqrt{2}}})

![Equation h = d/4 √(2 - √2](https://latex.codecogs.com/svg.image?\inline&space;\LARGE&space;\bg{white}{\color{White}h=\frac{d}{4}\sqrt{2-\sqrt{2}}})


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
