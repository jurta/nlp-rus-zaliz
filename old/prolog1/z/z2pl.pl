r :-
        see('zaliza.pl'), tell('zaliza.pl~'),
%         see('testw'), tell('testw~'),
        readl, % reads,
        seen,see(user),told,tell(user).

reads :- get0(C), C \== -1, !, put(C), reads.
reads.

readl :- readln(L), L \== [end_of_file], !, concat_atom(L,A), writef('%w\n',[A]), readl.
readl.

% repeat,readln(L),member('-',L),write(L),nl,fail;
