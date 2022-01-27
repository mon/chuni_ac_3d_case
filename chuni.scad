$fn=32;

// this makes rendering take like 5 minutes
slow_penguin = true;

// bottom overlap is more like 3.5mm so just be real fuckin
// cheeky and use this for all the walls
wall_thick = 3.5;

acrylic_thick = 3.2;
metal_thick = 1.4;

rib_strength = 1.2;
rib_height = 4;
rib_x = 5;
rib_y = 6;

// for the pengiiiiin
layer_height = 0.28;

con_width = 700;
con_height = 170;
con_depth = 40.5 + acrylic_thick + metal_thick;

// not explicitly for IO but may as well use it
io_hole_x_start = 40;
io_hole_x_end = 135;
io_hole_y_start = 9;
io_hole_y_end = 23;
io_total= 21.5; // the piece of metal itself

height_before_angle = 113;
angle = 45;

overlap_leadin = 5;
side_overlap = 10;
bottom_overlap = 5;
// no top overlap

hole_size = 6; // M5 but I don't trust my hole locations
// y is offset from con top
holes_xy = [
    [116.5, 96],
    [173, 39],
];

air_strings_offset = 10; // from start of `angle`
air_strings_filler = 8; // to stop the plastic cracking
air_strings_wire_channel = 12; // height
// actually 33 but doesn't need to be so big
air_strings_wire_channel_x = 30;
air_strings_angle = 20;
air_holes_normal = 6;
air_holes_bigger = 12; // more like 10mm but whatever

// the screw attaching it to the case
air_strings_screw = 4;
air_strings_attach = [
    [19.05,468.1],
    [19.05*5,455.4],
];
// the nut, [width, depth]
air_strings_nut = [7.8,3];

// mirror, but keeps the original
module reflect(xyz) {
    children();
    mirror(xyz)
    children();
}

module im_gonna_put_holes_in_you(both=true) {
    reflect([both ? 1 : 0,0,0])
    for(hole = holes_xy) {
        translate([
            -con_width/2 + hole.x,
            con_height - hole.y
        ])
        circle(d=hole_size);
    }
}

module main_2d(holes = false) {
    w = con_width+wall_thick*2;
    h = con_height+wall_thick*2;
    
    difference() {
        translate([-w/2,0])
        square([w,h]);
        
        reflect([1,0,0])
        translate([-w/2, h-height_before_angle])
        rotate([0,0,-angle])
        mirror([0,1,0]) // flip it to face down
        square([w,w]);
        
        if(holes) {
            im_gonna_put_holes_in_you();
        }
    }
}

// lots of warping otherwise thanks to the weight of the airs
// and there being only 2 screws to mount the thing
module ribs(height, scale = 1.0) {
    rib_start = [-con_width/2, wall_thick];
    // little past the screws
    rib_end = [
        rib_start.x + holes_xy[1].x + 10,
        rib_start.y + con_height
    ];
    
    sz = [rib_end.x-rib_start.x, rib_end.y-rib_start.y];
    increment = [sz.x/rib_x, sz.y/rib_y];
    
    difference() {
        intersection() {
            linear_extrude(height+0.1)
            main_2d();
            
            linear_extrude(height+0.1)
            translate(rib_start)
            square(sz);
            
            union() {
                for(x = [1:rib_x]) {
                    x_off = x * increment.x + rib_start.x;
                    translate([
                        x_off - rib_strength,
                        rib_start.y + con_height/2])
                    linear_extrude(height, scale=scale)
                    square([rib_strength, con_height], center=true);
                }
                for(y = [1:rib_y]) {
                    y_off = y * increment.y + rib_start.y;
                    translate([
                        rib_start.x,
                        y_off - rib_strength])
                    linear_extrude(height, scale=scale)
                    square([con_width, rib_strength], center=true);
                }
            }
        }
        // avoid the mounting plates
        linear_extrude(height+0.1)
        offset(delta=11)
        hull()
        im_gonna_put_holes_in_you(both=false);
        
        // clear the entry for the wiring
        air_translate()
        linear_extrude(46)
            translate([78.88,480.8])
            rotate([0,0,180])
            // make it bigger than moldy
            square([25.4,19.05] + [5,5]);
    }
}

module main_box(pengy = true) {
    w = con_width+wall_thick*2;
    h = con_height+wall_thick*2;
    
    difference() {
        union() {
            // main box
            difference() {
                linear_extrude(con_depth)
                main_2d(holes = true);
                
                translate([0,0,wall_thick])
                linear_extrude(con_depth)
                offset(delta = -wall_thick)
                main_2d();
            }
            
            // strength
            reflect([1,0,0])
            translate([0,0,wall_thick-0.01])
            ribs(rib_height, scale = 0.5);
        }
        
        translate([0,0,-0.01])
        air_holes();
        
        // cutout the bit at the top since it's flush
        translate([
            -con_width/2,
            con_height+wall_thick/2,
            con_depth - io_total,
        ])
        cube([con_width, wall_thick*2, io_total*2]);
        
        // cutout the angled bits cause the metal goes all
        // the way
        translate([0,0,con_depth - metal_thick])
        linear_extrude(metal_thick*2)
        reflect([1,0,0])
        translate([-w/2, h-height_before_angle])
        rotate([0,0,-angle])
        mirror([0,1,0]) // flip it to face down
        translate([0,-wall_thick*1.5])
        // this is really just eyeballed
        square([90,wall_thick*2]);
        
        if(pengy && slow_penguin) {
            translate([-250,-130,-0.01])
            linear_extrude(layer_height)
            mirror([1,0,0])
            import("Chuni_Penguin.svg");
        }
    }
}

module air_translate() {
    w = con_width+wall_thick*2;
    h = con_height+wall_thick*2;
    
    translate([-w/2, h-height_before_angle])
    rotate([90,-180,90])
    translate([-114.3,-480.8,-air_strings_filler])
    children();
}

module air_translate_2d() {
    rotate([0,0,90])
    translate([0,-480.8])
    children();
}

// this is the left air string, mirror for right
module air() {
    linear_extrude(air_strings_filler)
    difference() {
        union() {
            import("quarter inch/wall 1_flat.svg");
            
            // fill in the old holes
            translate([138,327])
            circle(d=18);
            
            translate([254.5,18.7])
            circle(d=18);
            
            translate([180.2,54.35])
            rotate([0,0,60/2])
            circle(d=7);
            
        }
        
        // moldy hole was wrong
        translate([139.5,326.5])
        circle(d=air_holes_bigger);
        
        translate([254+3,18+2.5])
        circle(d=air_holes_bigger);
        
        translate([183,52.6])
        circle(d=air_holes_normal);
        
        // width is too high for my tastes
        rotate(air_strings_angle+0.9)
        translate([156,-60])
        square([22, 2000]);
    }
    
    // this routes the cable, and also provides some strength
    mirror([0,0,1]) // goes out the back
    linear_extrude(air_strings_wire_channel)
    intersection() {
        import("quarter inch/wall 1_flat.svg"); // clip it
        
        // ugh, has to be tweaked
        rotate([0,0,air_strings_angle-2.4])
        
        difference() {
            base = [184,215];
            l = 200;
            translate(base)
            square([air_strings_wire_channel_x, l]);
            
            translate(base + [wall_thick,0])
            square([air_strings_wire_channel_x-wall_thick*2, l]);
            
            // just lazy cutoff
            translate([0,-100 + 15])
            translate(base)
            square([air_strings_wire_channel_x, 100]);
        }
    }
}

module airs() {
    reflect([1,0,0])
    air_translate()
    air();
}

module air_holes() {
    reflect([1,0,0])
    air_translate()
    linear_extrude(air_strings_filler + wall_thick*2)
    union() {
        for(hole = air_strings_attach) {
            translate(hole)
            circle(d=air_strings_screw+0.5);
        }
        
        translate([78.88,480.8])
        rotate([0,0,180])
        // make it bigger than moldy
        square([25.4,19.05] + [5,5]);
    }
    
    reflect([1,0,0])
    translate([air_strings_filler + (wall_thick-air_strings_nut[1]),0])
    air_translate()
    linear_extrude(air_strings_filler + wall_thick*2)
    union() {
        for(hole = air_strings_attach) {
            translate(hole)
            circle(d=air_strings_nut[0], $fn=6);
        }
    }
    
    // extra bit in case your connector goes in upside down
    reflect([1,0,0])
    translate([con_width/2,108])
    mirror([1,0,0])
    cube([12,13,con_depth]);
}

// so it fits on the printer
module air_splitter() {
    translate([0,0,-500])
    linear_extrude(1000)
    rotate([0,0,air_strings_angle])
    translate([0,-150])
    square([280,300]);
}

op = "render";
//op = "air";
//op = "air_top";
//op = "air_bottom";
//op = "case_left";
//op = "case_right";

//op = "";
//ribs();

if(op == "render") {
    main_box();
    airs();
} else if(op == "case_left" || op == "case_right") {
    w = con_width+wall_thick*2;
    
    mirror([op == "case_right" ? 1 : 0,0])
    intersection() {
        translate([w/2,0])
        main_box(pengy = (op == "case_left"));
        
        cube([200,200,con_depth]);
    }
} else if(op == "air") {
    air_translate_2d()
    air();
} else if(op == "air_top") {
    difference() {
        air_translate_2d()
        air();
        
        air_splitter();
    }
} else if(op == "air_bottom") {
    intersection() {
        air_translate_2d()
        air();
        
        air_splitter();
    }
}