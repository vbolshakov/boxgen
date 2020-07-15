module boxgen(
  dim = [54,54,44],
  thickness=3, //material thickness
  finger_width = undef, //default thickness*2
  bottoninset = 0, //height of bottom inset
  frontinset = 0, //distance of front inset
  front_thickness = undef, //front material thickness
  kerf = 0.0,
  dividers = undef, //array of dividers [x, y, z] or [[x1, x2, ..], 
  dividers_type = undef, //
  finger_holes = undef,
  empty_sides = undef //array of
  )
  
{
  //Finger width
  finger_width = (finger_width==undef) ? thickness * 2 : finger_width;
  
  front_thickness = (front_thickness==undef) ? thickness : front_thickness;
  
  fingers = [
    max(3,floor( ceil((dim.x - 2*thickness)/finger_width) /2 ) * 2 - 1),
    max(3,floor( ceil(dim.y/finger_width) /2 ) * 2 - 1),
    max(3,floor( ceil(dim.z/finger_width) /2 ) * 2 - 1)   
  ];
  
  fingers_width = [
   (dim.x - 2*thickness)/fingers.x,
    dim.y/fingers.y,
    dim.z/fingers.z,
  ];
  
  START_SLOT = 1;
  START_TAB = 2;

  //Bottom panel
  module bottom(dim, fingers, fingers_width) {
    difference() {
      square([dim.x, dim.y], center=true);

      start = (frontinset == 0) ? START_SLOT : START_TAB;

      //Front side
      for(i=[start:2:fingers.x])
        translate([-(dim.x - 2*thickness + fingers_width.x)/2 + fingers_width.x*i, 0]) {
          translate([0, -(dim.y - front_thickness)/2 + frontinset])
            #square([fingers_width.x, front_thickness], center = true);
          }

      //Back side
      for(i=[START_SLOT:2:fingers.x])
        translate([-(dim.x - 2*thickness + fingers_width.x)/2 + fingers_width.x*i, 0]) {
          translate([0, (dim.y - thickness)/2])
            #square([fingers_width.x, thickness], center = true);
          }

      for(i=[START_SLOT:2:fingers.y])
        translate([0, -(dim.y + fingers_width.y)/2 + fingers_width.y*i]) {
          //Left side
          translate([-(dim.x - thickness)/2, 0])
            #square([thickness, fingers_width.y], center = true);
          //Right side
          translate([(dim.x - thickness)/2, 0])
            #square([thickness, fingers_width.y], center = true);
        }
    }
  }

  FRONT = 1;
  BACK = 2;
  SIDE = 3;
  
  //Side panel
  module side(dim, fingers, fingers_width, type) {
    difference() {
      square([dim.x, dim.y], center=true);

      bottomstart = ((type == FRONT)&&((frontinset > 0))) ? START_SLOT : START_TAB;

      //Bottom
      for(i=[bottomstart:2:fingers.x])
        translate([
            -(dim.x - ((type == FRONT)||(type == BACK)?2*thickness:0) + fingers_width.x)/2 + fingers_width.x*i,
            -(dim.y - thickness)/2 + bottoninset])
          #square([fingers_width.x - kerf, thickness], center = true);
      
      if ((type == FRONT)&&(bottoninset > 0)&&(frontinset > 0))
        translate([0, -(dim.y - bottoninset)/2])
          #square([dim.x, bottoninset], center = true);

      sidestart = (type == SIDE) ? START_TAB : START_SLOT;

      //Left side (to front)
      for(i=[sidestart:2:fingers.y])
        translate([
            0,
            -dim.y/2 - fingers_width.y/2 + fingers_width.y*i]
        ) {
          thickness = (type == FRONT)||(type == BACK) ? thickness : front_thickness;
          frontinset = (type == SIDE) ? frontinset : 0;
          translate([-(dim.x - thickness)/2 + frontinset, 0])
            #square([thickness, fingers_width.y - ((type==SIDE)?kerf:0)], center = true);
        }

      //Right side (to back)
      for(i=[sidestart:2:fingers.y])
        translate([
          0,
          -(dim.y + fingers_width.y)/2 + fingers_width.y*i]
        ) {
          translate([(dim.x-thickness)/2, 0])
            #square([thickness, fingers_width.y - ((type==SIDE)?kerf:0)], center = true);
        }
    }
  }

  spacing = 1;
  //Bottom
  bottom(dim, fingers, fingers_width);

  //Back
  translate([0,(dim.y+dim.z)/2 + spacing])
    side([dim.x, dim.z], [fingers.x, fingers.z], [fingers_width.x, fingers_width.z], type=BACK);
  
  //Front
  translate([0,-(dim.y+dim.z)/2 - spacing + bottoninset])
    mirror([0,1])
      side([dim.x, dim.z], [fingers.x, fingers.z], [fingers_width.x, fingers_width.z], type=FRONT);

  //Left
  translate([-(dim.x+dim.z)/2 - spacing, 0])
    rotate([0,0,90])
      side([dim.y, dim.z], [fingers.y, fingers.z], [fingers_width.y, fingers_width.z], type=SIDE);

  //Right
  translate([(dim.x+dim.z)/2 + spacing, 0])
    mirror([1,0])rotate([0,0,90])
      side([dim.y, dim.z], [fingers.y, fingers.z], [fingers_width.y, fingers_width.z], type=SIDE);
 
}

boxgen([54*3,54*2,44], thickness=3, /*finger_width=6,*/ bottoninset=3, kerf=0.0, front_thickness=6, frontinset = 3);