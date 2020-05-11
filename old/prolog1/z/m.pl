

fl:-w(W,_,P,F),fl0(W,P,F,R,WF),(R=='��'->nl;true),w2(WF).%ww(['%w: %w',R,WF]).

fl0(W,P,F,R,WF):-
        nonvar(W),
        name(W,W2), n_o(P,P3,O), f(F,F2), name(F3,[F2]),
        fl(W2,P3,F3,O,R,WF2), name(WF,WF2).
fl0(W,_P,_F,R,WF):-
        nonvar(WF),
        name(WF,WF2), fl(W2,_P3,F3,_O,R,WF2),
        %n_o(P,P3,O),
        %f(F,F2),
        name(F3,[_F2]),
        name(W,W2).

fl(F):-fl(X,R,1,O,P,F),name(W,X),w(W,_,R2,F2),f(F2,0'1),n_o(R2,R,O),writef('%w: %w, %w, %w\n',[P,W,O,R]),fail.

fl2 :-
        w(W1,_,P1,F1),
        fl0(W1,P1,F1,_R1,WF), fl0(W2,P2,F2,_R2,WF),
        w(W2,_,P2,F2), P1\==P2,
        w(WF).




fl(W,'�',_, _ ,'��',W).
fl(W,'�',1, _ ,'��',WF) :- append(W,"�",WF).
fl(W,'�',1,'�','��',WF) :- append(W,"�",WF).
fl(W,'�',1,'�','��',W).
fl(W,'�',1, _ ,'��',WF) :- append(W,"�",WF).
fl(W,'�',1, _ ,'��',WF) :- append(W,"��",WF).
fl(W,'�',1, _ ,'��',WF) :- append(W,"�",WF).

fl(W,'�',F, _ ,P,WF) :- nonvar(W),  append(W2,"�",W), fl2(W2,'�',F, _ ,P,WF).
fl(W,'�',F, _ ,P,WF) :- nonvar(WF), fl2(W2,'�',F, _ ,P,WF), append(W2,"�",W).
fl2(W,'�',_, _ ,'��',W).
fl2(W,'�',1, _ ,'��',WF) :- append(W,"�",WF).
fl2(W,'�',1, _ ,'��',WF) :- append(W,"�",WF).
fl2(W,'�',1, _ ,'��',WF) :- append(W,"�",WF).
fl2(W,'�',1, _ ,'��',WF) :- append(W,"��",WF).
fl2(W,'�',1, _ ,'��',WF) :- append(W,"�",WF).
% fl(W,'�',_, _ ,'��',W).
% fl(W,'�',1, _ ,'��',WF) :- replace2("�",W,"�",WF).
% fl(W,'�',1, _ ,'��',WF) :- replace2("�",W,"�",WF).
% fl(W,'�',1, _ ,'��',WF) :- replace2("�",W,"�",WF).
% fl(W,'�',1, _ ,'��',WF) :- replace2("�",W,"��",WF).
% fl(W,'�',1, _ ,'��',WF) :- replace2("�",W,"�",WF).

n_o('�','�','�'). n_o('��','�','�'). n_o('�','�','�'). n_o('��','�','�').

fl(W,'���',1,3,WF) :- replace2("��",W,"��",WF).



% ?- w(W,_,'��',_),name(W,WW),emansipe(WW,WW2),name(W2,WW2),not(w(W2,_,'��',_)),writeln(W2),fail.

% emansipe(?Masc,?Femin).
emansipe(Masc,Femin) :- append(Root,"��",Masc), append(Root,"����",Femin), !.
emansipe(Masc,Femin) :- append(Root,"���",Masc), append(Root,"�����",Femin), !.
emansipe(Masc,Femin) :- append(Root,"���",Masc), append(Root,"����",Femin), !.
emansipe(Masc,Femin) :- append(Root,"���",Masc), append(Root,"���",Femin), !.
emansipe(Masc,Femin) :- append(Root,"��",Masc), append(Root,"����",Femin), !.
emansipe(Masc,Femin) :- append(Root,"���",Masc), append(Root,"�������",Femin), !.
emansipe(Masc,Femin) :- last(C,Masc), member(C,"����"), append(Masc,"��",Femin).
emansipe(Masc,Femin) :- last(C,Masc), member(C,"�"), append(Masc,"��",Femin).
emansipe(Masc,Masc)  :- append(_,"��",Masc), !, fail.
emansipe(Masc,Femin) :- append(Root,"��",Masc), append(Root,"����",Femin), !.
emansipe(Masc,Femin) :- append(Root,"��",Masc), append(Root,"����",Femin), !.
emansipe(Masc,Femin) :- append(Root,"��",Masc), append(Root,"����",Femin), !.
emansipe(Masc,Femin) :- append(Root,"�",Masc), append(Root,"��",Femin).
