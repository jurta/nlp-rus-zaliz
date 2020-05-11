
ww(WW,A) :- w(W,A), name(W,WW).

% ?- ww(W,A),accent(W,A,WA),puts(WA),fail.
% ?- time((tell(acc),ww(W,A),accent(W,A,WA),puts(WA),fail;told)).

accent_type(0). % 0 - accent after letter, 1 - accent before letter
% accent_type(a). % 0 - accent after letter, 1 - accent before letter
accent_char(1,0x27). % primary accent letter
accent_char(2,0x60). % secondary accent letter

accent(W,A,WA) :- nonvar(W), гласные2(W), accent_a(W,A,1,WA), !.
accent(W,A,WA) :- nonvar(WA), accent_r(W,A,1,WA), !.
accent(W,0,W)  :- !.
accent(W,_,W).

accent_a(W,a(A1,A2),C,WA) :- accent_e(W,A1,C,W1), accent_e(W1,A2,2,WA), !.
accent_a(W,A,C,WA)        :- accent_e(W,A,C,WA).

accent_r(W,a(A1,A2),C,WA) :- accent_e(W1,A2,2,WA), accent_e(W,A1,C,W1), !.
accent_r(W,A,C,WA)        :- accent_e(W,A,C,WA).

accent_e(W,e(A),_,WA) :- replacen(W, 0'е, 1, A, 0'ё, WA).
accent_e(W,A,AI,WA) :-
        accent_type(AT), accent_char(AI,AC), selectn(WA, AC, AT, A, W).

% backup
% accent_e(W,e(A),_,WA) :- replace_elem(W,A,0'ё,WA), !.
% accent_e(W,0,_,W) :- !.
% accent_e(W,A,AI,WA) :-
%         accent_type(AT), accent_char(AI,AC),
%         Index is A - AT, insert_elem(W,A,AC,AT,WA), !.
% accent_e_r(W,A,AI,WA) :-
% %         accent_type(AT),
%         accent_char(AI,AC),
% %         insert_elem(W,A,AC,AT,WA), !.
%         select(WA,AC,W), nth0(A,WA,AC).
% accent_e_r(W,e(A),_,WA) :-
%         append(W0,[0'ё|W1],WA), append(W0,[0'е|W1],W),
%         length(W0,N), succ(N,A), !.
% % accent_e_r(W,A,1,C,WA) :-
% %         select(WA,C,W), nth1(A,WA,C).
% accent_letters(A,[C],[C,A]) :- flag(accent_type,0,0).
% accent_letters(A,[C],[A,C]) :- flag(accent_type,1,1).
% accent_letters(A,[C1],[C2]) :- flag(accent_type,2,2), accent_letter(A,C1,C2).
% accent_letter(0x27,C1,C2) :- accent_letter1(C1,C2).
% accent_letter(0x60,C1,C2) :- accent_letter2(C1,C2).
% accent_letter1(C1,C2) :- гласные(L), nth1(I,L,C1), nth1(I,"aеёiouyэюя",C2).
% accent_letter2(C1,C2) :- гласные(L), nth1(I,L,C1), nth1(I,"аеёиоуыэюя",C2).

% брр                      0              брр
% абажур 5                 5              абажу'р
% аистенок 5,5             e(5)           аистёнок
% агитбригада 9.3          a(9,3)         аги`тбрига'да
% впередсмотрящий 12.5,5   a(12,e(5))     вперёдсмотря'щий
% светло-зеленый 11,11.3   a(e(11),3)     све`тло-зелёный
% темно-зеленый 10,10.2,2  a(e(10),e(2))  тёмно-зелёный

test_accent :-
        test_accent(W), w(W,WW,[a(A)]),
        accent(WW,A,WA),   format('~s ~16| ~w ~32| ~s\n',[WW,A,WA]),
        accent(WW2,A2,WA), format('   ~16| ~w ~32| ~s\n',[A2,WW2]),
        fail.

test_accent('брр').
test_accent('абажур').         test_accent('аистенок').
test_accent('агитбригада').    test_accent('впередсмотрящий').
test_accent('светло-зеленый'). test_accent('темно-зеленый').

w(W,WW,[a(A)]) :- w(W,A), name(W,WW).

% гласная(C) :- member(C,"аеёиоуыэюя").
гласная(C) :- гласные(L), member(C,L).
гласные("аеёиоуыэюя").

% гласные2(W) - гласных_больше_двух
гласные2(W) :- nth1(N1,W,X), гласная(X), nth1(N2,W,Y), гласная(Y), N1\==N2, !.
% в три раза медленее:
% гласные2(W) :- гласная(X), гласная(Y), nth1(N1,W,X), nth1(N2,W,Y), N1\==N2, !.


% uname(?UnicodeAtom, ?UnicodeString) - UNICODE name
uname('',[]) :- !.
uname(Atom,[UChar|List]) :-
        nonvar(UChar), H is UChar // 256, L is UChar mod 256,
        name(Atom0, [H,L]), uname(Atom1,List), concat(Atom0, Atom1, Atom).
uname(Atom,[UChar|List]) :-
        nonvar(Atom), name(Atom, [H,L|List2]), UChar is H * 256 + L,
        name(Atom1, List2), uname(Atom1,List).

% selectn(?List1, ?Elem, +First, ?Index, ?List2)
selectn(List1, X, N, List2) :- selectn(List1, X, 0, N, List2).
selectn([X|Tail], X, I, I, Tail).
selectn([Head|Tail], Elem, I, N, [Head|Rest]) :-
        selectn(Tail, Elem, I, M, Rest),
        succ(M, N).

% replacen(?List1, ?OldElem, +First, ?Index, ?NewElem, ?List2)
replacen(List1, Old, N, New, List2) :- replacen(List1, Old, 0, N, New, List2).
replacen([X|Tail], X, I, I, Y, [Y|Tail]).
replacen([Head|Tail], Elem, I, N, NewElem, [Head|Rest]) :-
        replacen(Tail, Elem, I, M, NewElem, Rest),
        succ(M, N).

% % insert_elem(+List1,+Index,+Elem,+Offset,-List2)
% % is true when List2 has the same element as List1 with inserted Elem
% % Offset = if 0 then insert after position; if 1 - insert before
% insert_elem(List1,Index,Elem,Offset,List2) :-
%         integer(Index), Index2 is Index-Offset-1, length(L1,Index2),
%         append(L1,[E|L2],List1), append(L1,[E,Elem|L2],List2), !.
% insert_elem(List1,Index,Elem,Offset,List2) :-
%         nonvar(List2), Index2 is Index-Offset-1, length(L1,Index2),
%         append(L1,[E|L2],List1), append(L1,[E,Elem|L2],List2), !.

% % this alternative don't work if there is same letter before needed letter
% % insert_elem(W,A,AC,0,WA) :- integer(A), select(WA,AC,W), nth0(A,WA,AC).
% % insert_elem(W,A,AC,1,WA) :- integer(A), select(WA,AC,W), nth1(A,WA,AC).

% replace_elem(List1,Index,New,List2) :-
%         integer(Index), succ(Index2,Index), length(WA,Index2),
%         append(WA,[_|WB],List1), append(WA,[New|WB],List2), !.
% replace_elem(List1,Index,Old,New,List2) :-
%         integer(Index), succ(Index2,Index), length(WA,Index2),
%         append(WA,[Old|WB],List1), append(WA,[New|WB],List2), !.
