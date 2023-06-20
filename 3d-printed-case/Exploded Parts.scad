//build exploded version

use <Train Display Case.scad>
use <Train Display Case Back.scad>
use <Train Platform.scad>

translate ([44.25,35,40]) color ("green") rotate ([90,0,0]) new_front ();
//translate ([40,15,8]) 
translate ([44.25,10,60]) rotate ([-90,0,0]) color ("orange")new_frame ();


//test back fit 
//translate ([41.25,16.5,23.5]) rotate ([90,0,0]) new_back ();
//OR
translate ([45.25,5.5,23.5]) color ("teal") rotate ([90,0,0]) new_back ();

translate ([44,0,2]) color("red") top ();

translate ([10,2,-10]) color("grey") ramped_base ();