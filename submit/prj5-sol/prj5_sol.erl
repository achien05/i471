-module(prj5_sol).

-export([
  assoc/1,
  arith0/2,
  arith1/2,
  make_server/2
]).

% May use any of the constructs covered in class including guarded
% matches (using when), if-endif expressions with chains of
% conditions, case expressions with guarded matches.

% Additionally, may use the following not covered in class:
%
%  =:= and =/= for strict equality.
%  is_integer/1 and is_atom/1 for type checking.
%  List functions like lists:reverse/1.
%  The 'or', 'and' and 'not' logical operators.
%  Note that parentheses are necessary in
%  (A =:= B) or (C =/= D).

%------------------------------ assoc/1 ---------------------------------

% #1: "20-points"
%
% assoc/1 maintains association lists.  Behavior depends on it single Req
% argument:
%  { new, Default }:
%    Returns a new association list with Default value for undefined keys.
%  { put, Assoc, Key, Value }:
%    Returns a new association list which is just like Assoc except that
%    Key is associated with Value.
%  { get, Assoc, Key }:
%    Returns *last* associated value for Key in association list Assoc if any;
%    otherwise it returns Default value for Assoc.  Keys are compared
%    using strict equality =:=, =/= .
% Any exceptions (including unmatched argument) should be propagated to
% the caller.
%
%  *Hints*: 
%    Use pattern-matching along with guards to match the different kinds
%    of Req arguments.
%
assoc({new, Default}) -> 
  [Default];
assoc({put, Assoc, Key, Val}) ->
  Assoc ++ [{Key, Val}];
assoc({get, [], _}) ->                    %fail condition
  fail;
assoc({get, [{Key, Val}|_T], Key}) ->     %find condition
  Val;
assoc({get, [{_Ki, _Val}|T], Key}) ->     %default always first, go to below rule, then this is for recursion
  assoc({get, T, Key});
assoc({get, [Default|T], Key}) ->               %initially starts w/ default, triggers here
  X=assoc({get, lists:reverse(T), Key}),  %reverse to find the last match
  if  (X =/= fail) -> X;                  %determines if found or failed, if found return found Val
      true -> Default                     %if failed return default
  end.

%------------------------------ arith0/2 --------------------------------

% An Expr is either an Integer (for which is_integer/1 returns true),
% an Atom (for which is_atom/1 returns true), or { BinOp, Expr1, Expr2 }
% for BinOp one of add, sub, mul, divv (divv avoids a clash with the
% builtin div operator) or { assign, Atom, Expr } (where is_atom(Atom)
% returns true).

% An Expr can be evaluated within an association-list environment Env
% in the obvious way with the values of any Atom's obtained from Env.
% Specifically, { assign, Atom, Expr } will associate the value of Expr
% with Atom in a new environment;  the value of any other Atom in an
% expression is looked up in the current environment.

% #2: "30-points"
%
% arith0(Expr, Env):
%   Expr is as above and Env is an association-list as in #1.
%   Returns a pair { Value, Env1 } where Value is the value of the
%   evaluation of Expr in Env0 and Env1 is the updated environment.
%
% Notes:
%   Env1 will be the same as Env except when Expr involves an assign.   
%   The Value of an assignment-Expr {assign, Atom, Expr1} is the
%   value of Expr1.
%
% Any exceptions (including unmatched arguments) should be propagated to
% the caller.
%
% Hint: Recurse on the different kinds of expressions.
%
arith0(Expr, Env) when is_integer(Expr) -> 
  {Expr, Env};
arith0(Expr, Env) when is_atom(Expr) ->
  {assoc({get, Env, Expr}), Env};
arith0({BinOp, Atom, Expr}, Env) when (BinOp =:= assign) and is_atom(Atom) ->
  {X1,Env2} = arith0(Expr, Env),
  {X1, assoc({put, Env2, Atom, X1})};
arith0({BinOp, Expr1, Expr2}, Env) when (BinOp =:= add) ->
  {X1,X2} = arith0(Expr1, Env), {Y1,Y2} = arith0(Expr2, X2),
  {X1 + Y1, Y2};
arith0({BinOp, Expr1, Expr2}, Env) when (BinOp =:= sub) ->
  {X1,X2} = arith0(Expr1, Env), {Y1,Y2} = arith0(Expr2, X2),
  {X1 - Y1, Y2}; 
arith0({BinOp, Expr1, Expr2}, Env) when (BinOp =:= mul) ->
  {X1,X2} = arith0(Expr1, Env), {Y1,Y2} = arith0(Expr2, X2),
  {X1 * Y1, Y2}; 
arith0({BinOp, Expr1, Expr2}, Env) when (BinOp =:= divv) ->
  {X1,X2} = arith0(Expr1, Env), {Y1,Y2} = arith0(Expr2, X2),
  {X1 div Y1, Y2}.

%------------------------------ arith1/2 --------------------------------

% #3: "10-points"
%
% arith1/2 arith1(Expr, Env) is just like arith0/2 except that
% Expr should also allow unary minus; specifically {uminus Exp}.
%
% Hint: You could copy over the code for arith0/2 and add in a function
% clause for uminus.  However, it may be better to refactor arith0/2 so 
% that it becomes a trivial wrapper and then call the wrapped function 
% here when the input is not a uminus.
%
arith1(Expr, Env) when is_integer(Expr) -> 
  {Expr, Env};
arith1(Expr, Env) when is_atom(Expr) ->
  {assoc({get, Env, Expr}), Env};
arith1({UnaOp, Expr}, Env) when (UnaOp =:= uminus) ->
  {X1,_} = arith1(Expr, Env),
  {X1*(-1), Env};
arith1({BinOp, Atom, Expr}, Env) when (BinOp =:= assign) and is_atom(Atom) ->
  {X1,Env2} = arith1(Expr, Env),
  {X1, assoc({put, Env2, Atom, X1})};
arith1({BinOp, Expr1, Expr2}, Env) when (BinOp =:= add) ->
  {X1,X2} = arith1(Expr1, Env), {Y1,Y2} = arith1(Expr2, X2),
  {X1+Y1, Y2};
arith1({BinOp, Expr1, Expr2}, Env) when (BinOp =:= sub) ->
  {X1,X2} = arith1(Expr1, Env), {Y1,Y2} = arith1(Expr2, X2),
  {X1-Y1, Y2};
arith1({BinOp, Expr1, Expr2}, Env) when (BinOp =:= mul) ->
  {X1,X2} = arith1(Expr1, Env), {Y1,Y2} = arith1(Expr2, X2),
  {X1*Y1, Y2};
arith1({BinOp, Expr1, Expr2}, Env) when (BinOp =:= divv) ->
  {X1,X2} = arith1(Expr1, Env), {Y1,Y2} = arith1(Expr2, X2),
  {X1 div Y1, Y2}.

%----------------------------- make_server/2 ----------------------------


% #4: "40-points"
%
% make_server(Fn, State): creates a server with processing function Fn
% and state State.  The processing function takes a {Request, State}
% and returns a {Response, NewState}.
%
% make_server/2 returns a pair { PId, ReqFn } where Pid is the PID
% of the server process and ReqFn is a function which takes a Req argument
% as follows:
%
%   { req, Request } :
%     Should send Request to the server process which should call
%     its processing function Fn(Request, State) (where State is the
%     server's current state).  Assume the processing function call
%     returns { Response, NewState }.  The server should continue
%     running with processing function unchanged but state set to NewState.
%     The call to ReqFn should return { result, Response }.
% 
%     If an exception Ex:Why occurs while calling processing function Fn,
%     then returns { exception, {Ex, Why} } and continues running server
%     with both processing function and state unchanged.
%
%   { upgrade, Fn1 } :
%     Upgrades the server processing function to Fn1, returns
%     { upgraded, Fn } where Fn is the previous processing function.
%
%   { stop } :
%     Should stop server and return { stopped, Errors } where Errors
%     is a list all {Ex, Why} errors which have occurred during the
%     lifetime of the server, in the order in which they occurred.
%
%   If any other request is received, the server should continue
%   after logging a message on the console.
%
%  *Hints*: Use an auxiliary function which is run by the server process.
%
make_server(Fn, State) -> 
  ServerPid = spawn(fun() -> auxFunc(Fn, State, []) end),  
  RtnFunc = fun(ReqPair)->
    case ReqPair of
      {req, Request} -> ServerPid ! {self(), {req, Request}},
        receive {result, Response} -> {result, Response};
                {exception, Exception} -> {exception, Exception}
        end;
      {upgrade, Fn1} -> ServerPid ! {self(), {upgrade, Fn1}},
        receive {upgraded, OldFn} -> {upgraded, OldFn} end;
      {stop} -> ServerPid ! {self(), {stop}},
        receive {stopped, ExceptionList} -> {stopped, ExceptionList} end
    end
  end,
  {ServerPid, RtnFunc}.

auxFunc(Fn, State, Exceptions) -> receive
    {ClientPid, {req, Request}} ->
      try Fn(Request, State) of
        {Response, NewState} -> ClientPid ! {result, Response}, auxFunc(Fn, NewState, Exceptions)
      catch
        throw:X -> ClientPid ! {exception, {throw, X}}, auxFunc(Fn, State, Exceptions ++ [{throw, X}]);
        exit:X -> ClientPid ! {exception, {exit, X}}, auxFunc(Fn, State, Exceptions ++ [{exit, X}]);
        error:X -> ClientPid ! {exception, {error, X}}, auxFunc(Fn, State, Exceptions ++ [{error, X}])
      end;
    {ClientPid, {upgrade, Fn1}} ->
      ClientPid ! {upgraded, Fn},
      auxFunc(Fn1, State, Exceptions);
    {ClientPid, {stop}}->
      ClientPid ! {stopped, Exceptions},
      true
    end.
  



