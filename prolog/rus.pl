%% -*- mode: Prolog; coding: cyrillic-koi8; -*-
%%%% rus.pl - Russian related information

:- module(rus,
          [
%             alphabet_upper_case/1 % 
%           , alphabet_lower_case/1 % 
%           , letter/1            % 
%           , vowels/1            % 
%           , consonants/1        % 
%           , vowel/1            % 
%           , consonant/1        % 
%            vowels2/1
          ]).

%%%% Orphography

alphabet_upper_case("АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЬЫЪЭЮЯ").
alphabet_lower_case("абвгдеёжзийклмнопрстуфхцчшщьыъэюя").
letter(L) :- alphabet_lower_case(LS), member(L, LS).

vowels("аеёиоуыэюя").
consonants("бвгджзйклмнпрстфхцчшщ").

vowel(V) :- vowels(VS), member(V, VS).
consonant(C) :- consonants(CS), member(C, CS).


%%%% Accentuation
%%% accent_word(?WordInfo, ?WordAccented)
%%  Accentuate word. Accept WordInfo as 2-place or 4-place w structure
accent_word(w(W,A), WA) :-
        accent_word(W, A, WA).
accent_word(w(W,A,_,_), WA) :-
        accent_word(W, A, WA).

%%% accent_word(?Word, ?Accent, ?WordAccented)
%%  Accentuate word. Accept Word as atom, string or list of characters
accent_word(W, A, WA) :-
        atom(W), atom_chars(W, WS), !,
        accent(WS, A, WAS),
        atom_chars(WA, WAS), !.
accent_word(W, A, WA) :-
        string(W), string_to_list(W, WS), !,
        accent(WS, A, WAS),
        string_to_list(WA, WAS), !.
accent_word(W, A, WA) :-
        accent(W, A, WA).

%%% accent_type(-AccentType)
%%  Accent type:
%%    0 - accent after letter,
%%    1 - accent before letter
%%    a - use special accented characters
%%  Change it by change_parameter(rus, accent_type, a)..
parameter(accent_type, 0).

%%% accent_char(+AccentType, -AccentCharacter)
%%  Accent character: ', ` or accented letters
accent_char(1,0x27).            % primary accent letter
accent_char(2,0x60).            % secondary accent letter
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

%%% accent(W, A, WA)
%%  Accentuate word.
%%    W - list of ASCII characters
%%    A - accent: int, e(int), a(int,int), a(e(int),int) or a(int,e(int))
%%        where int - integer, e(_) - "jo", a(first_accent,second_accent)
%%    WA - list of ASCII characters with added accent
accent(W, A, WA) :-
        parameter(accent_type, AT),
        accent(W, A, AT, WA).

%%% accent(W, A, AT, WA)
%%  Same as accent(W, A, WA) but with added accent type AT
accent(W, A, AT, WA) :-
        nonvar(W),
        vowels2(W),             % no need to accentuate words with 1 vowel
        accent_a(W, A, AT, 1, WA), !.
accent(W, A, AT, WA) :-
        nonvar(WA),
        accent_r(W, A, AT, 1, WA), !.
accent(W, 0, _, W)  :- !.
accent(W, _, _, W).

%%% accent_a(W, a(A1,A2), AT, C, WA)
%%  Add first and second accents separately
accent_a(W, a(A1,A2), AT, C, WA) :-
        !,
        accent_e(W, A1, AT, C, W1),
        accent_e(W1, A2, AT, 2, WA).
accent_a(W, A, AT, C, WA) :-
        accent_e(W, A, AT, C, WA).

%%% accent_r(W, a(A1,A2), AT, C, WA)
%%  Similar to accent_a, but remove accents in reverse order
accent_r(W, a(A1,A2), AT, C, WA) :-
        !,
        accent_e(W1, A2, AT, 2, WA),
        accent_e(W, A1, AT, C, W1).
accent_r(W, A, AT, C, WA) :-
        accent_e(W, A, AT, C, WA).

%%% accent_e(W, A, AT, AI, WA)
%%  1. Replace "je" by "jo" and vice versa
%%  2. If accent type is accented letter then replace accented letter
%%  3. If accent type is apostrophe then add it before or after
accent_e(W, e(A), _, _, WA) :-
        !,
        replacen(W, 0'е, 1, A, 0'ё, WA).
accent_e(W, A, a, _AI, WA) :-
        accent_char(AI, AC),
        replacen(W, AI, 1, A, AC, WA).
accent_e(W, A, AT, AI, WA) :-
        accent_char(AI, AC),
        selectn(WA, AC, AT, A, W).

%%% test_accent_word
test(accent) :-
        test_accent_word(W, A, AT, WA),
        (   (accent(W, A, AT, WAX), WA = WAX)
        ->  true
        ;   writef("Failed accent_word(%s, %w, %w, WA)\n", [W, A, AT])
        ),
        (   (accent(WX, A, AT, WA), W = WX)
        ->  true
        ;   writef("Failed accent_word(W, %w, %w, %s)\n", [A, AT, WA])
        ),
        fail ; true.

test_accent_word("абажур",5,0,"абажу'р").
test_accent_word("аистенок",e(5),0,"аистёнок").
test_accent_word("агитбригада",a(9,3),0,"аги`тбрига'да").
test_accent_word("впередсмотрящий",a(12,e(5)),0,"вперёдсмотря'щий").
test_accent_word("светло-зеленый",a(e(11),3),0,"све`тло-зелёный").
test_accent_word("темно-зеленый",a(e(10),e(2)),0,"тёмно-зелёный").
test_accent_word("серо-буро-малиновый",a(14,7),0,"серо-бу`ро-мали'новый"). % "се`ро-бу`ро-мали'новый"
test_accent_word("абажур",5,1,"абаж'ур").
test_accent_word("аистенок",e(5),1,"аистёнок").
test_accent_word("агитбригада",a(9,3),1,"аг`итбриг'ада").
test_accent_word("впередсмотрящий",a(12,e(5)),1,"вперёдсмотр'ящий").
test_accent_word("светло-зеленый",a(e(11),3),1,"св`етло-зелёный").
test_accent_word("темно-зеленый",a(e(10),e(2)),1,"тёмно-зелёный").
test_accent_word("серо-буро-малиновый",a(14,7),1,"серо-б`уро-мал'иновый"). % "се`ро-бу`ро-мали'новый"
test_accent_word("абажур",7,0,"абажур"). % wrong, no accent added
test_accent_word("аистенок",e(0),0,"аистенок"). % wrong, no accent added
test_accent_word("аистенок",e(9),0,"аистенок"). % wrong, no accent added
test_accent_word("агитбригада",a(12,3),0,"агитбригада"). % wrong, no accent added
test_accent_word("впередсмотрящий",a(12,e(16)),0,"впередсмотрящий"). % wrong, no accent added

%%%% Additional
%%% vowels2(+Word)
%%  True if Word have vowels more than two. (Used for word accentuation).
vowels2(Word) :-
        nth1(N1, Word, C1),
        vowel(C1),
        nth1(N2, Word, C2),
        vowel(C2),
        N1 \== N2.
% в три раза медленее:
% гласные2(W) :- гласная(X), гласная(Y), nth1(N1,W,X), nth1(N2,W,Y), N1\==N2, !.

%%%% Grammatical predicates (should be put into rus_syntax module)
%%% num2case(+N, -Case)
%%  test: between(0, 135, N), rus:num2case(N, C), write_ln(N-C), fail ; true.
num2case(N, с(и,е)) :-
        1 is N mod 10,
        N3 is N mod 100,
        N3 \== 11, !.
num2case(N, с(р,е)) :-
        N2 is N mod 10,
        N2 >= 2,
        N2 =< 4,
        N3 is N mod 100,
        (   N3 < 12
        ;   N3 > 14
        ), !.
num2case(_, с(р,м)) :- !.
