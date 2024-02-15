//amendments by rogerw-gh to fix issues and make assembly simpler
// add new components - separate legs, platform surfaces
// increased depth of back volume, changed holes

//Choose a pattern for the ventilated back
perforations = 4;// [1:squares,2:circles,3:hexagons,4:diagonal slots]

/* [Hidden] */

$fa = 1;
$fs = 0.4;
cd = 0.1;// small offset for removing holes and cavities
pa = 0.3;// 'print allowance' addtional size for holes to accommodate improperly sized holes 
square_xy = 4;
back_x = 97.5;
back_y = 34.5;
front_x = 100;
front_y = 38;
diff_x = (front_x - back_x) /2;
diff_y = (front_y - back_y)/2;
back_z = 2;
first_row_y = 10;
second_row_y = 17;
third_row_y = 24;
screw_hole_x = 4;
screw_hole_y = 3;
screw_hole_dia = 2.5+pa;
head_hole_dia = 4.5;
bolt_round = 40;

//translate ([-diff_x,-diff_y,1.99]) cube ([front_x,front_y,back_z]);
new_back ();

// test location marker positioning
//translate ([0,12,0]) cube ([13.25,2,6]);
//translate ([back_x-13.25,12,0]) cube ([13.25,2,6]);

module new_back () {
    difference () {
        union () {
            translate ([-diff_x,-diff_y,1.99]) cube ([front_x,front_y+1,back_z/2]);
            cube ([back_x,back_y,back_z]);
        }//end union
        //perforations..
        if (perforations == 1) {
            square_holes ();
        }//endif
        if (perforations == 2) {
            round_holes ();
        }//endif
        if (perforations == 3) {
            hex_holes ();
        }//endif
        if (perforations == 4) {
            diagonal_slots ();
        }//endif
        
        drill_screw_holes ();
        internal_recess ();
        
    }//end diff
}//end module

module internal_recess () {
      translate ([9,-0.5,-0.01]) cube ([back_x-18,back_y+1,back_z-0.01]);
}//end module

module drill_screw_holes () {
    translate ([screw_hole_x,screw_hole_y,-cd]) 
        cylinder (d=screw_hole_dia,h=back_z*3,$fn=bolt_round);
    translate ([screw_hole_x,screw_hole_y,back_z-1]) 
        cylinder (d=head_hole_dia,h=back_z,$fn=bolt_round);
    
    
    translate ([screw_hole_x,back_y-screw_hole_y,-cd])
        cylinder (d=screw_hole_dia,h=back_z*3,$fn=bolt_round);
    translate ([screw_hole_x,back_y-screw_hole_y,back_z-1])
        cylinder (d=head_hole_dia,h=back_z,$fn=bolt_round);
    
    translate ([back_x-screw_hole_x,screw_hole_y,-cd])
        cylinder (d=screw_hole_dia,h=back_z*3,$fn=bolt_round);
    translate ([back_x-screw_hole_x,screw_hole_y,back_z-1])
        cylinder (d=head_hole_dia,h=back_z,$fn=bolt_round);
    
    translate ([back_x-screw_hole_x,back_y-screw_hole_y,-cd])
        cylinder (d=screw_hole_dia,h=back_z*3,$fn=bolt_round);
    translate ([back_x-screw_hole_x,back_y-screw_hole_y,back_z-1])
        cylinder (d=head_hole_dia,h=back_z,$fn=bolt_round);
    
    
    
}//end module

module diagonal_slots () {
    slot_width = 3;
    slot_offset = 6;
    slot_count = 9;
    slot1_pts = [[3,0],[6,0],[0,6],[0,3]];
    slot2_pts = [[3+slot_offset,0],[6+slot_offset,0],[0,6+slot_offset],[0,3+slot_offset]];
    slot3_pts = [[3+slot_offset*2,0],[6+slot_offset*2,0],[0,6+slot_offset*2],[0,3+slot_offset*2]];
    
    slot4_pts = [[3+slot_offset*3,0],[6+slot_offset*3,0],[slot_offset,6+slot_offset*2],[slot_offset-3,6+slot_offset*2]];
        
 ///   slot5_pts = [[3+slot_offset*3,0],[6+slot_offset*3,0],[slot_offset,6+slot_offset*2],[slot_offset-3,6+slot_offset*2]];
    
    translate ([10,9,-cd] ) linear_extrude (back_z*3) polygon (slot1_pts);
    translate ([10,9,-cd] ) linear_extrude (back_z*3) polygon (slot2_pts);
    translate ([10,9,-cd] ) linear_extrude (back_z*3) polygon (slot3_pts);
    translate ([10,9,-cd] ) linear_extrude (back_z*3) polygon (slot4_pts);
    
    for (slot_pos=[1:slot_count]){
        
        translate ([10+slot_pos*slot_offset,9,-cd] ) 
            linear_extrude (back_z*3) 
                polygon (slot4_pts);
    }//endfor
    
    //end slots
    final_x = slot_count*slot_offset+10;
    
    slot_end_pts = [[slot_offset*4,slot_width],[slot_offset*4,slot_offset],[slot_offset*2,slot_offset*3],[slot_offset+3,slot_offset*3]];
    translate ([final_x,9,-cd] ) 
            linear_extrude (back_z*3) 
                polygon (slot_end_pts);
    
    slot_end_pts2 = [[slot_offset*4,slot_offset*1+slot_width],[slot_offset*4,slot_offset*2],[slot_offset*3,slot_offset*3],[slot_offset+9,6+slot_offset*2]];
    translate ([final_x,9,-cd] ) 
            linear_extrude (back_z*3) 
                polygon (slot_end_pts2);
    slot_end_pts3 = [[slot_offset*4,slot_offset*2+slot_width],[slot_offset*4,slot_offset*3],[slot_offset*3+slot_width,slot_offset*3]];
    translate ([final_x,9,-cd] ) 
            linear_extrude (back_z*3) 
                polygon (slot_end_pts3);
}

module square_holes () {
    row_count = 3;
    hole_count = 12;
    hole_off_x = 15;
    square_xy = 4;
    hole_x = 7;
    row_1_y = 10;
    row_2_y = row_1_y + hole_x;
    row_3_y = row_2_y + hole_x;
    
    hole_dist = hole_x*hole_count;
    //echo (hole_dist=hole_dist);
    start_x = (back_x - hole_dist)/2 + (hole_x - square_xy)/2;
    //echo (start_x);
    //row 1
    for (hole=[0:1:hole_count-1]) {
        translate ([start_x+hole*hole_x,row_1_y,-cd])
            cube([4,4,back_z*3]);
        //echo(hole_off_x+hole*hole_x);
    }
    for (hole=[0:1:hole_count-1]) {
        translate ([start_x+hole*hole_x,row_2_y,-cd])
            cube([4,4,back_z*3]);
        //echo(hole_off_x+hole*hole_x);
    }
    for (hole=[0:1:hole_count-1]) {
        translate ([start_x+hole*hole_x,row_3_y,-cd])
            cube([4,4,back_z*3]);
        //echo(hole_off_x+hole*hole_x);
    }
    
}//end module

module round_holes () {
    row_count = 3;
    hole_count = 12;
    hole_off_x = 15;
    hole_x = 7;
    hole_dia = 5;
    row_1_y = 10+hole_dia/2;
    row_2_y = 10 + hole_dia + hole_dia/2;
    row_3_y = 10 + hole_dia*2 + hole_dia/2;
    row_4_y = 10 + hole_dia*3 + hole_dia/2;
    hole_dist = hole_x*hole_count;

    start_x = (back_x - hole_dist)/2 + (hole_x)/2;
    start_2 = (back_x - hole_dist)/2 + (hole_x);
    
    //row 1
    for (hole=[0:1:hole_count-1]) {
        translate ([start_x+hole*hole_x,row_1_y,-cd])
            cylinder (d=hole_dia,h=back_z*3,$fn=40);
    }
    for (hole=[0:1:hole_count-2]) {
        translate ([start_2+hole*hole_x,row_2_y,-cd])
            cylinder (d=hole_dia,h=back_z*3,$fn=40);
    }
    for (hole=[0:1:hole_count-1]) {
        translate ([start_x+hole*hole_x,row_3_y,-cd])
            cylinder (d=hole_dia,h=back_z*3,$fn=40);
    }
        for (hole=[0:1:hole_count-2]) {
        translate ([start_2+hole*hole_x,row_4_y,-cd])
            cylinder (d=hole_dia,h=back_z*3,$fn=40);
    }
    
}//end module

module hex_holes () {
    row_count = 3;
    hole_count = 10;
    hole_off_x = 15;
    hole_x = 8;
    hole_dia = 6;
    //row_1_y = 10;
    row_1_y = 10+hole_dia/2;
    row_2_y = 10 + hole_dia + hole_dia/2;
    row_3_y = 10 + hole_dia*2 + hole_dia/2;
    row_4_y = 10 + hole_dia*3 + hole_dia/2;
    hole_dist = hole_x*hole_count;

    start_x = (back_x - hole_dist)/2 + (hole_x)/2;
    start_2 = (back_x - hole_dist)/2 ;
    //row 1
        //row 1
    for (hole=[0:1:hole_count-1]) {
        translate ([start_x+hole*hole_x,row_1_y,-cd])
            cylinder (d=hole_dia,h=back_z*3,$fn=6);
    }
    for (hole=[0:1:hole_count]) {
        translate ([start_2+hole*hole_x,row_2_y,-cd])
            cylinder (d=hole_dia,h=back_z*3,$fn=6);
    }
    for (hole=[0:1:hole_count-1]) {
        translate ([start_x+hole*hole_x,row_3_y,-cd])
            cylinder (d=hole_dia,h=back_z*3,$fn=6);
    }
//        for (hole=[0:1:hole_count]) {
//        translate ([start_2+hole*hole_x,row_4_y,-cd])
//            cylinder (d=hole_dia,h=4,$fn=6);
//    }

    
}//end module

module old_back () {
difference(){
    cube([105,22,39]);
    
    translate([2,-1,-1])
        cube([101,21,38]);
    translate([22.25,19,10])
        cube([4,4,4]);
    translate([28.25,19,10])
    cube([4,4,4]);
    translate([34.25,19,10])
    cube([4,4,4]);
    translate([40.25,19,10])
    cube([4,4,4]);
    translate([46.25,19,10])
    cube([4,4,4]);
    translate([52.25,19,10])
    cube([4,4,4]);
    translate([58.25,19,10])
    cube([4,4,4]);
    translate([64.25,19,10])
    cube([4,4,4]);

    translate([22.25,20,17])
    cube([4,2,4]);
    translate([28.25,20,17])
    cube([4,2,4]);
    translate([34.25,20,17])
    cube([4,2,4]);
    translate([40.25,20,17])
    cube([4,2,4]);
    translate([46.25,20,17])
    cube([4,2,4]);
    translate([52.25,20,17])
    cube([4,2,4]);
    translate([58.25,20,17])
    cube([4,2,4]);
    translate([64.25,20,17])
    cube([4,2,4]);

    translate([22.25,20,24])
    cube([4,2,4]);
    translate([28.25,20,24])
    cube([4,2,4]);
    translate([34.25,20,24])
    cube([4,2,4]);
    translate([40.25,20,24])
    cube([4,2,4]);
    translate([46.25,20,24])
    cube([4,2,4]);
    translate([52.25,20,24])
    cube([4,2,4]);
    translate([58.25,20,24])
    cube([4,2,4]);
    translate([64.25,20,24])
    cube([4,2,4]);
}

rotate([270,0,0])
    translate([17.25,-7.25,15])
        cylinder(h=6,r=1.20);
rotate([270,0,0])
    translate([17.25,-30.5,15])
        cylinder(h=6,r=1.20);
rotate([270,0,0])
    translate([75.50,-7.25,15])
        cylinder(h=6,r=1.20);
rotate([270,0,0])
    translate([75.50,-30.5,15])
        cylinder(h=6,r=1.20);

translate([16,18.6,12])
cube([5,2.4,14]);

translate([2,2,2])
cube([1.25,1,33]);
translate([2,4.3,2])
cube([1.25,1,33]);

translate([102,2,2])
cube([1.25,1,33]);
translate([102,4.3,2])
cube([1.25,1,33]);

}