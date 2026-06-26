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

%% --- isConsistentExp/2 (reduct/boolean-reduct/delete-inconsistent-handle.metta:40) ---
%% A/B vs an optimised MeTTa walker was within noise on mux6, BUT the MeTTa
%% version errors on improper-list inputs that arise when `concatTuple` unions
%% a list with a bare Symbol (PeTTaV1's get-metatype fails on improper lists
%% because `is_list/1` only succeeds on proper lists). Keeping the Prolog stub
%% sidesteps the edge case; semantics are robust by construction.
%%
%% Short-circuit walker: returns false on the first (X, NOT X) pair found.
%% A handle X and Y are negations iff X = [NOT, Y]  or  Y = [NOT, X].

:- dynamic('isConsistentExp'/2).
:- retractall('isConsistentExp'(_, _)).

%% Empty handle set is trivially consistent.
'isConsistentExp'([], true) :- !.
%% Proper list: scan for a negation pair.
'isConsistentExp'(HandleSet, Result) :-
    is_list(HandleSet), !,
    ( has_neg_pair(HandleSet) -> Result = false ; Result = true ).
%% Anything else (bare Symbol, improper list, etc.) — no negation pair.
'isConsistentExp'(_, true).

has_neg_pair([H|T]) :- has_neg_with(H, T), !.
has_neg_pair([_|T]) :- has_neg_pair(T).

has_neg_with(X, [Y|_]) :- is_neg_pair(X, Y), !.
has_neg_with(X, [_|T]) :- has_neg_with(X, T).

is_neg_pair(X, ['NOT', Y]) :- Y == X, !.
is_neg_pair(['NOT', Y], X) :- Y == X, !.

%% --- setDifference/3 (utilities/general-helpers.metta:105) ---
%% MeTTa version walks Set1 and per element calls (once (is-member $h $set2))
%% which expands via collapse/superpose — each membership check is itself a
%% reduce/2 dispatched walk. Native subtract preserves element order (so call
%% sites depending on Set1's order keep working) but pays only C-level
%% memberchk per element.
:- dynamic('setDifference'/3).
:- retractall('setDifference'(_, _, _)).

'setDifference'([], _, []) :- !.
'setDifference'([H|T], Set2, R) :-
    is_list(Set2), !,
    ( memberchk(H, Set2)
      -> 'setDifference'(T, Set2, R)
       ; R = [H|Rest], 'setDifference'(T, Set2, Rest)
    ).
'setDifference'(Set1, _, Set1).  %% non-list set2 — degenerate, return Set1 as-is

%% --- getGuardSet/2 (reduct/boolean-reduct/rte-helpers.metta:20) ---
%% MeTTa version drives an if-decons-expr-custom primitive that accounts for
%% 5.7 % of mux6 wall on its own (649K calls). The stub does the head test
%% directly and delegates the literal collection to the existing getLiterals
%% stub. Semantics:
%%   - [] -> []
%%   - [OR | _] -> []
%%   - proper list otherwise -> getLiterals(Exp)
%%   - non-list (Symbol) -> Exp unchanged
:- dynamic('getGuardSet'/2).
:- retractall('getGuardSet'(_, _)).

'getGuardSet'([], []) :- !.
'getGuardSet'(['OR'|_], []) :- !.
'getGuardSet'(Exp, Lits) :-
    is_list(Exp), !,
    'getLiterals'(Exp, Lits).
'getGuardSet'(Exp, Exp).

%% --- sortDeme/2 (representation/instance.metta:134) ---
%% MeTTa version converts InstSet -> Expression list, then calls
%% selectionSort with sInstComparator. selectionSort is O(N^2) with the
%% comparator dispatched through reduce/2 per pair. On mux6 the chain
%% (selectionSort_Spec_[sInstComparator] -> sInstComparator -> cScoreExpr<)
%% accounts for ~5.7 % wall.
%%
%% Sort order (matches sInstComparator + cScoreExpr<):
%%   primary: penalizedScore DESCENDING (highest score first)
%%   tiebreak: cpxy ASCENDING (simpler trees win ties)
%% NaN penalizedScore: sorted to the end (mirrors MeTTa: NaN < non-NaN
%% by cScoreExpr<, so descending puts it last).
:- dynamic('sortDeme'/2).
:- retractall('sortDeme'(_, _)).

'sortDeme'(['mkSInstSet', InstList], ['mkSInstSet', Sorted]) :-
    is_list(InstList), !,
    maplist(make_sort_pair_, InstList, Pairs),
    keysort(Pairs, KSorted),
    pairs_values(KSorted, Sorted).
'sortDeme'(Set, Set).  %% shape mismatch fallback — returns unchanged

make_sort_pair_(Inst, Key-Inst) :-
    Inst = ['mkSInst', ['mkPair', _, ['mkCscore', _, Cpxy, _, _, PenSc]]], !,
    sort_key_of_(PenSc, Cpxy, Key).
make_sort_pair_(Inst, k(1.0Inf, 0)-Inst).  %% shape mismatch — sort last

sort_key_of_(PenSc, Cpxy, k(NegPS, Cpxy)) :-
    number(PenSc), PenSc =:= PenSc, !,   %% not NaN
    NegPS is -PenSc.
sort_key_of_(_, Cpxy, k(1.0Inf, Cpxy)). %% NaN -> sort last

%% --- any/2 (utilities/general-helpers.metta:218) ---
%% MeTTa version: `(once (is-member True $bools))` — `is-member` walks the
%% list with MeTTa-level reduce/2 dispatch per element. Native `memberchk(true)`
%% is a single indexed C-level call. 401K calls on mux6.
%% Note: PeTTaV1 parses literal True/False to lowercase atoms, so we test
%% against `true` (the actual runtime atom).
:- dynamic('any'/2).
:- retractall('any'(_, _)).

'any'(Bools, true) :- is_list(Bools), memberchk(true, Bools), !.
'any'(_, false).

%% Register the stubs as MeTTa funs (idempotent).
:- register_fun('getLiterals').
:- register_fun('getChildrenExp').
:- register_fun('replaceVarsWithTruth').
:- register_fun('isConsistentExp').
:- register_fun('setDifference').
:- register_fun('getGuardSet').
:- register_fun('sortDeme').
:- register_fun('any').
