
%% next is from w.pl
% selectn(?List1, ?Elem, +First, ?Index, ?List2)
selectn0(List1, E, N, List2) :- selectn(List1, E, 0, N, List2).
selectn1(List1, E, N, List2) :- selectn(List1, E, 1, N, List2).
selectn([E|Tail], E, I, I, Tail).
selectn([Head|Tail], Elem, I, N, [Head|Rest]) :-
        selectn(Tail, Elem, I, M, Rest),
        succ(M, N).

% replacen(?List1, ?OldElem, +First, ?Index, ?NewElem, ?List2)
replacen0(List1, Old, N, New, List2) :- replacen(List1, Old, 0, N, New, List2).
replacen1(List1, Old, N, New, List2) :- replacen(List1, Old, 1, N, New, List2).
replacen([E|Tail], E, I, I, Y, [Y|Tail]).
replacen([Head|Tail], Elem, I, N, NewElem, [Head|Rest]) :-
        replacen(Tail, Elem, I, M, NewElem, Rest),
        succ(M, N).

%% count - copy it from z.pl

%% next is only for testing, all this is NOT needed
nthqq_gen([Elem|_], Elem, Base, Base, Goal) :- call(Goal, Elem).
nthqq_gen([Elem|Tail], Elem2, N, Base, Goal) :-
        call(Goal, Elem), !, succ(N, M), nthqq_gen(Tail, Elem2, M, Base, Goal).
nthqq_gen([_|Tail], Elem, N, Base, Goal) :-
        nthqq_gen(Tail, Elem, N, Base, Goal).
nthq0(Index, List, Elem, Goal) :- nth0(Index, List, Elem), call(Goal, Elem).
nthq1(Index, List, Elem, Goal) :- nth1(Index, List, Elem), call(Goal, Elem).
nthqq0(Index, List, Elem, Goal) :- nthqq_gen(List, Elem, 0, Index, Goal).
nthqq1(Index, List, Elem, Goal) :- nthqq_gen(List, Elem, 1, Index, Goal).
nthqqq0(Index, List, Elem, Goal) :- sublist(Goal, List, List2), nth0(Index, List2, Elem).
nthqqq1(Index, List, Elem, Goal) :- sublist(Goal, List, List2), nth1(Index, List2, Elem).

% vowel(X) :- member(X,[a,e,i,o,u]).
