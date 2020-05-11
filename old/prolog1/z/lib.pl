portray(X):-write(X).

% from ./lang/langware/lib.pl
% repeat(+N) - succeeds N times
% e.g. repeat(3), write('Hello, Prolog'), nl, fail. % write string 3 times

% replaced by next
% repeat(N) :- N > 0.
% repeat(N) :- N > 0, N1 is N-1, repeat(N1).
repeat(N) :- between(0, N, _).

% very new
a(a). a(b). a(c). a(d). a(e). a(f).
a :- a(X), fail(4), write(X). % should be 'e'

fail(N) :- flag(fails, N1, N1), N1 =< 0, flag(fails, _, N+1), fail.
fail(_) :- flag(fails, N, N-1), N =< 1, flag(fails, _, 0).

% fail(N) :- random(2,N2), N2==2.
% fail(N) :- fail.

% random(Int,N) :- N is random(Int) + 1.
random(Int,N) :- random(0,Int,N).

% property lists
getp(P,V,[P,V|_]).
getp(P,V,[_,_|T]) :- getp(P,V,T).
% or member(X,L).

word(W,PL) :- w(W,L), allp(PL,L).

allp([],_).
allp([P,V|T],L) :- getp(P,V,L), allp(T,L).

ww1:-telling(O),tell(testw),w(W,_,'ж',_),fail(1000),write(W),nl,fail;told,tell(O). 
ww2:-word(W,[g,мо,s,'16']),write(W),nl,fail.
ww3:-word(W,[]),name(W,WW),length(WW,N),N>23,write(W),nl,fail.
ww4:-word(W,[]),name(W,WW),length(WW,N),N>10,suffix("ое",WW),write(W),nl,fail.
ww5:-word(W,[g,G]),G\==с,G\==со,name(W,WW),suffix("ое",WW),write([W,G]),nl,fail.

wwg1:-word(W,[g,G]),G\==м,G\==мо,not(гласная(_)),name(W,WW),suffix("ое",WW),write([W,G]),nl,fail.

% statistics
stat:-w(W,_,_,_),length(W,L),flag(w,WN,WN+1),flag(l,WL,WL+L),fail.
stat:-flag(w,WN,0),flag(l,WL,0),M is WL/WN,write([words:WN,len:WL,average_len:M]).
stat2 :-
        flag(w, OldW, 0), flag(l, OldL, 0),
        (w(W,_,_,_), length(W,L), flag(w,WN,WN+1), flag(l,WL,WL+L),
        fail;
        flag(w, WNT, OldW), flag(l, WLT, OldL), M is WLT/WNT,
        write([words:WNT,len:WLT,average_len:M])).

% from documentation
succeeds_n_times(Goal, Times) :-
        flag(succeeds_n_times, Old, 0),
        (Goal, flag(succeeds_n_times, N, N+1), fail ;
        flag(succeeds_n_times, Times, Old)).

% from ./doc/prog/prolog/new/cmu/library/prolog/library/
prefix([], _).
prefix([Elem|T1], [Elem|T2]) :- prefix(T1, T2).

suffix(Suffix, Suffix) :- is_list(Suffix).
suffix(Suffix, [_|T])  :- suffix(Suffix, T).

% ?- time((see('zaliza.pl'),tell('zaliza.pl~'),gets(S),puts(S),fail;seen,see(user),told,tell(user))).
% 18,366,678 inferences in 34.33 seconds (535004 Lips)
gets(S) :- get0(C), (C == -1 -> !,fail ; gets_2(C,"",S)) ; gets(S).
gets_2(-1,S,S) :- !.
gets_2(10,S,S).
gets_2(C,S,[C|S2]) :- C\==10, get0(C2), gets_2(C2,S,S2).

puts(S) :- atom(S), !, writeln(S).
puts(S) :- is_list(S), !, writef("%s\n",[S]).
