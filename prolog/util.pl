%% -*- mode: Prolog; -*-
%%%% util.pl - utilities
%%   $Id: util.pl,v 1.1 2001/02/20 22:19:54 juri Exp $
%%   Copyright (c) 2000 Juri Linkov.  All rights reserved.

%%%% Parameters

%%% change_parameter(+Name, +NewValue)
change_parameter(Module, Name, Value) :-
        retractall( Module:parameter(Name, _) ),
        asserta( Module:parameter(Name, Value) ).

%%%% List processing

%%% s(+Subset, +Set)
%%  alias for subset(+Subset, +Set) for using in top-level queries
s(Subset, Set) :-
        subset(Subset, Set).

%%% m(?Elem, +List)
%%  alias for memberchk(?Elem, +List) for using in top-level queries
m(Elem, List) :-
        memberchk(Elem, List).

%%% prefix(?Prefix, ?List)
%%  is true when Prefix is prefix of List
prefix([], _).
prefix([Elem|T1], [Elem|T2]) :-
        prefix(T1, T2).

prefix_slow(Prefix, Word) :-
        append(Prefix, _, Word).

%%% suffix(?Suffix, ?List)
%%  is true when Suffix is suffix of List
suffix(Suffix, Suffix) :-
        is_list(Suffix).
suffix(Suffix, [_|T]) :-
        suffix(Suffix, T).

suffix_slow(Suffix, Word) :-
        append(_, Suffix, Word).

%%% selectn(?List1, ?Elem, +First, ?Index, ?List2)
selectn(List1, X, N, List2) :- selectn(List1, X, 0, N, List2).
selectn([X|Tail], X, I, I, Tail).
selectn([Head|Tail], Elem, I, N, [Head|Rest]) :-
        selectn(Tail, Elem, I, M, Rest),
        succ(M, N).

%%% replacen(?List1, ?OldElem, +First, ?Index, ?NewElem, ?List2)
replacen(List1, Old, N, New, List2) :- replacen(List1, Old, 0, N, New, List2).
replacen([X|Tail], X, I, I, Y, [Y|Tail]).
replacen([Head|Tail], Elem, I, N, NewElem, [Head|Rest]) :-
        replacen(Tail, Elem, I, M, NewElem, Rest),
        succ(M, N).

%%% uniq_sorted(+SortedList, -UniqueList) - removes duplicates in sorted list
uniq_sorted([], []).
uniq_sorted([H,H|T], T2) :-
        !, uniq_sorted([H|T], T2).
uniq_sorted([H|T], [H|T2]) :-
        uniq_sorted(T, T2).

%%% count_sorted(WordList3, WordList4)
%%  
count_sorted(List1, List2) :-
        maplist(count_sorted1, List1, List),
        count_sorted2(List, List2).

count_sorted1(Elem, 1-Elem).
% count_sorted1(Elem, Elem-1).

count_sorted2([], []).
% count_sorted2([H-N1,H-N2|T], T2) :-
%         !, N3 is N1 + N2,
%         count_sorted2([H-N3|T], T2).
count_sorted2([N1-H,N2-H|T], T2) :-
        !, N3 is N1 + N2,
        count_sorted2([N3-H|T], T2).
count_sorted2([H|T], [H|T2]) :-
        count_sorted2(T, T2).

%%% setofall(Var, Goal, Set)
%%  
setofall(Var, Goal, Set) :-
        findall(Var, Goal, Bag), 
        sort(Bag, Set).

%%% bagof0(+Var, +Goal, -Bag)
%%  Same as bagof(+Var, +Goal, -Bag), but don't fail if result Bag is empty.
%%  This is better than "bagof0(X,P,S) :- bagof(X,P,S), !, true ; S=[]."
%%  because bagof can backtrack over the alternatives of free variables.
bagof0(Var, Goal, Bag) :-
        (   bagof(Var, Goal, Bag)
	*-> true
	;   Bag = []
	).

%%% safe bagof, clever bagof, careful bagof, uniq -c
my_bagof(Gen, Goal, Bag) :-
	my_assert_bag(Gen, Goal), 
	my_collect_bags([], [Bag]).

my_assert_bag(Templ, G) :-
	'$record_bag'(-), 
	G,
	    '$record_bag'(Templ), 
	fail.
my_assert_bag(_, _).

my_collect_bags(Sofar, Result) :-
	'$collect_bag'(Vars, Bag), !,
	my_collect_bags([Vars-Bag|Sofar], Result).
my_collect_bags(L, L).

%%%% Conversion

%%% uname(?UnicodeAtom, ?UnicodeString)
%%  UNICODE name
uname('', []) :- !.
uname(Atom, [UChar|List]) :-
        nonvar(UChar),
        H is UChar // 256,
        L is UChar mod 256,
        name(Atom0, [H,L]),
        uname(Atom1, List),
        concat(Atom0, Atom1, Atom).
uname(Atom, [UChar|List]) :-
        nonvar(Atom),
        name(Atom, [H,L|List2]),
        UChar is H * 256 + L,
        name(Atom1, List2),
        uname(Atom1, List).

%%%% Linguistic utilities

%%% case_word(?WordLower, ?WordUpper)
%%  Word in lower case WordLower corresponds to WordUpper in upper case.
%%  Here Word is list of characters.
case_word(WL, WU) :-
        alphabet_upper_case(AU),
        alphabet_lower_case(AL),
        tr(AL, AU, WL, WU).

%%% cap_word(?WordLower, ?WordUpper)
%%  WordUpper is capitalized WordLower.
cap_word([HL|TL], [HU|TU]) :-
        case_letter(HL, HU),
        case_word(TU, TL).

%%% case_letter(?CharLower, ?CharUpper) - 
%%  CharLower in lower case is CharUpper in upper case.
case_letter(L, U) :-
        alphabet_upper_case(AU),
        alphabet_lower_case(AL),
        tr1(AL, AU, L, U).

%%% tr(+AlphabetLower, +AlphabetUpper, ?WordLower, ?WordUpper)
%%  Transliterate list of characters
tr(AL, AU, WL, WU) :-
        maplist( tr1(AL, AU), WL, WU ), !.

%%% tr1(+AlphabetLower, +AlphabetUpper, ?CharLower, ?CharUpper)
%%  Transliterate one character, where CharLower from AlphabetLower
%%  corresponds to CharUpper with same position in AlphabetUpper
tr1(AL, AU, CL, CU) :-
        nth1(I, AL, CL),
        nth1(I, AU, CU), !.
tr1(_, _, C, C).

%%%% Misc

fails(N) :- flag(fails, N1, N1), N1 =< 0, flag(fails, _, N+1), fail.
fails(_) :- flag(fails, N, N-1), N =< 1, flag(fails, _, 0).
random_wi(wi(W,I),N) :-
        F is random(N),
        write(F),
        wi(W,I),
        fails(F).

%%% write_sl(StringList,Separator). - write list of strings
write_sl([],_)      :- !.
write_sl([H],_)     :- writef("%s",[H]), !.
write_sl([H|T],Sep) :- writef("%s%s",[H,Sep]), write_sl(T,Sep).

%%% write_wl(StringList,Separator). - write list of strings
write_wl([],_)      :- !.
write_wl([H],_)     :- writef("%w",[H]), !.
write_wl([H|T],Sep) :- writef("%w%s",[H,Sep]), write_wl(T,Sep).

%%% backup
% case_word(WL,WU) :- maplist(case_letter, WL, WU).
% cap_word([HL|TL],[HU|TU]) :- case_letter(HL,HU), maplist(case_letter, TU, TL).
% case_letter(L,U) :- alphabet_upper_case(AU), alphabet_lower_case(AL), tr(L,U,AL,AU).
% my_bagof(Gen, Goal, Bag) :- '$e_free_variables'(Gen^Goal, Vars), my_assert_bag(Vars-Gen, Goal), my_collect_bags([], Bags), member(Vars-Bag, Bags), Bag \== [].
% my_assert_bag(Templ, G) :- '$record_bag'(-), G, '$record_bag'(Templ), fail.
% my_assert_bag(_, _).
% my_collect_bags(Sofar, Result) :- '$collect_bag'(Vars, Bag), !, my_collect_bags([Vars-Bag|Sofar], Result).
% my_collect_bags(L, L).
