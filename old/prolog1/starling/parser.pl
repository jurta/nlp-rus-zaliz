
% build regular expressions from examples: induction !!!

parse_accent(S,A) :- phrase(parse_accent(A),S,[]).

parse_accent(a(A1,A2)) --> number_e(A1), ".", number_e(A2).
parse_accent(A)        --> number_e(A).
number_e(e(E))         --> integer(E),   ",", integer(E2), {E == E2}.
number_e(E)            --> integer(E).

integer(N) --> digit(D1), !, digits(Ds), { name(N, [D1|Ds]) }.
digits([D|R]) --> digit(D), digits(R).
digits([]) --> [].
digit(D, [D|R], R)  :- between(0'0, 0'9, D).
