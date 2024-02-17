//Train platform for Train Display Case

view_part = 0; //[0:top,1:base]


/* [Hidden] */
pa = 0.3;
cd = 0.1; //small value to ensure holes are through
station_ramp_x = 168;
station_ramp_y = 40;
station_ramp_z = 10;
centre_flat_x = 100;
centre_flat_y = 43;

flat_offset_x = (station_ramp_x - centre_flat_x)/2;

top_z = 2;
top_x = 100;
top_y = 44;
display_base_x = 56+pa;
display_base_y = 12.5+pa;

gutter_x = 64+pa;//surround for bottom
gutter_y = 18+pa;
gutter_z = 5;
gutter_off_x = (station_ramp_x - gutter_x)/2;
gutter_off_y = (station_ramp_y - gutter_y)/2;
gutter_wall_x = (gutter_x-display_base_x-2*pa)/2;
gutter_wall_y = (gutter_y-display_base_y-2*pa)/2;
top_offset_x = top_x/2 - (gutter_x - 3*pa)/2;
top_offset_y = top_y/2 - (gutter_y - 3*pa)/2;


cable_slot_x = display_base_x-2;//some value
cable_slot_y = 8;
exit_slot_x = 6;
exit_slot_z = 6;
exit_slot_y = 20;


if (view_part == 0 ) top ();
    
if (view_part == 1 ) ramped_base ();
    
module ramped_base () {
    difference () {
        union () {
            hull () {
                cube ([station_ramp_x,station_ramp_y,cd]);
                
                translate ([flat_offset_x,0,0])
                    cube ([centre_flat_x,station_ramp_y,station_ramp_z]);
            }//end hull
            translate ([gutter_off_x,gutter_off_y,0])
            hollow_gutter ();
        }//end union
        
        //through cable slot
        translate ([station_ramp_x/2-cable_slot_x/2,station_ramp_y/2-cable_slot_y/2,-cd])
            cube ([cable_slot_x,cable_slot_y,20]);
        //hollow_out base
        
        hull () {
                translate ([5,5,-cd]) cube ([station_ramp_x-10,station_ramp_y-10,cd]);
                
                translate ([flat_offset_x,5,-cd])
                    cube ([centre_flat_x-10,station_ramp_y-10,station_ramp_z-3]);
            }//end hull
            
        //wall cable_slot
            translate ([station_ramp_x/2-3,-cd,-cd])
                cube ([6,10,3]);
            translate ([station_ramp_x/2,-cd,3]) rotate ([-90,0,0])
                cylinder (d=6,h=10,$fn=40);
    
    }//end diff
    //add cable tie slots to cube 
    difference () {
    translate ([station_ramp_x/2-5,0,0])
                cube ([10,12,10]);
        translate ([station_ramp_x/2-3,-cd,-cd])
                cube ([6,13,3]);
            translate ([station_ramp_x/2,-cd,3]) rotate ([-90,0,0])
                cylinder (d=6,h=13,$fn=40);
        translate ([station_ramp_x/2-6,6,-cd])
            cube ([15,3,2]);
        translate ([station_ramp_x/2-6,6,5])
            cube ([15,3,2]);
    }//end diff
}//end module

module hollow_gutter () {
    difference () {
        cube ([gutter_x-pa,gutter_y-pa,station_ramp_z+gutter_z]);
        
        translate ([gutter_wall_x,gutter_wall_y,-cd])
            cube ([gutter_x-2*gutter_wall_x,gutter_y-2*gutter_wall_y,station_ramp_z+gutter_z+2]);
        
    }//end diff
    
}// end module
    

module top () {
    difference () {
    cube ([top_x,top_y,top_z]);
    translate ([top_offset_x,top_offset_y,-cd])
        cube ([gutter_x+pa,gutter_y+pa,gutter_z]);
    }//end diff
}