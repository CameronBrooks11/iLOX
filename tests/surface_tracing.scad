use <..\src\snap.scad>;
use <..\src\geo_tricho.scad>;
use <..\src\tess.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 10;
substrate_height = 2*10;
levels = 3;

gen_centers = hexagon_centers_lvls(radius=radius, levels=levels);

hexagonsSolid(radius=radius, height=substrate_height, hexagon_centers=gen_centers, color_scheme="scheme1", alpha=1);
