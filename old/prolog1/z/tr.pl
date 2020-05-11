
% tr(?English,?Russian).
% tr("the boy reads the book",R).
% tr("big boy",R).
% tr("front page","титульный лист").

test2 :- tr_sent("the boy reads the book",R), writef('%s\n',[R]).

tr_sent(E,R) :- nonvar(E), parse_sent(E,EL), tr_list(EL,RL), parse_sent(R,RL).

tr_list(EL,RL) :- nonvar(EL), tr_e_r(EL,RL).
tr_list(EL,RL) :- nonvar(RL), tr_r_e(RL,EL).

tr_words([],[]).
tr_words([HE|TE],[HR|TR]) :- e_r(HE,HR), tr_words(TE,TR).

e_r('boy','мальчик'). % мальчик 2 мо 3a
e_r('read','читать'). % читать 4 нсв 1a
e_r('book','книга').  % книга 3 ж 3a

% fl(W,'нсв',1,3,WF).
% v(v).

tr_e_r(E,R) :- s_e(S,E), write(S), nl, s_r(S,R).
tr_r_e(R,E) :- s_r(S,R), write(S), nl, s_e(S,E).
% tr_e_r(E,R) :- phrase(sd_e(S),E,[]), write(S), nl, phrase(sd_r(S),R,[]).
% tr_r_e(R,E) :- phrase(sd_r(S),R,[]), write(S), nl, phrase(sd_e(S),E,[]).

s_e(s(Pred,Obj,Subj),[N1,V,N2]) :- n_e(N1,Obj), v_e(V,Pred), n_e(N2,Subj).
sd_e(s(V,N1,N2)) --> nd_e(N1), vd_e(V), nd_e(N2).
nd_e(n(N),[NW|T],T) :- n_e(NW,N).
vd_e(v(V),[VW|T],T) :- v_e(VW,V).
n_e('boy',boy1).
n_e('boy',boy2).
n_e('book',book1).
n_e('book',book2).
v_e('book',book1).
v_e('read',read1).
v_e('read',read2).

s_r(s(Pred,Obj,Subj),[N1,V,N2]) :- n_r(N1,Obj), v_r(V,Pred), n_r(N2,Subj).
sd_r(s(V,N1,N2)) --> nd_r(N1), vd_r(V), nd2_r(N2).
nd_r(n(N),[NW|T],T) :- nd_r(NW,N).
nd2_r(n(N),[NW|T],T) :- nonvar(NW), name(NW,F), fl(W,'ж',1,'о','вп',F), name(NW2,W), n_r(NW2,N).
nd2_r(n(N),[NW|T],T) :- nonvar(N), n_r(NW2,N), name(NW2,W), fl(W,'ж',1,'о','вп',F), name(NW,F).
vd_r(v(V),[VW|T],T) :- nonvar(VW), name(VW,F), fl(W,'нсв',1,3,F), name(VW2,W), v_r(VW2,V).
vd_r(v(V),[VW|T],T) :- nonvar(V), v_r(VW2,V), name(VW2,W), fl(W,'нсв',1,3,F), name(VW,F).
n_r('мальчик',boy1).
n_r('мальчик',boy2).
n_r('книга',book1).
n_r('дева',book2).
v_r('заносить в книгу',book1).
v_r('читать',read1).
v_r('читать',read2).








