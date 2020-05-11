
% ?- ww(W,A),accent(W,A,WA),puts(WA),fail.
% ?- time((tell(acc),ww(W,A),accent(W,A,WA),puts(WA),fail;told)).

accent_word(W,WA) :- ww(W,A),accent(W,A,WA).

% accent_type(0). % 0 - accent after letter, 1 - accent before letter
accent_type(a). % a - use special accented characters
accent_char(1,0x27). % primary accent letter
accent_char(2,0x60). % secondary accent letter

accent_char(0'а,0'┬).
accent_char(0'е,0'┼).
accent_char(0'ё,0'█).
accent_char(0'и,0'▐).
accent_char(0'о,0'▒).
accent_char(0'у,0'√).
accent_char(0'ы,0' ).
accent_char(0'э,0'°).
accent_char(0'ю,0'·).
accent_char(0'я,0'╒).
accent_char(C,C).

accent(W,A,WA) :- nonvar(W), гласные2(W), accent_a(W,A,1,WA), !.
accent(W,A,WA) :- nonvar(WA), accent_r(W,A,1,WA), !.
accent(W,0,W)  :- !.
accent(W,_,W).

accent_a(W,a(A1,A2),C,WA) :- accent_e(W,A1,C,W1), accent_e(W1,A2,2,WA), !.
accent_a(W,A,C,WA)        :- accent_e(W,A,C,WA).

accent_r(W,a(A1,A2),C,WA) :- accent_e(W1,A2,2,WA), accent_e(W,A1,C,W1), !.
accent_r(W,A,C,WA)        :- accent_e(W,A,C,WA).

accent_e(W,e(A),_,WA)     :- replacen(W,0'е,1,A,0'ё,WA).
accent_e(W,A,_AI,WA)      :-
        accent_type(a), accent_char(AI,AC), replacen(W,AI,1,A,AC,WA).
accent_e(W,A,AI,WA)       :-
        accent_type(AT), accent_char(AI,AC), selectn(WA,AC,AT,A,W).

test_accent :-
        test_accent(W), w(W,WW,[a(A)]),
        accent(WW,A,WA),   format('~s ~16| ~w ~32| ~s\n',[WW,A,WA]),
        accent(WW2,A2,WA), format('   ~16| ~w ~32| ~s\n',[A2,WW2]),
        fail.

test_accent('брр').             % 0          0              брр
test_accent('абажур').          % 5          5              абажу'р
test_accent('аистенок').        % 5,5        e(5)           аистёнок
test_accent('агитбригада').     % 9.3        a(9,3)         аги`тбрига'да
test_accent('впередсмотрящий'). % 12.5,5     a(12,e(5))     вперёдсмотря'щий
test_accent('светло-зеленый').  % 11,11.3    a(e(11),3)     све`тло-зелёный
test_accent('темно-зеленый').   % 10,10.2,2  a(e(10),e(2))  тёмно-зелёный

%% interface to w database
w(W,WW,[a(A)]) :- w(W,A), name(W,WW).
ww(WW,A) :- w(W,A), name(W,WW).

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
