%%% zalizq.pl - queries for database zaliz
% -*- mode: Prolog; coding: cyrillic-koi8; -*-

:- discontiguous
        qd/3,                   % query documentation
        qq/3.                   % query itself

%%% Queries
% bagof(W,A^S^M^w(W,A,S,M),L),length(L,Len),write_ln(Len),fail.
% setof(W,A^S^M^w(W,A,S,M),L),length(L,Len),write_ln(Len),fail.
% setof(POS, W^A^M^S^SI^(w(W,A,S,M),zaliz:get_base_syn_inf(S,SI),memberchk(pos(POS),SI)),L).
% setof(POS, W^A^M^S^D^DS^(w(W,A,S,M),zaliz:get_syntax_inf(S,POS,D,DS)),L).

%% ws - all substantives
qd(ws, '��� ���������������', [r(w)]).
qq(ws, w(W,A,S,i(_,_,_M)), w(W,A)) :-
        zaliz:get_base_syn_inf(S, SI),
        memberchk(pos(�), SI).

%% wan - all not inflecatable words
qd(wan, '��� ������������ �����', [r(w)]).
% qq(wan, w(W,A,_S,i(0)), w(W,A)).
qq(wan, wi(W,WL), w(W,A)) :-
%         memberchk(m(MI),WL), memberchk(i(0),MI),
        memberchk(m(i(0)),WL),
        memberchk(a(A),WL).

%% wsa - substantives inflected as adjectives
qd(wsa, '��������������� ������������ ���������', [r(w)]).
qq(wsa, w(W,A,S,i(_,_,M)), w(W,A)) :-
        zaliz:get_base_syn_inf(S, SI),
        memberchk(pos(�), SI),
        memberchk(mi(�), M).

%% was - adjectives inflected as substantives
%  actually there is no such words
qd(was, '�������������� �������������� ���������', [r(w)]).
qq(was, w(W,A,S,i(_,_,M)), w(W,A)) :-
        zaliz:get_base_syn_inf(S, SI),
        memberchk(pos(�), SI),
        member(X, [�,�,�,��,��,��]),
        memberchk(mi(X), M).

%% wam - adjectives inflected as pronouns
qd(wam, '�������������� ������ͣ����� ���������', [r(w)]).
qq(wam, w(W,A,S,i(_,_,M)), w(W,A)) :-
        zaliz:get_base_syn_inf(S, SI),
        memberchk(pos(�), SI),
        memberchk(mi(��), M).

%% wa1n - adjectives with accent type 1 and no running vowels
%  qn(wa1n) = 3694
qd(wa1n, '�������������� ������� ���� ��������� � ��� �����������', [r(w)]).
qq(wa1n, w(W,A,�,i(1,a)), w(W,A)).

%% wa1ch - adjectives with accent type 1 and running vowels
%  qn(wa1ch) = 9680
qd(wa1ch, '�������������� ������� ���� ��������� � � ������������', [r(w)]).
qq(wa1ch, w(W,A,�,i(1,a,M)), w(W,A)) :-
        memberchk(�, M).

%% sam - 2-letter suffix of adjective inflected as pronoun
qd(sam, '��������� �������������� ������ͣ����� ���������', [r(s),c(10),u(���������)]).
qq(sam, w(W,_A,S,i(_,_,M)), Suffix) :-
        zaliz:get_base_syn_inf(S, SI),
        memberchk(pos(�), SI),
        memberchk(mi(��), M),
        name(W, WW),
        append(_, [S1,S2], WW),
        name(Suffix, [S1,S2]).

%% sa - 2-letter suffix of all adjectives
qd(sa, '��������� ��������������', [r(s),c(8),u(���������)]).
qq(sa, w(W,_A,S,i(_,_,_M)), Suffix) :-
        zaliz:get_base_syn_inf(S, SI),
        memberchk(pos(�), SI),
        name(W, WW),
        append(_, [S1,S2], WW),
        name(Suffix, [S1,S2]).

%% ss - 2-letter suffix of all nouns
qd(ss, '��������� ���������������', [r(s),c(8),u(���������)]).
qq(ss, w(W,_A,S,i(_,_,_M)), Suffix) :-
        zaliz:get_base_syn_inf(S, SI),
        memberchk(pos(�), SI),
        name(W, WW),
        append(_, [S1,S2], WW),
        name(Suffix, [S1,S2]).

%% query
qd(qq, 'qq', []).
qq(qq, w(_W,_A,_S,_M), _X).

query(_W,Q,_R) :-
        call(Q).

%% qprm - parametrized query - NOT USED
%  old examples:
%    qp(qprm,[pos(�),an(�),g(G),mi(�)],(G\==�),wi(W,WI),5).
%    qp(qprm,[pos(�),an(�),mi(�)],(s([g(G)],WI),G\==�),wi(W,WI),5).
%    qp(qprm,[�2(_)],(true),wi(W,WI),5).
%  new examples:
%    qp(q(wi(W,WI),(s([pos(�),an(�),g(G),mi(�)],WI),G\==�)),5).
%    qp(q(wi(W,WI),(s([�2(_)],WI))),5).
%    qp(q(wi(W,WI),(s([�2(_)],WI),suffix("�",W))),5).
%    qp(q(wi(W,WI),(s([z(Z)],WI),s([�(�,�)],Z))),5).
%    qp(q(wi(W,WI),(s([z(Z)],WI),not(s([��(_,_)],Z)))),5).
%    qp(q(wi(W,WI),(s([z(Z)],WI),not(m(��(_,_),Z)))),5).
%    qp(q(wi(W,WI),(s([n(N)],WI),s([�(�,�)],N))),5).
qd(qprm, '����������������� ������', [r(w)]).
qq(qprm, wi(_W,_WL), Pred) :-
        call(Pred).
% qq(qprm, wi(_W,WL), q(PL, Pred)) :- subset(PL, WL), call(Pred).

%% wmv - musculine adjectives inflected as feminine
qd(wmv, '��������������� �������� ����, ������� ������� ��������������� ���', [r(w)]).
qq(wmv, wi(_W,WL), 0) :-
        subset([pos(�),g(�),mi(��)], WL).

% qq(wmv, wi(_W,WL), 0) :-
%         memberchk(s(SI), WL), memberchk(m(M), WL),
%         memberchk(pos(�), SI), memberchk(g(�), SI), memberchk(mi(��), M),
%         memberchk(pos(�), WL), memberchk(g(�), WL), memberchk(mi(��), WL).

% qq(wmv, w(W,A,S,i(_,_,M)), w(W,A)) :-
%         zaliz:get_base_syn_inf(S, SI),
%         memberchk(pos(�), SI),
%         memberchk(g(�), SI),
%         memberchk(mi(��), M).

%%% Statistics

%% move it to main

