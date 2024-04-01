use <..\src\snap.scad>;
use <..\src\geo_tricho.scad>;
use <..\src\tess.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 2.4;
overlap = 0.2;
substrate_height = 3;
levels = 3;

r = (radius + overlap) / sqrt(3);

gap = 2;
ani = 5 + gap * (1 + sin($t * 360)); // Use sine function for smooth up and down animation (30-60 fps at 60 steps is good)
xyz = [0, 0, ani];

gen_centers = hexagon_centers_lvls(radius=radius, levels=levels);
//print_points(gen_centers, text_size=0.2, color="Azure");

// from: https://www.researchgate.net/publication/346730095/figure/fig1/AS:1083887929303061@1635430428214/Dimensions-of-the-tensile-test-specimen-ASTM-D638-type-I.jpg
connection_width=19;
connection_length=165;

// Determine the range of the center points for normalization
min_x = min([for(center = gen_centers) center[0]]);
max_x = max([for(center = gen_centers) center[0]]);
min_y = min([for(center = gen_centers) center[1]]);
max_y = max([for(center = gen_centers) center[1]]);


color("DarkSlateBlue", alpha=1) 
union() {
    union(){
        hexagonsSolid(radius=radius, height=substrate_height, hexagon_centers=gen_centers, alpha=1);
        translate([0, 0, substrate_height]) 
        place_trichos_at_centers(centers=gen_centers, r=r); 
    }

    linear_extrude(height = substrate_height) 
    polygon(
        points=[
            [-connection_length/2, connection_width/2],
            [-connection_length/2, -connection_width/2],        
            [min_x, min_y],
            [0, min_y],
            [0, max_y],
            [min_x, max_y],
        ]);
}

/*
color("DarkSlateGray", alpha=1) 
union() {
    translate([0, 0, substrate_height]) 
    cloneSnap(centers=gen_centers, h=substrate_height, r=r, ol=overlap,  clone_xyz=xyz);

    translate([0, 0, xyz[2]]) 
    linear_extrude(height = substrate_height) 
    polygon(
        points=[
            [0, min_y],
            [max_x, min_y],
            [connection_length/2, -connection_width/2],
            [connection_length/2, connection_width/2],  
            [max_x, max_y],
            [0, max_y]
        ]);
}
        



*/