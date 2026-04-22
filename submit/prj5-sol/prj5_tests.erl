-module(prj5_tests).
-include_lib("eunit/include/eunit.hrl").
-compile([nowarn_export_all, export_all]).


-import(prj5_sol, [
  assoc/1,
  arith0/2,
  arith1/2,
  make_server/2
]).

%---------------------------- Test Control ------------------------------
%% Enabled Tests
%% The skeleton file is distributed with all tests deactivated
%% by being enclosed within if(false) ... endif directives.
%% As code is completed, activate test by moving `-if(false).`
%% down past tests for completed code.
%% Enable all tests before submission.



  -define(test_assoc, enabled).
  -define(test_arith0, enabled).
  -define(test_arith1, enabled).
  -define(test_make_server, enabled).

-if(false).  
-endif.

%------------------------------ assoc/1 ---------------------------------

-ifdef(test_assoc).
assoc_test_() ->
  Default = 42,
  X0 = assoc({new, Default}),
  X1 = assoc({put, X0, a, 11}),
  X2 = assoc({put, X1, b, 22}),
  X3 = assoc({put, X2, a, 33}),
  Tests = [
    { "assoc X0", ?_assertEqual(Default, assoc({get, X0, a})) },
    { "assoc get X1 a", ?_assertEqual(11, assoc({get, X1, a})) },
    { "assoc get X1 b", ?_assertEqual(Default, assoc({get, X1, b})) },
    { "assoc get X2 a", ?_assertEqual(11, assoc({get, X2, a})) },
    { "assoc get X2 b", ?_assertEqual(22, assoc({get, X2, b})) },
    { "assoc get X3 a", ?_assertEqual(33, assoc({get, X3, a})) },
    { "assoc get X3 b", ?_assertEqual(22, assoc({get, X3, b})) },
    { "assoc get X3 b", ?_assertEqual(Default, assoc({get, X3, c})) },
    { "assoc gett error",
      ?_assertError(function_clause, assoc({gett, X3, c})) }
  ],
  { "assoc tests", Tests }.
-else.
assoc_test_() -> [].
-endif. %test_assoc


%---------------------------- arith0/2 -------------------------------

arith_tests(FnName, ArithFn) ->
  Expr = fun(Pair) -> element(1, Pair) end,
  X0 = assoc({new, 0}),
  X0Tests = [
    { FnName ++ " X0 22", ?_assertEqual(22, Expr(ArithFn(22, X0))) },
    { FnName ++ " X0 2+3", ?_assertEqual(5, Expr(ArithFn({add, 2, 3}, X0))) },
    { FnName ++ " X0 2-3", ?_assertEqual(-1, Expr(ArithFn({sub, 2, 3}, X0))) },
    { FnName ++ " X0 2*3", ?_assertEqual(6, Expr(ArithFn({mul, 2, 3}, X0))) },
    { FnName ++ " X0 22/3",
      ?_assertEqual(7, Expr(ArithFn({divv, 22, 3}, X0))) },
    { FnName ++ " X0 22+(33-12)/9",
      ?_assertEqual(24, Expr(ArithFn({add, 22, {divv, {sub, 33, 12}, 9}}, X0))
      ) },
    { FnName ++ " X0 a", ?_assertEqual(0, Expr(ArithFn(a, X0))) },
    { FnName ++ " X0 a+3", ?_assertEqual(3, Expr(ArithFn({add, a, 3}, X0))) },
    { FnName ++ " X0 a-3", ?_assertEqual(-3, Expr(ArithFn({sub, a, 3}, X0))) },
    { FnName ++ " X0 a*3", ?_assertEqual(0, Expr(ArithFn({mul, a, 3}, X0))) },
    { FnName ++ " X0 a/3", ?_assertEqual(0, Expr(ArithFn({divv, a, 3}, X0))) },
    { FnName ++ " mull error",
      ?_assertError(function_clause, Expr(ArithFn({mull, 2, 3}, X0))) },
    { FnName ++ " div0 error 22/0",
      ?_assertError(badarith, Expr(ArithFn({divv, 22, 0}, X0))) }
  ],
  { Val1, X1 } = ArithFn({assign, a, 2}, X0),
  { Val2, X2 } = ArithFn({assign, b, {add, 3, a}}, X1),
  X2Tests = [
    { FnName ++ " X0 a=2", ?_assertEqual(2, Val1) },
    { FnName ++ " X1 b=3+a", ?_assertEqual(5, Val2) },
    { FnName ++ " X2 add", ?_assertEqual(7, Expr(ArithFn({add, a, b}, X2))) },
    { FnName ++ " X2 sub", ?_assertEqual(-3, Expr(ArithFn({sub, a, b}, X2))) },
    { FnName ++ " X2 mul", ?_assertEqual(10, Expr(ArithFn({mul, a, b}, X2))) },
    { FnName ++ " X2 divv", ?_assertEqual(2, Expr(ArithFn({divv, b, a}, X2))) }
  ],
  {Val3, X3} = ArithFn({assign, a, {mul, a, b}}, X2),  %a=10, b=5
  X3Tests = [
    { FnName ++ " X2 a=a*b", ?_assertEqual(10, Val3) },
    { FnName ++ " X3 a+b", ?_assertEqual(15, Expr(ArithFn({add, a, b}, X3))) },
    { FnName ++ " X3 a-b", ?_assertEqual(5, Expr(ArithFn({sub, a, b}, X3))) },
    { FnName ++ " X3 a*b", ?_assertEqual(50, Expr(ArithFn({mul, a, b}, X3))) },
    { FnName ++ " X3 a/b", ?_assertEqual(2, Expr(ArithFn({divv, a, b}, X3))) }
  ],
  {Val4, X4} = ArithFn({assign, a, {assign, b, {add, a, {mul, a, b}}}}, X3),
  X4Tests = [
    { FnName ++ " MultiAssign a = b = a + a*b", ?_assertEqual(60, Val4) },
    { FnName ++ " X4 a", ?_assertEqual(60, Expr(ArithFn(a, X4))) },
    { FnName ++ " X4 b", ?_assert(Expr(ArithFn(b, X4)) == 60) }
  ],
  X0Tests ++ X2Tests ++ X3Tests ++ X4Tests.

-ifdef(test_arith0).
arith0_test_() ->
  { "arith0 tests", arith_tests("arith0", fun prj5_sol:arith0/2) }.
-else.
arith0_test_() -> [].
-endif. %test_arith0


%---------------------------- arith1/2 -------------------------------


-ifdef(test_arith1).
arith1_test_() ->
  BaseTests = arith_tests("arith1", fun prj5_sol:arith1/2),
  Expr = fun(Pair) -> element(1, Pair) end,
  X0 = assoc({new, 0}),
  { Val1, X1 } = arith1({assign, a, {uminus, -2}}, X0),   %a = 2
  { Val2, X2 } = arith1({assign, b, {add, {uminus, -3}, a}}, X1), %b = 5
  UminusTests = [
    { "arith1 X0 a= - -2", ?_assertEqual(2, Val1) },
    { "arith1 X1 b = - -3 + a", ?_assertEqual(5, Val2) },
    { "arith1 X2 -a + -b",
       ?_assertEqual(-7, Expr(arith1({add, {uminus, a}, {uminus, b}}, X2))) },
    { "arith1 X2 (-a+12)*(- -22 - -b)",
       ?_assertEqual(270, Expr(arith1({mul, {add, {uminus, a}, 12},
                                      {sub, {uminus, -22}, {uminus, b}}}, X2)))     }
  ],
  { "arith1 tests", BaseTests ++ UminusTests }.
-else.
arith1_test_() -> [].
-endif. %test_arith1


%------------------------------ make_server/2 ---------------------------

-ifdef(test_make_server).
make_server_test_() ->
  { Pid, ReqFn } = make_server(fun prj5_sol:arith0/2, assoc({new, 0})),
  Expr = fun (Pair) -> element(2, Pair) end,
  E1 = {sub, {add, {mul, a, b}, b}, {divv, b, a}}, 
  E2 = {sub, {add, {mul, a, b}, b}, {divv, b, {uminus, a}}},
  UminusErr = { error, function_clause },
  Div0Err = { error, badarith },
  Tests = [ %depends on ordering, AFAICT this is guaranteed
    { "make_server server-is-alive", ?_assert(is_process_alive(Pid)) },
    { "make_server arith0: div0 a/a",
      ?_assertEqual(Div0Err, Expr(ReqFn({req, {divv, a, a}}))) },
    { "make_server arith0: a=2",
      ?_assertEqual(2, Expr(ReqFn({req, {assign, a, 2}}))) },
    { "make_server arith0: 7 + (b=3)",
      ?_assertEqual(10, Expr(ReqFn({req, {add, 7, {assign, b, 3}}}))) },
    { "make_server arith0: a*b+b-b/a",
      ?_assertEqual(8, Expr(ReqFn({req, E1}))) },
    { "make_server arith0: uminus unimplemented a*b+b-b/-a",
      ?_assertEqual(UminusErr, Expr(ReqFn({req, E2}))) },
    { "make_server upgrade to arith1",
      ?_assertEqual({upgraded, fun prj5_sol:arith0/2},
                    ReqFn({upgrade, fun prj5_sol:arith1/2})) },
    { "make_server arith1: a*b+b-b/-a",
      ?_assertEqual(10, Expr(ReqFn({req, E2}))) },
    { "make_server downgrade to arith0",
      ?_assertEqual({upgraded, fun prj5_sol:arith1/2},
                    ReqFn({upgrade, fun prj5_sol:arith0/2})) },
    { "make_server downgraded uminus unimplemented: a*b+b-b/-a",
      ?_assertEqual(UminusErr, Expr(ReqFn({req, E2}))) },
    { "make_server stop",
      ?_assertEqual({stopped, [Div0Err, UminusErr, UminusErr]},
                    ReqFn({stop})) },
    { "make_server server-is-dead", ?_assertNot(is_process_alive(Pid)) }
  ],
  { "make-server tests", Tests }.
-else.
make_server_test_() -> [].
-endif. %test_make_server

%---------------------------------- main/1 ------------------------------

% for automated testing using gradescope
% run this file using escript after compiling using erlc *.erl
main([]) ->
    Tests = lists:flatten([
	assoc_test_(),
	arith0_test_(),
	arith1_test_(),
	make_server_test_()
    ]),
    eunit:test(Tests, [ verbose ]).
