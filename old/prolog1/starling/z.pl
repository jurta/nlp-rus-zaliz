% write_sl(StringList,Separator). - write list of strings
write_sl([],_)      :- !.
write_sl([H],_)     :- writef("%s",[H]), !.
write_sl([H|T],Sep) :- writef("%s%s",[H,Sep]), write_sl(T,Sep).

setofall(Var, Goal, Set) :-
        findall(Var, Goal, Bag), 
        sort(Bag, Set).

accent:-w(W,a(A),_,_,_,_,_,_),name(W,WW),select(L,0'',WW),nth0(A,L,0''),puts(L),fail. 


permute(L1,L2) :- select(L1,X,L),select(L2,X,L).

prefix(Prefix, List) :- append(Prefix, _, List).
suffix(Suffix, List) :- append(_, Suffix, List).
% last(Elem, List) :- append(_, [Elem], List).

% prefix([], _).
% prefix([H|T1], [H|T2]) :-  prefix(T1, T2).

% suffix(Elem, Elem)     :- is_list(Elem).
% suffix(Elem, [_|List]) :- suffix(Elem, List).

% last(Elem, List) :- suffix([Elem], List).

lastof(W,L) :- last(C,W), member(C,L).

replace(C1,C2,S1,S2) :- nonvar(S1), append(S,[C1|C],S1), append(S,[C2|C],S2), !.
replace(C1,C2,S1,S2) :- nonvar(S2), append(S,[C2|C],S2), append(S,[C1|C],S1).

replace2(C1,C2,S1,S2) :- replace(C1,C2,S1,S2), !.
replace2(_,_,S,S).


%% миг -> век -> эра
%% должен быть поиск в ширину !
word_chain_test :- word_chain('миг',['миг']).
word_chain('век',L) :- write(L), nl, !.
word_chain(W1,L) :-
        name(W1,WW), append(WW1,[_|WW2],WW), append(WW1,[_|WW2],WW3),
        w(W2,_,G,_,_), (G==м;G==мо;G==ж;G==жо;G==с;G==со),
        W1\==W2, not(member(W2,L)), name(W2,WW3),
        writef("%w %w\n",[W1,W2]),
        word_chain(W2,[W2|L]).


