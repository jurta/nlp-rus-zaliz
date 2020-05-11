make_list("the boy reads the book",[w("the",[]),w("boy",[]),w("reads",[]),w("the",[]),w("book",[])]).

% texts is a list of sentences
% sentence is a list of words terminated by list of . ! ? or two newlines
% word is a list of letters
text([H|T]) --> sentence(H), sentences(T).
sentences([H|T]) --> sentence(H), period, sentences(T).
sentences([]) --> [].

sentence([Word|Words]) --> word(Word), !, [ ], space, words(Words).

words([Word|Words]) --> word(Word), !, [ ], space, words(Words).
words([]) --> [].

word(w([Char|Chars],[])) --> [Char], {is_letter(Char)}, !, letter(Chars).

letter([Char|Chars]) --> [Char], {is_letter(Char)}, !, letter(Chars).
letter([]) --> [].

is_letter(D) :- between(0'a, 0'z, D).

space --> [Char], {Char==32}, space.
space --> [].
period --> [0'.];[0'!];[0'?].

% write_sent(S).
write_sent([]) :- !.
write_sent([w(Word,_)]) :- !, write_word(Word).
write_sent([w(Word,_)|T]) :- write_word(Word), write_space, write_sent(T).

write_word(Word) :- writef('%s',[Word]).
write_space :- writef(' ',[]).
