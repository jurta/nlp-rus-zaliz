:-dynamic stored_defs_handle/1.
:-use_module(library(table)).

defs_table(Words):-
	stored_defs_handle(Words),!.
defs_table(Words):-
%         File = '/root/doc/lang/rus/zaliz/zaliz/zaliz',
        File = '../conv/z.tab',
%         File = 'z',
	new_table(File,
		  [
                   word(atom,[])
                  , accent(integer,[syntax]) % , accent(atom,[])
                  , fraz(string,[])
                  , comm(string,[])
                  , fakul(string,[])
                  , usage(string,[])
                  , verb(string,[])
%                   , syntax(code_list,[])
%                   , paradigm(code_list,[])
%                   , comments(atom,[])
                  ],
		  [field_separator(0'	)],
		  Words),
	asserta(stored_defs_handle(Words)).

word(Word,Accent,Fraz):-
	defs_table(DHandle),
	in_table(DHandle,
		 [
                  word(Word)
                 , accent(Accent)
                 , fraz(Fraz)
                 , comm(_Comm)
                 , fakul(_Fakul)
                 , usage(_Usage)
                 , verb(_Verb)
%                  , syntax(Syntax)
%                  , paradigm(Paradigm)
%                  , comments(Comments)
                 ],
		  _RPos).

word(Word,Accent,Syntax,Paradigm,Comments):-
	defs_table(DHandle),
	in_table(DHandle,
		 [word(Word),
                  accent(Accent),
                  syntax(Syntax),
                  paradigm(Paradigm),
                  comments(Comments)],
		  _RPos).

word2(Term):-
	defs_table(DHandle),
	in_table(DHandle,
		 [
%                   word(Word),
%                   accent(Accent),
%                   syntax(Syntax),
%                   paradigm(Paradigm),
%                   comments(Comments)
                 ],
		  RPos),
        read_table_record(DHandle,RPos,_Next,
% 			  record(Term,_,_)
			  Term
                         )
%         ,term_to_atom(Term,Term2)
        .

accent_char(W,C) :-
        word(W,I,_), integer(I),
%         word(W,A,_),
% !!! term_to_atom(I,A),
        % atom_to_term(A,I,[]),
        name(W,WW),nth1(I,WW,C2),name(C,[C2]).

% setof(C,W^accent_char(W,C),L),member(C2,L),setof(_,W2^accent_char(W2,C2),L2),length(L2,I),write([C2,I]),nl,fail.
% [ю, 880] [а, 25752] [д, 1] [е, 12816] [и, 20139] [м, 2] [о, 16344]
% [я, 4612] [р, 2] [с, 2] [т, 4] [у, 5948] [в, 1] [ы, 3063] [э, 117] [ч, 1]

% 5 ?- setof(C,W^accent_char(W,C),L),member(C2,L),setof(W2,accent_char(W2,C2),L2),length(L2,I),I<10,write([C2,L2]),nl,fail.
% [д, [нибудь]]
% [м, [промерить]]
% [р, [лихорадочный, прибраться]]
% [с, [еместровый, крейсировать]]
% [т, [олонеть, пехтерь, сабантуй]]
% [в, [приживал]]
% [ч, [саморазгрузчик]]

%% setof(LL,W2^other_vowels(W2,э,LL),L2).
other_vowels(W,C,L) :-
        word(W,I,_), integer(I), name(W,WW),
        selectn1(WW,C2,I,WW2), sublist(vowel,WW2,L22), list_to_set(L22,L2),
        maplist(atom_char,L,L2), atom_char(C,C2).

% setof([L1,L2],W2^before_after_vowels(W2,э,L1,L2),L).
before_after_vowels(W,C,LL1,LL2) :-
        word(W,I,_), integer(I), name(W,WW), nth1(I,WW,C2), atom_char(C,C2),
        append(W1,W2,WW),length(W1,I),
        sublist(vowel,W1,L1), length(L1,LL1),
        sublist(vowel,W2,L2), length(L2,LL2).

%% stat1(а,S).
stat1(C,Set) :-
        bagof([L1,L2],W2^before_after_vowels(W2,C,L1,L2),Lists),
        list_to_set(Lists,Set1),
        maplist(count(Lists),Set1,Set2),
        keysort(Set2,Set).

count(Lists, Elem, N-Elem) :-
        delete(Lists,Elem,ResList),
        length(Lists,I1), length(ResList,I2), N is I1-I2.

% vowel(X) :- member(X,[0'а,0'е,0'ё,0'и,0'о,0'у,0'ы,0'э,0'ю,0'я]).
vowel(X) :- member(X,"аеёиоуыэюя").

cv_pattern(X,0'v) :- vowel(X), !.
cv_pattern(_,0'c).

cv_word(W2) :- word(W,_I,_), name(W,WW), maplist(cv_pattern,WW,WW2), atom_chars(W2,WW2).

stat2(Set) :-
        bagof(W,cv_word(W),Lists),
        list_to_set(Lists,Set1),
        maplist(count(Lists),Set1,Set2),
        keysort(Set2,Set).

stat2_2 :- cv_word(W), incr_record(W), write('.'), flush, fail.
% stat2_2 :-
%         setof(X,recorded(c,c(X)),S), keysort(S,S2),
%         tell(cvccv),
% %         recorded(c,c(N-W)), %% c(N-W),
% %         writeln([N,W]),
%         checklist(writeln,S2), % writeln(S2),
%         fail.
stat2_2 :- told.

stat2_3 :- setof(W,(cv_word(W), flag(W, X, X+1), write('.'), flush),S),fail.

incr_record(W) :- flag(W, X, X+1), recorded(k,W), !.
incr_record(W) :- recorda(k,W).
% clean :- recorded(k,Key), flag(Key,_,0), fail.
% incr_record(W) :- recorded(c,c(N-W),R), erase(R), succ(N,N2), recorda(c,c(N2-W)), !.
% incr_record(W) :- recorda(c,c(1-W)).
% clean :- recorded(c,c(_-_),R), erase(R), fail.
% incr_record(W) :- c(N-W), retract(c(N-W)), succ(N,N2), assert(c(N2-W)), !.
% incr_record(W) :- assert(c(1-W)).
% clean :- c(N-W), retract(c(N-W)), fail.

%%% test
defs_table2(Words):- stored_defs_handle(Words), !.
% defs_table2(Words):-
%         File = 'table',
% 	new_table(File, [word(atom,[]),acc(string,[]),fraz(string,[])],
%                   [field_separator(0'	)], Words),
% 	asserta(stored_defs_handle(Words)).
defs_table2(Words):-
        File = 'table3',
	new_table(File, [word(atom,[])], [], Words),
	asserta(stored_defs_handle(Words)).

w(Word):- defs_table2(DHandle), in_table(DHandle, [word(Word)], _RPos).
w(Word,A,F):- defs_table2(DHandle),
        in_table(DHandle, [word(Word),acc(A),fraz(F)], _RPos).
