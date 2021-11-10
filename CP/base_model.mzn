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
int: lower_bound = max(DY);
int: upper_bound = sum(DY);

% ==== Output variables ==== 

% Horizontal coordinate of circuits
array[N_CIRCUITS] of var 0..width-1: x;

% Vertical coordinate of circuits
array[N_CIRCUITS] of var 0..sum(DY)-1: y;

% Height of the plate to minimize
var lower_bound..upper_bound: height;
height = max([y[i] + DY[i] | i in N_CIRCUITS]);

% ==== Domain reduction ====

constraint forall(i in N_CIRCUITS) (x[i]<=width-DX[i])::domain;
constraint forall(i in N_CIRCUITS) (y[i]<=height-DY[i])::domain;

% ==== Main constraints ====

% Forse inutili per come abbiamo costruito il problema e per la riduzione del dominio, ma non dovrebbero creare problemi

% Maximum width
constraint max([x[i] + DX[i] | i in N_CIRCUITS]) <= width;

% Maximum height
constraint max([y[i] + DY[i] | i in N_CIRCUITS]) <= upper_bound;

% ==== Global constraints ==== 

% Each circuit is an activity with duration equal to its height and amount of resource equal to its width
constraint cumulative(y, DY, DX, width);
constraint cumulative(x, DX, DY, height);

% Relationships among circuits
constraint diffn(x, y, DX, DY);

% ==== Search ====

% Questa parte dobbiamo modificarla ma per il momento la lascio così

        
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