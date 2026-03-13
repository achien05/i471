#!/usr/bin/env -S swipl
%-*- mode: prolog; -*-

:- module(lab6_sol,  [
      cons_list_car/2, cons_list_cadr/2, cons_list_cddr/2,
      caddr/2, cdar/2,
      area/2, length_second/2,
      sum_list/2, sum_list/3, sum_lengths/2
  ]).

/* *IMPORTANT NOTE*:

   In order to avoid singleton variable warnings in the skeleton
   code, all variable names use a leading underscore as in _List.
   When writing the code, please remove the leading underscore
   and change to simply List.
*/

% For the next few exercises we represent lists in Prolog using a
% non-standard representation which we call a cons-list.  Specifically,
% an empty list is represented as the Prolog atom nil and the list
% with head Hd and tail Tl is represented as the Prolog structure
% cons(Hd, Tl).

% #1
% cons_list_car(Ls, Hd): succeed iff Hd matches the head of cons-list Ls.
cons_list_car(_Ls, _Hd) :- cons(_Hd,_) = _Ls.

% #2
% cons_list_cadr(Ls, Cadr): succeed iff Cadr matches the scheme
% cadr of cons-list Ls.
cons_list_cadr(_Ls, _Cadr) :- cons(_,cons(_Cadr, _)) = _Ls.

% #3
% cons_list_cddr(Ls, Cddr): succeed iff Cddr matches the scheme
% cddr of cons-list Ls.
cons_list_cddr(_Ls, _Cddr) :- cons(_,cons(_, _Cddr)) = _Ls.

% The following problems should use regular Prolog list syntax.

% #4
% caddr(List, Caddr): succeed iff Caddr matches the Scheme caddr of List.
caddr(_List, _Caddr) :- [_|[_|[_Caddr|_]]] = _List.

% #5
% cdar(List, Cdar): succeed iff Cdar matches the Scheme cdar of List.
cdar(_List, _Cdar) :- [[_|_Cdar]|_] = _List.

% #6
% procedure length_second(List, Len): succeed iff Len
% matches the length of the second element in List (which
% should be a list).
% Hint: use pattern matching on List to extract its second
% element Second and then use length(Second, Len) to match
% Len with the length of Second.
length_second(_List, _Len) :- [_|[Second|_]]=_List, length(Second, _Len).

% #7
% area(Shape, Area): succeed iff Area matches the area of Shape,
% for Shape in rect(Width, Height) and circle(Radius).
area(_Shape, _Area) :- rect(Width, Height) = _Shape, _Area is Width*Height.
area(_Shape, _Area) :- circle(Radius) = _Shape, _Area is pi*Radius*Radius.

% #8
% sum_lengths(List, LensSum): assuming that each element of List is
% itself a list, succeed iff LensSum matches the sum of the lengths of
% the lists in List.
sum_lengths(_List, _LensSum) :- []=_List, 0 = _LensSum.
sum_lengths(_List, _LensSum) :- [H|T]=_List, length(H, TLensSum), sum_lengths(T, LLensSum), _LensSum is LLensSum+TLensSum.

% #9
% sum_list(List, Sum): succeed iff Sum matches the sum of the numbers in
% number-list Sum.  *Must* be implemented as a wrapper which simply
% calls a tail-recursive sum_list(List, Acc, Sum) which succeeds
% if Sum matches the sum of Acc and the numbers in number-list List.
sum_list(_List, _Sum) :- sum_list(_List, 0, _Sum).
sum_list(_List, _Acc, _Sum) :- []=_List, _Acc=_Sum.
sum_list(_List, _Acc, _Sum) :- [H|T]=_List, X is H+_Acc, sum_list(T, X, _Sum).
