% tell('zaliz.sml'),gis;told.

gis :- w(W,_,G,P,_),iflag(G,P,F),writef("%w/%w\n",[W,F]),fail.

iflag(G,P,'A') :- (G==�;G==��),(P==1;P==3;P==4).
iflag(G,P,'B') :- (G==�;G==��),(P==2;P==5;P==6).
iflag(G,P,'C') :- (G==�;G==��),(P==1).
iflag(G,P,'P') :- (G==�),(P==1;P==3).
iflag(G,P,'R') :- (G==�),(P==2).
iflag(G,P,'V') :- (G==��;G==���),(P==1).
iflag(G,P,'W') :- (G==��;G==���),(P==2).

% w(W,_,�,3,_),name(W,X),reverse(X,[0'�,0'�|_]),writeln(W),fail.
% w(W,_,�,2,_),name(W,X),reverse(X,[0'�,Y|_]),Y\==0'�,writeln(W),fail.
% w(W,_,���,2,_),name(W,[0'�,0'�|_]).
% w(W,_,���,1,_),name(W,WW),reverse(WW,[_,_,X|_]),X\==0'�.
