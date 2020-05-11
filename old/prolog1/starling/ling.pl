
case_word(WL,WU) :- alphabet_u(AU), alphabet_l(AL), tr(AL,AU,WL,WU).
cap_word([HL|WL],[HU|WU]) :- case_letter(HL,HU), case_word(WU,WL).
case_letter(L,U) :- alphabet_u(AU), alphabet_l(AL), tr1(AL,AU,L,U).

tr(AL,AU,WL,WU) :- maplist(tr1(AL,AU),WL,WU), !.

tr1(AL,AU,CL,CU) :- nth1(I,AL,CL), nth1(I,AU,CU), !.
tr1(_,_,C,C).

% case_word(WL,WU) :- maplist(case_letter, WL, WU).
% cap_word([HL|TL],[HU|TU]) :- case_letter(HL,HU), maplist(case_letter, TU, TL).
% case_letter(L,U) :- alphabet_u(AU), alphabet_l(AL), tr(L,U,AL,AU).
