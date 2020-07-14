module boxgen(
  dim = [54,54,44],
  thickness=3,
  finger_width = undef, //default thickness*2
  bottoninset = 0,
  kerf = 0.0
  )
  
{
  //Finger width
  finger_width =  (finger_width==undef) ? thickness * 2 : finger_width;
  
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

  //Bottom panel
  module bottom(dim, fingers, fingers_width, thickness) {
    difference() {
      square([dim.x, dim.y], center=true);
      
      for(i=[1:2:fingers.x])
        translate([-(dim.x - 2*thickness)/2 - fingers_width.x/2 + fingers_width.x*i, 0]) {
          //Front
          translate([0, -(dim.y - thickness)/2])
            #square([fingers_width.x, thickness], center = true);
          //Back
          translate([0, (dim.y - thickness)/2])
            #square([fingers_width.x, thickness], center = true);
          }

      for(i=[1:2:fingers.y])
        translate([0, -dim.y/2 - fingers_width.y/2 + fingers_width.y*i]) {
          //Left
          translate([-(dim.x-thickness)/2, 0])
            #square([thickness, fingers_width.y], center = true);
          //Right
          translate([(dim.x-thickness)/2, 0])
            #square([thickness, fingers_width.y], center = true);
        }
    }
  }

  FACE = 1;
  SIDE = 2;
  
  //Side panel
  module side(dim, fingers, fingers_width, thickness, type) {
    difference() {
      square([dim.x, dim.y], center=true);

      //Bottom
      for(i=[2:2:fingers.x])
        translate([-(dim.x - ((type==FACE)?2*thickness:0))/2 - fingers_width.x/2 + fingers_width.x*i, -(dim.y-thickness)/2 + bottoninset])
          #square([fingers_width.x - kerf, thickness], center = true);

      //Sides
      start = type;
      for(i=[start:2:fingers.y])
        translate([0, -dim.y/2 - fingers_width.y/2 + fingers_width.y*i])
        {
          //Left
          translate([-(dim.x-thickness)/2, 0])
            #square([thickness, fingers_width.y - ((type==SIDE)?kerf:0)], center = true);
          //Right
          translate([(dim.x-thickness)/2, 0])
            #square([thickness, fingers_width.y - ((type==SIDE)?kerf:0)], center = true);
        }
    }
  }

  //Bottom
  bottom(dim, fingers, fingers_width, thickness);

  //Back
  translate([0,(dim.y+dim.z)/2+1])
    side([dim.x, dim.z], [fingers.x, fingers.z], [fingers_width.x, fingers_width.z], thickness, type=FACE);
  
  //Front
  translate([0,-(dim.y+dim.z)/2-1])
    mirror([0,1])
      side([dim.x, dim.z], [fingers.x, fingers.z], [fingers_width.x, fingers_width.z], thickness, type=FACE);

  //Left
  translate([-(dim.x+dim.z)/2-1, 0])
    rotate([0,0,90])
      side([dim.y, dim.z], [fingers.y, fingers.z], [fingers_width.y, fingers_width.z], thickness, type=SIDE);

  //Right
  translate([(dim.x+dim.z)/2+1, 0])
    mirror([1,0])rotate([0,0,90])
      side([dim.y, dim.z], [fingers.y, fingers.z], [fingers_width.y, fingers_width.z], thickness, type=SIDE);
 
}

boxgen(thickness=3, finger_width=6, bottoninset=0, kerf=0.0);