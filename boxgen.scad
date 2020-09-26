module boxgen(
  dim = [54,54,44],
  thickness=3,              //material thickness
  finger_width = undef,     //default thickness*2
  bottom_thickness = undef, //bottom material thickness
  bottom_inset = 0,         //height of bottom inset
  front_thickness = undef,  //front material thickness
  front_inset = 0,          //distance of front inset
  drawer_slide_width = 0 ,  //extend bottom width to work as sliders 
  kerf = 0.0,               //kerf compensation, slots and holes width will be decreased  
  dividers = undef,         //array of dividers [x, y, z] 
  dividers_height = undef,  //height of dividers
  holes = undef,            //position and size of holes, not implemented 
  empty_sides = undef       //array of sides to remove, not implemented
  )
  
{
  front_thickness = (front_thickness == undef) ? thickness : front_thickness;
  bottom_thickness = (bottom_thickness == undef) ? thickness : bottom_thickness;

  bottom_inset = (drawer_slide_width == 0) ? bottom_inset : 0;

  //Inner dimensions
  idim = [
    dim.x - thickness * 2,
    dim.y - thickness - front_thickness - front_inset,
    dim.z - bottom_thickness - bottom_inset
  ];

  //Finger width
  finger_width = (finger_width==undef) ? thickness * 2 : finger_width;
  
  fingers = [
    max(3,floor( ceil(idim.x/finger_width) /2 ) * 2 - 1),
    max(3,floor( ceil(dim.y/finger_width) /2 ) * 2 - 1),
    max(3,floor( ceil(dim.z/finger_width) /2 ) * 2 - 1)
  ];
  
  fingers_width = [
    idim.x/fingers.x,
    dim.y/fingers.y,
    dim.z/fingers.z,
  ];
  
  START_SLOT = 1;
  START_TAB = 2;
  
  div_fingers = (dividers == undef) ? undef : [
    ((dividers.x == undef)||(dividers.x == 0)) ? 3 : dividers.x + 1,
    ((dividers.y == undef)||(dividers.y == 0)) ? 3 : dividers.y + 1
    ];
    
  div_finger_width = 3 * thickness;

  div_width = [
    idim.x - thickness * (div_fingers.x - 1),
    idim.y - thickness * (div_fingers.y - 1)
  ];

  div_space = (dividers == undef) ? undef : [
     div_width.x / div_fingers.x,
     div_width.y / div_fingers.y
    ];
    
  div_finger_space = (dividers == undef) ? undef : [
     idim.x / (div_fingers.x * 2),
     idim.y / (div_fingers.y * 2)
    ];

  dividers_height = (dividers_height == undef) ? idim.z : (dividers_height>idim.z) ? idim.z : dividers_height;
    
  //Bottom panel
  module bottom(dim, fingers, fingers_width) {
    difference() {
      square([dim.x + drawer_slide_width * 2, dim.y - 0.001], center=true);

      start = (front_inset == 0) ? START_SLOT : START_TAB;

      //Front side
      for(i=[start:2:fingers.x])
        translate([-(dim.x - 2*thickness + fingers_width.x)/2 + fingers_width.x*i, 0])
          translate([0, -(dim.y - front_thickness)/2 + front_inset])
            #square([fingers_width.x - ((front_inset > 0)?kerf:0), front_thickness], center = true);

      //Back side
      for(i=[START_SLOT:2:fingers.x])
        translate([-(dim.x - 2*thickness + fingers_width.x)/2 + fingers_width.x*i, 0])
          translate([0, (dim.y - thickness)/2])
            #square([fingers_width.x, thickness], center = true);

      for(i=[START_SLOT:2:fingers.y])
        translate([0, -(dim.y + fingers_width.y)/2 + fingers_width.y*i]) {
          //Left side
          translate([-(dim.x - thickness)/2, 0])
            #square([thickness, fingers_width.y], center = true);
          //Right side
          translate([(dim.x - thickness)/2, 0])
            #square([thickness, fingers_width.y], center = true);
        }

      //Slots for vertical dividers tabs
      if(dividers.x != undef)
        for(x=[1:1:dividers.x])
          translate([-idim.x/2 + thickness*(x-1/2)+ div_space.x*x, 0])
            for(y=[0:1:div_fingers.y-1])
              translate([0, -idim.y/2 - thickness/2 + front_thickness/2 + front_inset/2 + div_finger_space.y*(1+2*y)])
                #square([thickness, div_finger_width - kerf], center = true);

      //Slots for horizontal dividers tabs
      if(dividers.y != undef)
        for(y=[1:1:dividers.y])
          translate([0, -idim.y/2 + front_thickness/2 + front_inset/2 + thickness*(y-1) + div_space.y*y])
            for(x=[0:1:div_fingers.x-1])
              translate([-idim.x/2 + div_finger_space.x*(1+2*x), 0])
                #square([div_finger_width - kerf, thickness], center = true);
    }
  }
  
  FRONT = 1;
  BACK = 2;
  SIDE = 3;
  DIVIDER = 11;
    
  //Side panel
  module side(dim, fingers, fingers_width, type) {
    difference() {
      square([dim.x, dim.y], center=true);

      bottomstart = ((type == FRONT)&&(front_inset > 0)) ? START_SLOT : START_TAB;

      //Bottom
      for(i=[bottomstart:2:fingers.x])
        translate([
            -(dim.x - ((type == FRONT)||(type == BACK)?2*thickness:0) + fingers_width.x)/2 + fingers_width.x*i,
            -(dim.y - bottom_thickness)/2 + bottom_inset])
          #square([fingers_width.x - (((type == FRONT)&&(front_inset > 0))?0:kerf), bottom_thickness], center = true);
      
      if ((type == FRONT)&&(bottom_inset > 0)&&(front_inset > 0))
        translate([0, -(dim.y - bottom_inset)/2])
          #square([dim.x, bottom_inset], center = true);

      sidestart = (type == SIDE) ? START_TAB : START_SLOT;

      //Left side (to front)
      for(i=[sidestart:2:fingers.y])
        translate([0, -dim.y/2 - fingers_width.y/2 + fingers_width.y*i]) {
          thickness = (type == FRONT)||(type == BACK) ? thickness : front_thickness;
          front_inset = (type == SIDE) ? front_inset : 0;
          translate([-(dim.x - thickness)/2 + front_inset, 0])
            #square([thickness, fingers_width.y - ((type==SIDE)?kerf:0)], center = true);
        }

      //Right side (to back)
      for(i=[sidestart:2:fingers.y])
        translate([0, -(dim.y + fingers_width.y)/2 + fingers_width.y*i]) {
          translate([(dim.x-thickness)/2, 0])
            #square([thickness, fingers_width.y - ((type==SIDE)?kerf:0)], center = true);
        }

      //Slots for vertical dividers tabs
      if (((type==FRONT)||(type==BACK))&&(dividers.x != undef))
        for(x=[1:1:dividers.x])
          translate([-idim.x/2 + thickness*(x-1/2)+ div_space.x*x, -dim.y/2 + bottom_thickness + bottom_inset + dividers_height/2 + dividers_height/4])
            #square([thickness, dividers_height/2], center = true);

      //Slots for horizontal dividers tabs
      if ((type==SIDE)&&(dividers.y != undef))
            for(y=[1:1:dividers.y])
              translate([-idim.y/2 + front_thickness/2 + front_inset/2 + thickness*(y-1) + div_space.y*y, -dim.y/2 + bottom_thickness + bottom_inset + dividers_height/2 + dividers_height/4])
                    #square([thickness, dividers_height/2], center = true);
    }
  }

  //Vertical divider panel
  module verticaldivider() {
    difference() {
      translate([(thickness - front_thickness - front_inset)/2, 0])
        union() {
          square([idim.y, dividers_height],center=true);

          //Back tabs
          translate([-idim.y/2 - thickness/2, dividers_height/2 - dividers_height/4])
            #square([thickness, dividers_height/2], center = true);

          //Front tabs
          translate([idim.y/2 + front_thickness/2, dividers_height/2 - dividers_height/4])
            #square([front_thickness, dividers_height/2], center = true);

          //Bottom tabs
          for(y=[0:1:div_fingers.y-1])
            translate([-idim.y/2 + div_finger_space.y*(1+2*y), -dividers_height/2 - bottom_thickness/2])
              #square([div_finger_width, bottom_thickness], center = true);
        }
          // Slots for horizontal dividers
          translate([(thickness - front_thickness - front_inset), 0])
            for(y=[1:1:dividers.y])
              translate([-idim.y/2 + front_thickness/2 + front_inset/2 + thickness*(y-1) + div_space.y*y, dividers_height/4])
                    #square([thickness, dividers_height/2], center = true);
    }
  }

  //Horizontal divider panel
  module horizontaldivider() {
    difference() {
      union() {
        square([idim.x, dividers_height],center=true);

        //Left tabs
        translate([-idim.x/2 - thickness/2, dividers_height/2 - dividers_height/4])
          #square([thickness, dividers_height/2], center = true);

        //Right tabs
        translate([idim.x/2 + thickness/2, dividers_height/2 - dividers_height/4])
          #square([thickness, dividers_height/2], center = true);
      
        //Bottom tabs
        for(x=[0:1:div_fingers.x-1])
          translate([-idim.x/2 + div_finger_space.x*(1+2*x), -dividers_height/2 - bottom_thickness/2])
            #square([div_finger_width, bottom_thickness], center = true);
    }

      // Slots for vertical dividers
      for(x=[1:1:dividers.x])
        translate([-idim.x/2 + thickness*(x-1/2)+ div_space.x*x, -dividers_height/4])
          #square([thickness, dividers_height/2], center = true);
    }
  }

  spacing = 1;

  //Bottom
  bottom(dim, fingers, fingers_width);

  //Back
  translate([0, (dim.y+dim.z)/2 + spacing])
    side([dim.x, dim.z], [fingers.x, fingers.z], [fingers_width.x, fingers_width.z], type=BACK);
  
  //Front
  translate([0, -(dim.y+dim.z)/2 - spacing + ((front_inset==0)?0:bottom_inset)])
    mirror([0,1])
      side([dim.x, dim.z], [fingers.x, fingers.z], [fingers_width.x, fingers_width.z], type=FRONT);

  //Left
  translate([-(dim.x+dim.z)/2 - drawer_slide_width - spacing, 0])
    rotate(90)
      side([dim.y, dim.z], [fingers.y, fingers.z], [fingers_width.y, fingers_width.z], type=SIDE);

  //Right
  translate([(dim.x+dim.z)/2 + drawer_slide_width + spacing, 0])
    mirror([1,0])
      rotate(90)
        side([dim.y, dim.z], [fingers.y, fingers.z], [fingers_width.y, fingers_width.z], type=SIDE);

  //Vertical dividers
  translate([dim.x/2 + drawer_slide_width + spacing + dim.z + spacing + dividers_height/2 + bottom_thickness, 0]) 
    for(x=[1:1:dividers.x])
      translate([(dividers_height + bottom_thickness + spacing) * (x-1) , 0])
          rotate(-90)
            verticaldivider();

  //Horizontal divider
  translate([0, dim.y/2 + spacing + dim.z + spacing + dividers_height/2 + bottom_thickness]) 
  for(y=[1:1:dividers.y])
    translate([0, (dividers_height + bottom_thickness + spacing) * (y-1)])
        horizontaldivider();
 
}