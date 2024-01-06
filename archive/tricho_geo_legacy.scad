// Example usage of customCylinder.scad
//customCylinder(r1 = 10, r2 = 20, height = 25, $fn=6);
//customCylinder(r1 = 10, r2 = 20, hypotenuse = 30, $fn=6);
//customCylinder(r1 = 10, angle = 90, height = 20, $fn=6);

// params

//stemHeight = 0.75;
//stemRadius= 0.75;
//capRadius = 1.5;
//capScale = 3/4;
//annulusHeight = 0.40;
//baseHeight = 0.75;
//baseRadius = stemRadius*3;
//z_fite = 0.05;
//flatCapRatio=0;
//
////lock array params
//n=3;
//m=3;
//capMulti=4/3;

stem_radius = 0.75;
stem_height = 1.00; //later will be auto calc with tol from head

cap_radius1 = 1.5;
cap_height_1 = 0.5;
cap_height_1_1 = 0.2;

cap_radius2 = 0.75;
cap_height_1_2 = 1.25;
echo("stem");
translate([0,0,0]) customCylinder(r1 = stem_radius, r2 = stem_radius, height = stem_height, $fn=6);
echo("stem-1");
translate([0,0,stem_height]) customCylinder(r1 = stem_radius, r2 = cap_radius1, height = cap_height_1, $fn=6);
echo("1-1");
translate([0,0,stem_height+cap_height_1]) customCylinder(r1 = cap_radius1, r2 = cap_radius1, height = cap_height_1_1, $fn=6);
echo("1-2");
translate([0,0,stem_height+cap_height_1+cap_height_1_1]) customCylinder(r1 = cap_radius1, r2 = cap_radius2, height = cap_height_1_2, $fn=6);

// --------------------------------------------------------------------
// customCylinder allows for the definition of the hypotenuse and angle
// --------------------------------------------------------------------
// Function to calculate height from hypotenuse, r1, and r2
function calculateHeightFromHypotenuse(r1, r2, hypotenuse) = sqrt(hypotenuse^2 - (r2 - r1)^2);

// Function to calculate height from r1, r2, and angle
function calculateHeightFromAngle(r1, r2, angle) = 
    let(norm_angle = angle % 180)
    norm_angle < 90
        ? (r2 - r1) / tan(abs(90 - norm_angle))
        : (r1 - r2) / tan(norm_angle);

// Function to calculate r2 from angle, r1, and height
function calculateR2FromAngle(angle, r1, height) = 
    let(norm_angle = angle % 90)
    angle < 90
        ? r1 + (tan(abs(90 - norm_angle)) * height)  // Increase r2 for angles less than 90
        : r1 - (tan(norm_angle) * height);  // Decrease r2 for angles between 90 and 180

// Function to calculate angle from r1, r2, and height
function calculateAngleFromDimensions(r1, r2, height) =
    r2 > r1
        ? 90 - atan(abs(r2 - r1) / height)
        : 90 + atan(abs(r1 - r2) / height);

// Custom cylinder function
module customCylinder(r1, r2 = undef, height = undef, hypotenuse = undef, angle = undef, $fn=$fn) {
    local_angle = angle;
  
    if (hypotenuse != undef && r2 != undef && height == undef) {
        // Height is calculated from hypotenuse
        local_height = calculateHeightFromHypotenuse(r1, r2, hypotenuse);
        local_angle = local_angle != undef ? local_angle : calculateAngleFromDimensions(r1, r2, local_height);
        echo("Final parameters: height = ", local_height, ", r1 = ", r1, ", r2 = ", r2, ", angle = ", local_angle);
        cylinder(h = local_height, r1 = r1, r2 = r2, $fn=$fn);
    } 
    else if (angle != undef && height != undef && r2 == undef) {
        // r2 is calculated from angle
        local_r2 = calculateR2FromAngle(angle, r1, height);
        echo("Final parameters: height = ", height, ", r1 = ", r1, ", r2 = ", local_r2, ", angle = ", angle);
        cylinder(h = height, r1 = r1, r2 = local_r2, $fn=$fn);
    }
    else if (height != undef && r1 != undef && r2 != undef) {
        // All parameters are defined, create the cylinder
        local_angle = local_angle != undef ? local_angle : calculateAngleFromDimensions(r1, r2, height);
        echo("Final parameters: height = ", height, ", r1 = ", r1, ", r2 = ", r2, ", angle = ", local_angle);
        cylinder(h = height, r1 = r1, r2 = r2, $fn=$fn);
    }
    else {
        echo("Error: Insufficient parameters to define the cylinder.");
    }
}