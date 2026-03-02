sudoku(Rows) :-
    Rows = [A, B, C, D],   
    row([1,2,3,4], A),
    row([1,2,3,4], B),
    maplist(\=,A,B),

    blocks(A, B),

    row([1,2,3,4], C),
    maplist(\=,A,C),
    maplist(\=,B,C),

    row([1,2,3,4], D),
    maplist(\=,A,D),
    maplist(\=,B,D),
    maplist(\=,C,D),

    blocks(C, D).

row([], []).
row(Row, [H|T]) :-
    nth1(_, Row,H, Rest),
    row(Rest, T).

all_distinct([]).
all_distinct([X|Xs]) :-
    \+ member(X, Xs), 
    all_distinct(Xs).

blocks([], []).
blocks([N11,N12|Bs1],[N21,N22|Bs2] ) :- all_distinct([N11,N12,N21,N22]),blocks(Bs1,Bs2). 

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
solution(L) :- sudoku(L), maplist(portray_clause,L).

solutions(Rows, L) :- findall(Rows, sudoku(Rows), L), maplist(separator, L).

    separator(L):-maplist(portray_clause,L),writeln('----------------------------').


solutions_length(Rows, Length) :- findall(Rows, sudoku(Rows), L),length(L, Length). 

/*%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*/
generator(N,Rows, Puzzle) :- new_sudoku(N, Rows, Puzzle), solutions_length(Puzzle, 1).

generator(N, Puzzle) :- sudoku(Rows), new_sudoku(N,Rows, Puzzle), solutions_length(Puzzle, 1).

new_sudoku(0,Rows,Rows).
new_sudoku(N, [Row|Rows], [NewRow|NewRows]) :-
    new_row(N,Nn, Row, NewRow), 
    new_sudoku(Nn, Rows, NewRows). 

new_row(N,N, [], []).
new_row(N,Nn, [X|Xs], [X|Ys]) :-  new_row(N,Nn, Xs, Ys).

new_row(N,Nn ,[_|Xs], [_|Ys]) :- 
    N > 0, 
    N1 is N - 1, 
    new_row(N1,Nn, Xs, Ys).
