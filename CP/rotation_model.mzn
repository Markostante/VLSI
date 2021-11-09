include "diffn.mzn";
include "cumulative.mzn";

% ==== Input variables ==== 

% Plate width
int: width;

% Number of total circuits to place
int: n;
set of int: N_CIRCUITS = 1..n;

% Width of circuits
array[N_CIRCUITS] of int: DX;

% Height of circuits
array[N_CIRCUITS] of int: DY;

% ==== Support variables ==== 

% Plate bounds
int: upper_bound = sum([max(DY[i], DX[i]) | i in N_CIRCUITS]);
int: lower_bound = max(DY ++ DX);

% Array to specify whether a circuit is rotated or not
array[N_CIRCUITS] of var bool: is_rotated;

% Actual horizontal dimension of circuits
array[N_CIRCUITS] of var int: DX_R = [if is_rotated[i] then DY[i] else DX[i] endif | i in N_CIRCUITS];

% Actual vertical dimension of the circuits
array[N_CIRCUITS] of var int: DY_R = [if is_rotated[i] then DX[i] else DY[i] endif | i in N_CIRCUITS];

% ==== Output variables ==== 

% Horizontal coordinate of circuits
array[N_CIRCUITS] of var 0..width-1: x;

% Vertical coordinate of circuits
array[N_CIRCUITS] of var 0..sum(DY)-1: y;

% Height of the plate to minimize
var lower_bound..upper_bound: height;
height = max([y[i] + DY_R[i] | i in N_CIRCUITS]);

% ==== Domain reduction ====

constraint forall(i in N_CIRCUITS) (x[i]<=width-DX_R[i])::domain;
constraint forall(i in N_CIRCUITS) (y[i]<=height-DY_R[i])::domain;

% ==== Main constraints ====

% Maximum width
constraint max([x[i] + DX_R[i] | i in N_CIRCUITS]) <= width;

% Maximum height
constraint max([y[i] + DY_R[i] | i in N_CIRCUITS]) <= upper_bound;

% A circuit cannot be rotated if its height is greater than plate width
constraint forall(i in N_CIRCUITS)(DY[i] > width -> is_rotated[i]==false);

% ==== Global constraints ====

% Each circuit is an activity with duration equal to its height and amount of resource equal to its width
constraint cumulative(y, DY_R, DX_R, width);
constraint cumulative(x, DX_R, DY_R, height);

% Relationships among circuits
constraint diffn(x, y, DX_R, DY_R);

% ==== Symmetry breaking constraints ====

% Circuits which have dimensions that are the same should not be rotated (forse inutile)
constraint symmetry_breaking_constraint(
  forall (i in N_CIRCUITS) (DX[i] = DY[i] -> is_rotated[i] = 0)
);

% The circuit with the maximum height is placed at position (x,y) = (0,0)
int: index_max_height = arg_max(DY);

constraint symmetry_breaking_constraint(
  x[index_max_height] == 0 /\ y[index_max_height] == 0
);

% Higher density of circuits on the left
array[N_CIRCUITS] of int: area = [ DX[i] * DY[i] | i in N_CIRCUITS];

constraint symmetry_breaking_constraint(
  sum(i in N_CIRCUITS where x[i] <= width div 2)(area[i]) > sum(i in N_CIRCUITS where x[i] > width div 2)(area[i])
);

% ==== Search ====

% Questa parte dobbiamo modificarla ma per il momento la lascio così

int: heuristic = 6;
int: restart = 4;

ann: search_ann_x = 
if heuristic == 1 then
  int_search(x, input_order, indomain_min)
elseif heuristic == 2 then
  int_search(x, first_fail, indomain_min)
elseif heuristic == 3 then
  int_search(x, dom_w_deg, indomain_min)
elseif heuristic == 4 then
  int_search(x, input_order, indomain_random)
elseif heuristic == 5 then
  int_search(x, first_fail, indomain_random)
else
  int_search(x, dom_w_deg, indomain_random)
endif;

ann: search_ann_y = 
if heuristic == 1 then
  int_search(y, input_order, indomain_min)
elseif heuristic == 2 then
  int_search(y, first_fail, indomain_min)
elseif heuristic == 3 then
  int_search(y, dom_w_deg, indomain_min)
elseif heuristic == 4 then
  int_search(y, input_order, indomain_random)
elseif heuristic == 5 then
  int_search(y, first_fail, indomain_random)
else
  int_search(y, dom_w_deg, indomain_random)
endif;

ann: restart_ann =
if restart == 1 then
  restart_constant(100)
elseif restart == 2 then
  restart_linear(100)
elseif restart == 3 then
  restart_geometric(1.5,100)
elseif restart == 4 then
  restart_luby(100)
else
  restart_none
endif;

%solve :: search_ann_x
%      :: search_ann_y
%      :: restart_ann
%         minimize height;


solve minimize height;


output ["\(width) \(height)\n\(n)\n"]
       %++ ["Plate height: \(height)\n"]
       ++ ["\(DX_R[i]) \(DY_R[i]) \(x[i]) \(y[i])"
       ++ "\n"
      | i in 1..n];