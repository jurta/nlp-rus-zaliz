

fl:-w(W,_,P,F),fl0(W,P,F,R,WF),(R=='ип'->nl;true),w2(WF).%ww(['%w: %w',R,WF]).

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




fl(W,'м',_, _ ,'ип',W).
fl(W,'м',1, _ ,'рп',WF) :- append(W,"а",WF).
fl(W,'м',1,'о','вп',WF) :- append(W,"а",WF).
fl(W,'м',1,'н','вп',W).
fl(W,'м',1, _ ,'дп',WF) :- append(W,"у",WF).
fl(W,'м',1, _ ,'тп',WF) :- append(W,"ом",WF).
fl(W,'м',1, _ ,'пп',WF) :- append(W,"е",WF).

fl(W,'ж',F, _ ,P,WF) :- nonvar(W),  append(W2,"а",W), fl2(W2,'ж',F, _ ,P,WF).
fl(W,'ж',F, _ ,P,WF) :- nonvar(WF), fl2(W2,'ж',F, _ ,P,WF), append(W2,"а",W).
fl2(W,'ж',_, _ ,'ип',W).
fl2(W,'ж',1, _ ,'рп',WF) :- append(W,"ы",WF).
fl2(W,'ж',1, _ ,'вп',WF) :- append(W,"у",WF).
fl2(W,'ж',1, _ ,'дп',WF) :- append(W,"е",WF).
fl2(W,'ж',1, _ ,'тп',WF) :- append(W,"ой",WF).
fl2(W,'ж',1, _ ,'пп',WF) :- append(W,"е",WF).
% fl(W,'ж',_, _ ,'ип',W).
% fl(W,'ж',1, _ ,'рп',WF) :- replace2("а",W,"ы",WF).
% fl(W,'ж',1, _ ,'вп',WF) :- replace2("а",W,"у",WF).
% fl(W,'ж',1, _ ,'дп',WF) :- replace2("а",W,"е",WF).
% fl(W,'ж',1, _ ,'тп',WF) :- replace2("а",W,"ой",WF).
% fl(W,'ж',1, _ ,'пп',WF) :- replace2("а",W,"е",WF).

n_o('м','м','н'). n_o('мо','м','о'). n_o('ж','ж','н'). n_o('жо','ж','о').

fl(W,'нсв',1,3,WF) :- replace2("ть",W,"ет",WF).



% ?- w(W,_,'мо',_),name(W,WW),emansipe(WW,WW2),name(W2,WW2),not(w(W2,_,'жо',_)),writeln(W2),fail.

% emansipe(?Masc,?Femin).
emansipe(Masc,Femin) :- append(Root,"дь",Masc), append(Root,"дица",Femin), !.
emansipe(Masc,Femin) :- append(Root,"оль",Masc), append(Root,"олева",Femin), !.
emansipe(Masc,Femin) :- append(Root,"сть",Masc), append(Root,"стья",Femin), !.
emansipe(Masc,Femin) :- append(Root,"нин",Masc), append(Root,"нка",Femin), !.
emansipe(Masc,Femin) :- append(Root,"ин",Masc), append(Root,"инка",Femin), !.
emansipe(Masc,Femin) :- append(Root,"ель",Masc), append(Root,"ельница",Femin), !.
emansipe(Masc,Femin) :- last(C,Masc), member(C,"мнрь"), append(Masc,"ша",Femin).
emansipe(Masc,Femin) :- last(C,Masc), member(C,"т"), append(Masc,"ка",Femin).
emansipe(Masc,Masc)  :- append(_,"ок",Masc), !, fail.
emansipe(Masc,Femin) :- append(Root,"ак",Masc), append(Root,"ачка",Femin), !.
emansipe(Masc,Femin) :- append(Root,"ук",Masc), append(Root,"учка",Femin), !.
emansipe(Masc,Femin) :- append(Root,"як",Masc), append(Root,"ячка",Femin), !.
emansipe(Masc,Femin) :- append(Root,"к",Masc), append(Root,"ца",Femin).
