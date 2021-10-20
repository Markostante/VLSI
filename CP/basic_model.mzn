% *** COSE DA SCRIVERE ANCHE NEL REPORT ***
include "disjunctive.mzn";
include "diffn.mzn";
include "cumulative.mzn";

%La prima cosa da fare è definire in che modo modellare le istanze fornite.
%Dalla traccia sappiamo che la seguente istanza:

%8
%4
%3 3
%3 5
%5 3
%5 5

%significa che il "contenitore" è un rettangolo con larghezza 8,
%abbiamo 4 figure in totale (tra quadrati e rettangoli),
%e le misure delle figure sono larghezza e altezza.

%Una possibile soluzione è la seguente:
%dichiariamo una variabile width che rappresenta la larghezza del contenitore e
%una variabile n (int) per indicare il numero di circuits
%due array di interi DX e DY con dimensione n che contengono le dimensioni in larghezza e altezza degli n circuits.

%Quindi l'istanza di prima verrebbe riscritta in un file dzn come segue:

%width = 8;
%n = 4;
%DX = [3, 3, 5, 5];
%DY = [3, 5, 3, 5];

%Deciso come salvare le istanze, possiamo iniziare col problema vero e proprio.
%Definiamo le variabili che prenderanno i valori dal file dzn come segue:

int: width;
%int: height; -> va calcolato facendo la somma di DY (significa che mettiamo
%tutti i circuit in colonna e otteniamo l’altezza massima non ottimizzata)
int: n;
array[1..n] of int: DX;
array[1..n] of int: DY;

%width = 8;
%n = 4;
%DX = [3, 3, 5, 5];
%DY = [3, 5, 3, 5];

int: max_height = sum([DY[i] | i in 1..n]);

%Dopo le istanze, dobbiamo aggiungere altri due array X e Y che fanno riferimento
%alle coordinate di ciascun circuit (le coordinate dell'angolo in basso a sinistra
% di ciascun circuit -> per capire meglio guarda "Solution Format" sul
%pdf di Zeynep).

array[1..n] of var 0..(width - min(DX)): X;
array[1..n] of var 0..(max_height - min(DY)): Y;

%Il -min(DX) ( -min(DY) ) nell'estremo superiore del range di valori
% di X (Y) serve per restringere il range di valori (quindi ottimizzare)
%che le coordinate possono assumere -> usiamo il minimo dell'array DX (DY)
%perché X (Y) può avere come valore massimo la larghezza (altezza) meno
%la larghezza (altezza) del circuit con larghezza (altezza) minore.

%definiamo la nostra objective function che corrisponde all’altezza del plate
var int: height = max([Y[i] + DY[i] | i in 1..n]);

%Ora aggiungiamo un constraint basico riguardante la sovrapposizione
%dei circuit:
%DUBBIO: nella lezione 2 dice di applicare un constraint noOverlap,
%ma non credo esista e, anche se esistesse, suppongo sia solo per array e non matrici

%il seguente constraint è una versione rivisitata del constraint noOverlap
%dello scheduling problem in Lesson 2:

%constraint forall(i in 1..n) (
%      %disjunctive([X[i] + DX[i]], [X[j] + DX[j] | j in 1..n where i < j])
%      disjunctive(X,DX)
%);

%constraint disjunctive(X,DX);
%constraint disjunctive(Y,DY);

constraint diffn(X, Y, DX, DY);

%constraint forall(i, j in 1..n where i < j) (
%     X[i] + DX[i] <= X[j]
%  \/ X[j] + DX[j] <= X[i]
%  \/ Y[i] + DY[i] <= Y[j]
%  \/ Y[j] + DY[j] <= Y[i]
%);

%Ora applichiamo un constraint per rispettare i limiti del contenitore -> abbiamo cambiato tipologia di constraint
%per utilizzare un global constraint sfruttando il concetto di linea verticale e orizzontale scritto nella traccia (cumulative constraint)
%Link da guardare anche per le cose del report + spiegazione fatta decentemente sul constraint:
%https://sofdem.github.io/gccat/gccat/Cdiffn.html

constraint cumulative(Y, DY, X, width);
constraint cumulative(X, DX, Y, max_height);

%Constraint sui boundaries che non utilizza un global constraint:
%constraint forall(i in 1..n) (
%  X[i] + DX[i] <= width /\ Y[i] + DY[i] <= max_height
%);

%solve satisfy;
solve minimize height;

%output ["\(width) \(height)\n\(n)\n"] ++ ["\(DX[i]) \(DY[i])\t\(X[i]) \(Y[i])\n" | i in 1..n];


output ["\(width) \(max_height)\n\(n)\n"]
       ++ ["Plate height: \(height)\n"]
       ++ ["\(DX[i]) \(DY[i]) \(X[i]) \(Y[i])"
       ++ "\n"
      | i in 1..n];





