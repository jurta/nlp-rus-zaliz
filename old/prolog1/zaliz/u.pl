portray(X):-write(X).

u(U,N):-(U=u(N);U=u(N,_);U=u(_,N);U=u(N,_,_,_);U=u(_,_,N,_)),!.

u :- w(W,U,_,_,_),u(U,10),writeln(W),fail.


