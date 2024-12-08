
use <../src/utils.scad>; // Utility functions for point operations

// Variables for arc parameters
arc_diameter = 20;
arc_start_angle = 90;
arc_end_angle = -90;
arc_num_points = 90;
arc_tolerance = 0.1;

// Generate the arc points
arc_points_list = arc_points(diameter = arc_diameter, start_angle = arc_start_angle, end_angle = arc_end_angle,
                             num_points = arc_num_points, z_val=arc_tolerance);

arc_shift_x = 10;
arc_shift_y = 10;

shifted_arc_points_list = shift_points(points = arc_points_list, shift_x = arc_shift_x, shift_y = arc_shift_y);

// Echo the resulting arc points
echo(shifted_arc_points_list);

// Place spheres at the generated arc points
place_spheres(points = shifted_arc_points_list,
              d = 0.1,         // Diameter of each sphere
              color = "Green", // Color of the spheres
              fn = 12          // Number of facets for sphere smoothness
);
