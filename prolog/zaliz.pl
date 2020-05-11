%% -*- mode: Prolog; coding: cyrillic-koi8; -*-
%%%% zaliz.pl - word formation according to A.A.Zaliznyak
%%   $Id: zaliz.pl,v 1.2 2001/02/20 22:19:46 juri Exp $
%%   Copyright (c) 2000 Juri Linkov.  All rights reserved.

:- module(z,                    % or zaliz, and no export here at all
          [ wi/2                % interface to database
          , word2paradigms/2    % word to infltables
          , word2paradigm/2     % слово -> парадигма
          , wi2paradigm/2       % словарная статья -> парадигма
          %% , wordform/4          % wordform/3
          , pr_parad/1
          , pr_parad2/1
          , pr_parads3/0
          , pr_parad3/1
          , run_tests/0
          ]).

% :- index(wf_we_tab(1,1,1,1,1,1,1,0)). % gives 3 sec from 198 sec
:- index(wf_we_tab(1,1,0,1,0,0,1,0)). % gives 7 sec from 198 sec
:- index(post_proc(1,1,1,1)).
:- index(get_wf_info(1,1,1,1)).
:- index(get_we_accent(1,1,1)).
:- index(wf_we_tab_pre(1,1,1)).
:- index(wf_postproc_wf(1,1,1,1)).
:- style_check(+string).

parameter(database_module, z0).

%%% mi(Word,Accent,WordBase,D,DS,T,U,U2,Ch,Ch2)
%%  Word - слово
%%  Accent - ударение: N a(N,N) e(N) e(N,N)
%%  WordBase - графическая основа слова
%%  D - вид склонения
%%   с - субстантивное
%%   а - адъективное
%%   м - местоимённое
%%  DS - морфологическая характеристика: с(м,о) с(ж,о) а г(св)
%%  T - тип склонения (0..8) или спряжения (1..16)
%%  U - схема ударения: a b a1 f2 a(a,a) a(a,c1) a(a,c2)
%%  U2 - окончание под ударением? б/у
%%  Ch - тип чередования 1: y/n
%%  Ch2 - тип чередования 2: y/n

%%%% Top-level

%%% word2paradigms(+Word, -InflTables)
word2paradigms(W, InflTables) :-
        bagof(InflTable, W^word2paradigm(W, InflTable), InflTables).

%%% word2paradigm(+Word, -WordForms)
word2paradigm(W, t(wi(W,WI),WordForms)) :-
        wi(W, WI),
        wi2paradigm(wi(W,WI), WordForms).

%%% wi2paradigm(+WordInfo, -WordForms)
wi2paradigm(wi(_W,WI), []) :-
        member(i(0), WI), !.
wi2paradigm(wi(W,WI), WordForms) :-
        memberchk(чр(POS), WI),
        get_paradigms(POS, GIS),
        string_to_atom(WS, W),
        get_mi_wfi(wi(WS,WI), MI), !,
        maplist(wordform_wf(MI), GIS, WordForms).

%%% wordform_wf(MI, GI, wf(GI,WA2))
%%  Add grammatical meaning to word form
wordform_wf(MI, GI, wf(GI,WA2)) :-
        wordform(MI, GI, WA2).

%%% word2wordforms(+Word, +GI, -WordForms)
word2wordforms(W, GI, WordForms) :-
        bagof(WordForm, W^GI^word2wordform(W, GI, WordForm), WordForms).

%%% word2wordform(+Word, +GI, -WordForms)
word2wordform(W, GI, WordForm) :-
        z0:w(W, A, S, M),       % TODO: use new wi(W,WI)
        wi2wordform(w(W,A,S,M), GI, WordForm).

%%% wi2wordform(+WordInfo, +GI, -WordForms)
wi2wordform(w(W,A,S,M), GI, WordForm) :-
        get_all_inf(w(W,A,S,M), _POS, MI), % TODO: use new get-inf
        wordform(MI, GI, WordForm).

%%%% Old Get Information

%%% get_all_inf(+WI, -POS, -MI)
get_all_inf(w(W,A,S,M),POS,mi(WB,A,D,MI2,I2,Ch)) :-
        get_syntax_inf(S,POS,D,DS),
        get_morpho_inf(M,DS,MI2,I2,Ch), string_to_atom(WW,W), wbase_str(WW,D,Ch,WB).

%%% get_syntax_inf(+SI, -POS, -D, -DS)
get_syntax_inf([SI|_],POS,D,DS) :- get_syntax_inf2(SI,POS,D,DS), !.
get_syntax_inf(SI,POS,D,DS) :- get_syntax_inf2(SI,POS,D,DS), !.

%%% get_syntax_inf2(+SI, -POS, -D, -DS)
get_syntax_inf2(м,с,с,с(м,н)).        % сущ. м.р. неод.
get_syntax_inf2(мо,с,с,с(м,о)).       % сущ. м.р. одуш.
get_syntax_inf2(ж,с,с,с(ж,н)).        % сущ. ж.р. неод.
get_syntax_inf2(жо,с,с,с(ж,о)).       % сущ. ж.р. одуш.
get_syntax_inf2(с,с,с,с(с,н)).        % сущ. с.р. неод.
get_syntax_inf2(со,с,с,с(с,о)).       % сущ. с.р. одуш.
get_syntax_inf2(св,г,г,г(св)).
get_syntax_inf2(нсв,г,г,г(нсв)).
get_syntax_inf2('св-нсв',г,г,г('св-нсв')).
get_syntax_inf2(п,п,а,а).
get_syntax_inf2(мс,м,м,м).
get_syntax_inf2('мс-п',п,а,а).
get_syntax_inf2(числ,ч,ч,ч).
get_syntax_inf2(SI,SI,SI,SI).

%%% get_morpho_inf(+I, +DS, -MI2, -Ch).
get_morpho_inf('', _, '', [], n).
get_morpho_inf(i(T,U), DS, mi2(DS,T,U), [], n).
get_morpho_inf(i(T,U,A), DS, mi2(DS,T,U), A, Ch) :- has_running_vowel(A, Ch).

%%%% New Get Information

%%% wi(W, A, I) - interface to database
%%  Word Information: W - word, A - accent, I - information
%%  wi(WS, [a(A)|WI]) :- z0:w(W, A, S, M), atom_chars(W, WS), get_all_info(S, M, WI).
wi(W, WI) :-
        z0:w(W, A, S, M),
        get_all_info(w(W,A,S,M), WI).

wic(WS, WI) :-
        wi(W, WI),
        atom_chars(W, WS).

wis(WS, WI) :-
        wi(W, WI),
        string_to_atom(WS, W).

%%% get_all_info(w(W,A,S,M), wi(W,WI))
get_all_info(w(W,A,S,M), WI) :-
        findall(I, get_info(w(W,A,S,M), I), WI).

%%% s2([],_)
%%  same as subset but for get_info instead of findall
s2([],_) :- !.
s2([I|T],w(W,A,S,M)) :-
        get_info(w(W,A,S,M), I),
        s2(T,w(W,A,S,M)).

%%% get_info(w(_W,A,_S,_M), у(A))
%%  
% please consider this format:
%       w(вал,[у-2,чр-с,р-м,с-с,и-1,у1-c]). % where Key-Value = -(Key,Valule)
% i.e.: w(вал,[-(у,2),-(чр,с)]).
get_info(w(_W,A,_S,_M), у(A)).
get_info(w(_W,_A,S,_M), SI) :-
        get_base_syn_info(S, SIL),
        member(SI, SIL).
get_info(w(_W,_A,S,M), MI) :-
        (   memberchk(м(S2), M)
        ->  get_base_morph_info(S2, MIL)
        ;   get_base_morph_info(S, MIL)
        ),
        member(MI, MIL).
% TODO: rewrite next 4 to 1 predicate
get_info(w(_W,_A,_S,i(I)), и(I)).
get_info(w(_W,_A,_S,i(I,A1)), WI) :-
        member(WI, [и(I),у1(A1)]).
get_info(w(_W,_A,_S,[i(I)|MI]), WI) :-
        member(WI, [и(I)|MI]),
        WI \= м(_).
get_info(w(_W,_A,_S,[i(I,A1)|MI]), WI) :-
        member(WI, [и(I),у1(A1)|MI]),
        WI \= м(_).

%%% get_base_syn_info(+MI, -MI2)
%%  - "Основная синтаксическая характеристика имени"
%%  чр - часть речи, ср - синтаксичекий род
get_base_syn_info(м,        [чр(с),ср(м),о(н)]).   % сущ. м.р. неод.
get_base_syn_info(мо,       [чр(с),ср(м),о(о)]).   % сущ. м.р. одуш.
get_base_syn_info(ж,        [чр(с),ср(ж),о(н)]).   % сущ. ж.р. неод.
get_base_syn_info(жо,       [чр(с),ср(ж),о(о)]).   % сущ. ж.р. одуш.
get_base_syn_info(с,        [чр(с),ср(с),о(н)]).   % сущ. с.р. неод.
get_base_syn_info(со,       [чр(с),ср(с),о(о)]).   % сущ. с.р. одуш.
get_base_syn_info('мо-жо',  [чр(с),ср(G),о(о)]) :- % сущ. общ.р. одуш.
        member(G, [м,ж]).
get_base_syn_info(мн,       [чр(с),ч(м),о(н)]).    % сущ. мн. неод.
get_base_syn_info(мно,      [чр(с),ч(м),о(о)]).    % сущ. мн. одуш.
get_base_syn_info(п,        [чр(п)]).              % прилагательное
get_base_syn_info(мс,       [чр(мс)]).             % местоимение
get_base_syn_info('мс-п',   [чр(п)]).              % местоимённое прилагательное
get_base_syn_info(числ,     [чр(ч)]).              % числительное
get_base_syn_info('числ-п', [чр(п)]).              % порядковое числительное
get_base_syn_info(св,       [чр(г),в(с)]).         % глагол
get_base_syn_info(нсв,      [чр(г),в(н)]).         % глагол
get_base_syn_info('св-нсв', [чр(г),в(A)]) :-       % глагол, A=aspect
        member(A ,[с,н]).
get_base_syn_info(POS,[чр(POS)]) :-                % остальные
        %% next list got by: setof(S,W^A^M^(z0:w(W,A,S,M)),L).
        memberchk(POS, [межд, н, предик, предл, союз, сравн, вводн, част]).

%%% get_paradigms(+POS, -GIS)
%%  - GIS - list of grammatical informations (word paradigm list)
get_paradigms(POS, GIS) :-
%         write(POS), flush,
        bagof(Paradigm, paradigms(POS, Paradigm), GIS), !,
        asserta(:-(get_paradigms(POS, GIS),!)).
get_paradigms(POS, []) :- asserta(:-(get_paradigms(POS, []),!)). % comment out this

%%% paradigms(+POS, -GI)
%%  - POS = Part Of Speech
%%  - GI = Grammatical Information (грамматическое значение)
paradigms(с,с(C,N)) :- num(N), case(C).
paradigms(п,с(C,е,G)) :- gender(G), case(C). % в ед.ч. по родам
paradigms(п,с(C,м,м)) :- case(C).            % в мн.ч. только м.р.? р(_)
paradigms(п,пк(е,G)) :- gender(G).           % кр.ф. в ед.ч. по родам
paradigms(п,пк(м,м)).                        % кр.ф. в мн.ч. только м.р.? р(_)
% paradigms(п,пс(S)) :- degree(S).           % сравн. и превосх. степень
paradigms(м,с(C,N,G)) :- paradigms(п, п(C,N,G)). % местоимение как прилагательное
paradigms(ч,с(C)) :- case(C).
paradigms(г,ги).                                     % инфинитив
paradigms(г,г(T,P,N)) :- tense(T), Т \== п, person(P), num(N).
paradigms(г,г(T,G,N)) :- tense(T), Т == п, genders(G), num(N).
paradigms(г,гп(N)) :- num(N).                        % повелительное наклонение
paradigms(г,гд(T)) :- tense(T), Т \== б.             % деепричастие
paradigms(г,гп(T,V)) :- tense(T), Т \== б, voice(V). % причастие
% paradigms(г,[т(п),в(T),з(V)|PL]) :- tense(T), Т \== б, voice(V), paradigms(п, PL).

%%% GI - grammatical information
case(C)   :- cases(_,CS),   member(C,CS). 
num(N)    :- numbers(_,NS), member(N,NS).
gender(G) :- genders(_,GS), member(G,GS).
degree(S) :- degrees(_,SS), member(S,SS).
person(P) :- persons(_,PS), member(P,PS).
tense(T)  :- tenses(_,TS),  member(T,TS).
voice(V)  :- voices(_,VS),  member(V,VS).
mood(M)   :- moods(_,MS),   member(M,MS).
type(T)   :- types(_,TS),   member(T,TS).

%%% GIS - grammatical information
cases(п,[и,р,д,в,т,п]).         % падеж
numbers(ч,[е,м]).               % число
genders(р,[м,ж,с]).             % род
degrees(с,[с,п]).               % степени сравнения
persons(л,[1,2,3]).             % лицо
tenses(в,[п,н,б]).              % время
voices(з,[д,с]).                % залог
moods(н,[и,п,с]).               % наклонение
types(т,[и,п,д]).               % тип глагола: инфинитив, (дее)?причастие

%% другой способ представления
% case(и). case(р). case(д). case(в). case(т). case(п).
% cases(CS) :- bagof(C, case(C), CS).

%%% get_base_morph_info(+SI, -SI2)
%%  Основная морфологическая характеристика имени
%%  с - вид склонения, р - морфологический род
get_base_morph_info(м,        [с(с),р(м)]). % субстантивное склонение, м.р.
get_base_morph_info(мо,       [с(с),р(м)]). % субстантивное склонение, м.р.
get_base_morph_info(ж,        [с(с),р(ж)]). % субстантивное склонение, ж.р.
get_base_morph_info(жо,       [с(с),р(ж)]). % субстантивное склонение, ж.р.
get_base_morph_info('мо-жо',  [с(с),р(ж)]). % субстантивное склонение, ж.р.
get_base_morph_info(с,        [с(с),р(с)]). % субстантивное склонение, с.р.
get_base_morph_info(со,       [с(с),р(с)]). % субстантивное склонение, с.р.
get_base_morph_info(п,        [с(а)]).      % адъективное склонение
get_base_morph_info(мс,       [с(мс)]).     % местоимённое склонение
get_base_morph_info('мс-п',   [с(мс)]).     % адъективное склонение
get_base_morph_info(числ,     [с(ч)]).      % склонение числительных
get_base_morph_info('числ-п', [с(ч)]).      % адъективное склонение

%%% get_mi_wfi(wi(W,WI), mi(WB,Ac2,D,WFI,Ch,WI))
%%  Prepare some information for declension
get_mi_wfi(wi(W,WI), mi(WB,Ac2,D,WFI,Ch,WI2)) :-
        subset([у(Ac1),с(D),и(T),у1(U)], WI), !,
        once((memberchk(р(G), WI) ; G = м)),
        (   memberchk(о(A), WI)
        ->  WFI = wfi(D,T,U,G,A)
        ;   WFI = wfi(D,T,U)
        ),
        Ac1 = Ac2,              % TODO: a(X,Y) -> X, e(X) -> X, etc.
        ( memberchk(ч, WI) -> Ch=y ; Ch=n ), !,
        wbase_str(W, D, Ch, WB), !,
        subtract(WI, [чр(_),у(_),с(_),и(_),у1(_),р(_),о(_),ч], WI2), !.

%%% has_running_vowel(+I1, -Ch)
has_running_vowel(A, y) :- memberchk(ч, A), !.
has_running_vowel(_, n).

%%% wbase_str(+Word, +D, +Ch, -WordBase) - графическая основа слова
wbase_str(W,D,Ch,WB) :-
        wbase_str2(W,D,WB2),
        get_base_wbase(WB2,Ch,WB), !.
wbase_str(_,_,_,_) :- nl, write('*** wbase_str failed ***'), nl.

%%% wbase_str2(+Word, +D, -WordBase)
wbase_str2(W,D,WB) :- 
        (D=с;D=м),
        word_suffix(W, 1, WB, S), string_to_list(S, [C]),
        memberchk(C,[0'а,0'е,0'ё,0'и,0'й,0'о,0'у,0'ь,0'ы,0'э,0'ю,0'я]), !.
wbase_str2(W,D,W) :-
        (D=с;D=м), !.
wbase_str2(W,а,[WB,"ся"]) :-
        word_suffix(W, 2, WB2, "ся"), word_suffix(WB2, 2, WB, _), !.
wbase_str2(W,а,WB) :-
        word_suffix(W, 2, WB, _), !.
wbase_str2(W,_,W) :- !.

%%% get_base_wbase(+WordBase, +Ch, -WordBase2)
get_base_wbase(WB, n, WB) :- !.
get_base_wbase(WB, y, WB2) :-
        get_running_vowel(WB, C, WB2),
        memberchk(C, [0'а,0'е,0'ё,0'и,0'о,0'у,0'ы,0'э,0'ю,0'я]), !.
get_base_wbase(WB, _, WB) :- !.

%%%% Create wordform - Именное словоизменение

%%% wordform(+MI, +GI, -WordForm)
wordform(MI, GI, WF) :-
        wordform2(MI, GI, WF2),
        wf_postproc_wf(WF2, MI, GI, WF).

%%% wf_postproc_wf(+W, +MI, +GI, -W2)
wf_postproc_wf(w(W,A), mi(_,_,_,_,_,[]), _, w(W,A)) :- !.
wf_postproc_wf(w(W,A), mi(_,_,_,_,_,WI), GI, w(W,A,[FR])) :-
        member(FR, [n(FL),p(FL),z(FL)]),
        memberchk(FR, WI),
        member(GI2, FL), copy_term(GI2, GI), !. % try e_free_variables
wf_postproc_wf(w(W,A), MI, с(п,е), [w(W,A), w(W2,L2,[FR])]) :-
        MI = mi(_,_,_,_,_,WI),
        member(FR, [п2, п2(_)]), % now it is always п2(_)
        memberchk(FR, WI),
        wordform2(MI, с(д,е), w(W2,_A2)),
        string_length(W2, L2), !.
wf_postproc_wf(WA, _, _, WA).

%%% wordform2(+MI, +GI, -WordForm)
wordform2(mi(WB,A,D,WFI,Ch,_WI), GI, w(W2,A2)) :-    % mi(WB,A,D,MI2,_I2,Ch)
        (D==с ; D==а ; D==м),
        get_wf_info(WFI, GI, wf_tab(D2,N,G,T,U,O,C), _Comments),
        get_we_accent(U, GI, U2), !,
        get_accent(WB, U2, A, A2),
        wf_we_tab_pre(GI, wf_tab(D2,N,G,T,U2,O,C), S),
        wf_add_we(WB, S, Ch, W2), !.
wordform2(mi(WB,_,D,_,_,_), GI, w(W2,A2)) :-
        D == ч,
        wf_exc(WB, GI, w(W2,A2)).

%%% get_wf_info(+D, +MI2, +GI, WFTab).
get_wf_info(wfi(D,T,U,G,A), с(C,N), wf_tab(D,N,G,T,U,A,C), []).
get_wf_info(wfi(D,T,U), с(C,N,G,A), wf_tab(D,N,G,T,U,A,C), []).
get_wf_info(wfi(D,T,U), с(C,N,G), wf_tab(D,N,G,T,U,A,C), [о(A)]) :- (A=н;A=о).
get_wf_info(wfi(D,T,U), пк(N,G), wf_tab(D,N,G,T,U,о,и), []).

%%% get_we_accent(+Accent, +D, -U)
get_we_accent(a,      _, б).
get_we_accent(b,      _, у).
get_we_accent(b2,     _, у).
get_we_accent(c, с(_,е), б) :- !.
get_we_accent(c,      _, у).
get_we_accent(d, с(_,е), у) :- !.
get_we_accent(d,      _, б).
get_we_accent(e,     GI, б) :- GI = с(_,е) ; GI = с(и,м).
get_we_accent(e,      _, у).
get_we_accent(f, с(и,м), б) :- !.
get_we_accent(f,      _, у).

%%% get_accent(+WordBase, +U, +Ac, -Ac2)
get_accent(_, б, Ac, Ac).
get_accent(B, у, _, Ac2) :- string_length(B, Len), Ac2 is Len + 1.

%%% wf_we_tab_pre(+GI, +WordFormTab, -WordEnding)
%%  - дополнительные особенности окончаний субстантивного склонения
wf_we_tab_pre(с(р,м), wf_tab(с,_,м,4,_,_,_), "ей") :- !.
wf_we_tab_pre(с(р,м), wf_tab(с,_,G,4,б,_,_), "") :- (G=с;G=ж), !.
wf_we_tab_pre(с(р,м), wf_tab(с,_,G,4,у,_,_), "ей") :- (G=с;G=ж), !.

wf_we_tab_pre(с(р,м), wf_tab(с,_,м,6,б,_,_), "ев") :- !.
wf_we_tab_pre(с(р,м), wf_tab(с,_,м,6,у,_,_), "ёв") :- !.
wf_we_tab_pre(с(р,м), wf_tab(с,_,G,6,_,_,_), "й") :- (G=с;G=ж), !.

wf_we_tab_pre(с(р,м), wf_tab(с,_,G,7,U,_,_), S) :-
        wf_we_tab_pre(с(р,м), wf_tab(_,_,G,6,U,_,_), S), !.
wf_we_tab_pre(с(д,е), wf_tab(с,_,ж,7,б,_,_), "и") :- !.
wf_we_tab_pre(с(д,е), wf_tab(с,_,ж,7,у,_,_), "е") :- !.
wf_we_tab_pre(с(п,е), wf_tab(с,_,_,7,б,_,_), "и") :- !.
wf_we_tab_pre(с(п,е), wf_tab(с,_,_,7,у,_,_), "е") :- !.

wf_we_tab_pre(_, wf_tab(D,N,G,T,U,A,C), S2) :-
        type2type(T, T2),
        wf_we_tab(D, N, G, T2, U, A, C, S),
        post_proc(S, T, U, S2).

%%% type2type(+Type, -Type2)
type2type(1, 1).
type2type(3, 1).
type2type(4, 1).
type2type(5, 1).
type2type(2, 2).
type2type(6, 2).
type2type(7, 2).
type2type(8, 8).

%%% post_proc(+WordEnding, +Type, +Accent, -WordEnding2)
post_proc(S, 3, _, S2) :- replace_first_char(S, 0'ы, 0'и, S2).
post_proc(S, 4, _, S2) :- replace_first_char(S, 0'ы, 0'и, S2).
post_proc(S, 4, б, S2) :- replace_first_char(S, 0'о, 0'е, S2).
post_proc(S, 5, б, S2) :- replace_first_char(S, 0'о, 0'е, S2).
post_proc(S, 6, _, S2) :- replace_first_char(S, 0'ь, 0'й, S2).
post_proc(S, 7, _, S2) :- replace_first_char(S, 0'ь, 0'й, S2).
post_proc(S, _, _, S).

%%% wf_exc(+Word, +GI, -Word)
%% THIS SHOULD BE MOVED TO w(W,A,S,M) !!!
wf_exc("семь",ч(C),w("семь",2)) :- C=и;C=в.
wf_exc("семь",ч(C),w("семи",4)) :- C=р;C=д;C=п.
wf_exc("семь",ч(т),w("семью",5)).
wf_exc("восемь",ч(C),w("восемь",2)) :- C=и;C=в.
wf_exc("восемь",ч(C),w("восьми",6)) :- C=р;C=д;C=п.
wf_exc("восемь",ч(т),w("восемью",7)).
wf_exc("восемь",ч(т),w("восьмью",7)).

%%% wf_add_we(+WordBase, +WordEnding, +Ch, -Word)
wf_add_we(WB, "", y, W2) :- set_running_vowel(W2, 0'е, WB), !. %'
wf_add_we([WB,S2], S, _, W2) :- % добавить -ся
        wf_add_we(WB, S, _, WB2),
        string_concat(WB2, S2, W2).
wf_add_we(WB, S, _, W2) :- string_concat(WB, S, W2).

%%%% Таблицы стандартных окончаний
%% wf_we_tab - wordform word endings table

%%% Стандартные окончания субстантивного склонения
wf_we_tab(с,е,м,1,U,A,и,"" ) :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,е,м,2,U,A,и,"ь") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,е,с,1,U,A,и,"о") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,е,с,2,б,A,и,"е") :- (A=н;A=о).
wf_we_tab(с,е,с,2,у,A,и,"ё") :- (A=н;A=о).
wf_we_tab(с,е,ж,1,U,A,и,"а") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,е,ж,2,U,A,и,"я") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,м,м,1,U,A,и,"ы") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,м,м,2,U,A,и,"и") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,м,с,1,U,A,и,"а") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,м,с,2,U,A,и,"я") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,м,ж,1,U,A,и,"ы") :- (U=б;U=у), (A=н;A=о).
wf_we_tab(с,м,ж,2,U,A,и,"и") :- (U=б;U=у), (A=н;A=о).

wf_we_tab(с,е,G,1,_,_,р,"а" )  :- G=м;G=с.
wf_we_tab(с,е,G,2,_,_,р,"я" )  :- G=м;G=с.
wf_we_tab(с,е,ж,1,_,_,р,"ы" ).
wf_we_tab(с,е,ж,2,_,_,р,"и" ).
wf_we_tab(с,м,м,1,_,_,р,"ов").
wf_we_tab(с,м,м,2,_,_,р,"ей").
wf_we_tab(с,м,G,1,_,_,р,""  ) :- G=с;G=ж.
wf_we_tab(с,м,G,2,б,_,р,"ь" ) :- G=с;G=ж.
wf_we_tab(с,м,G,2,у,_,р,"ей") :- G=с;G=ж.

wf_we_tab(с,е,G,1,_,_,д,"у" ) :- G=м;G=с.
wf_we_tab(с,е,G,2,_,_,д,"ю" ) :- G=м;G=с.
wf_we_tab(с,е,ж,T,_,_,д,"е" ) :- T=1;T=2.
wf_we_tab(с,м,G,1,_,_,д,"ам") :- G=м;G=с;G=ж.
wf_we_tab(с,м,G,2,_,_,д,"ям") :- G=м;G=с;G=ж.

wf_we_tab(с,е,м,T,U,н,в,S  ) :- wf_we_tab(с,е,м,T,U,_,и,S).
wf_we_tab(с,е,м,T,U,о,в,S  ) :- wf_we_tab(с,е,м,T,U,_,р,S).
wf_we_tab(с,е,с,T,U,A,в,S  ) :- wf_we_tab(с,е,с,T,U,A,и,S).
wf_we_tab(с,е,ж,1,_,_,в,"у").
wf_we_tab(с,е,ж,2,_,_,в,"ю").
wf_we_tab(с,м,G,T,U,н,в,S  ) :- wf_we_tab(с,м,G,T,U,_,и,S).
wf_we_tab(с,м,G,T,U,о,в,S  ) :- wf_we_tab(с,м,G,T,U,_,р,S).

wf_we_tab(с,е,G,1,_,_,т,"ом") :- G=м;G=с.
wf_we_tab(с,е,G,2,б,_,т,"ем") :- G=м;G=с.
wf_we_tab(с,е,G,2,у,_,т,"ём") :- G=м;G=с.
wf_we_tab(с,е,ж,1,_,_,т,S   ) :- S="ой";S="ою".
wf_we_tab(с,е,ж,2,б,_,т,S   ) :- S="ей";S="ею".
wf_we_tab(с,е,ж,2,у,_,т,S   ) :- S="ёй";S="ёю".
wf_we_tab(с,м,G,1,_,_,т,"ами") :- G=м;G=с;G=ж.
wf_we_tab(с,м,G,2,_,_,т,"ями") :- G=м;G=с;G=ж.

wf_we_tab(с,е,G,T,_,_,п,"е" ) :- (G=м;G=с;G=ж), (T=1;T=2).
wf_we_tab(с,м,G,1,_,_,п,"ах") :- G=м;G=с;G=ж.
wf_we_tab(с,м,G,2,_,_,п,"ях") :- G=м;G=с;G=ж.

wf_we_tab(с,е,_,8,_,_,и,"ь").
wf_we_tab(с,е,_,8,_,_,в,"ь").
wf_we_tab(с,е,_,8,_,_,р,"и").
wf_we_tab(с,е,_,8,_,_,д,"и").
wf_we_tab(с,е,_,8,_,_,п,"и").
wf_we_tab(с,е,ж,8,_,_,т,"ью").
wf_we_tab(с,е,G,8,б,_,т,"ем") :- G=м;G=с.
wf_we_tab(с,е,G,8,у,_,т,"ём") :- G=м;G=с.
wf_we_tab(с,м,_,8,_,_,р,"ей").
wf_we_tab(с,м,G,8,U,A,C,S) :- wf_we_tab(с,м,G,2,U,A,C,S), C\==р.

%%% Стандартные окончания адъективного склонения, полные формы
wf_we_tab(а,е,м,1,б,_,и,"ый").
wf_we_tab(а,е,м,1,у,_,и,"ой").
wf_we_tab(а,е,м,2,_,_,и,"ий").
wf_we_tab(а,е,с,1,_,_,и,"ое").
wf_we_tab(а,е,с,2,_,_,и,"ее").
wf_we_tab(а,е,ж,1,_,_,и,"ая").
wf_we_tab(а,е,ж,2,_,_,и,"яя").
wf_we_tab(а,м,G,1,_,_,и,"ые") :- G=м;G=с;G=ж.
wf_we_tab(а,м,G,2,_,_,и,"ие") :- G=м;G=с;G=ж.

wf_we_tab(а,е,G,1,_,_,р,"ого") :- G=м;G=с.
wf_we_tab(а,е,G,2,_,_,р,"его") :- G=м;G=с.
wf_we_tab(а,е,ж,1,_,_,р,"ой" ).
wf_we_tab(а,е,ж,2,_,_,р,"ей" ).
wf_we_tab(а,м,G,1,_,_,р,"ых" ) :- G=м;G=с;G=ж.
wf_we_tab(а,м,G,2,_,_,р,"их" ) :- G=м;G=с;G=ж.

wf_we_tab(а,е,G,1,_,_,д,"ому") :- G=м;G=с.
wf_we_tab(а,е,G,2,_,_,д,"ему") :- G=м;G=с.
wf_we_tab(а,е,ж,1,_,_,д,"ой" ).
wf_we_tab(а,е,ж,2,_,_,д,"ей" ).
wf_we_tab(а,м,G,1,_,_,д,"ым" ) :- G=м;G=с;G=ж.
wf_we_tab(а,м,G,2,_,_,д,"им" ) :- G=м;G=с;G=ж.

wf_we_tab(а,е,м,T,U,н,в,S   ) :- wf_we_tab(а,е,м,T,U,_,и,S).
wf_we_tab(а,е,м,T,U,о,в,S   ) :- wf_we_tab(а,е,м,T,U,_,р,S).
wf_we_tab(а,е,с,T,U,A,в,S   ) :- wf_we_tab(а,е,с,T,U,A,и,S).
wf_we_tab(а,е,ж,1,_,_,в,"ую").
wf_we_tab(а,е,ж,2,_,_,в,"юю").
wf_we_tab(а,м,G,T,U,н,в,S   ) :- wf_we_tab(а,м,G,T,U,_,и,S).
wf_we_tab(а,м,G,T,U,о,в,S   ) :- wf_we_tab(а,м,G,T,U,_,р,S).

wf_we_tab(а,е,G,1,_,_,т,"ым" ) :- G=м;G=с.
wf_we_tab(а,е,G,2,_,_,т,"им" ) :- G=м;G=с.
wf_we_tab(а,е,ж,1,_,_,т,S    ) :- S="ой";S="ою".
wf_we_tab(а,е,ж,2,_,_,т,S    ) :- S="ей";S="ею".
wf_we_tab(а,м,G,1,_,_,т,"ыми") :- G=м;G=с;G=ж.
wf_we_tab(а,м,G,2,_,_,т,"ими") :- G=м;G=с;G=ж.

wf_we_tab(а,е,G,1,_,_,п,"ом") :- G=м;G=с.
wf_we_tab(а,е,G,2,_,_,п,"ем") :- G=м;G=с.
wf_we_tab(а,е,ж,1,_,_,п,"ой").
wf_we_tab(а,е,ж,2,_,_,п,"ей").
wf_we_tab(а,м,G,1,_,_,п,"ых") :- G=м;G=с;G=ж.
wf_we_tab(а,м,G,2,_,_,п,"их") :- G=м;G=с;G=ж.

%%% Стандартные окончания адъективного склонения, краткие формы
wf_we_tab(к,е,м,1,_,_,и,"" ).
wf_we_tab(к,е,м,2,_,_,и,"ь").
wf_we_tab(к,е,с,1,_,_,и,"о").
wf_we_tab(к,е,с,2,б,_,и,"е").
wf_we_tab(к,е,с,2,у,_,и,"ё").
wf_we_tab(к,е,ж,1,_,_,и,"а").
wf_we_tab(к,е,ж,2,_,_,и,"я").
wf_we_tab(к,м,G,1,_,_,и,"ы") :- G=м;G=с;G=ж.
wf_we_tab(к,м,G,2,_,_,и,"и") :- G=м;G=с;G=ж.

%%% Стандартные окончания местоименного склонения
wf_we_tab(м,е,м,1,_,_,и,"" ).
wf_we_tab(м,е,м,2,_,_,и,"ь").
wf_we_tab(м,е,с,1,_,_,и,"о").
wf_we_tab(м,е,с,2,б,_,и,"е").
wf_we_tab(м,е,с,2,у,_,и,"ё").
wf_we_tab(м,е,ж,1,_,_,и,"а").
wf_we_tab(м,е,ж,2,_,_,и,"я").
wf_we_tab(м,м,G,1,_,_,и,"ы") :- G=м;G=с;G=ж.
wf_we_tab(м,м,G,2,_,_,и,"и") :- G=м;G=с;G=ж.

wf_we_tab(м,е,G,1,_,_,р,"ого") :- G=м;G=с.
wf_we_tab(м,е,G,2,_,_,р,"его") :- G=м;G=с.
wf_we_tab(м,е,ж,1,_,_,р,"ой" ).
wf_we_tab(м,е,ж,2,_,_,р,"ей" ).
wf_we_tab(м,м,G,1,_,_,р,"ых" ) :- G=м;G=с;G=ж.
wf_we_tab(м,м,G,2,_,_,р,"их" ) :- G=м;G=с;G=ж.

wf_we_tab(м,е,G,1,_,_,д,"ому") :- G=м;G=с.
wf_we_tab(м,е,G,2,_,_,д,"ему") :- G=м;G=с.
wf_we_tab(м,е,ж,1,_,_,д,"ой" ).
wf_we_tab(м,е,ж,2,_,_,д,"ей" ).
wf_we_tab(м,м,G,1,_,_,д,"ым" ) :- G=м;G=с;G=ж.
wf_we_tab(м,м,G,2,_,_,д,"им" ) :- G=м;G=с;G=ж.

wf_we_tab(м,е,м,T,U,н,в,S  ) :- wf_we_tab(м,е,м,T,U,_,и,S).
wf_we_tab(м,е,м,T,U,о,в,S  ) :- wf_we_tab(м,е,м,T,U,_,р,S).
wf_we_tab(м,е,с,T,U,A,в,S  ) :- wf_we_tab(м,е,с,T,U,A,и,S).
wf_we_tab(м,е,ж,1,_,_,в,"у").
wf_we_tab(м,е,ж,2,_,_,в,"ю").
wf_we_tab(м,м,G,T,U,н,в,S  ) :- wf_we_tab(м,м,G,T,U,_,и,S).
wf_we_tab(м,м,G,T,U,о,в,S  ) :- wf_we_tab(м,м,G,T,U,_,р,S).

wf_we_tab(м,е,G,1,_,_,т,"ым" ) :- G=м;G=с.
wf_we_tab(м,е,G,2,_,_,т,"им" ) :- G=м;G=с.
wf_we_tab(м,е,ж,1,_,_,т,S    ) :- S="ой";S="ою".
wf_we_tab(м,е,ж,2,_,_,т,S    ) :- S="ей";S="ею".
wf_we_tab(м,м,G,1,_,_,т,"ыми") :- G=м;G=с;G=ж.
wf_we_tab(м,м,G,2,_,_,т,"ими") :- G=м;G=с;G=ж.

wf_we_tab(м,е,G,1,_,_,п,"ом") :- G=м;G=с.
wf_we_tab(м,е,G,2,б,_,п,"ем") :- G=м;G=с.
wf_we_tab(м,е,G,2,у,_,п,"ём") :- G=м;G=с.
wf_we_tab(м,е,ж,1,_,_,п,"ой").
wf_we_tab(м,е,ж,2,_,_,п,"ей").
wf_we_tab(м,м,G,1,_,_,п,"ых") :- G=м;G=с;G=ж.
wf_we_tab(м,м,G,2,_,_,п,"их") :- G=м;G=с;G=ж.

%%%% Utilities

%%% word_prefix(+S, +N, -S1, -S2)
word_prefix(S, N, S1, S2) :-
        string_length(S, Len),
        Len2 is Len - N,
        N2 is N + 1,
        substring(S, 1, N, S1),
        substring(S, N2, Len2, S2).
        
%%% word_suffix(+S, +N, -S1, -S2)
word_suffix(S, N, S1, S2) :-
        string_length(S, Len),
        Len2 is Len - N,
        N2 is Len2 + 1,
        substring(S, 1, Len2, S1),
        substring(S, N2, N, S2).

%%% replace_first_char(+S1, +C1, +C2, -S2)
replace_first_char(S1,C1,C2,S2) :-
        string_to_list(S1, L1),
        append([C1],S,L1), append([C2],S,L2),
        string_to_list(S2, L2).

%%% get_running_vowel(+S1, -C, -S2)
get_running_vowel(S1,C,S2) :-
        string_to_list(S1, L1),
        append(S,[C,C2],L1), append(S,[C2],L2),
        string_to_list(S2, L2).

%%% set_running_vowel(+S1, +C, -S2)
set_running_vowel(S1,C,S2) :-
        string_to_list(S2, L2),
        append(S,[C2],L2), append(S,[C,C2],L1),
        string_to_list(S1, L1).

%%%% User Interface

%%% pr_parad(+W)
pr_parad(W) :-
        writef("%w:\n", [W]),
        word2paradigms(W, InflTables), !,
        forall( member(InflTable, InflTables),
                pr_parad_table(InflTable)).
pr_parad(_) :-
        writef("  слово не найдено.\n").

%%% pr_parad_table(+InflTable)
pr_parad_table(t(WI,InflTable)) :-
        get_word_info(WI, Info),
        writef("  %w\n", [Info]),
%         ru_case(C), ru_number(N),
        forall( member(InflRow, InflTable),
                pr_parad_row(InflRow)).

%%% pr_parad_row(+WF)
pr_parad_row(wf(GIS,InflRow)) :-
        writef("    %w: %w\n", [GIS,InflRow]).

%%% pr_parad2(+W)
pr_parad2(W) :-
        % w(W,A,S,M), word2paradigms(w(W,A,S,M), InflTables), !,
        word2paradigms(W, InflTables), !,
        forall( member(InflTable, InflTables),
                pr_parad_table2(InflTable)).

%%% pr_parad_table2(+InflTable)
pr_parad_table2(t(_,InflTable)) :-
        forall( member(wf(_,W), InflTable),
                writef("%w\n", [W])).

%%% pr_parads3
pr_parads3 :-
        wi(W, WI),
        writef("%w:", [W]),
        pr_parads3(wi(W,WI)),
        nl.

pr_parads3(wi(W,WI)) :-
        wi2paradigm(wi(W,WI), WordForms),
        forall( member(wf(_,Word), WordForms),
                pr_parad_row3(Word)), !.
pr_parads3(_).

%%% pr_parad3(+W)
pr_parad3(W) :-
        % w(W,A,S,M), word2paradigms(w(W,A,S,M), InflTables), !,
        word2paradigms(W, InflTables), !,
        forall( member(InflTable, InflTables),
                pr_parad_table3(InflTable)).

%%% pr_parad_table2(+InflTable)
pr_parad_table3(t(_,InflTable)) :-
        forall( member(wf(_,W), InflTable),
                pr_parad_row3(W)),
        nl.

%%% pr_parad_row3(W)
%%  
pr_parad_row3(WordList) :-
        is_list(WordList), !,
        maplist(pr_parad_word3, WordList, WordList2),
        concat_atom(WordList2, '/', Word2),
        writef(" %w", [Word2]).
pr_parad_row3(Word) :-
        pr_parad_word3(Word, Word2),
        writef(" %w", [Word2]).

pr_parad_word3(w(W,_A), WA) :-
        %% rus:accent_word(w(W,A), WA), % not working accents
        W = WA,
        !.
pr_parad_word3(w(W,_A,Cm), WA) :-
        %% rus:accent_word(w(W,A), WA2), % not working accents
        W = WA2,
        maplist(pr_parad_word_comments3, Cm, Cm2),
        concat_atom(Cm2, Cm3),
        concat(Cm3, WA2, WA).

pr_parad_word_comments3(п2(P2), PP2) :- nonvar(P2), concat_atom(['(',P2,')'],PP2). % concat(P2, ' ', PP2)
pr_parad_word_comments3(p(_), '?').
pr_parad_word_comments3(z(_), '?').
pr_parad_word_comments3(n(_), '*').
pr_parad_word_comments3(_, 'x').

%%% get_word_info(+WI, -SI)
get_word_info(wi(W,WI), [W|WI]).
% get_word_info(w(W,_,SI,_), [W|SI]) :- !.
% get_word_info(wi(W,WI), [W|WI]) :- !.
% get_word_info(wi(W,WI), [W|Info]) :-
%         maplist(map_word_info, WI, Info), !.
% get_word_info(w(W,_,SI,_), [W|Info]) :-
%         maplist(map_word_info, SI, Info), !.

%%% map_word_info(+SI, -POS_Word)
map_word_info(чр(с), 'существительное').
map_word_info(ср(м), 'мужского рода').
map_word_info(ср(ж), 'женского рода').
map_word_info(ср(с), 'среднего рода').
map_word_info(о(о), 'одушевлённое').
map_word_info(о(н), 'неодушевлённое').
map_word_info(чр(п), 'прилагательное').
map_word_info(чр(г), 'глагол').
map_word_info(c(Comments), [Comments]).
map_word_info(I, I).
% writef("И.п.: %w!", [W]).
% word2infltables('книга',[t(w(книга,3,[с,р(ж)],[с,3,ж,"3ж"]),[книги,книгу])]).

%%%% wordform_f

%%% wordform_f(WS,WB,wf_we_tab(D,N,G,T,U,A,C,S))
%% wordform(WF1,X,WF2) :- wordform(WI,_,WF1), wordform(WI,X,WF2).
wordform_f(WS,WB,wf_we_tab(D,N,G,T,U,A,C,S)) :-
        string_length(WS, WSL),
        wf_we_tab(D,N,G,T,U,A,C,S),
        S \== "",
        string_length(S, SL),
        Start1 is WSL - SL,
        Start2 is Start1 + 1,
        substring(WS, 1, Start1, WB),
        substring(WS, Start2, SL, S).
        %% w(WB,_,_,_).

%%%% Tests
%%  Collect all WI:
%%    tell(wis),wi(_,WI),subtract(WI,[у(_),c(_)],WI2),write(WI2),nl,fail;told.
%%    tell(wis),wi(_,WI),subtract(WI,[у(_),c(_),c2(_),c3(_)],WI2),write(WI2),nl,fail;told.

%%% Top-level tests
run_tests :-
        test(W),
        wi(W,WI),
        write(WI), nl,
        pr_parads3(wi(W,WI)),
        nl,
        fail ; true.

test_word(wi(W,WI)) :-
        member(TS,[с]), % setof(X,W^WI^(wi(W,WI),member(с(X),WI)),L). -> [а,мс,с]
        member(G,[м,ж,с]), % setof(X,W^WI^(wi(W,WI),member(р(X),WI)),L).
        member(U1,[a,b,c,d,e,f]), % setof(X,W^WI^(wi(W,WI),member(у1(X),WI)),L). -> [a,a1,b,b1,c,c1,d,d1,e,f,f1,f2]
        between(1, 7, I), % setof(X,W^WI^(wi(W,WI),member(и(X),WI)),L). -> 0..16
        member(An, [н,о]),
%         once((wi(W, WI), subset([с(TS),р(G),у1(U1),и(I),о(A)], WI))).
        once((z0:w(W,A,S,M), s2([с(TS),р(G),у1(U1),и(I),о(An)], w(W,A,S,M)))),
        get_all_info(w(W,A,S,M), WI).

%%% Субстантивное склонение. Мужской род.
test(завод).
test(артист).
test(портфель).
test(житель).
test(чайник).
test(бульдог).
test(марш).
test(товарищ).
test(месяц).
test(принц).
test(случай).
test(герой).
test(сценарий).
test(викарий).

%%%% backup
% get_base_syn_inf(м,с(м,н)).        % сущ. м.р. неод.
% get_base_syn_inf(мо,с(м,о)).       % сущ. м.р. одуш.
% get_base_syn_inf(ж,с(ж,н)).        % сущ. ж.р. неод.
% get_base_syn_inf(жо,с(ж,о)).       % сущ. ж.р. одуш.
% get_base_syn_inf(с,с(с,н)).        % сущ. с.р. неод.
% get_base_syn_inf(со,с(с,о)).       % сущ. с.р. одуш.
% get_base_syn_inf('мо-жо',с(мж,о)). % сущ. мо-жо одуш.
% get_base_syn_inf(мн(н),с(мн,о)).   % сущ. мн. неод.
% get_base_syn_inf(мн(о),с(мн,о)).   % сущ. мн. одуш.
% get_base_syn_inf(п,п).             % прилагательное
% get_base_syn_inf(мс,мс).           % местоимение
% get_base_syn_inf('мс-п',п(мс)).    % местоимённое прилагательное
% get_base_syn_inf(числ,ч).          % числительное
% get_base_syn_inf(числ,п(ч)).       % порядковое числительное
% get_all_info_old(S, M, WI) :-
%         get_base_syn_inf(S, SI),
%         (   is_list(M)
%         ->  MI = M
%         ;   MI = [M]
%         ),
%         (   memberchk(mi(S2), MI)
%         ->  get_base_morph_inf(S2,TS)
%         ;   get_base_morph_inf(S,TS)
%         ),
%         append(SI, [с(TS)|MI], WI).
% %         WI = [s(SI), m(M)].
