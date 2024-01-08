use <viz-utils.scad>;
use <point-utils.scad>;
use <hexagons_tess.scad>;
use <tricho_geo.scad>;


module snap(
    lvls, ol, 
    h,
    r=undef, 
    centers_pts=undef, 
    beta_angle=undef, alpha_angle=undef, omega_angle=undef, 
    beta_height=undef, alpha_height=undef, omega_height=undef, inter_height=undef, 
    segments=undef,
    filter_points=undef,
    color_scheme=undef,
    clone_xyz=undef
    ) {


    filtered_centers = filter_center_points(centers_pts, filter_points);

    if(is_undef(centers_pts)){

        rad = r * sqrt(3) - ol;

        beta_angle = is_undef(beta_angle) ? 90 : beta_angle;
        alpha_angle = is_undef(alpha_angle) ? 30 : alpha_angle;
        omega_angle = is_undef(omega_angle) ? 60 : omega_angle;

        segments = is_undef(segments) ? 6 : segments;
        
        beta_height = is_undef(beta_height) ? (r / 2) : beta_height;
        alpha_height = is_undef(alpha_height) ? ( r / 3) : alpha_height;
        omega_height = is_undef(omega_height) ? (r * 2 / 3) : omega_height;
        inter_height = is_undef(inter_height) ? (r / 10) : inter_height;

        centers = hexagon_centers(radius=rad, levels=lvls);
        
        union(){
            echo("Centers: ", centers);
            hexagonsSolid(radius=rad, height=h,hexagon_centers=centers, color_scheme=color_scheme, alpha=1);
            
            color("blue", alpha=0.5) 
            place_trichos_at_centers(centers=centers, r=r, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
                    alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height); 
        }
            cloneSnap(centers=centers, r=r, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
                    alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height, lvls=lvls, ol=ol, clone_xyz=clone_xyz);

    } else {

        row_h = point_row_height(centers_pts);
        
        rad = (row_h / 1.5);

        r = (rad + ol) / sqrt(3);


        beta_angle = is_undef(beta_angle) ? 90 : beta_angle;
        alpha_angle = is_undef(alpha_angle) ? 30 : alpha_angle;
        omega_angle = is_undef(omega_angle) ? 60 : omega_angle;

        segments = is_undef(segments) ? 6 : segments;
        
        beta_height = is_undef(beta_height) ? (r / 2) : beta_height;
        alpha_height = is_undef(alpha_height) ? ( r / 3) : alpha_height;
        omega_height = is_undef(omega_height) ? (r * 2 / 3) : omega_height;
        inter_height = is_undef(inter_height) ? (r / 10) : inter_height;



        union(){
            //("Centers: ", centers_pts);
            hexagonsSolid(radius=rad, height=h, hexagon_centers=filtered_centers, color_scheme=color_scheme, alpha=1);
            
            color("DarkSlateBlue", alpha=0.5) 
            translate([0, 0, h]) 
            place_trichos_at_centers(centers=filtered_centers, r=r, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
                    alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height); 
        }
            cloneSnap(centers=centers_pts, h=h, r=r, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
                    alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height, lvls=lvls, ol=ol, filter_pts=filter_points, color_scheme=color_scheme, clone_xyz=clone_xyz);

    }

}


module cloneSnap(centers, h, r, beta_angle, beta_height, alpha_angle, alpha_height, omega_angle, omega_height, inter_height, lvls, ol, filter_pts=undef, color_scheme=undef, clone_xyz=undef){
    rad = r * sqrt(3) - ol;

    tri_centers = triangulated_center_points(centers);
    filtered_tri_centers = filter_triangulated_center_points(((r+ ol) / sqrt(3)*4), tri_centers, filter_pts);
    
    default_z_offs = 2*h+beta_height+alpha_height+omega_height+inter_height;

    translate([clone_xyz[0],clone_xyz[1],clone_xyz[2]+default_z_offs]) 
    rotate([180, 0, 0])
    union(){
        //echo("Triangulated Centers:", tri_centers);
        hexagonsSolid(radius=rad, height=h, hexagon_centers=filtered_tri_centers, color_scheme=color_scheme, alpha=1);

        color("DarkSlateGray", alpha=0.5) 
        translate([0, 0, h]) 
        place_trichos_at_centers(centers=filtered_tri_centers, r=r, beta_angle=beta_angle, beta_height=beta_height, alpha_angle=alpha_angle, 
                alpha_height=alpha_height, omega_angle=omega_angle, omega_height=omega_height, inter_height=inter_height); 
    }

}

