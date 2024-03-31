use <utils_viz.scad>;
use <utils_points.scad>;
use <tess.scad>;
use <geo_tricho.scad>;

// TODO:
// remove everything related to the tricho geo and make a completely generalized version of this module
// evemtually, the snap_[geo] modules will be merged into this one by defining the geo as a parameter 
// and offloading the geo-specific stuff to that geo module

module snap(
    r, 
    ol, 
    h,
    centers_pts=undef, 
    lvls=undef,
    segments=undef,
    filter_points=undef,
    color_scheme=undef,
    clone_xyz=[0,0,0]
    ) {

    if(is_undef(centers_pts)){

        rad = r * sqrt(3) - ol;

        centers = hexagon_centers_lvls(radius=rad, levels=lvls);
        
        union(){
            hexagonsSolid(radius=rad, height=h, hexagon_centers=centers, color_scheme=color_scheme, alpha=1);
            
            color("DarkSlateBlue", alpha=0.5) 
            translate([0, 0, h]) 
            place_trichos_at_centers(centers=centers, r=r); 
        }
    cloneSnap(centers=centers, h=h, r=r, ol=ol, filter_pts=filter_points, color_scheme=color_scheme, clone_xyz=clone_xyz);
    } else {
        filtered_centers = filter_center_points(centers_pts, filter_points);

        row_h = point_row_height(centers_pts);
        
        rad = (row_h / 1.5);
        r = (rad + ol) / sqrt(3);

        union(){
            hexagonsSolid(radius=rad, height=h, hexagon_centers=filtered_centers, color_scheme=color_scheme, alpha=1);
            
            color("DarkSlateBlue", alpha=0.5) 
            translate([0, 0, h]) 
            place_trichos_at_centers(centers=filtered_centers, r=r); 
        }
        
        cloneSnap(centers=centers_pts, h=h, r=r, ol=ol, filter_pts=filter_points, color_scheme=color_scheme, clone_xyz=clone_xyz);
    }
}


module cloneSnap(centers, h, r, ol, filter_pts=undef, color_scheme=undef, clone_xyz=undef){
    rad = r * sqrt(3) - ol;

    tri_centers = triangulated_center_points(centers);
    if(!is_undef(filter_pts)){
        tri_centers = filter_triangulated_center_points(((r+ ol) / sqrt(3)*4), tri_centers, filter_pts);
    }
    
    translate([clone_xyz[0],clone_xyz[1],clone_xyz[2]]) 
    rotate([180, 0, 0])
    union(){
        hexagonsSolid(radius=rad, height=h, hexagon_centers=tri_centers, color_scheme=color_scheme, alpha=1);
        
        color("DarkSlateGray", alpha=0.5) 
        translate([0, 0, h]) 
        place_trichos_at_centers(centers=tri_centers, r=r); 
    }

}