include "diffn.mzn";
include "cumulative.mzn";
include "lex_lesseq.mzn";

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

% The biggest circuit is always placed in the bottom left part of the plate + under and on the left wrt the second biggest
array[N_CIRCUITS] of int : ordered_circuits = sort_by(N_CIRCUITS, [-DY[c]*DX[c] | c in N_CIRCUITS]);

constraint symmetry_breaking_constraint(
  let {
    int: c1 = ordered_circuits[n], int: c2 = ordered_circuits[2]
  } in lex_lesseq([y[c1],x[c1]], [y[c2],x[c2]]) /\ x[c1] * 2 <= width /\ y[c1] * 2 <= height %usiamo lesseq perché tanto c'è diffn che ci dice che le coordinate devono essere differenti + nelle prime istanze capita che una delle due coordinate è uguale tra 2 circuits (nelle soluzioni che vengono fornite dal base model), e quindi less not-equal sarebbe stato un hard constraint -> da scrivere nel report, poi lo cancelliamo da qui
); 

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
       ++ ["\(DX_R[i]) \(DY_R[i]) \(x[i]) \(y[i])"
       ++ "\n"
      | i in 1..n];