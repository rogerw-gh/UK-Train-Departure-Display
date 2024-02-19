/*
Revisions by rogerw-gh to make case and display building easier.
*/
view_part = 0; //[0:front,1:frame]

/* [Hidden] */

$fa = 1;
$fs = 0.4;
cd =0.1;
pa = 0.3;
front_x = 100;
front_y = 38;
front_z = 15.5;
back_x = 97.5;
back_y = 34.5;
screw_hole_x = 4;
screw_hole_y = 3;
hole_x_pitch = back_x - 2*screw_hole_x;
hole_y_pitch = back_y - 2*screw_hole_y;
screw_hole_dia = 2+pa;
bolt_round = 40;


if (view_part == 0 ) new_front ();
    
if (view_part == 1 ) new_frame ();
    
module frame_legs () {
    difference () {
       union () {
           //two legs
        translate ([25,front_y-1,front_z/2-5])
            cube ([6,10,6]);
        translate ([70,front_y-1,front_z/2-5])
            cube ([6,10,6]);
           //base
        translate ([22,front_y+8.5,0])
            cube ([56,2,front_z-3]);
        }//end union 
        translate ([27,front_y-2,front_z/2-3])
            cube ([2,15,2]);
        translate ([72,front_y-2,front_z/2-3])
            cube ([2,15,2]);
    }//
    //absolute positioning 
    
    
}//end module
    
module new_frame () {
    difference () {
        cube ([front_x,front_y,front_z]);
        //back
        translate ([-cd*2,-cd,7.5]) cube([110,front_y-1.5+cd,20]);
        
        //shallow recess in back
        translate ([1,-cd,-cd]) cube([front_x-2,37,2+cd]);
        //create flange in back
        translate ([1,-cd,-cd]) cube([front_x-2,2,12+cd]);
        //create end steps for back to screw into
        translate ([10,-cd,-cd]) cube([front_x-20,37.1,6.5+cd]);
        //slot
        translate ([1,8,-cd]) cube([6,20,12+cd]);
        //extend slot horizontally to enable fit of electronics
        translate ([2,15,0]) cube([35,8,10]);
        //slot tidy up
        translate ([1,8,-cd]) cube([10,20,6.5+cd]);
        //holes 
        translate([screw_hole_x+1,screw_hole_y+2,-cd])
            cylinder (d=screw_hole_dia,h=10,$fn=12);
        
        translate([1+hole_x_pitch+screw_hole_x,screw_hole_y+2,-cd])
            cylinder (d=screw_hole_dia,h=10,$fn=12);
        
        translate([1+screw_hole_x,screw_hole_y+2+hole_y_pitch,-cd])
            cylinder (d=screw_hole_dia,h=10,$fn=12);
        translate([1+hole_x_pitch+screw_hole_x,screw_hole_y+2+hole_y_pitch,-cd])
            cylinder (d=screw_hole_dia,h=10,$fn=12);
         
         //cable_holes
                translate ([27,front_y-10,front_z/2-3])
        cube ([2,15,2]);
                translate ([72,front_y-10,front_z/2-3])
        cube ([2,15,2]);
    }//end diff
    frame_legs ();
}//end module



module new_front () {
    top_thick = 2;
    difference () {
        cube ([front_x,front_y-top_thick,front_z]);
        
        translate ([2,-cd,1])
            cube ([96,front_y-2-top_thick+cd,20]);//remove inner
        
        //small LH cutout
        translate ([-cd,-cd,8])
            cube ([1.5+cd,front_y+1+cd,10]);//LH end cleanup
        //make inside flush
        translate ([-cd,-cd,8])
            cube ([5,front_y-2-top_thick+cd,10]);//LH end cleanup
        
        //small RH cutout
        translate ([98.5,-cd,8])
            cube ([1.5+cd,front_y+1+cd,10]);//RH end cleanup
        //make inside flush
        translate ([97,-cd,8])
            cube ([5,front_y-2-top_thick+cd,10]);//RH end cleanup
        
        //board slots
        
        translate ([1,-cd,3.5])
            cube([2,front_y-3+cd,1.5]);
        translate ([98-cd,-cd,3.5])
            cube([1+cd,front_y-3+cd,1.5]);
            
        //front display window
        translate ([15,10,-cd])
            cube ([72,19,5]);      
        
    }//end diff
}//end module

module old_front () {
difference(){
    cube([105,2,39]);
    translate([16.95,-1,11.34])
        cube([71.10,4,19.26]);//first make difference work properly by offsetting the cube into Y and making the cube cut right through the panel.
}
rotate([270,0,0])
    translate([5.25,-5,2])
        cylinder(h=6,r=1.5);
rotate([270,0,0])
    translate([5.25,,-34,2])
        cylinder(h=6,r=1.5);
rotate([270,0,0])
    translate([99.25,-5,2])
        cylinder(h=6,r=1.5);
rotate([270,0,0])
    translate([99.25,-34,2])
        cylinder(h=6,r=1.5);

}//end module