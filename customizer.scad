include <boxgen.scad>

//Size by X axis in 54 mm units 
X = 1; // [1:4]

//Size by Y axis in 54 mm units
Y = 1; // [1:4]

//Size by Z axis in 44 mm units
Z = 1; // [1:2]

//Material thickness
T = 3; // [3:12]

//Amount to inset the bottom side
BI = 0; // [3:3:9]

//Front panel material thickness
FT = 3; // [3:12]

//Amount to inset the front side
FI = 0; // [0:3:6]

//Dividers by X axis
DX = 0; //[0:3]

//Dividers by Y axis
DY = 0; //[0:3]

boxgen(
  [54*X,54*Y,54*Z],
  thickness = T,
  bottoninset = BI,
  front_thickness = FT,
  frontinset = FI,
  dividers = [DX, DY]
);