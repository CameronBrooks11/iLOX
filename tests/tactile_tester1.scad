use <..\src\snap.scad>;
use <..\src\geo_tricho.scad>;
use <..\src\tess.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 10;
overlap = 0.5;
substrate_height = 3;
levels = 3;

r = (radius + overlap) / sqrt(3);

gap = 30;
ani = gap * (1 + sin($t * 360)); // Use sine function for smooth up and down animation (30-60 fps at 60 steps is good)
clone_xyz = [0, 0, ani];

gen_centers = hexagon_centers_lvls(radius=radius, levels=levels);
//print_points(gen_centers, text_size=0.2, color="Azure");

connection_width=19;
connection_length=165;

// Determine the range of the center points for normalization
min_x = min([for(center = gen_centers) center[0]]);
max_x = max([for(center = gen_centers) center[0]]);
min_y = min([for(center = gen_centers) center[1]]);
max_y = max([for(center = gen_centers) center[1]]);
  
/*
union() {
    hexagonsSolid(radius=radius, height=substrate_height, hexagon_centers=gen_centers, alpha=1);
    translate([0, 0, substrate_height]) 
    place_trichos_at_centers(centers=gen_centers, r=r, beta_height=r*3/4); 
}
*/

tri_centers = triangulated_center_points(gen_centers);

translate([clone_xyz[0],clone_xyz[1],clone_xyz[2]]) 
rotate([180, 0, 0])
union(){
    hexagonsSolid(radius=radius, height=substrate_height, hexagon_centers=gen_centers, alpha=1);

    translate([0, 0, substrate_height]) 
    place_trichos_at_centers(centers=tri_centers, r=r, beta_height=r*3/4); 
}
