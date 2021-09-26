% *** COSE DA SCRIVERE ANCHE NEL REPORT ***
include "disjunctive.mzn";
include "diffn.mzn";
include "cumulative.mzn";
include "lex_lesseq.mzn";

int: width;
int: max_height;
int: n;
array[1..n] of int: DX;
array[1..n] of int: DY;

% Primal problem: the i-th element of each array contains one (X/Y) coordinate of the bottom-left corner of the i-th piece of paper
array[1..n] of var 0..(width - min(DX)): X;
array[1..n] of var 0..(max_height - min(DY)): Y;
% Dual problem: each cell in the 2D grid contains the number of the piece of paper it belongs
array[1..max_height, 1..width] of var 0..n: B;

% Channelling constraint - per far comunicare i due modelli
constraint forall(i in 1..max_height, j in 1..width, v in 1..n) (
  B[i, j] = v <-> i > Y[v] /\ i <= Y[v] + DY[v] /\ j > X[v] /\ j <= X[v] + DX[v]
);

%Constraint non overlapping 
constraint diffn(X, Y, DX, DY);

constraint cumulative(Y, DY, X, width);
constraint cumulative(X, DX, Y, max_height);

% ****** FIN QUI BASIC MODEL ******

% ****** INIZIO SYMMETRY MODEL ******

% Symmetry breaking
%per spezzare le simmetrie dobbiamo collegare il modello che rompe le simmetrie e quello che consente di rispettare tutti gli altri constraint.
constraint symmetry_breaking_constraint(
     lex_lesseq(array1d(B), [B[i, j] | i in reverse(1..max_height), j in 1..width])  % prevent vertical flip
  /\ lex_lesseq(array1d(B), [B[i, j] | i in 1..n, j in reverse(1..n)])  % prevent horizontal flip
  /\ lex_lesseq(array1d(B), [B[i, j] | i, j in reverse(1..n)])  % prevent 180deg rotation
);

%definiamo la nostra objective function che corrisponde all’altezza del plate
var int: height = max([Y[i] + DY[i] | i in 1..n]);

% Parameters to control the search heuristic and restart strategy
int: hs = 3;
int: restart = 2;

%constraint sull'heuristic 
ann: search_ann = 
if hs == 1 then
  int_search(X, input_order, indomain_min)
elseif hs == 2 then
  int_search(X, first_fail, indomain_min)
elseif hs == 3 then
  int_search(X, dom_w_deg, indomain_min)
elseif hs == 4 then
  int_search(X, input_order, indomain_random)
else
  int_search(X, dom_w_deg, indomain_random)
endif;

ann: restart_ann =
if restart == 1 then
  restart_constant(100)
elseif restart == 2 then
  restart_geometric(1.5, 100)
else
  restart_luby(250)
endif;


%solve satisfy;
solve 
  :: search_ann
  :: restart_ann
minimize height;

%output ["\(width) \(height)\n\(n)\n"] ++ ["\(DX[i]) \(DY[i])\t\(X[i]) \(Y[i])\n" | i in 1..n];


output ["\(width) \(max_height)\n\(n)\n"]
       ++ ["Plate height: \(height)\n"]
       ++ ["\(DX[i]) \(DY[i]) \(X[i]) \(Y[i])"
       ++ "\n"
      | i in 1..n];





