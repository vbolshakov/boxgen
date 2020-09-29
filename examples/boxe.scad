include <../boxgen.scad>

boxgen(
  [326+6+2,246+5,3+(44+2)*3+3+3+3],
  finger_width = 12,
  front = false,
  top = true,
  bottom_inset = 0,
  shelves=2,
  dividers = [2, 2],
  thickness = 3,
  kerf = 0.125
);