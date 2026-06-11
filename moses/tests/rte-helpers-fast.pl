%% Native Prolog stubs for the predicates whose A/B against optimised MeTTa
%% showed a clear win on mux6 (≥5 % wall).
%%
%% Loaded via `(callPredicate (Predicate (consult …)))` in the benchmark
%% entry point AFTER MeTTa imports. `retractall` removes the MeTTa-asserted
%% clauses; clauses below take over.
%%
%% PeTTaV1's parser converts `True`/`False` literals to lowercase `true`/`false`
%% Prolog atoms (parser.pl:47-49), so any boolean return values use lowercase.
%%
%% Helper predicates (collect_lits/2, collect_kids/2) are pure Prolog — they're
%% NOT registered with register_fun and exist only as internal recursion bodies
%% for the registered stubs.

%% --- getLiterals/2 (reduct/boolean-reduct/rte-helpers.metta:119) ---
%% mux6 A/B win for stub: +6.1 % wall. Single-pass walk avoids the per-element
%% reduce/2 dispatch that filter-atom + isLiterals incurs.
:- dynamic('getLiterals'/2).
:- retractall('getLiterals'(_, _)).

'getLiterals'([], []) :- !.
'getLiterals'(['NOT'|X], ['NOT'|X]) :- !.
'getLiterals'(Exp, Lits) :-
    is_list(Exp), !,
    collect_lits(Exp, Lits).
'getLiterals'(Exp, Exp).

collect_lits([], []).
collect_lits([H|T], Lits) :-
    collect_lits(T, RLits),
    ( atom(H)
      -> ( (H == 'AND' ; H == 'OR') -> Lits = RLits
                                     ; Lits = [H|RLits] )
       ; is_list(H), H = ['NOT'|_]
         -> Lits = [H|RLits]
          ; Lits = RLits
    ).

%% --- getChildrenExp/2 (reduct/boolean-reduct/rte-helpers.metta:83) ---
%% mux6 A/B win for stub: +7.3 % wall.
:- dynamic('getChildrenExp'/2).
:- retractall('getChildrenExp'(_, _)).

'getChildrenExp'([], []) :- !.
'getChildrenExp'(['NOT'|_], []) :- !.
'getChildrenExp'(Exp, Kids) :-
    is_list(Exp), !,
    collect_kids(Exp, Kids).
'getChildrenExp'(_, []).

collect_kids([], []).
collect_kids([H|T], Kids) :-
    collect_kids(T, RKids),
    ( atom(H) -> Kids = RKids
       ; is_list(H), H = ['NOT'|_]
         -> Kids = RKids
          ; Kids = [H|RKids]
    ).

%% --- replaceVarsWithTruth/3 (scoring/bscore.metta:140) ---
%% mux6 A/B win for stub: +13.5 % wall — the single largest contribution.
%% The MeTTa version foldl's replaceVarWithTruth over the variable list,
%% walking the entire tree once per variable (16.6M elementary calls on mux6).
%% This stub walks the tree once with an assoc-list lookup at each leaf.
%%
%% Semantics preserved from the MeTTa original (verified by bscore-test.metta):
%%   - For a single-element expression [X], unwrap and recurse on X.
%%   - Multi-element expression: head equality-checked (no AND/OR wrap), tail
%%     elements recurse fully.
%%   - Atom: substitute if in the assoc; if it's a bare AND/OR symbol, wrap
%%     in a 1-element list (the MeTTa source's quirky branch).

:- dynamic('replaceVarsWithTruth'/3).
:- retractall('replaceVarsWithTruth'(_, _, _)).

'replaceVarsWithTruth'([LList, BoolExpr], BList, Out) :-
    pairs_keys_values(Pairs, LList, BList),
    list_to_assoc(Pairs, Env),
    rvw_full(Env, BoolExpr, Out).

rvw_full(Env, [Single], Out) :- !,
    rvw_full(Env, Single, Out).
rvw_full(Env, [H|T], [H2|T2]) :-
    is_list(T), T \== [], !,
    rvw_head(Env, H, H2),
    maplist(rvw_full(Env), T, T2).
rvw_full(_, [], []) :- !.
rvw_full(Env, X, V) :- atom(X), get_assoc(X, Env, V), !.
rvw_full(_, X, [X]) :- atom(X), (X == 'AND' ; X == 'OR'), !.
rvw_full(_, X, X).

rvw_head(Env, X, V) :- atom(X), get_assoc(X, Env, V), !.
rvw_head(_, X, X).

%% Register the stubs as MeTTa funs (idempotent).
:- register_fun('getLiterals').
:- register_fun('getChildrenExp').
:- register_fun('replaceVarsWithTruth').
