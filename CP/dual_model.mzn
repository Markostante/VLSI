include "diffn.mzn";
include "cumulative.mzn";
include "lex_lesseq.mzn";
include "global_cardinality_low_up.mzn";

%input

%plate width
int: width;

%plate maximum dimensions
int: upper_bound = sum([max(DY[i], DX[i]) | i in N_CIRCUITS]);
int: lower_bound = max(DY ++ DX);

%circuits number
int: n;
set of int: N_CIRCUITS = 1..n;

%width of circuits
array[N_CIRCUITS] of int: DX;

%height of circuits
array[N_CIRCUITS] of int: DY;

%horizontal coordinate of circuits
array[N_CIRCUITS] of var 0..width-1: x;

%vertical coordinate of circuits
array[N_CIRCUITS] of var 0..sum(DY)-1: y;

%domain reduction
constraint forall(c in N_CIRCUITS) (x[c]<=width-DX[c])::domain;
constraint forall(c in N_CIRCUITS) (y[c]<=height-DY[c])::domain;

%height of the plate to minimize
var lower_bound..upper_bound: height;
height = max([y[i] + DY[i] | i in N_CIRCUITS]);

%dual model
%channeling with a matrix with the distribution of the circuits
set of int: VALUES = 1..n+1;
array[0..upper_bound-1, 0..width-1] of var VALUES: plate;

%constraints

%implied constraints

%maximum width
constraint max([x[i] + DX[i] | i in N_CIRCUITS]) <= width;

% maximum height
constraint max([y[i] + DY[i] | i in N_CIRCUITS]) <= upper_bound;

% relationships among circuits
constraint diffn(x, y, DX, DY);

% considering each circuit as an activity whose duration is the height and amount of resources is equal to its width
constraint cumulative(y, DY, DX, width);
constraint cumulative(x, DX, DY, upper_bound);

% channelling constraint
% constraint on the board
constraint forall(i in 0..upper_bound-1, j in 0..width-1, k in N_CIRCUITS)(plate[i,j] == k <-> (x[k] <= i /\ i < x[k] + DX[k] /\ y[k] <= j /\ j < y[k] + DY[k]));

%I CARDINALITY CONSTRAINT SONO PRESI DA MURRO, ma non li ho capiti benissimo al 100%
% cardinality constraint
constraint forall(i in 0..upper_bound-1)(
  global_cardinality_low_up([plate[i,j] | j in 0..width-1], 0..n, [0 | k in 0..n], [width | k in 0..n])
);

constraint forall(j in 0..width-1)(
  global_cardinality_low_up([plate[i,j] | i in 0..upper_bound-1], 0..n, [0 | k in 0..n], [upper_bound | k in 0..n])
);

% symmetry breaking (horizontal flip, vertical flip and 180° rotation)
constraint symmetry_breaking_constraint(
           lex_lesseq(array1d(plate), [ plate[i,j] | i in 0..upper_bound-1, j in reverse(0..width-1)])
        /\ lex_lesseq(array1d(plate), [ plate[i,j] | i in reverse(0..upper_bound-1), j in 0..width-1])
        /\ lex_lesseq(array1d(plate), [ plate[i,j] | i in reverse(0..upper_bound-1), j in reverse(0..width-1)]));


%solve satisfy;
solve minimize height;

output ["\(width) \(height)\n\(n)\n"] ++ ["\(DX[i]) \(DY[i])\t\(x[i]) \(y[i])\n" | i in N_CIRCUITS];





