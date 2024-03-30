use <..\src\tess_hex.scad>;
use <..\src\snap_hex.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 1.5;
overlap = 0.2;
substrate_height = 1;
levels2 = 5;

stem_height = .9;

color_scheme="scheme1";

gap = 3;
ani = gap * (1 + sin($t * 360)); // Use sine function for smooth up and down animation (30-60 fps at 60 steps is good)

// Positioning of generated side
xyz = [0, 0, ani];

// Constant to control overlap, needs to be functionized
rad = radius * sqrt(3) - overlap;

// Filter points to remove the first 2 levels
filter_points_levels = [
    [0,0], 

    [-2.07679, -3.59711],
    [4.15359, 0], [2.07679, 3.59711],
    [-4.15359, 0], [-2.07679, 3.59711],
    [2.07679, -3.59711],
];

gen_centers = hexagon_centers(radius=rad, levels=levels2);
//print_points(gen_centers, text_size=0.2, color="Azure");

snap(
    lvls=levels2, ol=overlap, h=substrate_height, 
    centers_pts=gen_centers,
    beta_height = stem_height,
    filter_points=filter_points_levels, color_scheme=color_scheme, clone_xyz=xyz);