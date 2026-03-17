#!/usr/bin/env -S swipl
%-*- mode: prolog; -*-

:- module(prj3_sol,  [
	      greater_than_element/3,
	      greater_thans/3,
	      fill_list/3,
	      rm_prefix/3,
	      rm_suffix/3,
	      sentence/2,
	      sum_to/3,
	      sum_pairs/2,
	      poly_coeffs/3,
	      left_assoc/2
   ]).


/*********************** IMPORTANT RESTRICTIONS ************************/

/*

You may make use of the binary operators `=` (unify), `\=` (not
unify), is/2, arithmetic and relational operators, append/3, length/2,
member/2, reverse/2 but are *not* allowed to use any other features or
built-in Prolog procedures, unless expressly mentioned for that
exercise.  Violating this restriction will result in a zero on that
exercise.

You are not allowed to use any of Prolog's higher-order features or
extra-logical control features like or, cut, if-then, `call` or
`setof`. Violating this restriction will result in a *zero grade* for
the *entire project*.

Unless stated otherwise, you may introduce auxiliary helper
procedures.

*/


% #1: 5-points
% greater_than_element(IntList, N, GtElement): GtElement is
% an element of integer list IntList which is greater-than
% N.  On backtracking, GtElement must be produced in the same order
% as in IntList.
% *Restriction*: cannot use recursion.
% *Hint*:  use a Prolog built-in which was covered in class.
greater_than_element(IntList, N, Z) :- member(Z, IntList), Z @> N.

% #2: "10-points"
% greater_thans(IntList, N, GtList): GtList is a sub-list of
% those elements of integer list IntList which are greater than
% integer N.
% The elements in GtList must be in the same order in which they occur
% in IntList.
% Hint: `X =< Y` can be used to check if `X` is less-than-or-equal-to `Y`.
greater_thans([], _, []).
greater_thans(IntList, N, GtList) :- [Head|Tail]=IntList, Head @> N, greater_thans(Tail, N, Rtn), [Head|Rtn] = GtList.
greater_thans(IntList, N, GtList) :- [Head|Tail]=IntList, Head @=< N, greater_thans(Tail, N, Rtn), Rtn = GtList.

% #3: "10-points"
% List is a list consisting of N Fill elements.
fill_list(0, _, []).
fill_list(N, Fill, List):- N @> 0, M is N - 1, fill_list(M, Fill, Rtn), [Fill|Rtn] = List.

% #4: 10-points"
% rm_prefix(List, X, ListZ): ListZ matches List without its prefix of
% all elements which match X.
rm_prefix([], _, []).
rm_prefix(List, X, ListZ):- [Head|Tail]=List, Head = X, rm_prefix(Tail, X, Rtn), Rtn = ListZ.
rm_prefix(List, X, ListZ):- [Head|_]=List, Head \= X, List = ListZ.

% #5: "5-points"
% ListZ is List with any suffix elements equal to End removed.
rm_suffix(List, X, ListZ):- reverse(List, RevList), rm_prefix(RevList, X, TrimmedList), reverse(TrimmedList, ListZ).


% #6: 15-points
% A sentence is defined by the following EBNF grammar:
%
%   sentence
%     : noun_phrase verb_phrase
%     ;
%   noun_phrase
%     : ARTICLE? ADJECTIVE? NOUN
%     ;
%   verb_phrase
%     : VERB noun_phrase?
%     ;
%
% sentence(Vocab, Sentence): Sentence is a list of words constituting
% a sentence as per the above grammar, with words taken from list
% Vocab.  Vocab is a list of Prolog terms of the form:
% adjective(ADJECTIVE), article(ARTICLE), noun(NOUN), verb(VERB).
% Hint: use member/2 and append/3.
sentence(Vocab, Sentence):- noun_phrase(Vocab, X), verb_phrase(Vocab, Y), append(X, Y, Sentence).
noun_phrase(Vocab, NounPhrase):- member(article(X), Vocab), member(adjective(Y), Vocab), member(noun(Z), Vocab), [X, Y, Z] = NounPhrase.
noun_phrase(Vocab, NounPhrase):- member(article(X), Vocab), member(noun(Z), Vocab), [X, Z] = NounPhrase.
noun_phrase(Vocab, NounPhrase):- member(adjective(X), Vocab), member(noun(Z), Vocab), [X, Z] = NounPhrase.
noun_phrase(Vocab, NounPhrase):- member(noun(Z), Vocab), [Z] = NounPhrase.
verb_phrase(Vocab, VerbPhrase):- member(verb(X), Vocab), [X] = VP, noun_phrase(Vocab, NP), append(VP, NP, VerbPhrase).
verb_phrase(Vocab, VerbPhrase):- member(verb(X), Vocab), [X] = VerbPhrase.

% #7: 10-points
% sum_to(I, J, N): I, J and N are positive integers such that N = I + J.
% Note that N is instantiated when this procedure is called, I and J may
% or may not be instantiated.
% Answers must be generated in increasing order by I.
% *Restriction*: must consist of a single rule.
% *Hint*: use builtin between/3.
sum_to(I, J, N) :- succ(X, N), between(1, X, I), J is N-I.

% #8: 10-points
% sum_pairs(N, SumPairs): Given positive integer N, SumPairs is a list
% of pairs [I, J] with I, J > 0 and I + J == N, ordered in increasing
% order by I.
% Hint: use an auxiliary recursive procedure.
sum_pairs(N, SumPairs):- aux_sum_pairs(N, 1, [], SumPairs).
aux_sum_pairs(N, N, SumPairs, SumPairs).
aux_sum_pairs(N, X, OaccList, SumPairs):- sum_to(X, Y, N), Xsucc is X+1, append(OaccList, [[X,Y]], NaccList), aux_sum_pairs(N, Xsucc, NaccList, SumPairs).

% #9: 10-points
% poly_coeffs(Poly, Var, Coeffs): Given a polynomial
% CN*Var**N + ... + C2*Var**2 + C1*Var**1 + C0*Var**0,
% Coeffs is the list [C0, C1, C2, ..., CN].
% Note that Poly is guaranteed to contain all powers 0..N of Var.
% Hint: + is left-associative.
poly_coeffs(Poly, Var, Coeffs):- aux_poly_coeffs(Poly, Var, [], Coeffs).
aux_poly_coeffs(Poly, Var, OaccList, Coeffs):- *(Coeff, Exp) = Poly, **(Var,_)=Exp, append(OaccList, [Coeff], NaccList), NaccList = Coeffs.
aux_poly_coeffs(Poly, Var, OaccList, Coeffs):- +(Rest, X) = Poly, *(Coeff, Exp) = X, **(Var,_)=Exp, append(OaccList, [Coeff], NaccList), aux_poly_coeffs(Rest, Var, NaccList, Coeffs).


% #10: 15-points
% left_assoc(PlusTerm, LeftAssocTerm): PlusTerm is a Prolog term
% involving integers and Prolog's + operator.  LeftAssocTerm is
% like PlusTerm but associated so that the second operand of any
% + cannot be a +-term.
% *Hints*:
%    A + (B + C) ==> (A + B) + C.
%    integer/1 succeeds if its argument is an integer
left_assoc(PlusTerm, LeftAssocTerm):- list_left_assoc(PlusTerm,[], RtnList), build_left_assoc(RtnList, LeftAssocTerm).
list_left_assoc(PlusTerm, AccList, NewAccList):- integer(PlusTerm), append(AccList, [PlusTerm], NewAccList).
list_left_assoc(PlusTerm, AccList, BAccList):- +(A,B)=PlusTerm, list_left_assoc(A, AccList, AAccList), list_left_assoc(B, AAccList, BAccList).
build_left_assoc(List, LeftAssocTerm):- length(List, 1), member(LeftAssocTerm, List).
build_left_assoc(List, LeftAssocTerm):- [First|[Second|Rest]]=List, +(First, Second)=AccAdd, build_inner_left_assoc(Rest, AccAdd, LeftAssocTerm).
build_inner_left_assoc([], AccAdd, AccAdd).
build_inner_left_assoc(List, AccAdd, LeftAssocTerm):- [First|Rest]=List, +(AccAdd, First)=NewAccAdd, build_inner_left_assoc(Rest, NewAccAdd, LeftAssocTerm).




