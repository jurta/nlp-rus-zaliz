%% -*- mode: Prolog; coding: cyrillic-koi8; -*-
%%%% main.pl - (this will be renamed to top.pl or ui.pl)

%%%% Loading other program files and data

l :- [zaliz,rus,util,zalizq].
lz :- ['/root/usr/lang/rus/starling/z/conv/z.pl'].
lzc :- qcompile('/root/usr/lang/rus/starling/z/conv/z.pl').
lzq :- ['/root/usr/lang/rus/starling/z/conv/z.qlf'].

%%%% Performance measurement

prf2 :- tell(wouts), w(W,_,_,_), pr_parad2(W), fail ; told.
prprf2 :- profile((prf2), plain, 50).

prf3 :- tell(wouts), pr_parads3, pr_count2, fail ; told.
prprf3 :- profile((prf3), plain, 50).

% prtime1 :- time((w(W,_,_,_), w(W,A,SI,MI), fail ; true)).

prtime2 :- time((w(W,A,SI,MI), pr_count, wi2paradigm(w(W,A,SI,MI), _InflTables), fail ; true)).
% prtime3 :- time((w(W,A,SI,MI), pr_count, oldword2infltables(W, _InflTables), fail ; true)).
% prtime4 :- time((w(W,A,SI,MI), pr_count, oldword2infltables(W, _InflTables), fail ; true)).

% prprof2 :- profile((w(W,A,SI,MI), pr_count, wi2paradigm(w(W,A,SI,MI), _InflTables), fail ; nl), plain, 50).
prprof2 :- profile((z:wi(W,WI), pr_count, wi2paradigm(wi(W,WI), _InflTables), fail ; nl), plain, 50).

prwi2 :- profile((z:wi(_W,_WI), fail), plain, 50).

pr_count :- flag(pr_count, N, N+1), 0 is N mod 1400, write('.'), flush ; true.
pr_count2 :- flag(pr_count, N, N+1), 0 is N mod 1400, telling(S), tell(stderr), write('.'), flush, told, tell(S) ; true.

%%%% Parameters

%%% default_columns(-Columns) - number od columns per row
parameter(default_columns, 5).

%%% default_width(-Width) - row width in characters
parameter(default_width, 80).

%%% default_limit(-LimitWords) - query if this limit exceeded
parameter(default_limit_words, 200).

%%% show_accents(-BinaryChoice) - show accents in the found words
parameter(show_accents, 0).

%%%% Light-weight top-level queries
%%  Examples:
%%  i,wi(W,I),s([mi(со)],I),pw(W,I),fail;nl,fail.
%%  i,wi(W,I),s([mi(со)],I),ic,fail;pc,fail.
%%  i,wi(W,I),s([чр(с),с(п)],I),pw(W),fail;nl,fail.
%%  setof([POS,S],W^WI^(wi(W,WI),s([чр(POS),с(S)],WI)),L).
%%    L = [[мс, мс], [п, мс], [п, п], [с, мс], [с, п], [с, с]]
i :- flag(column, _, 1), flag(counter, _, 0).
ic :- flag(counter, N, N+1).
pc :- flag(counter, N, N), nl, write(N), nl.
pw(WS) :-
        atom_chars(WA, WS),
        print_next_column_word(WA).
pw(WS,I) :-
        memberchk(a(A),I),
        rus:accent_word(WS,A,WSA),
        atom_chars(WA, WSA),
        print_next_column_word(WA).

print_next_column_word(Word) :-
        flag(column, N, N+1),
        parameter(default_columns, Columns),
        print_next_word(Word, Columns, N).

%%%% Top-level

% pr_parad(абажур).
% pr_parad(абажура).

%%% q(+QueryName) - query
%%  print words satisfying QueryName
q(QueryName) :-
        qd(QueryName, _, QueryParam),
        (   memberchk(c(Columns), QueryParam)
        ;   parameter(default_columns, Columns)
        ), !,
        (   memberchk(r(s), QueryParam) % query returning strings
        ->  qs(QueryName, Columns)
        ;   q(QueryName, Columns)
        ).

%%% q(+QueryName, +Columns) - query
%%  as q(+QueryName) plus specify number of columns
q(QueryName, Columns) :-
        print_query_header(QueryName),
        bagof0(Word, QueryName^find_word(QueryName, Word), WordList2), !,
        % use this instead of setof which sorts russian by koi8 wrong
        uniq_sorted(WordList2, WordList3),
        maplist(add_accent_if_needed, WordList3, WordList),
        print_list_by_columns(WordList, Columns, 0),
        print_length(WordList, слово).

%%% add_accent_if_needed(+Word, -Word2)
add_accent_if_needed(r(wi(W,I),_Res), WordR) :-
        (   (
                parameter(show_accents, ShowAccents),
                memberchk(ShowAccents, [1,y,yes,t,true,d,da])
            )
        ->  memberchk(a(A), I),
            rus:accent_word(W, A, WordA)
        ;   W = WordA
        ),
        atom_chars(WordR, WordA).

%%% qp(+QueryName, +Parameters) - query
%%  as q(+QueryName) plus specify parameters
%%  Query = q(Input, CallQuery)
qp(Query, Columns) :-
        Query = q(_,_), !,
        print_query_header(Query),
        bagof0(Word, Query^Word^find_word(Query, Word), WordList2), !,
        % use this instead of setof which sorts russian by koi8 wrong
        uniq_sorted(WordList2, WordList3),
        maplist(add_accent_if_needed, WordList3, WordList),
        print_list_by_columns_with_confirmation(WordList, Columns),
        print_length(WordList, слово).

%%% qp(+QueryName, +Parameters) - query
%%  as q(+QueryName) plus specify parameters
%%  Query = q(Input, CallQuery, Output)
qp(Query, Columns) :-
        Query = q(_,_,_), !,
        print_query_header(Query),
        bagof0(Word, Query^Word^find_word(Query, Word), WordList2), !,
        maplist(get_res, WordList2, WordList3),
        count_uniq_sorted(WordList3, WordList4),
        maplist(add_amount_if_needed, WordList4, WordList),
        print_list_by_columns(WordList, Columns, 0),
        print_length(WordList, слово),
        print_any(WordList4, WordList2).

get_res(r(_,Res), Res).
get_wi(r(WI,_), WI).

count_uniq_sorted(WordList2, WordList6) :-
        msort(WordList2, WordList3),
        count_sorted(WordList3, WordList4),
        keysort(WordList4, WordList5),
        reverse(WordList5, WordList6).

print_any(WordList, WordList2) :-
        member(Key-Value, WordList),
        Key < 20,
        writef("%w:\n", [Value]),
        bagof(X, Y^(member(X, WordList2),X=r(Y,Value)), WordList3),
        %% sublist(=(r(_,Value)), WordList2, WordList3),
        %% maplist(get_wi, WordList3, WordList4),
        uniq_sorted(WordList3, WordList5),
        maplist(add_accent_if_needed, WordList5, WordList9),
        print_list_by_columns_with_confirmation(WordList9, 5),
        fail ; true.

%%% qf(+QueryName, +FileName) - query to file
%%  save to file all words satisfying QueryName.
%%  example: qf(fmv,'fmv.out').
qf(QueryName, FileName) :-
        tell(FileName),
        q(QueryName),
        told.

%%% qf(+QueryName, +Columns, +FileName) - query to file
%%  - save query to file with columns
%%  - same as qf(+QueryName, +FileName) plus specify number of columns
%%  Example: qf(fmv,4,'fmv.out').
qf(QueryName, Columns, FileName) :-
        tell(FileName),
        q(QueryName, Columns),
        told.

%%% qn(+QueryName) - query number of words
%%  show only amount of found words
qn(QueryName) :-
        print_query_header(QueryName),
        bagof0(Word, QueryName^find_word(QueryName, Word), WordList2), !,
        uniq_sorted(WordList2, WordList),
        writef("  (в этом режиме слова не показываются)\n"),
        print_length(WordList, слово).

%%% qs(+QueryName, +Columns) - query strings and sort
qs(QueryName, Columns) :-
        print_query_header(QueryName),
        %% setof(Word, QueryName^find_word(QueryName, Word), WordList), !,
        bagof0(Word, QueryName^find_word(QueryName, Word), WordList2), !,
        count_uniq_sorted(WordList2, WordList3),
        maplist(add_amount_if_needed, WordList3, WordList),
        print_list_by_columns(WordList, Columns, 0),
        %% better to use first word from qd for UnitWord
        qd(QueryName, _, QueryParam),
        (   memberchk(u(UnitWord), QueryParam)
        ;   UnitWord = строка
        ),
        print_length(WordList, UnitWord).

%%% add_amount_if_needed(+Word, -Word2)
add_amount_if_needed(Key-Value, Word2) :-
        concat_atom([Value,'/',Key], Word2).

%%% qhelp - list all available queries
qhelp :-
        qd(QueryName, QueryDoc, _QueryParam),
        writef("%w - %w\n", [QueryName, QueryDoc]),
        fail ; true.

%%% qload - load all available queries
qload :-
        qd(QueryName, _, _),
        abolish(QueryName,2),
        assert(:-(QueryName,q(QueryName))),
        fail ; true.

%%%% Query and print results

%%% find_word(+QueryName, -Word) - find next word satisfying to query
find_word(q(wi(W,I), Pred, Res), r(wi(W,I),Res)) :-
        wi(W, I),
        call(Pred).
find_word(q(wi(W,I), Pred), r(wi(W,I),0)) :-
        wi(W, I),
        call(Pred).
find_word(QueryName, r(wi(W,I), Result)) :-
        QueryName \= q(_,_),
        QueryName \= q(_,_,_),
        wi(W, I),
        call(qq, QueryName, wi(W,I), Result).
% find_word(QueryName, Result) :-
%         w(W, A, S, M),
%         call(qq, QueryName, w(W,A,S,M), Result).

%%% print_query_header(+QueryName)
print_query_header(QueryName) :-
        qd(QueryName, QueryDoc, _QueryParam),
        writef("* %w:\n", [QueryDoc]), !.
print_query_header(_) :-
        writef("* запрос с таким названием не найден\n"), !.

%%% print_length(+WordList, +UnitWord)
%%  Print resulting word list length in Russian
%%  UnitWord - word in which result is measured
print_length(WordList, UnitWord) :-
        length(WordList, WordListLen),
        %% print слово in rigth case
        rus:num2case(WordListLen, GI),
        z:word2wordforms(UnitWord, GI, [w(UnitWF,_)|_]),
        writef("* всего найдено %w %w.\n", [WordListLen, UnitWF]), !.
print_length(_, _).

%%% print_list_by_columns_with_confirmation()
print_list_by_columns_with_confirmation(WordList, Columns) :-
        length(WordList, Length),
        parameter(default_limit_words, Limit),
        (   Length > Limit
	->  writef("Найдено %w, показывать все? ", [Length]),
            get0(C),
            C == 121
	;   true
	), !,
        print_list_by_columns(WordList, Columns) ; true.

%%% print_list_by_columns(+WordList) - print list of words
%%  - currently not used
print_list_by_columns(WordList) :-
        forall( member(Word, WordList), writeln(Word) ).

%%% print_list_by_columns(+WordList, +Columns)
print_list_by_columns(WordList, Columns) :-
        print_list_by_columns(WordList, Columns, 0).

%%% print_list_by_columns(+WordList, +Columns, +Counter)
print_list_by_columns([], Columns, C) :-
	(   0 is C mod Columns
	->  true
	;   nl
	), !.
print_list_by_columns([Word|List], Columns, C) :-
        succ(C, C2),
        print_next_word(Word, Columns, C2),
        print_list_by_columns(List, Columns, C2).

%%% print_next_word(Word, Columns, C2)
print_next_word(Word, Columns, C2) :-
        write(Word),
	(   0 is C2 mod Columns
	->  nl
	;   atom_length(Word, WLen),
            parameter(default_width, Width),
            PLen is Width / Columns - WLen,
            writef("%r", [' ', PLen])
	).

%%%% wf_we_stat

wf_domain(d,L) :- setofall(D,(z:wf_we_tab(D,_,_,_,_,_,_,_),nonvar(D)),L).
wf_domain(n,L) :- setofall(N,(z:wf_we_tab(_,N,_,_,_,_,_,_),nonvar(N)),L).
wf_domain(g,L) :- setofall(G,(z:wf_we_tab(_,_,G,_,_,_,_,_),nonvar(G)),L).
wf_domain(t,L) :- setofall(T,(z:wf_we_tab(_,_,_,T,_,_,_,_),nonvar(T)),L).
wf_domain(u,L) :- setofall(U,(z:wf_we_tab(_,_,_,_,U,_,_,_),nonvar(U)),L).
wf_domain(a,L) :- setofall(A,(z:wf_we_tab(_,_,_,_,_,A,_,_),nonvar(A)),L).
wf_domain(c,L) :- setofall(C,(z:wf_we_tab(_,_,_,_,_,_,C,_),nonvar(C)),L).
wf_domain(s,L) :- setofall(S,(z:wf_we_tab(_,_,_,_,_,_,_,S),nonvar(S)),L).

print_wf_domains :- wf_domain(S,L), S\==s, writef("%w: ",[S]), writeln(L), fail.
print_wf_domains :- wf_domain(s,L), write('s: '),write_wl(L,","),nl,fail.

get_all_wf(wf_we_tab(D,N,G,T,U,A,C)) :-
        wf_domain(d,DL), member(D,DL),
        wf_domain(n,NL), member(N,NL),
        wf_domain(g,GL), member(G,GL),
        wf_domain(t,TL), member(T,TL),
        wf_domain(u,UL), member(U,UL),
        wf_domain(a,AL), member(A,AL),
        (D\==к, wf_domain(c,CL), member(C,CL) ; D==к, C=и),
        (T==8, D==с ; T\==8).

print_all_real_wf :-
        get_all_wf(wf_we_tab(D,N,G,T,U,A,C)),
        write(z:wf_we_tab(D,N,G,T,U,A,C)), nl, fail.

check_domain_coverage :-
        get_all_wf(wf_we_tab(D,N,G,T,U,A,C)),
        not(z:wf_we_tab(D,N,G,T,U,A,C,_)),
        write(wf_we_tab(D,N,G,T,U,A,C)),nl,fail.

get_all_wfi(L2) :-
        setofall(wfi(D,G,T,U,A),N^C^(get_all_wf(wf_we_tab(D,N,G,T,U,A,C))),L),
        maplist(get_all_wfi, L, L2).
get_all_wfi(wfi(D,G,T,U,A), [wfi(D,G,T,U,A),L]) :-
        setofall([N,C,S],(z:wf_we_tab(D,N,G,T,U,A,C,S)),L).

%% Perl-specific stuff
print_all_wfi :-
        get_all_wfi(L2),
        checklist(print_all_wfi, L2).
print_all_wfi([wfi(D,G,T,U,A),L]) :-
        writef("\"%w%w%w%w%w\" => {",[D,G,T,A,U]),
        checklist(print_all_wfi, L),
        writef("},\n").
print_all_wfi([N,C,S]) :-
        writef("\"%w%w\" => \"%w\",",[C,N,S]).

%%%% backup
set_word_count(N) :- flag(word_count, N, _).
get_word_count(N) :- flag(word_count, _, N).
inc_word_count(N) :- flag(word_count, N, N+1).
write_word(W,_A) :- writeln(W). % write(W), write(' ').

%%%% Post-load
% :- l.
% :- qload.

