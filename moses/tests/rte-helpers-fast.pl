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

%% Register the stubs as MeTTa funs (idempotent).
:- register_fun('getLiterals').
:- register_fun('getChildrenExp').
