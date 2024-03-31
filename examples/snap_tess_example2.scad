use <..\src\snap.scad>;
use <..\src\tess.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 2;
overlap = 0.1;
substrate_height = 1;
levels = 3;

color_scheme="scheme1";

gap = 2;
ani = 5 + gap * (1 + sin($t * 360)); // Use sine function for smooth up and down animation (30-60 fps at 60 steps is good)
xyz = [0, 0, ani];

// Constant to control overlap, needs to be functionized
rad = radius * sqrt(3) - overlap;

gen_centers = hexagon_centers_lvls(radius=rad, levels=levels);
//print_points(gen_centers, text_size=0.2, color="Azure");

snap(
    r=rad, 
    ol=overlap, 
    h=substrate_height, 
    lvls=levels, 
    centers_pts=gen_centers, 
    color_scheme=color_scheme, 
    clone_xyz=xyz);