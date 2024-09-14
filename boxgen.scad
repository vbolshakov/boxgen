module boxgen(
  dim = [54,54,44],
  thickness=3,                //material thickness
  finger_width = undef,       //default thickness*3

  top = false,
  top_thickness = undef,      //top material thickness

  bottom_thickness = undef,   //bottom material thickness
  bottom_inset = 0,           //height of bottom inset

  front = true,
  front_thickness = undef,    //front material thickness
  front_inset = 0,            //distance of front inset

  drawer_slide_width = 0 ,    //extend bottom width to work as sliders

  shelves = 0,
  shelf_thickness = undef,    //shelf material thickness
  shelf_support = false,      //generate shelves support
  
  dividers = undef,           //array of dividers [x, y] 
  divider_thickness = undef,  //divider material thickness
  divider_height = undef,     //height of dividers
  divider_removable = false,  //diveders without tab
  
  kerf = 0.0,               //kerf compensation, slots and holes width will be decreased  
  )
 
{
  top_thickness = (top_thickness == undef) ? thickness : top_thickness;
  front_thickness = (front_thickness == undef) ? thickness : front_thickness;
  bottom_thickness = (bottom_thickness == undef) ? thickness : bottom_thickness;

  bottom_inset = (drawer_slide_width == 0) ? bottom_inset : 0;

  //Inner dimensions
  idim = [
    dim.x - thickness * 2,
    dim.y - thickness - front_thickness - front_inset,
    dim.z - bottom_thickness - bottom_inset
  ];

  shelves = (!front_inset) ? shelves : 0;
  shelf_thickness = (shelf_thickness == undef) ? thickness : shelf_thickness;
  
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
  
  START_SLOT = 0;
  START_TAB = 1;

  divider_thickness = (divider_thickness == undef) ? thickness : divider_thickness;
  divider_height = (divider_height == undef) ? idim.z : divider_height;

  div_fingers = (dividers == undef) ? undef : [
    ((dividers.x == undef)||(dividers.x == 0)) ? 3 : dividers.x + 1,
    ((dividers.y == undef)||(dividers.y == 0)) ? 3 : dividers.y + 1
    ];
    
  div_space = (dividers == undef) ? undef : [
    (idim.x - divider_thickness * dividers.x  ) / (dividers.x + 1),
    (idim.y - divider_thickness * dividers.y  ) / (dividers.y + 1),
  ];

  divider_finger_width = (dividers == undef) ? undef : [
    div_space.x/3,
    div_space.y/3
  ];
   
  div_finger_space = (dividers == undef) ? undef : [
     idim.x / (div_fingers.x * 2),
     idim.y / (div_fingers.y * 2)
    ];

/*TODO:
1. Generate shelf support if shelves and dividers defined simulteniously
2. Generate slots in top if top and dividers, and div_heigth = idim.z
3. Defferent finger width for front size in top=true mode
*/

  module fingers(start, num, width, thickness, kerf = 0, kerfcompensation = 0){
    for(i=[start:2:num-1])
      translate([width*i + kerfcompensation, 0])
        #square([width - kerf, thickness]);
  }

  //Bottom panel
  module bottom(dim, fingers, fingers_width) {
    difference() {
      translate([-drawer_slide_width, 0])
      square([dim.x + drawer_slide_width * 2, dim.y]);

      start = (front_inset == 0) ? START_SLOT : START_TAB;

      //Front side
      if(front)
        translate([thickness, front_inset])
          fingers(start, fingers.x, fingers_width.x, front_thickness, ((front_inset > 0)?kerf:0), ((front_inset > 0)?kerf/2:0));
//          for(i=[start:2:fingers.x-1])
//            translate([fingers_width.x*i + ((front_inset > 0)?kerf/2:0), 0])
//              #square([fingers_width.x - ((front_inset > 0)?kerf:0), front_thickness]);

      //Back side
      translate([thickness, (dim.y - thickness)])
        fingers(0, fingers.x, fingers_width.x, thickness);
//        for(i=[0:2:fingers.x])
//          translate([fingers_width.x*i, 0])
//            #square([fingers_width.x, thickness]);

      //Left side
      translate([(thickness), 0])
      rotate([0,0,90])fingers(0, fingers.y, fingers_width.y, thickness);
//      for(i=[0:2:fingers.y])
//        translate([0, fingers_width.y*i])
//          #square([thickness, fingers_width.y]);

      //Right side
      translate([(dim.x), 0])
      rotate([0,0,90])fingers(0, fingers.y, fingers_width.y, thickness);
//      translate([(dim.x - thickness), 0])
//      for(i=[0:2:fingers.y])
//        translate([0, fingers_width.y*i])
//          #square([thickness, fingers_width.y]);

      if(!divider_removable){
        //Slots for vertical dividers tabs
        if(dividers.x != undef)
          translate([0, front_thickness + front_inset])
          for(x=[1:1:dividers.x])
            translate([divider_thickness/2 + divider_thickness*(x-1/2)+ div_space.x*x, 0])
          for(i=[0:1:div_fingers.y-1])
            translate([0, div_finger_space.y*(i*2+1) - divider_finger_width.y/2 + kerf/2])
              #square([divider_thickness, divider_finger_width.y - kerf]); 
             

        //Slots for horizontal dividers tabs
        if(dividers.y != undef)
          translate([thickness, front_thickness + front_inset ])
          for(y=[1:1:dividers.y])
            translate([0, divider_thickness*(y-1) + div_space.y*y])
              for(i=[0:1:div_fingers.x-1])
                translate([div_finger_space.x*(i*2+1) - divider_finger_width.x/2 + kerf/2, 0])
                  #square([divider_finger_width.x - kerf, divider_thickness]);
      }
    }
  }
  
  FRONT = 1;
  BACK = 2;
  SIDE = 3;
    
  //Side panel
  module side(dim, fingers, fingers_width, type) {
    kerfcompensation = (((type == FRONT)&&(front_inset > 0))?0:kerf/2);
    difference() {

      square([dim.x, dim.y - ((type == FRONT)&&(bottom_inset > 0)&&(front_inset > 0) ? bottom_inset :0)]);

      bottomstart = ((type == FRONT)&&(front_inset > 0)) ? START_SLOT : START_TAB;

      //Bottom
      translate([(type != SIDE)?thickness:0, 0])
      for(i=[bottomstart:2:fingers.x-1])
        translate([fingers_width.x*i + kerfcompensation, ((type == FRONT)&&(bottom_inset > 0)&&(front_inset > 0) ? 0 : bottom_inset)])
          #square([fingers_width.x - (((type == FRONT)&&(front_inset > 0))?0:kerf), bottom_thickness]);

      //Top
      if(top)
        translate([(type != SIDE)?thickness:0, 0])
        for(i=[bottomstart:2:fingers.x-1])
          translate([ fingers_width.x*i + kerfcompensation, dim.y - top_thickness - ((type == FRONT)&&(bottom_inset > 0)&&(front_inset > 0) ? bottom_inset : 0)])
            #square([fingers_width.x - (((type == FRONT)&&(front_inset > 0))?0:kerf), top_thickness ]);

      sidestart = (type == SIDE) ? START_TAB : START_SLOT;

      //Front enge
      if((front)||(type != SIDE))
        for(i=[sidestart:2:fingers.y-1])
          translate([0, fingers_width.y*i]) {
            thickness = (type == FRONT)||(type == BACK) ? thickness : front_thickness;
            front_inset = (type == SIDE) ? front_inset : 0;
            translate([front_inset, 0])
              #square([thickness, fingers_width.y - ((type==SIDE)?kerf:0)]);
          }

      //Back edge
      translate([dim.x - thickness, 0])
        for(i=[sidestart:2:fingers.y-1])
          translate([0, fingers_width.y*i])
            #square([thickness, fingers_width.y - ((type==SIDE)?kerf:0)]);


      //Shelves
      if(shelves > 0)
        for(j=[1:1:(shelves)])
          for(i=[bottomstart:2:fingers.x-1])
            translate([0, bottom_thickness + bottom_inset + shelf_thickness*(j-1)])
            translate([fingers_width.x*i + kerf/2, ((dim.y - bottom_thickness - bottom_inset - top_thickness - shelf_thickness*shelves)/(shelves+1))*j])
              #square([fingers_width.x - kerf, shelf_thickness]);

      //Dividers
      if(!divider_removable){
        if(type != SIDE)
        //Slots for vertical dividers tabs
        if(dividers.x != undef)
          translate([0, bottom_thickness + bottom_inset + divider_height/2 ])
          for(x=[1:1:dividers.x])
            translate([divider_thickness/2 + divider_thickness*(x-1/2)+ div_space.x*x, kerf/2])
              #square([divider_thickness, divider_height/3 - kerf]); 

        if(type == SIDE)
        //Slots for horizontal dividers tabs
        if(dividers.y != undef)
          translate([front_thickness + front_inset, bottom_thickness + bottom_inset + divider_height/2 ])        
            for(i=[1:1:dividers.y])
              translate([div_space.y*i + divider_thickness*(i-1) + kerf/2, 0])
                #square([divider_thickness, divider_height/3 - kerf]);
      }
    }
  }

  // Horizontal divider panel
  module hdivider() 
  {
    translate([0, bottom_thickness])    
    difference() {
      union(){
        square([idim.x, divider_height]);
        if (!divider_removable){
          //Left tab
          translate([-thickness, divider_height/2])
            #square([thickness, divider_height/3]);
          //Right tabs
          translate([idim.x, divider_height/2])
            #square([thickness, divider_height/3]);
        //Bottom tabs
        for(i=[0:1:div_fingers.x-1])
          translate([div_finger_space.x*(i*2+1) - divider_finger_width.x/2, - bottom_thickness])
            #square([divider_finger_width.x, bottom_thickness]);        
        }
      }
      // Slots for X dividers
      for(i=[1:1:dividers.x])
        translate([div_space.x*i + divider_thickness*(i-1), 0])
          #square([divider_thickness, divider_height/2]);
    }
  }

  //Vertical divider panel
  module vdivider() 
  {
    difference() {
      union() {
        square([idim.y, divider_height]); 
        if (!divider_removable){
          //Back tabs
          translate([-thickness, divider_height/2])
            #square([thickness, divider_height/3]);
          //Front tabs
          translate([idim.y, divider_height/2])
            #square([front_thickness, divider_height/3]);
          //Bottom tabs
          for(i=[0:1:div_fingers.y-1])
            translate([div_finger_space.y*(i*2+1) - divider_finger_width.y/2, - bottom_thickness])
              square([divider_finger_width.y, bottom_thickness]);        
        }
      }
      // Slots for horizontal dividers
      for(i=[1:1:dividers.y])
        translate([div_space.y*i + divider_thickness*(i-1), divider_height/2])
          #square([divider_thickness, divider_height/2]);
    }
  }


  //Generate parts
  spacing = 1;
  
  //Bottom
  bottom(dim, fingers, fingers_width);

  //Back
  translate([0, dim.y + spacing])
    side([dim.x, dim.z], [fingers.x, fingers.z], [fingers_width.x, fingers_width.z], type=BACK);

  //Front
  if(front)
    translate([0, - spacing]) mirror([0,1])
      side([dim.x, dim.z], [fingers.x, fingers.z], [fingers_width.x, fingers_width.z], type=FRONT);

  //Left
  translate([- (drawer_slide_width + spacing), 0]) rotate(90)
    side([dim.y, dim.z], [fingers.y, fingers.z], [fingers_width.y, fingers_width.z], type=SIDE);

  //Right
  translate([dim.x + drawer_slide_width + spacing, 0]) mirror([1,0]) rotate(90)
    side([dim.y, dim.z], [fingers.y, fingers.z], [fingers_width.y, fingers_width.z], type=SIDE);

  if (dividers) {
    if (dividers.y)
      translate([thickness, dim.y + spacing + dim.z + spacing])
        for(i=[0:1:dividers.y-1])        
          translate([0, (divider_height + bottom_thickness + spacing)*(i)])
            hdivider();
        
    if (dividers.x)
      translate([dim.x + drawer_slide_width + spacing + dim.z + spacing + bottom_thickness, 0])
        for(i=[0:1:dividers.x-1])        
        translate([(divider_height + bottom_thickness + spacing)*(i), dim.y - thickness ]) rotate ([0,0,-90])
            vdivider();
    }
}


boxgen(
  [54*2,54*2,44],
  thickness = 3,
  bottom_thickness = 4,
  front_thickness = 4,
  front_inset = 6,
  drawer_slide_width = 8,
  dividers = [3,3]
);