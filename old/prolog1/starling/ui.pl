% ?- [ui].
% ?- [zaliz0,ling,rus,w,wf].

% pr_parad(абажур).
% pr_parad(абажура).

% pr_parad(+Word). -- print paradigm
pr_parad(W) :-
        w(W,_,G,T,_,_,_,_), name(W,WW),
        format('Падеж ~7| Ед.ч. ~34| Мн.ч. ~72|~n'),
        member(CA,"ирдвтп"), name(C,[CA]), case_name(CA,CU),
        %% wf3(WW,с,е,G,T,_U,н,C,SE), wf3(WW,с,м,G,T,_U,н,C,SM),
        %% format('~s ~7| ~s~34| ~s~72|~n', [CU,SE,SM]),
        findall(SE,wf3(WW,с,е,G,T,_U,н,C,SE),SEL),
        findall(SM,wf3(WW,с,м,G,T,_U,н,C,SM),SML),
        pr_s_row(CU,SEL,SML),
        fail.

pr_s_row(_,[],[]) :- !.
pr_s_row(_,SEL,[]) :- pr_s_row("",SEL,["-"]).
pr_s_row(_,[],SML) :- pr_s_row("",["-"],SML).
pr_s_row(CU,[SE|SEL],[SM|SML]) :-
        format('~s ~7| ~s~34| ~s~72|~n', [CU,SE,SM]),
        pr_s_row("",SEL,SML).

pr_parad(W,c) :-
        format(' ~7| Ед.ч. ~34| Мн.ч. ~72|~n'),
        format('~c. ~7| ~s~34| ~s~72|~n', [CU,SE,SM]),
        fail.

% Парадигма
% вал     Имя существительное
%         Ед.ч.           	Мн.ч.
% Им.     вал             	валы
% Род.    вала            	валов
% Дат.    валу            	валам
% Вин.    вал             	валы
% Тв.     валом           	валами
% Пр.     вале            	валах
%         валу (на валу)

% case_name(CA,[CU,0'.]) :- case_letter(CA,CU).
case_name(0'и,"Им.").  case_name(0'р,"Род."). case_name(0'д,"Дат.").
case_name(0'в,"Вин."). case_name(0'т,"Тв.").  case_name(0'п,"Пр.").

pr_parad(W,v) :- write(v).

