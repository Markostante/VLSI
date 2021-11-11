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

% Search and restart choice variables
int: SEARCH_TYPE = 2;
int: RESTART_TYPE = 4;

% Search type
ann: search_ann = 
  if SEARCH_TYPE == 1 then int_search([height], input_order, indomain_min)
  elseif SEARCH_TYPE == 2 then int_search([height], first_fail, indomain_min)
  elseif SEARCH_TYPE == 3 then int_search([height], dom_w_deg, indomain_min)
  elseif SEARCH_TYPE == 4 then int_search([height], input_order, indomain_random)
  elseif SEARCH_TYPE == 5 then int_search([height], first_fail, indomain_random)
  else int_search([height], dom_w_deg, indomain_random)
  endif;

% Restart type
ann: restart_ann =
  if RESTART_TYPE == 1 then restart_constant(750)
  elseif RESTART_TYPE == 2 then restart_linear(20)
  elseif RESTART_TYPE == 3 then restart_geometric(1.5, 500)
  else restart_luby(250)
  endif;

% Solve CP problem
%solve :: search_ann :: restart_ann minimize height;


solve minimize height;


output ["\(width) \(height)\n\(n)\n"]
       %++ ["Plate height: \(height)\n"]
       ++ ["\(DX[i]) \(DY[i]) \(x[i]) \(y[i])"
       ++ "\n"
      | i in 1..n];