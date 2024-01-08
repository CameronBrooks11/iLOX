use <..\src\hexagons_tess.scad>;
use <..\src\snap_hex.scad>;
use <..\src\viz-utils.scad>;
use <..\src\point-utils.scad>;

// Params
radius = 1.5;
levels1 = 3;
overlap = 0.2;

// Example 1
snap(lvls=levels1, r=radius, ol=overlap);