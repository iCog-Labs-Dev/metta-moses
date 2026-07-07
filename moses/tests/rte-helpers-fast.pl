%% Native Prolog stubs for the reduct/scoring hot-path helpers (mux6 A/B
%% showed ≥5 % wall each for the originals; re-ported for the n-ary
%% labels-as-vars convention).
%%
%% Loaded via `(callPredicate (Predicate (consult …)))` in moses.metta AFTER
%% the MeTTa imports. `retractall` removes the MeTTa-asserted clauses; the
%% clauses below take over.
%%
%% SHAPE: boolean operators are n-ary — ['AND', C1, ..., Cn] /
%% ['OR', C1, ..., Cn] / unary ['NOT', X]. Labels are UNBOUND PROLOG VARS
%% (labels-as-vars), which imposes two hard rules on every clause here:
%%
%%   1. NEVER pattern-match a position that can hold a label var against a
%%      non-var term — head unification BINDS the var (e.g. ['NOT'|X] vs a
%%      bare tuple [V,...] would bind V := 'NOT'). Dispatch with ==/2 inside
%%      guarded if-then-else instead; ==/2 never binds.
%%   2. NEVER use memberchk/subtract on lists that can hold label vars —
%%      they unify. Use the ==-based memberq_ below. ==/2 on two vars is
%%      exactly label identity, which is the semantics the MeTTa versions
%%      (memberOf/subAll/intersect/uniqueStruct in rte-helpers.metta) implement.
%%
%% PeTTaV1's parser converts `True`/`False` literals to lowercase `true`/
%% `false` Prolog atoms (parser.pl:47-49), so boolean returns use lowercase.
%%
%% replaceVarsWithTruth is intentionally NOT stubbed anymore: the
%% labels-as-vars scoring path evaluates candidate terms by binding the
%% label vars directly (no label->truth substitution walk exists on the hot
%% path), so the old stub has no live caller.
%%
%% lib_tabling / (tabled removeEmptyAND) must stay OFF: SLG tabling stores
%% variant-renamed answers, which destroys shared label-var identity in the
%% returned trees.
%%
%% collect_lits/2, collect_kids/2, memberq_/2, memberq_true/1 are internal
%% Prolog helpers — not registered with register_fun.

%% --- getLiterals/2 (reduct/boolean-reduct/rte-helpers.metta) ---
%% Literals of an n-ary AND/OR node: leaf elements (vars, atoms, grounded)
%% and ['NOT', _] elements. (NOT x) input is itself a literal; leaves pass
%% through unchanged. Mirrors the MeTTa version: filter every element of
%% the expression — the AND/OR head symbol drops out inside collect_lits.
:- dynamic('getLiterals'/2).
:- retractall('getLiterals'(_, _)).

'getLiterals'(Exp, Exp) :- \+ is_list(Exp), !.   %% Symbol / Var / Grounded leaf
'getLiterals'([], []) :- !.
'getLiterals'([H|T], Out) :- !,
    (  H == 'NOT' -> Out = [H|T]
    ;  collect_lits([H|T], Out)
    ).

collect_lits([], []).
collect_lits([H|T], Lits) :-
    collect_lits(T, R),
    (  var(H)    -> Lits = [H|R]                             %% label var = literal
    ;  atomic(H) -> ( (H == 'AND' ; H == 'OR') -> Lits = R ; Lits = [H|R] )
    ;  is_list(H), H = [HH|_], HH == 'NOT' -> Lits = [H|R]   %% HH aliases, never binds
    ;  Lits = R
    ).

%% --- getChildrenExp/2 (reduct/boolean-reduct/rte-helpers.metta) ---
%% Non-literal children (nested sub-expressions) of an n-ary node.
%% Mirrors the MeTTa version: filter every element — leaves and the AND/OR
%% head symbol drop out inside collect_kids.
:- dynamic('getChildrenExp'/2).
:- retractall('getChildrenExp'(_, _)).

'getChildrenExp'(Exp, []) :- \+ is_list(Exp), !.
'getChildrenExp'([], []) :- !.
'getChildrenExp'([H|T], Out) :- !,
    (  H == 'NOT' -> Out = []
    ;  collect_kids([H|T], Out)
    ).

collect_kids([], []).
collect_kids([H|T], Kids) :-
    collect_kids(T, R),
    (  var(H)    -> Kids = R
    ;  atomic(H) -> Kids = R
    ;  H == []   -> Kids = R                                 %% stray empty tuple
    ;  is_list(H), H = [HH|_], HH == 'NOT' -> Kids = R
    ;  is_list(H) -> Kids = [H|R]
    ;  Kids = R
    ).

%% --- getGuardSet/2 (reduct/boolean-reduct/rte-helpers.metta) ---
%% Leaf -> itself; [] -> []; OR node -> [] (no guard set); else literals.
:- dynamic('getGuardSet'/2).
:- retractall('getGuardSet'(_, _)).

'getGuardSet'(Exp, Exp) :- \+ is_list(Exp), !.
'getGuardSet'([], []) :- !.
'getGuardSet'([H|_], []) :- H == 'OR', !.
'getGuardSet'(Exp, Lits) :- 'getLiterals'(Exp, Lits).

%% --- removeEmptyAND/2 (reduct/boolean-reduct/cut-unnecessary-and.metta) ---
%% Drop ['AND'] (childless AND) subtrees anywhere in the expression; the
%% dropped node signals upward as 'Nothing' and is filtered out by the
%% parent. Non-AND expressions map over EVERY element (the head symbol is a
%% leaf that passes through unchanged), mirroring the MeTTa map/filter pair.
%% ==/2-only dispatch: a label var head must not unify with 'AND'.
:- dynamic('removeEmptyAND'/2).
:- retractall('removeEmptyAND'(_, _)).

'removeEmptyAND'(Exp, Exp) :- \+ is_list(Exp), !.   %% Symbol / Var / Grounded leaf
'removeEmptyAND'([], []) :- !.
'removeEmptyAND'([H|T], Out) :- !,
    (  H == 'AND'
    -> ( T == [] -> Out = 'Nothing'
       ; rea_kids_(T, Kids), Out = ['AND'|Kids] )
    ;  rea_kids_([H|T], Out)
    ).

rea_kids_([], []).
rea_kids_([X|Xs], Out) :-
    'removeEmptyAND'(X, X1),
    rea_kids_(Xs, R),
    ( X1 == 'Nothing' -> Out = R ; Out = [X1|R] ).

%% The five ==-semantics set walks below (memberOf .. concatAll) mirror
%% reduct/boolean-reduct/rte-helpers.metta. Membership is memberq_ (==/2 only,
%% never binds label vars). Each has a leading non-list guard: a bare label
%% var as the collection would otherwise head-unify with [] and be BOUND;
%% failing instead mirrors the MeTTa versions' silent decons-atom failure on
%% leaves. append/3 only unifies the list SPINE — elements pass through by
%% reference, so var identity is preserved.

%% --- memberOf/3 (reduct/boolean-reduct/rte-helpers.metta) ---
:- dynamic('memberOf'/3).
:- retractall('memberOf'(_, _, _)).
'memberOf'(El, Tuple, R) :- is_list(Tuple), !,
    ( memberq_(El, Tuple) -> R = true ; R = false ).

%% --- subAll/3 (reduct/boolean-reduct/rte-helpers.metta) ---
:- dynamic('subAll'/3).
:- retractall('subAll'(_, _, _)).
'subAll'(T, _, _) :- \+ is_list(T), !, fail.
'subAll'([], _, []) :- !.
'subAll'([H|T], Del, R) :- is_list(Del), !,
    'subAll'(T, Del, R0),
    ( memberq_(H, Del) -> R = R0 ; R = [H|R0] ).

%% --- uniqueStruct/2 (reduct/boolean-reduct/rte-helpers.metta) ---
:- dynamic('uniqueStruct'/2).
:- retractall('uniqueStruct'(_, _)).
'uniqueStruct'(T, _) :- \+ is_list(T), !, fail.
'uniqueStruct'([], []) :- !.
'uniqueStruct'([H|T], [H|R]) :- !,
    'subAll'(T, [H], T1),
    'uniqueStruct'(T1, R).

%% --- intersect/3 (reduct/boolean-reduct/rte-helpers.metta) ---
:- dynamic('intersect'/3).
:- retractall('intersect'(_, _, _)).
'intersect'(X, _, _) :- \+ is_list(X), !, fail.
'intersect'([], _, []) :- !.
'intersect'([H|T], Y, R) :- is_list(Y), !,
    'intersect'(T, Y, R0),
    ( memberq_(H, Y) -> R = [H|R0] ; R = R0 ).

%% --- concatAll/2 (reduct/boolean-reduct/rte-helpers.metta) ---
:- dynamic('concatAll'/2).
:- retractall('concatAll'(_, _)).
'concatAll'(T, _) :- \+ is_list(T), !, fail.
'concatAll'([], []) :- !.
'concatAll'([H|T], R) :- is_list(H), !,
    'concatAll'(T, R0),
    append(H, R0, R).

%% --- isConsistentExp/2 (reduct/boolean-reduct/delete-inconsistent-handle.metta) ---
%% Short-circuit scan for a complementary pair; NOT is unary wrapped
%% ['NOT', C]. Complement test uses ==/2 throughout: for label vars that is
%% var identity, exactly matching the MeTTa areNegations semantics.
:- dynamic('isConsistentExp'/2).
:- retractall('isConsistentExp'(_, _)).

'isConsistentExp'([], true) :- !.
'isConsistentExp'(HandleSet, Result) :-
    is_list(HandleSet), !,
    ( has_neg_pair(HandleSet) -> Result = false ; Result = true ).
'isConsistentExp'(_, true).

has_neg_pair([H|T]) :- has_neg_with(H, T), !.
has_neg_pair([_|T]) :- has_neg_pair(T).

has_neg_with(X, [Y|_]) :- is_neg_pair(X, Y), !.
has_neg_with(X, [_|T]) :- has_neg_with(X, T).

is_neg_pair(X, Y) :- nonvar(Y), Y = [YH, YC], YH == 'NOT', YC == X, !.
is_neg_pair(X, Y) :- nonvar(X), X = [XH, XC], XH == 'NOT', XC == Y.

%% --- setDifference/3 (utilities/general-helpers.metta) ---
%% Order-preserving difference with ==-based membership (memberchk would
%% unify a label var with the first element of Set2).
:- dynamic('setDifference'/3).
:- retractall('setDifference'(_, _, _)).

'setDifference'([], _, []) :- !.
'setDifference'([H|T], Set2, R) :-
    is_list(Set2), !,
    (  memberq_(H, Set2)
    -> 'setDifference'(T, Set2, R)
    ;  R = [H|Rest], 'setDifference'(T, Set2, Rest)
    ).
'setDifference'(Set1, _, Set1).   %% non-list set2 — degenerate, unchanged

memberq_(X, [Y|_]) :- X == Y, !.
memberq_(X, [_|T]) :- memberq_(X, T).

%% --- sortDeme/2 (representation/instance.metta) ---
%% keysort on (negated penalizedScore, cpxy) — primary: penalizedScore
%% DESCENDING, tiebreak: cpxy ASCENDING, NaN sorted last. Instance trees may
%% carry label vars but the matched skeleton (mkSInst/mkPair/mkCscore) and
%% the score slots are ground, so the pattern match cannot bind them.
:- dynamic('sortDeme'/2).
:- retractall('sortDeme'(_, _)).

'sortDeme'(['mkSInstSet', InstList], ['mkSInstSet', Sorted]) :-
    is_list(InstList), !,
    maplist(make_sort_pair_, InstList, Pairs),
    keysort(Pairs, KSorted),
    pairs_values(KSorted, Sorted).
'sortDeme'(Set, Set).   %% shape mismatch fallback — unchanged

make_sort_pair_(Inst, Key-Inst) :-
    nonvar(Inst),
    Inst = ['mkSInst', ['mkPair', _, ['mkCscore', _, Cpxy, _, _, PenSc]]], !,
    sort_key_of_(PenSc, Cpxy, Key).
make_sort_pair_(Inst, k(1.0Inf, 0)-Inst).   %% shape mismatch — sort last

sort_key_of_(PenSc, Cpxy, k(NegPS, Cpxy)) :-
    number(PenSc), PenSc =:= PenSc, !,   %% not NaN
    NegPS is -PenSc.
sort_key_of_(_, Cpxy, k(1.0Inf, Cpxy)).  %% NaN -> sort last

%% --- any/2 (utilities/general-helpers.metta) ---
%% ==-based scan for `true` (memberchk would bind an unbound element).
:- dynamic('any'/2).
:- retractall('any'(_, _)).

'any'(Bools, true) :- is_list(Bools), memberq_true(Bools), !.
'any'(_, false).

memberq_true([H|_]) :- H == true, !.
memberq_true([_|T]) :- memberq_true(T).

%% Register the stubs as MeTTa funs (idempotent).
:- register_fun('getLiterals').
:- register_fun('removeEmptyAND').
:- register_fun('memberOf').
:- register_fun('subAll').
:- register_fun('uniqueStruct').
:- register_fun('intersect').
:- register_fun('concatAll').
:- register_fun('getChildrenExp').
:- register_fun('getGuardSet').
:- register_fun('isConsistentExp').
:- register_fun('setDifference').
:- register_fun('sortDeme').
:- register_fun('any').
