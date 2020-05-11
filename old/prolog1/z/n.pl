
nn(N) --> nn1000(N1000), [�����], nn1000(N100), {N is N1000*1000+N100}.
nn(N) --> nn1000(N).

nn1000(N) --> n1000(N100), n20(N1), {N is N100*100+N1}.
nn1000(N) --> n1000(N100), n100(N10), n10(N1), {N is N100*100+N10*10+N1}.

n10(1)  --> [����]  .
n10(2)  --> [���]   .
n10(3)  --> [���]   .
n10(4)  --> [������].
n10(5)  --> [����]  .
n10(6)  --> [�����] .
n10(7)  --> [����]  .
n10(8)  --> [������].
n10(9)  --> [������].
n10(10) --> [������].
%n10(0)  --> [].

% n20(N) --> n10(N10), [�������], 
%         (append(X3,"�",X2)                    ; X2=X3),
%         (append(X4,"�",X3)                    ; X3=X4),
%         (append(X6,"�",X4), append(X6,"�",X5) ; X4=X5),
%         append(X5,"�������",X), !.

n10(0)   --> [].
n100(0)  --> [].
n1000(0) --> [].


n(N)  :- num(N,X), name(Y,X), write(Y), nl, fail.
n2(N) :- num(N,X), name(Y,X), w(Y,A,B,C), write([Y,A,B,C]), nl, fail.
num(1, "����"  ) :- !.
num(2, "���"   ) :- !.
num(3, "���"   ) :- !.
num(4, "������") :- !.
num(5, "����"  ) :- !.
num(6, "�����" ) :- !.
num(7, "����"  ) :- !.
num(8, "������") :- !.
num(9, "������") :- !.
num(10,"������") :- !.
num(N,X) :-
        N<20, N>10, N2 is N-10, num(N2,X2),
        (append(X3,"�",X2)                    ; X2=X3),
        (append(X4,"�",X3)                    ; X3=X4),
        (append(X6,"�",X4), append(X6,"�",X5) ; X4=X5),
        append(X5,"�������",X), !.
num(40,"�����") :- !.
num(90,"���������") :- !.
num(N,X) :-
        0 is N mod 10, N2 is N / 10, num(N2,X2),
        (N2<4, append(X2,"�����",X);N2<10, append(X2,"�����",X)), !.
num(100,"���") :- !.
num(N,X) :-
        %N < 100,
        N3 is N mod 10, N2 is N // 10 * 10, num(N2,X2), num(N3,X3),
        append(X2," ",X4),append(X4,X3,X), !.
%num(200,'������').