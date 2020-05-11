% tell('zaliz.sml'),gis;told.

gis :- w(W,_,G,P,_),iflag(G,P,F),writef("%w/%w\n",[W,F]),fail.

iflag(G,P,'A') :- (G==м;G==мо),(P==1;P==3;P==4).
iflag(G,P,'B') :- (G==м;G==мо),(P==2;P==5;P==6).
iflag(G,P,'C') :- (G==ж;G==жо),(P==1).
iflag(G,P,'P') :- (G==п),(P==1;P==3).
iflag(G,P,'R') :- (G==п),(P==2).
iflag(G,P,'V') :- (G==св;G==нсв),(P==1).
iflag(G,P,'W') :- (G==св;G==нсв),(P==2).

% w(W,_,п,3,_),name(W,X),reverse(X,[0'й,0'и|_]),writeln(W),fail.
% w(W,_,п,2,_),name(W,X),reverse(X,[0'й,Y|_]),Y\==0'и,writeln(W),fail.
% w(W,_,нсв,2,_),name(W,[0'р,0'и|_]).
% w(W,_,нсв,1,_),name(W,WW),reverse(WW,[_,_,X|_]),X\==0'а.
