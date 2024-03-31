use <..\src\tess.scad>;
use <..\src\snap.scad>;
use <..\src\utils_viz.scad>;
use <..\src\utils_points.scad>;

// Params
radius = 1.5;
levels = 3;
overlap = 0.2;
substrate_thickness = 1;
z_shift=8;

// Example 1
snap(lvls=levels, r=radius, ol=overlap, h=substrate_thickness, clone_xyz=[0,0,z_shift]);