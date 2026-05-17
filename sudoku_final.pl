/*
 * The main predicate, solves a 4x4 Sudoku puzzle.
 * The grid is represented as a list of 4 rows: [A, B, C, D].
 * This predicate enforces row, column, and 2x2 block constraints dynamically.
 */
sudoku(Rows) :-
% Enforce domain and row uniqueness of A and B via permutations 
    Rows = [A, B, C, D],   
    row([1,2,3,4], A),
    row([1,2,3,4], B),
%column uniqueness between row A and B using element-wise inequality
    maplist(\=,A,B),
%2x2 block constraints for the top half of the grid
    blocks(A, B),

    row([1,2,3,4], C),
%column uniqueness for row C against all previous rows
    maplist(\=,A,C),
    maplist(\=,B,C),

    row([1,2,3,4], D),
%column uniqueness for row D against all previous rows
    maplist(\=,A,D),
    maplist(\=,B,D),
    maplist(\=,C,D),

    blocks(C, D).
    
%Generates the row permutation.
row([], []).
row(Row, [H|T]) :-
    nth1(_, Row,H, Rest),
    row(Rest, T).

 %Succeeds if all elements in the given list are unique.
all_distinct([]).
all_distinct([X|Xs]) :-
    \+ member(X, Xs), 
    all_distinct(Xs).
/** Validates the 2x2 block constraints.
  * Takes two adjacent rows, extracts elements in pairs of two, 
  * checks for uniqueness, and recurses.
  * easy Adaptable on 9X9 version */
blocks([], []).
blocks([N11,N12|Bs1],[N21,N22|Bs2] ) :- all_distinct([N11,N12,N21,N22]),blocks(Bs1,Bs2). 

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
/*UTILITY PREDICATES                                                                */
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
% Finds and prints a single valid Sudoku solution.
solution(L) :- sudoku(L), maplist(portray_clause,L).

% Finds all possible solutions and prints them separated by adding a dividing line between.
solutions(Rows, L) :- findall(Rows, sudoku(Rows), L), maplist(separator, L).

    separator(L):-maplist(portray_clause,L),writeln('----------------------------').

% Calculates the total number of valid solutions for a given grid state.
solutions_length(Rows, Length) :- findall(Rows, sudoku(Rows), L),length(L, Length). 

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
/* PUZZLE GENERATOR PREDICATES                                                      */
/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/

/** Generates a valid Sudoku puzzle with exactly 1 unique solution 
  * starting from a PROVIDED solved grid.
  * It takes an already solved grid (Rows), masks N elements to create the Puzzle,
  * and verifies that the resulting puzzle yields exactly one solution. */
generator(N,Rows, Puzzle) :- new_sudoku(N, Rows, Puzzle), solutions_length(Puzzle, 1).

/** Generates a valid Sudoku puzzle with exactly 1 unique solution 
  * starting from SCRATCH.
  * It first internally generates a valid solved grid (sudoku(Rows)), 
  * then masks N elements to create the Puzzle, and verifies its uniqueness.
  * * Note on Mathematical Proof: By utilizing this predicate through a brute-force 
  * approach (e.g., querying for N=12 masked elements), one can mathematically 
  * prove the minimum number of given elements (clues) required to guarantee 
  * a unique solution in a 4x4 Sudoku(4 elements) */
generator(N, Puzzle) :- sudoku(Rows), new_sudoku(N,Rows, Puzzle), solutions_length(Puzzle, 1).

/** Traverses the grid and replaces exactly N elements with unbound variables ('_')
  * to create a puzzle state from a solved grid*/
new_sudoku(0,Rows,Rows).
new_sudoku(N, [Row|Rows], [NewRow|NewRows]) :-
    new_row(N,Nn, Row, NewRow), 
    new_sudoku(Nn, Rows, NewRows). 

/** Helper predicate to traverse a single row and mask elements.
  * Keeps track of the remaining number of variables (from N down to Nn) to insert */
new_row(N,N, [], []).
new_row(N,Nn, [X|Xs], [X|Ys]) :-  new_row(N,Nn, Xs, Ys).

new_row(N,Nn ,[_|Xs], [_|Ys]) :- 
    N > 0, 
    N1 is N - 1, 
    new_row(N1,Nn, Xs, Ys).
