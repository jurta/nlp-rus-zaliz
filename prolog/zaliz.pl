%% -*- mode: Prolog; coding: cyrillic-koi8; -*-
%%%% zaliz.pl - word formation according to A.A.Zaliznyak
%%   $Id: zaliz.pl,v 1.2 2001/02/20 22:19:46 juri Exp $
%%   Copyright (c) 2000 Juri Linkov.  All rights reserved.

:- module(z,                    % or zaliz, and no export here at all
          [ wi/2                % interface to database
          , word2paradigms/2    % word to infltables
          , word2paradigm/2     % ����� -> ���������
          , wi2paradigm/2       % ��������� ������ -> ���������
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
%%  Word - �����
%%  Accent - ��������: N a(N,N) e(N) e(N,N)
%%  WordBase - ����������� ������ �����
%%  D - ��� ���������
%%   � - �������������
%%   � - �����������
%%   � - ������ͣ����
%%  DS - ��������������� ��������������: �(�,�) �(�,�) � �(��)
%%  T - ��� ��������� (0..8) ��� ��������� (1..16)
%%  U - ����� ��������: a b a1 f2 a(a,a) a(a,c1) a(a,c2)
%%  U2 - ��������� ��� ���������? �/�
%%  Ch - ��� ����������� 1: y/n
%%  Ch2 - ��� ����������� 2: y/n

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
        memberchk(��(POS), WI),
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
get_syntax_inf2(�,�,�,�(�,�)).        % ���. �.�. ����.
get_syntax_inf2(��,�,�,�(�,�)).       % ���. �.�. ����.
get_syntax_inf2(�,�,�,�(�,�)).        % ���. �.�. ����.
get_syntax_inf2(��,�,�,�(�,�)).       % ���. �.�. ����.
get_syntax_inf2(�,�,�,�(�,�)).        % ���. �.�. ����.
get_syntax_inf2(��,�,�,�(�,�)).       % ���. �.�. ����.
get_syntax_inf2(��,�,�,�(��)).
get_syntax_inf2(���,�,�,�(���)).
get_syntax_inf2('��-���',�,�,�('��-���')).
get_syntax_inf2(�,�,�,�).
get_syntax_inf2(��,�,�,�).
get_syntax_inf2('��-�',�,�,�).
get_syntax_inf2(����,�,�,�).
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

%%% get_info(w(_W,A,_S,_M), �(A))
%%  
% please consider this format:
%       w(���,[�-2,��-�,�-�,�-�,�-1,�1-c]). % where Key-Value = -(Key,Valule)
% i.e.: w(���,[-(�,2),-(��,�)]).
get_info(w(_W,A,_S,_M), �(A)).
get_info(w(_W,_A,S,_M), SI) :-
        get_base_syn_info(S, SIL),
        member(SI, SIL).
get_info(w(_W,_A,S,M), MI) :-
        (   memberchk(�(S2), M)
        ->  get_base_morph_info(S2, MIL)
        ;   get_base_morph_info(S, MIL)
        ),
        member(MI, MIL).
% TODO: rewrite next 4 to 1 predicate
get_info(w(_W,_A,_S,i(I)), �(I)).
get_info(w(_W,_A,_S,i(I,A1)), WI) :-
        member(WI, [�(I),�1(A1)]).
get_info(w(_W,_A,_S,[i(I)|MI]), WI) :-
        member(WI, [�(I)|MI]),
        WI \= �(_).
get_info(w(_W,_A,_S,[i(I,A1)|MI]), WI) :-
        member(WI, [�(I),�1(A1)|MI]),
        WI \= �(_).

%%% get_base_syn_info(+MI, -MI2)
%%  - "�������� �������������� �������������� �����"
%%  �� - ����� ����, �� - ������������� ���
get_base_syn_info(�,        [��(�),��(�),�(�)]).   % ���. �.�. ����.
get_base_syn_info(��,       [��(�),��(�),�(�)]).   % ���. �.�. ����.
get_base_syn_info(�,        [��(�),��(�),�(�)]).   % ���. �.�. ����.
get_base_syn_info(��,       [��(�),��(�),�(�)]).   % ���. �.�. ����.
get_base_syn_info(�,        [��(�),��(�),�(�)]).   % ���. �.�. ����.
get_base_syn_info(��,       [��(�),��(�),�(�)]).   % ���. �.�. ����.
get_base_syn_info('��-��',  [��(�),��(G),�(�)]) :- % ���. ���.�. ����.
        member(G, [�,�]).
get_base_syn_info(��,       [��(�),�(�),�(�)]).    % ���. ��. ����.
get_base_syn_info(���,      [��(�),�(�),�(�)]).    % ���. ��. ����.
get_base_syn_info(�,        [��(�)]).              % ��������������
get_base_syn_info(��,       [��(��)]).             % �����������
get_base_syn_info('��-�',   [��(�)]).              % ������ͣ���� ��������������
get_base_syn_info(����,     [��(�)]).              % ������������
get_base_syn_info('����-�', [��(�)]).              % ���������� ������������
get_base_syn_info(��,       [��(�),�(�)]).         % ������
get_base_syn_info(���,      [��(�),�(�)]).         % ������
get_base_syn_info('��-���', [��(�),�(A)]) :-       % ������, A=aspect
        member(A ,[�,�]).
get_base_syn_info(POS,[��(POS)]) :-                % ���������
        %% next list got by: setof(S,W^A^M^(z0:w(W,A,S,M)),L).
        memberchk(POS, [����, �, ������, �����, ����, �����, �����, ����]).

%%% get_paradigms(+POS, -GIS)
%%  - GIS - list of grammatical informations (word paradigm list)
get_paradigms(POS, GIS) :-
%         write(POS), flush,
        bagof(Paradigm, paradigms(POS, Paradigm), GIS), !,
        asserta(:-(get_paradigms(POS, GIS),!)).
get_paradigms(POS, []) :- asserta(:-(get_paradigms(POS, []),!)). % comment out this

%%% paradigms(+POS, -GI)
%%  - POS = Part Of Speech
%%  - GI = Grammatical Information (�������������� ��������)
paradigms(�,�(C,N)) :- num(N), case(C).
paradigms(�,�(C,�,G)) :- gender(G), case(C). % � ��.�. �� �����
paradigms(�,�(C,�,�)) :- case(C).            % � ��.�. ������ �.�.? �(_)
paradigms(�,��(�,G)) :- gender(G).           % ��.�. � ��.�. �� �����
paradigms(�,��(�,�)).                        % ��.�. � ��.�. ������ �.�.? �(_)
% paradigms(�,��(S)) :- degree(S).           % �����. � �������. �������
paradigms(�,�(C,N,G)) :- paradigms(�, �(C,N,G)). % ����������� ��� ��������������
paradigms(�,�(C)) :- case(C).
paradigms(�,��).                                     % ���������
paradigms(�,�(T,P,N)) :- tense(T), � \== �, person(P), num(N).
paradigms(�,�(T,G,N)) :- tense(T), � == �, genders(G), num(N).
paradigms(�,��(N)) :- num(N).                        % ������������� ����������
paradigms(�,��(T)) :- tense(T), � \== �.             % ������������
paradigms(�,��(T,V)) :- tense(T), � \== �, voice(V). % ���������
% paradigms(�,[�(�),�(T),�(V)|PL]) :- tense(T), � \== �, voice(V), paradigms(�, PL).

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
cases(�,[�,�,�,�,�,�]).         % �����
numbers(�,[�,�]).               % �����
genders(�,[�,�,�]).             % ���
degrees(�,[�,�]).               % ������� ���������
persons(�,[1,2,3]).             % ����
tenses(�,[�,�,�]).              % �����
voices(�,[�,�]).                % �����
moods(�,[�,�,�]).               % ����������
types(�,[�,�,�]).               % ��� �������: ���������, (���)?���������

%% ������ ������ �������������
% case(�). case(�). case(�). case(�). case(�). case(�).
% cases(CS) :- bagof(C, case(C), CS).

%%% get_base_morph_info(+SI, -SI2)
%%  �������� ��������������� �������������� �����
%%  � - ��� ���������, � - ��������������� ���
get_base_morph_info(�,        [�(�),�(�)]). % ������������� ���������, �.�.
get_base_morph_info(��,       [�(�),�(�)]). % ������������� ���������, �.�.
get_base_morph_info(�,        [�(�),�(�)]). % ������������� ���������, �.�.
get_base_morph_info(��,       [�(�),�(�)]). % ������������� ���������, �.�.
get_base_morph_info('��-��',  [�(�),�(�)]). % ������������� ���������, �.�.
get_base_morph_info(�,        [�(�),�(�)]). % ������������� ���������, �.�.
get_base_morph_info(��,       [�(�),�(�)]). % ������������� ���������, �.�.
get_base_morph_info(�,        [�(�)]).      % ����������� ���������
get_base_morph_info(��,       [�(��)]).     % ������ͣ���� ���������
get_base_morph_info('��-�',   [�(��)]).     % ����������� ���������
get_base_morph_info(����,     [�(�)]).      % ��������� ������������
get_base_morph_info('����-�', [�(�)]).      % ����������� ���������

%%% get_mi_wfi(wi(W,WI), mi(WB,Ac2,D,WFI,Ch,WI))
%%  Prepare some information for declension
get_mi_wfi(wi(W,WI), mi(WB,Ac2,D,WFI,Ch,WI2)) :-
        subset([�(Ac1),�(D),�(T),�1(U)], WI), !,
        once((memberchk(�(G), WI) ; G = �)),
        (   memberchk(�(A), WI)
        ->  WFI = wfi(D,T,U,G,A)
        ;   WFI = wfi(D,T,U)
        ),
        Ac1 = Ac2,              % TODO: a(X,Y) -> X, e(X) -> X, etc.
        ( memberchk(�, WI) -> Ch=y ; Ch=n ), !,
        wbase_str(W, D, Ch, WB), !,
        subtract(WI, [��(_),�(_),�(_),�(_),�1(_),�(_),�(_),�], WI2), !.

%%% has_running_vowel(+I1, -Ch)
has_running_vowel(A, y) :- memberchk(�, A), !.
has_running_vowel(_, n).

%%% wbase_str(+Word, +D, +Ch, -WordBase) - ����������� ������ �����
wbase_str(W,D,Ch,WB) :-
        wbase_str2(W,D,WB2),
        get_base_wbase(WB2,Ch,WB), !.
wbase_str(_,_,_,_) :- nl, write('*** wbase_str failed ***'), nl.

%%% wbase_str2(+Word, +D, -WordBase)
wbase_str2(W,D,WB) :- 
        (D=�;D=�),
        word_suffix(W, 1, WB, S), string_to_list(S, [C]),
        memberchk(C,[0'�,0'�,0'�,0'�,0'�,0'�,0'�,0'�,0'�,0'�,0'�,0'�]), !.
wbase_str2(W,D,W) :-
        (D=�;D=�), !.
wbase_str2(W,�,[WB,"��"]) :-
        word_suffix(W, 2, WB2, "��"), word_suffix(WB2, 2, WB, _), !.
wbase_str2(W,�,WB) :-
        word_suffix(W, 2, WB, _), !.
wbase_str2(W,_,W) :- !.

%%% get_base_wbase(+WordBase, +Ch, -WordBase2)
get_base_wbase(WB, n, WB) :- !.
get_base_wbase(WB, y, WB2) :-
        get_running_vowel(WB, C, WB2),
        memberchk(C, [0'�,0'�,0'�,0'�,0'�,0'�,0'�,0'�,0'�,0'�]), !.
get_base_wbase(WB, _, WB) :- !.

%%%% Create wordform - ������� ��������������

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
wf_postproc_wf(w(W,A), MI, �(�,�), [w(W,A), w(W2,L2,[FR])]) :-
        MI = mi(_,_,_,_,_,WI),
        member(FR, [�2, �2(_)]), % now it is always �2(_)
        memberchk(FR, WI),
        wordform2(MI, �(�,�), w(W2,_A2)),
        string_length(W2, L2), !.
wf_postproc_wf(WA, _, _, WA).

%%% wordform2(+MI, +GI, -WordForm)
wordform2(mi(WB,A,D,WFI,Ch,_WI), GI, w(W2,A2)) :-    % mi(WB,A,D,MI2,_I2,Ch)
        (D==� ; D==� ; D==�),
        get_wf_info(WFI, GI, wf_tab(D2,N,G,T,U,O,C), _Comments),
        get_we_accent(U, GI, U2), !,
        get_accent(WB, U2, A, A2),
        wf_we_tab_pre(GI, wf_tab(D2,N,G,T,U2,O,C), S),
        wf_add_we(WB, S, Ch, W2), !.
wordform2(mi(WB,_,D,_,_,_), GI, w(W2,A2)) :-
        D == �,
        wf_exc(WB, GI, w(W2,A2)).

%%% get_wf_info(+D, +MI2, +GI, WFTab).
get_wf_info(wfi(D,T,U,G,A), �(C,N), wf_tab(D,N,G,T,U,A,C), []).
get_wf_info(wfi(D,T,U), �(C,N,G,A), wf_tab(D,N,G,T,U,A,C), []).
get_wf_info(wfi(D,T,U), �(C,N,G), wf_tab(D,N,G,T,U,A,C), [�(A)]) :- (A=�;A=�).
get_wf_info(wfi(D,T,U), ��(N,G), wf_tab(D,N,G,T,U,�,�), []).

%%% get_we_accent(+Accent, +D, -U)
get_we_accent(a,      _, �).
get_we_accent(b,      _, �).
get_we_accent(b2,     _, �).
get_we_accent(c, �(_,�), �) :- !.
get_we_accent(c,      _, �).
get_we_accent(d, �(_,�), �) :- !.
get_we_accent(d,      _, �).
get_we_accent(e,     GI, �) :- GI = �(_,�) ; GI = �(�,�).
get_we_accent(e,      _, �).
get_we_accent(f, �(�,�), �) :- !.
get_we_accent(f,      _, �).

%%% get_accent(+WordBase, +U, +Ac, -Ac2)
get_accent(_, �, Ac, Ac).
get_accent(B, �, _, Ac2) :- string_length(B, Len), Ac2 is Len + 1.

%%% wf_we_tab_pre(+GI, +WordFormTab, -WordEnding)
%%  - �������������� ����������� ��������� �������������� ���������
wf_we_tab_pre(�(�,�), wf_tab(�,_,�,4,_,_,_), "��") :- !.
wf_we_tab_pre(�(�,�), wf_tab(�,_,G,4,�,_,_), "") :- (G=�;G=�), !.
wf_we_tab_pre(�(�,�), wf_tab(�,_,G,4,�,_,_), "��") :- (G=�;G=�), !.

wf_we_tab_pre(�(�,�), wf_tab(�,_,�,6,�,_,_), "��") :- !.
wf_we_tab_pre(�(�,�), wf_tab(�,_,�,6,�,_,_), "��") :- !.
wf_we_tab_pre(�(�,�), wf_tab(�,_,G,6,_,_,_), "�") :- (G=�;G=�), !.

wf_we_tab_pre(�(�,�), wf_tab(�,_,G,7,U,_,_), S) :-
        wf_we_tab_pre(�(�,�), wf_tab(_,_,G,6,U,_,_), S), !.
wf_we_tab_pre(�(�,�), wf_tab(�,_,�,7,�,_,_), "�") :- !.
wf_we_tab_pre(�(�,�), wf_tab(�,_,�,7,�,_,_), "�") :- !.
wf_we_tab_pre(�(�,�), wf_tab(�,_,_,7,�,_,_), "�") :- !.
wf_we_tab_pre(�(�,�), wf_tab(�,_,_,7,�,_,_), "�") :- !.

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
post_proc(S, 3, _, S2) :- replace_first_char(S, 0'�, 0'�, S2).
post_proc(S, 4, _, S2) :- replace_first_char(S, 0'�, 0'�, S2).
post_proc(S, 4, �, S2) :- replace_first_char(S, 0'�, 0'�, S2).
post_proc(S, 5, �, S2) :- replace_first_char(S, 0'�, 0'�, S2).
post_proc(S, 6, _, S2) :- replace_first_char(S, 0'�, 0'�, S2).
post_proc(S, 7, _, S2) :- replace_first_char(S, 0'�, 0'�, S2).
post_proc(S, _, _, S).

%%% wf_exc(+Word, +GI, -Word)
%% THIS SHOULD BE MOVED TO w(W,A,S,M) !!!
wf_exc("����",�(C),w("����",2)) :- C=�;C=�.
wf_exc("����",�(C),w("����",4)) :- C=�;C=�;C=�.
wf_exc("����",�(�),w("�����",5)).
wf_exc("������",�(C),w("������",2)) :- C=�;C=�.
wf_exc("������",�(C),w("������",6)) :- C=�;C=�;C=�.
wf_exc("������",�(�),w("�������",7)).
wf_exc("������",�(�),w("�������",7)).

%%% wf_add_we(+WordBase, +WordEnding, +Ch, -Word)
wf_add_we(WB, "", y, W2) :- set_running_vowel(W2, 0'�, WB), !. %'
wf_add_we([WB,S2], S, _, W2) :- % �������� -��
        wf_add_we(WB, S, _, WB2),
        string_concat(WB2, S2, W2).
wf_add_we(WB, S, _, W2) :- string_concat(WB, S, W2).

%%%% ������� ����������� ���������
%% wf_we_tab - wordform word endings table

%%% ����������� ��������� �������������� ���������
wf_we_tab(�,�,�,1,U,A,�,"" ) :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,2,�,A,�,"�") :- (A=�;A=�).
wf_we_tab(�,�,�,2,�,A,�,"�") :- (A=�;A=�).
wf_we_tab(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf_we_tab(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).

wf_we_tab(�,�,G,1,_,_,�,"�" )  :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"�" )  :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,"�" ).
wf_we_tab(�,�,�,2,_,_,�,"�" ).
wf_we_tab(�,�,�,1,_,_,�,"��").
wf_we_tab(�,�,�,2,_,_,�,"��").
wf_we_tab(�,�,G,1,_,_,�,""  ) :- G=�;G=�.
wf_we_tab(�,�,G,2,�,_,�,"�" ) :- G=�;G=�.
wf_we_tab(�,�,G,2,�,_,�,"��") :- G=�;G=�.

wf_we_tab(�,�,G,1,_,_,�,"�" ) :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"�" ) :- G=�;G=�.
wf_we_tab(�,�,�,T,_,_,�,"�" ) :- T=1;T=2.
wf_we_tab(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

wf_we_tab(�,�,�,T,U,�,�,S  ) :- wf_we_tab(�,�,�,T,U,_,�,S).
wf_we_tab(�,�,�,T,U,�,�,S  ) :- wf_we_tab(�,�,�,T,U,_,�,S).
wf_we_tab(�,�,�,T,U,A,�,S  ) :- wf_we_tab(�,�,�,T,U,A,�,S).
wf_we_tab(�,�,�,1,_,_,�,"�").
wf_we_tab(�,�,�,2,_,_,�,"�").
wf_we_tab(�,�,G,T,U,�,�,S  ) :- wf_we_tab(�,�,G,T,U,_,�,S).
wf_we_tab(�,�,G,T,U,�,�,S  ) :- wf_we_tab(�,�,G,T,U,_,�,S).

wf_we_tab(�,�,G,1,_,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,G,2,�,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,G,2,�,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,S   ) :- S="��";S="��".
wf_we_tab(�,�,�,2,�,_,�,S   ) :- S="��";S="��".
wf_we_tab(�,�,�,2,�,_,�,S   ) :- S="��";S="��".
wf_we_tab(�,�,G,1,_,_,�,"���") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"���") :- G=�;G=�;G=�.

wf_we_tab(�,�,G,T,_,_,�,"�" ) :- (G=�;G=�;G=�), (T=1;T=2).
wf_we_tab(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

wf_we_tab(�,�,_,8,_,_,�,"�").
wf_we_tab(�,�,_,8,_,_,�,"�").
wf_we_tab(�,�,_,8,_,_,�,"�").
wf_we_tab(�,�,_,8,_,_,�,"�").
wf_we_tab(�,�,_,8,_,_,�,"�").
wf_we_tab(�,�,�,8,_,_,�,"��").
wf_we_tab(�,�,G,8,�,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,G,8,�,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,_,8,_,_,�,"��").
wf_we_tab(�,�,G,8,U,A,C,S) :- wf_we_tab(�,�,G,2,U,A,C,S), C\==�.

%%% ����������� ��������� ������������ ���������, ������ �����
wf_we_tab(�,�,�,1,�,_,�,"��").
wf_we_tab(�,�,�,1,�,_,�,"��").
wf_we_tab(�,�,�,2,_,_,�,"��").
wf_we_tab(�,�,�,1,_,_,�,"��").
wf_we_tab(�,�,�,2,_,_,�,"��").
wf_we_tab(�,�,�,1,_,_,�,"��").
wf_we_tab(�,�,�,2,_,_,�,"��").
wf_we_tab(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

wf_we_tab(�,�,G,1,_,_,�,"���") :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"���") :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,"��" ).
wf_we_tab(�,�,�,2,_,_,�,"��" ).
wf_we_tab(�,�,G,1,_,_,�,"��" ) :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��" ) :- G=�;G=�;G=�.

wf_we_tab(�,�,G,1,_,_,�,"���") :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"���") :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,"��" ).
wf_we_tab(�,�,�,2,_,_,�,"��" ).
wf_we_tab(�,�,G,1,_,_,�,"��" ) :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��" ) :- G=�;G=�;G=�.

wf_we_tab(�,�,�,T,U,�,�,S   ) :- wf_we_tab(�,�,�,T,U,_,�,S).
wf_we_tab(�,�,�,T,U,�,�,S   ) :- wf_we_tab(�,�,�,T,U,_,�,S).
wf_we_tab(�,�,�,T,U,A,�,S   ) :- wf_we_tab(�,�,�,T,U,A,�,S).
wf_we_tab(�,�,�,1,_,_,�,"��").
wf_we_tab(�,�,�,2,_,_,�,"��").
wf_we_tab(�,�,G,T,U,�,�,S   ) :- wf_we_tab(�,�,G,T,U,_,�,S).
wf_we_tab(�,�,G,T,U,�,�,S   ) :- wf_we_tab(�,�,G,T,U,_,�,S).

wf_we_tab(�,�,G,1,_,_,�,"��" ) :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��" ) :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,S    ) :- S="��";S="��".
wf_we_tab(�,�,�,2,_,_,�,S    ) :- S="��";S="��".
wf_we_tab(�,�,G,1,_,_,�,"���") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"���") :- G=�;G=�;G=�.

wf_we_tab(�,�,G,1,_,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,"��").
wf_we_tab(�,�,�,2,_,_,�,"��").
wf_we_tab(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

%%% ����������� ��������� ������������ ���������, ������� �����
wf_we_tab(�,�,�,1,_,_,�,"" ).
wf_we_tab(�,�,�,2,_,_,�,"�").
wf_we_tab(�,�,�,1,_,_,�,"�").
wf_we_tab(�,�,�,2,�,_,�,"�").
wf_we_tab(�,�,�,2,�,_,�,"�").
wf_we_tab(�,�,�,1,_,_,�,"�").
wf_we_tab(�,�,�,2,_,_,�,"�").
wf_we_tab(�,�,G,1,_,_,�,"�") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"�") :- G=�;G=�;G=�.

%%% ����������� ��������� ������������� ���������
wf_we_tab(�,�,�,1,_,_,�,"" ).
wf_we_tab(�,�,�,2,_,_,�,"�").
wf_we_tab(�,�,�,1,_,_,�,"�").
wf_we_tab(�,�,�,2,�,_,�,"�").
wf_we_tab(�,�,�,2,�,_,�,"�").
wf_we_tab(�,�,�,1,_,_,�,"�").
wf_we_tab(�,�,�,2,_,_,�,"�").
wf_we_tab(�,�,G,1,_,_,�,"�") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"�") :- G=�;G=�;G=�.

wf_we_tab(�,�,G,1,_,_,�,"���") :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"���") :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,"��" ).
wf_we_tab(�,�,�,2,_,_,�,"��" ).
wf_we_tab(�,�,G,1,_,_,�,"��" ) :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��" ) :- G=�;G=�;G=�.

wf_we_tab(�,�,G,1,_,_,�,"���") :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"���") :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,"��" ).
wf_we_tab(�,�,�,2,_,_,�,"��" ).
wf_we_tab(�,�,G,1,_,_,�,"��" ) :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��" ) :- G=�;G=�;G=�.

wf_we_tab(�,�,�,T,U,�,�,S  ) :- wf_we_tab(�,�,�,T,U,_,�,S).
wf_we_tab(�,�,�,T,U,�,�,S  ) :- wf_we_tab(�,�,�,T,U,_,�,S).
wf_we_tab(�,�,�,T,U,A,�,S  ) :- wf_we_tab(�,�,�,T,U,A,�,S).
wf_we_tab(�,�,�,1,_,_,�,"�").
wf_we_tab(�,�,�,2,_,_,�,"�").
wf_we_tab(�,�,G,T,U,�,�,S  ) :- wf_we_tab(�,�,G,T,U,_,�,S).
wf_we_tab(�,�,G,T,U,�,�,S  ) :- wf_we_tab(�,�,G,T,U,_,�,S).

wf_we_tab(�,�,G,1,_,_,�,"��" ) :- G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��" ) :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,S    ) :- S="��";S="��".
wf_we_tab(�,�,�,2,_,_,�,S    ) :- S="��";S="��".
wf_we_tab(�,�,G,1,_,_,�,"���") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"���") :- G=�;G=�;G=�.

wf_we_tab(�,�,G,1,_,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,G,2,�,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,G,2,�,_,�,"��") :- G=�;G=�.
wf_we_tab(�,�,�,1,_,_,�,"��").
wf_we_tab(�,�,�,2,_,_,�,"��").
wf_we_tab(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf_we_tab(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

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
        writef("  ����� �� �������.\n").

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

pr_parad_word_comments3(�2(P2), PP2) :- nonvar(P2), concat_atom(['(',P2,')'],PP2). % concat(P2, ' ', PP2)
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
map_word_info(��(�), '���������������').
map_word_info(��(�), '�������� ����').
map_word_info(��(�), '�������� ����').
map_word_info(��(�), '�������� ����').
map_word_info(�(�), '������̣����').
map_word_info(�(�), '��������̣����').
map_word_info(��(�), '��������������').
map_word_info(��(�), '������').
map_word_info(c(Comments), [Comments]).
map_word_info(I, I).
% writef("�.�.: %w!", [W]).
% word2infltables('�����',[t(w(�����,3,[�,�(�)],[�,3,�,"3�"]),[�����,�����])]).

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
%%    tell(wis),wi(_,WI),subtract(WI,[�(_),c(_)],WI2),write(WI2),nl,fail;told.
%%    tell(wis),wi(_,WI),subtract(WI,[�(_),c(_),c2(_),c3(_)],WI2),write(WI2),nl,fail;told.

%%% Top-level tests
run_tests :-
        test(W),
        wi(W,WI),
        write(WI), nl,
        pr_parads3(wi(W,WI)),
        nl,
        fail ; true.

test_word(wi(W,WI)) :-
        member(TS,[�]), % setof(X,W^WI^(wi(W,WI),member(�(X),WI)),L). -> [�,��,�]
        member(G,[�,�,�]), % setof(X,W^WI^(wi(W,WI),member(�(X),WI)),L).
        member(U1,[a,b,c,d,e,f]), % setof(X,W^WI^(wi(W,WI),member(�1(X),WI)),L). -> [a,a1,b,b1,c,c1,d,d1,e,f,f1,f2]
        between(1, 7, I), % setof(X,W^WI^(wi(W,WI),member(�(X),WI)),L). -> 0..16
        member(An, [�,�]),
%         once((wi(W, WI), subset([�(TS),�(G),�1(U1),�(I),�(A)], WI))).
        once((z0:w(W,A,S,M), s2([�(TS),�(G),�1(U1),�(I),�(An)], w(W,A,S,M)))),
        get_all_info(w(W,A,S,M), WI).

%%% ������������� ���������. ������� ���.
test(�����).
test(������).
test(��������).
test(������).
test(������).
test(�������).
test(����).
test(�������).
test(�����).
test(�����).
test(������).
test(�����).
test(��������).
test(�������).

%%%% backup
% get_base_syn_inf(�,�(�,�)).        % ���. �.�. ����.
% get_base_syn_inf(��,�(�,�)).       % ���. �.�. ����.
% get_base_syn_inf(�,�(�,�)).        % ���. �.�. ����.
% get_base_syn_inf(��,�(�,�)).       % ���. �.�. ����.
% get_base_syn_inf(�,�(�,�)).        % ���. �.�. ����.
% get_base_syn_inf(��,�(�,�)).       % ���. �.�. ����.
% get_base_syn_inf('��-��',�(��,�)). % ���. ��-�� ����.
% get_base_syn_inf(��(�),�(��,�)).   % ���. ��. ����.
% get_base_syn_inf(��(�),�(��,�)).   % ���. ��. ����.
% get_base_syn_inf(�,�).             % ��������������
% get_base_syn_inf(��,��).           % �����������
% get_base_syn_inf('��-�',�(��)).    % ������ͣ���� ��������������
% get_base_syn_inf(����,�).          % ������������
% get_base_syn_inf(����,�(�)).       % ���������� ������������
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
%         append(SI, [�(TS)|MI], WI).
% %         WI = [s(SI), m(M)].
