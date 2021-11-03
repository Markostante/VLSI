include "diffn.mzn";
include "cumulative.mzn";

%plate width
int: width;

%plate maximum dimensions
int: upper_bound = sum([max(DY[i], DX[i]) | i in N_CIRCUITS]);
int: lower_bound = max(DY ++ DX);

%circuits
int: n;
set of int: N_CIRCUITS = 1..n;

%width of circuits
array[N_CIRCUITS] of int: DX;

%height of circuits
array[N_CIRCUITS] of int: DY;

%circuits area
%array[N_CIRCUITS] of int: area = [ DX[i] * DY[i] | i in N_CIRCUITS];

%circuit with the maximum height
%int: index_max_height = arg_max(DY);

%variable definition

%horizontal coordinate of circuits
array[N_CIRCUITS] of var 0..width-1: x;

%vertical coordinate of circuits
array[N_CIRCUITS] of var 0..sum(DY)-1: y;

%height of the plate to minimize
var lower_bound..upper_bound: height;
height = max([y[i] + DY[i] | i in N_CIRCUITS]);

% area of circuits
array[N_CIRCUITS] of int: area = [ DX[i] * DY[i] | i in N_CIRCUITS];

% circuit with the maximum height
int: index = arg_max(DY);

%domain reduction
constraint forall(c in N_CIRCUITS) (x[c]<=width-DX[c])::domain;
constraint forall(c in N_CIRCUITS) (y[c]<=height-DY[c])::domain;

%constraints

%implied constraints

%maximum width
constraint max([x[i] + DX[i] | i in N_CIRCUITS]) <= width;

% maximum height (it could be eliminated for construction of height_max if we do not take into account rotation)
constraint max([y[i] + DY[i] | i in N_CIRCUITS]) <= upper_bound;

% relationships among circuits
constraint diffn(x, y, DX, DY);


% considering each circuit as an activity whose duration is the height and amount of resources is equal to its width
constraint cumulative(y, DY, DX, width);
constraint cumulative(x, DX, DY, height);

% symmetry breaking constraint
constraint symmetry_breaking_constraint(
  x[index] == 0 /\ y[index] == 0
);

% higher density on the left wrt the right
constraint symmetry_breaking_constraint(
  sum(i in N_CIRCUITS where x[i] <= width div 2)(area[i]) > sum(i in N_CIRCUITS where x[i] > width div 2)(area[i])
);
        
% Parameters to control the search heuristic and restart strategy
int: heuristic = 1;
int: restart = 1;

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
       ++ ["\(DX[i]) \(DY[i]) \(x[i]) \(y[i])"
       ++ "\n"
      | i in 1..n];