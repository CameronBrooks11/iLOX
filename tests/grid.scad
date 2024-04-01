use <..\src\snap.scad>;
use <..\src\tess.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 2.4;
overlap = 0.2;
substrate_height = 1;
n=3;
m=3;

gap = 3;

ani = 5 + gap * (1 + sin($t * 360)); // Use sine function for smooth up and down animation (30-60 fps at 60 steps is good)
xyz = [0, 0, ani];

gen_centers = hexagon_centers_NxM(radius=radius, n=n, m=m);
//print_points(gen_centers, text_size=0.2, color="Azure");

snap(
    r=radius, 
    ol=overlap, 
    h=substrate_height, 
    centers_pts=gen_centers, 
    n=n,
    m=m,
    clone_xyz=xyz);