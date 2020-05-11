% ?- [ui].
% ?- [zaliz0,ling,rus,w,wf].

% pr_parad(������).
% pr_parad(�������).

% pr_parad(+Word). -- print paradigm
pr_parad(W) :-
        w(W,_,G,T,_,_,_,_), name(W,WW),
        format('����� ~7| ��.�. ~34| ��.�. ~72|~n'),
        member(CA,"������"), name(C,[CA]), case_name(CA,CU),
        %% wf3(WW,�,�,G,T,_U,�,C,SE), wf3(WW,�,�,G,T,_U,�,C,SM),
        %% format('~s ~7| ~s~34| ~s~72|~n', [CU,SE,SM]),
        findall(SE,wf3(WW,�,�,G,T,_U,�,C,SE),SEL),
        findall(SM,wf3(WW,�,�,G,T,_U,�,C,SM),SML),
        pr_s_row(CU,SEL,SML),
        fail.

pr_s_row(_,[],[]) :- !.
pr_s_row(_,SEL,[]) :- pr_s_row("",SEL,["-"]).
pr_s_row(_,[],SML) :- pr_s_row("",["-"],SML).
pr_s_row(CU,[SE|SEL],[SM|SML]) :-
        format('~s ~7| ~s~34| ~s~72|~n', [CU,SE,SM]),
        pr_s_row("",SEL,SML).

pr_parad(W,c) :-
        format(' ~7| ��.�. ~34| ��.�. ~72|~n'),
        format('~c. ~7| ~s~34| ~s~72|~n', [CU,SE,SM]),
        fail.

% ���������
% ���     ��� ���������������
%         ��.�.           	��.�.
% ��.     ���             	����
% ���.    ����            	�����
% ���.    ����            	�����
% ���.    ���             	����
% ��.     �����           	������
% ��.     ����            	�����
%         ���� (�� ����)

% case_name(CA,[CU,0'.]) :- case_letter(CA,CU).
case_name(0'�,"��.").  case_name(0'�,"���."). case_name(0'�,"���.").
case_name(0'�,"���."). case_name(0'�,"��.").  case_name(0'�,"��.").

pr_parad(W,v) :- write(v).

