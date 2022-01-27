use <cherry_mx.scad>
// https://github.com/adrianschlatter/threadlib
use <threadlib/threadlib.scad>

stl = true;

$fn = 64;

hole_d = 12;
hole_flat = 11;
metal_thick = 1.4;
acrylic_d = 20 - 1;
// the hole in the acrylic is off center, this is what the orig uses
button_d = 16;

min_clearance = 3; // the switch is bigger than acrylic_d

interface = 2;

// little higher than metal just for clearance
raise = 0.2;

// must be at least 5 or switch collides
switch_height = 8 + raise + interface;

module switch_hole(expansion = false) {
    // from Cherry MX data sheet
    holesize = 14;

    translate([-holesize/2, -holesize/2])
    square([holesize,holesize]);

    // expansion for inner layers so the clips have something to grab
    if(expansion) {
        expand_hole = [5, 15];
        translate(-expand_hole/2)
        square(expand_hole);
    }
}

module plate() {
    translate([0,0,-metal_thick])
    linear_extrude(metal_thick)
    difference() {
        square([50,50], center=true);
        
        intersection() {
            circle(d=hole_d);
            square([hole_d, hole_flat], center=true);
        }
    }
}


module thread() {
    height = 50; // tune depending on turns
    
    rotate([180,0,0])
    difference() {
        intersection() {
            bolt("M12x0.75", turns=10);
            
            linear_extrude(height)
            square([hole_d, hole_flat-0.8], center=true);
        }
        
        // for switch wires to get through
        translate([0,0,-0.01])
        cylinder(height, d=7);
    }
}

if(!stl)
%plate();

need_d = 2 * sqrt(2 * 7*7) + min_clearance;
top_d = (need_d > acrylic_d) ? need_d : acrylic_d;

// off center cutout
translate([0,-1]) {
    if(!stl)
    translate([0,0,switch_height - 5])
    cherry_mx_model();
    
    difference() {
        hull() {
            linear_extrude(0.01)
            circle(d=acrylic_d);
            
            translate([0,0,switch_height - 0.01])
            linear_extrude(0.01)
            square(14+min_clearance, center=true);
        }
        //cylinder(h=switch_height, d1=acrylic_d, d2=top_d);
        
        translate([0,0,interface-0.01])
        linear_extrude(switch_height+0.02)
        switch_hole();
        
        translate([0,0,switch_height-3])
        // should be -1 but give us plenty
        linear_extrude((switch_height-0.8)-(switch_height-3))
        switch_hole(expansion=true);
        
        translate([0,1,-0.01])
        cylinder(h=interface+1, d=7);
    }
}

thread();