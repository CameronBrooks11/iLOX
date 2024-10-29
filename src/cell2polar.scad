// Takes a cell pair and an optional anti-cell pair and returns the volume of the cell minus the volume of the anti-cell
// to create the effecitve 3D representation of the cell pair. The anti-cell pair is optional and can be used to create
// voids in the cell pair. the radius will be the distance from the center of the +/-y axis to the edge of the cell to
// the largest x value in the cell division. To restore the relative positioning of the cells including the tolerance,
// the cells must be translated such that they are positioned relative to their apothem rather than their radius. This
// is done by translating the cells by the difference between the apothem and the radius.

// Function to calculate the apothem from the radius and number of sides
function apothem(R, n) = R * cos(180 / n);

// Function to find the numerical difference between the radius and the apothem
function radius_apothem_diff(R, n) = R - apothem(R, n);

// Function to calculate the full central angle of a regular polygon
// This is the angle between two vertices
function central_angle(n) = 360 / n;

// Function to calculate the half central angle of a regular polygon
// This is the angle between the vertice and the midpoint of a side
// This is useful for rotating the polygon to align with the x-axis
function half_central_angle(n) = central_angle(n) / 2;

// Module to render the cells with optional colors
module cells2polarpos(cells, n, radius, colors = [ "Green", "Blue" ])
{
    n = n;
    echo("n: ", n);
    echo("radius: ", radius);
    echo("cells[0]: ", cells[0]);
    echo("cells[1]: ", cells[1]);
    echo("cells[2]: ", cells[2]);
    echo("cells[3]: ", cells[3]);

    // Calculate the apothem 
    apo = apothem(radius, n);

    // First shape ('a' cell)
    color(colors[0]) translate([ 0, 0, 0 ]) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n) difference()
    {
        polygon(points = cells[0]);
        polygon(points = cells[2]);
    }

    // Second shape ('b' cell)
    color(colors[1]) translate([ apo*2, 0, 0 ]) rotate([ 0, 0, half_central_angle(n) ])
        rotate_extrude($fn = n) translate([ -radius * 2, 0, 0 ]) difference()
    {
        polygon(points = cells[1]);
        polygon(points = cells[3]);
    }
}

module cellA2polar(cells, n, radius, color = "Green")
{
    color(color) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n) difference()
    {
        polygon(points = cells[0]);
        polygon(points = cells[2]);
    }
}

module cellB2polar(cells, n, radius, color = "Blue")
{
    color(color) rotate([ 0, 0, half_central_angle(n) ]) rotate_extrude($fn = n) translate([ -radius * 2, 0, 0 ])
        difference()
    {
        polygon(points = cells[1]);
        polygon(points = cells[3]);
    }
}

// Module to place either cellA2polar or cellB2polar at given positions
module place_polar_cells(cells, positions, n, radius, rotate = false, cell_type="A", color="CadetBlue") {
    // Iterate over the array of positions and place a cell at each point
    rot = rotate ? half_central_angle(n) : 0;
    for (pos = positions) {
        translate([pos[0], pos[1], 0]) rotate([ 0, 0, rot ]) {
            if (cell_type == "A") {
                cellA2polar(cells = cells, n = n, radius = radius, color = color);
            } else if (cell_type == "B") {
                cellB2polar(cells = cells, n = n, radius = radius, color = color);
            }
        }
    }
}