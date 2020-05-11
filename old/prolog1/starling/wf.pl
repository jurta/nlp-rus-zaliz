
wf_domains :- setofall(D,wf(D,_,_,_,_,_,_,_),L),write('D: '),writeln(L),fail.
wf_domains :- setofall(N,wf(_,N,_,_,_,_,_,_),L),write('N: '),writeln(L),fail.
wf_domains :- setofall(G,wf(_,_,G,_,_,_,_,_),L),write('G: '),writeln(L),fail.
wf_domains :- setofall(T,wf(_,_,_,T,_,_,_,_),L),write('T: '),writeln(L),fail.
wf_domains :- setofall(U,wf(_,_,_,_,U,_,_,_),L),write('U: '),writeln(L),fail.
wf_domains :- setofall(A,wf(_,_,_,_,_,A,_,_),L),write('A: '),writeln(L),fail.
wf_domains :- setofall(C,wf(_,_,_,_,_,_,C,_),L),write('C: '),writeln(L),fail.
wf_domains :- setofall(S,wf(_,_,_,_,_,_,_,S),L),write('S: '),write_sl(L," "),nl,fail.

check_domain_coverage :-
        member(DA,"����"), name(D,[DA]),
        member(NA,"��"), name(N,[NA]),
        member(GA,"���"), name(G,[GA]),
        member(TA,"12"), name(T,[TA]),
        member(UA,"��"), name(U,[UA]),
        member(AA,"��"), name(A,[AA]),
        (D\==�, member(CA,"������"), name(C,[CA]) ; D==�, C=�),
        not(wf(D,N,G,T,U,A,C,_)),
        write(wf(D,N,G,T,U,A,C)),nl,fail.

% wf("",D,G,N,T,T,A) :- (D=�, (G=�, ((T=� ; (T=�, A=�))) T=� ; (T=�, A=�)

% D="����", N="��", G="���", T="12", U="��_", A="��_", C="������"

%% ����������� ��������� �������������� ���������

wf(�,�,�,1,U,A,�,"" ) :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,2,�,A,�,"�") :- (A=�;A=�).
wf(�,�,�,2,�,A,�,"�") :- (A=�;A=�).
wf(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,1,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).
wf(�,�,�,2,U,A,�,"�") :- (U=�;U=�), (A=�;A=�).

wf(�,�,G,1,_,_,�,"�" )  :- G=�;G=�.
wf(�,�,G,2,_,_,�,"�" )  :- G=�;G=�.
wf(�,�,�,1,_,_,�,"�" ).
wf(�,�,�,2,_,_,�,"�" ).
wf(�,�,�,1,_,_,�,"��").
wf(�,�,�,2,_,_,�,"��").
wf(�,�,G,1,_,_,�,""  ) :- G=�;G=�.
wf(�,�,G,2,�,_,�,"�" ) :- G=�;G=�.
wf(�,�,G,2,�,_,�,"��") :- G=�;G=�.

wf(�,�,G,1,_,_,�,"�" ) :- G=�;G=�.
wf(�,�,G,2,_,_,�,"�" ) :- G=�;G=�.
wf(�,�,�,T,_,_,�,"�" ) :- T=1;T=2.
wf(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

wf(�,�,�,T,U,�,�,S  ) :- wf(�,�,�,T,U,_,�,S).
wf(�,�,�,T,U,�,�,S  ) :- wf(�,�,�,T,U,_,�,S).
wf(�,�,�,T,U,A,�,S  ) :- wf(�,�,�,T,U,A,�,S).
wf(�,�,�,1,_,_,�,"�").
wf(�,�,�,2,_,_,�,"�").
wf(�,�,G,T,U,�,�,S  ) :- wf(�,�,G,T,U,_,�,S).
wf(�,�,G,T,U,�,�,S  ) :- wf(�,�,G,T,U,_,�,S).

wf(�,�,G,1,_,_,�,"��") :- G=�;G=�.
wf(�,�,G,2,�,_,�,"��") :- G=�;G=�.
wf(�,�,G,2,�,_,�,"��") :- G=�;G=�.
wf(�,�,�,1,_,_,�,S   ) :- S="��";S="��".
wf(�,�,�,2,�,_,�,S   ) :- S="��";S="��".
wf(�,�,�,2,�,_,�,S   ) :- S="��";S="��".
wf(�,�,G,1,_,_,�,"���") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"���") :- G=�;G=�;G=�.

wf(�,�,G,T,_,_,�,"�" ) :- (G=�;G=�;G=�), (T=1;T=2).
wf(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

%% ����������� ��������� ������������ ���������, ������ �����

wf(�,�,�,1,�,_,�,"��").
wf(�,�,�,1,�,_,�,"��").
wf(�,�,�,2,_,_,�,"��").
wf(�,�,�,1,_,_,�,"��").
wf(�,�,�,2,_,_,�,"��").
wf(�,�,�,1,_,_,�,"��").
wf(�,�,�,2,_,_,�,"��").
wf(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

wf(�,�,G,1,_,_,�,"���") :- G=�;G=�.
wf(�,�,G,2,_,_,�,"���") :- G=�;G=�.
wf(�,�,�,1,_,_,�,"��" ).
wf(�,�,�,2,_,_,�,"��" ).
wf(�,�,G,1,_,_,�,"��" ) :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��" ) :- G=�;G=�;G=�.

wf(�,�,G,1,_,_,�,"���") :- G=�;G=�.
wf(�,�,G,2,_,_,�,"���") :- G=�;G=�.
wf(�,�,�,1,_,_,�,"��" ).
wf(�,�,�,2,_,_,�,"��" ).
wf(�,�,G,1,_,_,�,"��" ) :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��" ) :- G=�;G=�;G=�.

wf(�,�,�,T,U,�,�,S   ) :- wf(�,�,�,T,U,_,�,S).
wf(�,�,�,T,U,�,�,S   ) :- wf(�,�,�,T,U,_,�,S).
wf(�,�,�,T,U,A,�,S   ) :- wf(�,�,�,T,U,A,�,S).
wf(�,�,�,1,_,_,�,"��").
wf(�,�,�,2,_,_,�,"��").
wf(�,�,G,T,U,�,�,S   ) :- wf(�,�,G,T,U,_,�,S).
wf(�,�,G,T,U,�,�,S   ) :- wf(�,�,G,T,U,_,�,S).

wf(�,�,G,1,_,_,�,"��" ) :- G=�;G=�.
wf(�,�,G,2,_,_,�,"��" ) :- G=�;G=�.
wf(�,�,�,1,_,_,�,S    ) :- S="��";S="��".
wf(�,�,�,2,_,_,�,S    ) :- S="��";S="��".
wf(�,�,G,1,_,_,�,"���") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"���") :- G=�;G=�;G=�.

wf(�,�,G,1,_,_,�,"��") :- G=�;G=�.
wf(�,�,G,2,_,_,�,"��") :- G=�;G=�.
wf(�,�,�,1,_,_,�,"��").
wf(�,�,�,2,_,_,�,"��").
wf(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.

%% ����������� ��������� ������������ ���������, ������� �����

wf(�,�,�,1,_,_,�,"" ).
wf(�,�,�,2,_,_,�,"�").
wf(�,�,�,1,_,_,�,"�").
wf(�,�,�,2,�,_,�,"�").
wf(�,�,�,2,�,_,�,"�").
wf(�,�,�,1,_,_,�,"�").
wf(�,�,�,2,_,_,�,"�").
wf(�,�,G,1,_,_,�,"�") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"�") :- G=�;G=�;G=�.

%% ����������� ��������� ������������� ���������

wf(�,�,�,1,_,_,�,"" ).
wf(�,�,�,2,_,_,�,"�").
wf(�,�,�,1,_,_,�,"�").
wf(�,�,�,2,�,_,�,"�").
wf(�,�,�,2,�,_,�,"�").
wf(�,�,�,1,_,_,�,"�").
wf(�,�,�,2,_,_,�,"�").
wf(�,�,G,1,_,_,�,"�") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"�") :- G=�;G=�;G=�.

wf(�,�,G,1,_,_,�,"���") :- G=�;G=�.
wf(�,�,G,2,_,_,�,"���") :- G=�;G=�.
wf(�,�,�,1,_,_,�,"��" ).
wf(�,�,�,2,_,_,�,"��" ).
wf(�,�,G,1,_,_,�,"��" ) :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��" ) :- G=�;G=�;G=�.

wf(�,�,G,1,_,_,�,"���") :- G=�;G=�.
wf(�,�,G,2,_,_,�,"���") :- G=�;G=�.
wf(�,�,�,1,_,_,�,"��" ).
wf(�,�,�,2,_,_,�,"��" ).
wf(�,�,G,1,_,_,�,"��" ) :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��" ) :- G=�;G=�;G=�.

wf(�,�,�,T,U,�,�,S  ) :- wf(�,�,�,T,U,_,�,S).
wf(�,�,�,T,U,�,�,S  ) :- wf(�,�,�,T,U,_,�,S).
wf(�,�,�,T,U,A,�,S  ) :- wf(�,�,�,T,U,A,�,S).
wf(�,�,�,1,_,_,�,"�").
wf(�,�,�,2,_,_,�,"�").
wf(�,�,G,T,U,�,�,S  ) :- wf(�,�,G,T,U,_,�,S).
wf(�,�,G,T,U,�,�,S  ) :- wf(�,�,G,T,U,_,�,S).

wf(�,�,G,1,_,_,�,"��" ) :- G=�;G=�.
wf(�,�,G,2,_,_,�,"��" ) :- G=�;G=�.
wf(�,�,�,1,_,_,�,S    ) :- S="��";S="��".
wf(�,�,�,2,_,_,�,S    ) :- S="��";S="��".
wf(�,�,G,1,_,_,�,"���") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"���") :- G=�;G=�;G=�.

wf(�,�,G,1,_,_,�,"��") :- G=�;G=�.
wf(�,�,G,2,�,_,�,"��") :- G=�;G=�.
wf(�,�,G,2,�,_,�,"��") :- G=�;G=�.
wf(�,�,�,1,_,_,�,"��").
wf(�,�,�,2,_,_,�,"��").
wf(�,�,G,1,_,_,�,"��") :- G=�;G=�;G=�.
wf(�,�,G,2,_,_,�,"��") :- G=�;G=�;G=�.


wf2(_,D,N,G,1,U,A,C,S) :- wf(D,N,G,1,U,A,C,S).
wf2(_,D,N,G,2,U,A,C,S) :- wf(D,N,G,2,U,A,C,S).

%% ������� ����� ��������� 3-7 �� 1,2

wf2(B,D,N,G,3,U,A,C,S) :-
        lastof(B,"���"), wf(D,N,G,1,U,A,C,S2),
        replace2(0'�,0'�,S2,S).
wf2(B,D,N,G,4,U,A,C,S) :-
        lastof(B,"����"), wf(D,N,G,1,U,A,C,S2),
        replace2(0'�,0'�,S2,S3), replace2(0'�,0'�,S3,S).

wf3(W,D,N,G,T,U,A,C,WF) :- nonvar(W), wbase(W,D,B), wf2(B,D,N,G,T,U,A,C,S), append(B,S,WF).
wf3(W,D,N,G,T,U,A,C,WF) :- nonvar(WF), append(B,S,WF), wf2(B,D,N,G,T,U,A,C,S), wbase(W,D,B).

%% ����������� ������ �����
wbase(W,D,B) :- (D=�;D=�), append(B,[C],W), member(C,"�ţ���������"), !.
wbase(W,D,W) :- (D=�;D=�), !.
wbase(W,�,B) :- append(B,[_,_,0'�,0'�],W), !.
wbase(W,�,B) :- append(B,[_,_],W), !.


% ?- wf3("������",�,N,�,1,U,�,C,S),writef("%w %w %s\n",[N,C,S]),fail.


%% 

% ?- w(W,_,P,T,_,_,_,_),p_d(P,D),name(W,WW),wbase(WW,D,B),last(C,B),name(CA,[C]),writeln([CA,T]),fail.

p_d(�,�).
p_d(��,�).
p_d(�,�).
p_d(��,�).
p_d(�,�).
p_d(��,�).
p_d(�,�).


%!!! ?- w(W,_,P,T,_,_,_,_),p_d(P,D),name(W,WW),wbase(WW,D,B),last(C,B),not(t_l(T,C)),name(CA,[C]),writeln([CA,T]),fail.

t_l(0,_).
t_l(T,C) :- (T=1;T=2), member(C,"��������������").
t_l(3,C) :- member(C,"���").
t_l(4,C) :- member(C,"����").
t_l(5,C) :- member(C,"�"). % t_l(5,0'�).
t_l(6,C) :- member(C,"�ţ�������").
t_l(7,C) :- member(C,"�"). % t_l(7,0'�).


% ?- w(W,_,P,T,_,_,_,_),p_d(P,D),T==0,name(W,WW),wbase(WW,D,B),last(C,B),name(CA,[C]),writeln([W,CA,T,P]),fail.
% ?- w(W,_,P,T,_,_,_,_),p_d(P,D),T==2,name(W,WW),wbase(WW,D,B),last(C,B),name(CA,[C]),writeln([W,CA,T,P]),fail.
% ?- w(W,_,P,T,_,_,_,_),p_d(P,D),T==8,name(W,WW),wbase(WW,D,B),last(C,B),name(CA,[C]),writeln([W,CA,T,P]),fail.

% ?- w(W,_,G,2,_),(G==�;G==��),name(W,WW),wbase(WW,�,BB),last(0'�,BB),puts(WW),fail.
% ?- setofall(C,(w(W,_,G,2,_),(G==�;G==��),name(W,WW),wbase(WW,�,BB),last(C,BB)),L),puts(L).
% ?- w(W,_,�,8,_).                
% ?- w(W,_,�,8,_).

% setofall(Z,(w(W,_,G,8,_),name(W,WW),append(_,[X,Y],WW),Z=[X,Y]),L),write_sl(L," ").
% �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� �� ��

% setofall(Z,(w(W,_,G,8,_),name(W,WW),append(_,[X],WW),Z=X),L),puts(L).
% ���

%! w(W,_,�,2,_),name(W,WW),append(_,[0'�],WW),writeln(W),fail.
%! w(W,_,�,8,_),name(W,WW),append(_,[0'�],WW),writeln(W),fail.
%! w(W,_,��,8,_),name(W,WW),append(_,[0'�],WW),writeln(W),fail.

% words with one letter different
% ������ ������, ���� ���� ����, ������ ������,
% ������ ������ ������ ������
% ?- w(W,_,_,_,_),name(W,WW),append(WW1,[_|WW2],WW),append(WW1,[_|WW2],WW3).
% ?- w(W1,_,_,_,_),name(W1,WW),append(WW1,[_|WW2],WW),append(WW1,[_|WW2],WW3),w(W2,_,_,_,_),W1\==W2,name(W2,WW3).
% ?- w(W1,_,_,_,_),name(W1,WW),append(WW1,[_|WW2],WW),append(WW1,[_|WW2],WW3),w(W2,_,_,_,_),W1\==W2,name(W2,WW3),writef("%w %w\n",[W1,W2]),fail.
% ?- w(W1,_,G1,P1,_),name(W1,WW),append(WW1,[_|WW2],WW),append(WW1,[_|WW2],WW3),w(W2,_,G2,P2,_),W1\==W2,name(W2,WW3),writef("%w %w %w = %w %w %w\n",[W1,G1,P1,W2,G2,P2]),fail.
% ?- tell(similar),w(W1,_,G1,P1,_),name(W1,WW),append(WW1,[_|WW2],WW),append(WW1,[_|WW2],WW3),w(W2,_,G2,P2,_),W1\==W2,name(W2,WW3),writef("%w %w %w = %w %w %w\n",[W1,G1,P1,W2,G2,P2]),flush,fail;told.
% ?- tell(similar),w(W1,_,G1,P1,_),name(W1,WW),append(WW1,[_|WW2],WW),append(WW1,[_|WW2],WW3),once((w(W2,_,G2,P2,_),W1\==W2,name(W2,WW3))),writef("%w %w %w = %w %w %w\n",[W1,G1,P1,W2,G2,P2]),flush,fail;told.
% ?- tell(similar),w(W1,_,G1,P1,_),name(W1,WW),append(WW1,[_|WW2],WW),append(WW1,[_|WW2],WW3),once((w(W2,_,G2,P2,_),name(W2,WW3))),W1\==W2,writef("%w %w %w = %w %w %w\n",[W1,G1,P1,W2,G2,P2]),flush,fail;told.


check_types :-
        w(W,_,G,P1,_), G\==��, G\==��_���, G\==��, G\==����, G\==��_�, P1\==0,
        name(W,WW), append(_,[C0,C2],WW),
        not(((C0==0'�;C0==0'�),C2==0'�;(C0==0'�;C0==0'�),C2==0'�;C0==0'�,(C2==0'�;C2==0'�);C0==0'�,C2==0'�;C0==0'�,C2==0'�)),
        (G==��_�� -> R=� ; name(G,[RR|_]), name(R,[RR])),
        (R==�;R==�;R==�),
        wbase(WW,�,B), append(_,[C1],B),
        l_t(P2,R,C1,C2), P1\==P2,
        writef("%w %w %w %w\n",[W,G,P1,P2]), fail.

l_t(8,G,_,C2) :- member(C2,"�"), (G=�;G=�), !.
l_t(3,_,C1,_) :- member(C1,"���"), !.
l_t(4,_,C1,_) :- member(C1,"����"), !.
l_t(5,_,C1,_) :- member(C1,"�"), !.
l_t(6,_,C1,_) :- member(C1,"�ţ�������"), !.
l_t(6,_G,C1,_) :- member(C1,"�"), !. % G=�, !. % !!!
l_t(7,_,C1,_) :- member(C1,"�"), !.
l_t(2,G,_,C2) :- member(C2,"�"), G=�, !.
l_t(1,G,_,C2) :- member(C2,"�"), G=�, !.
l_t(1,G,_,C2) :- member(C2,"�"), G=�, !.
l_t(2,G,_,C2) :- member(C2,"ţ"), G=�, !.
l_t(2,G,_,C2) :- member(C2,"�"), G=�, !.
l_t(8,G,_,C2) :- member(C2,"�"), G=�, !.
l_t(1,G,_,_)  :- G=�, !.
l_t(0,_,_,_)  :- !.


% ?- w(W,_,G,P,_),G\==��,G\==���,G\==��_���,name(W,WW),append(_,[0'�,0'�,0'�],WW),writeln([W,G,P]),fail.
% ���� ���� ������ ���� ����� ���� ���� ����-����

% ?- w(W,_,G,P,_),(G==�;G==��),name(W,WW),append(_,[0'�,0'�],WW),writeln([W,G,P]),fail.
% ����� ������ �����-������� ���� ������ ������ ������ ������ �������� ������
% ���� ������� ���� ����� ���

% ?- w(W,_,�,_,_),w(W,_,�,_,_),writeln(W),fail.
% ������� ������ ���� ���� �������� ������� ������� �������� ���������
% ������ �������

% ?- w(W,_,��,_,_),w(W,_,��,_,_),writeln(W),fail.
% �������� �������

% ?- w(W,_,��_��,_,_),name(W,WW),append(_,[C],WW),not(member(C,"��������")),writeln(W),fail.
% ����� ������-��������

% ?- w(W,_,G,P,_),P\==0,(G==�;G==��),name(W,WW),append(_,[C],WW),member(C,"��������"),writeln(W),fail.
% �������������� �������������������� ���������� ��������� ��������

% second accent is after first accent ?
% ?- w(W,a(X,Y)), (X=e(XX)->true;X=XX), (Y=e(YY)->true;Y=YY), XX =< YY.
