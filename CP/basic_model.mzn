%include "disjunctive.mzn";
include "diffn.mzn";
include "cumulative.mzn";

%plate width
int: width;
set of int: FEASIBLE_WIDTH = 1..width;

%plate maximum height
int: height_max;
set of int: FEASIBLE_HEIGHT = 1..height_max;

%circuits
int: n;
set of int: N_CIRCUITS = 1..n;

%width of circuits
array[N_CIRCUITS] of FEASIBLE_WIDTH: DX;

%height of circuits
array[N_CIRCUITS] of FEASIBLE_HEIGHT: DY;

%array to specify whether a circuit is rotated or not
array[N_CIRCUITS] of var bool: is_rotated;

%horizontal dimension of circuits
array[N_CIRCUITS] of var FEASIBLE_WIDTH: DX_R = [if is_rotated[i] then DY[i] else DX[i] endif | i in N_CIRCUITS];

%vertical dimension of the circuits
array[N_CIRCUITS] of var FEASIBLE_HEIGHT: DY_R = [if is_rotated[i] then DX[i] else DY[i] endif | i in N_CIRCUITS];

%circuits area
%array[N_CIRCUITS] of int: area = [ DX[i] * DY[i] | i in N_CIRCUITS];

%circuit with the maximum height
%int: index_max_height = arg_max(DY);

%variable definition

%horizontal coordinate of circuits
array[N_CIRCUITS] of var 0..width-min(DX): x;

%vertical coordinate of circuits
array[N_CIRCUITS] of var 0..height_max-min(DY): y;

%height of the plate to minimize
var FEASIBLE_HEIGHT: height;
height = max([y[i] + DY[i] | i in N_CIRCUITS]);

%constraints

%implied constraints

%maximum width
constraint max([x[i] + DX_R[i] | i in N_CIRCUITS]) <= width;

% maximum height (it could be eliminated for construction of height_max if we do not take into account rotation)
constraint max([y[i] + DY_R[i] | i in N_CIRCUITS]) <= height_max;

% relationships among circuits
constraint diffn(x, y, DX_R, DY_R);

% a circuit cannot be rotated whether its height is greater than width
constraint forall(i in N_CIRCUITS)(DY[i] > width -> is_rotated[i]==false);

% considering each circuit as an activity whose duration is the height and amount of resources is equal to its width
constraint cumulative(y, DY_R, DX_R, width);
constraint cumulative(x, DX_R, DY_R, height_max);



solve minimize height;

%output ["\(width) \(height)\n\(n)\n"] ++ ["\(DX[i]) \(DY[i])\t\(X[i]) \(Y[i])\n" | i in 1..n];


output ["\(width) \(height_max)\n\(n)\n"]
       ++ ["Plate height: \(height)\n"]
       ++ ["\(DX_R[i]) \(DY_R[i]) \(x[i]) \(y[i])"
       ++ "\n"
      | i in 1..n];