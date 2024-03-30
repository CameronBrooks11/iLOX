use <..\src\snap.scad>;
use <..\src\tess.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 2;
overlap = 0.1;
substrate_height = 1;
levels = 3;

stem_height = 2;

color_scheme="scheme1";

gap = 5;
ani = gap * (1 + sin($t * 360)); // Use sine function for smooth up and down animation (30-60 fps at 60 steps is good)

// Positioning of generated side
xyz = [0, 0, ani];

// Constant to control overlap, needs to be functionized
rad = radius * sqrt(3) - overlap;

// Filter points to remove the first 2 levels
filter_points_levels = [
    [0,0]
];

gen_centers = hexagon_centers_lvls(radius=rad, levels=levels);
//print_points(gen_centers, text_size=0.2, color="Azure");

snap(
    lvls=levels, ol=overlap, h=substrate_height, 
    centers_pts=gen_centers,
    beta_height = stem_height, color_scheme=color_scheme, clone_xyz=xyz);