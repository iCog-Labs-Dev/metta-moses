# Tic-tac-toe as a generic ACTION domain

This package expresses tic-tac-toe as an action domain for the pluggable
generic action evaluator (`scoring/action-registry.metta`,
`scoring/action-eval.metta`, `scoring/action-ops.metta`). It is the
reference domain package: candidate trees built from structural operators
(`and_seq`, `or_seq`, ...) plus the domain actions/perceptions below are
executed by `evalAction` against an opaque world, and an episode runner
turns one game into a raw score. The existing strategy example in
`examples/tic-tac-toe/` remains a separate, untouched package; this one
only reuses its board helpers, move finders, and opponent policies.

Files (load in this order, after the scoring block):

1. `ttt-action-world.metta` — world `(mkTTTWorld board player moved)`,
   accessors, and `applyTTTMove` (the one-move-per-turn latch: once a
   placement happens, later placement actions in the same turn are
   success-NOOPs, so `(or_seq tttWin tttBlock tttCenter tttCorner tttSide)`
   equals the strategy example's PRIORITIZED-OR).
2. `ttt-action-primitives.metta` — actions `tttWin tttBlock tttCenter
   tttCorner tttSide`, perceptions `tttCanWin tttCanBlock tttCenterFree`.
3. `ttt-action-episode.metta` — `tttActionEpisode`: one game as X vs an
   opponent policy; win 1.0 / draw 0.0 / loss -1.0; a turn with no
   placement (latch still False) is a forfeit, -1.0.
4. `ttt-action-registration.metta` — THE domain-package interface (the
   four numbered sections every domain provides).

## Adding a new action domain (e.g. ant trail)

1. **World**: a constructor `(mk<Dom>World ...)` plus accessors. The world
   is opaque to the engine and to all structural ops — only your domain
   clauses inspect it. Encode per-turn/budget bookkeeping (like TTT's
   `moved` latch) inside it.
2. **Primitives**: ONE bare-head clause per action/perception, following
   the contract from `scoring/action-ops.metta`:
   `(= (<name> $children $world) (mkARes <Bool> <World'>))`.
   Children arrive unevaluated; leaves ignore them. Prefix names with your
   domain (`ant...`, `ttt...`) to avoid clause collisions — the engine
   reduce-dispatches on the bare operator symbol, so every domain's clause
   heads share one global namespace. Do NOT add `(: <name> ...)` type
   declarations to ops — they break the engine's reduce dispatch. Unknown
   ops score worst automatically; you never touch the engine.
3. **Episode runner**: run a compiled tree in your world and return a
   Number (higher = better). Decide failure semantics explicitly — TTT
   forfeits (-1.0) on any turn where the tree places no mark, which also
   closes the empty-exemplar (`(and_seq ())`) loophole.
4. **Registration file**: copy `ttt-action-registration.metta`'s four
   numbered sections — (1) `actionDomainActions` / `actionDomainPerceptions`
   / `actionDomainOpponents` config clauses, (2) `actionDomainRunEpisode`
   (the expression arrives already compiled), (3) `actionDomainBestScore`,
   (4) one `registerActionDomain` line (domain NAME only — CLI routing).
   The config clauses are the single source of the domain's vocabulary;
   there is no per-primitive registration. THE QUOTE RULE: quote-wrap
   EVERY config clause that returns a list of op symbols —
   `(= (actionDomainActions <dom>) (quote (<act> ...)))` — and likewise
   the opponents tuple whenever any entry names a loaded function
   (primitives are live bare-head clauses and opponent policies usually
   are too): a bare tuple compiles as a call, the clause silently yields
   nothing, and the domain scores as misconfigured. The same rule applies
   to hand-written wrapped-shape literals in tests/playgrounds —
   `(evalAction (quote (and_seq (...))) <world>)`. The scoring layer
   unwraps config-clause quotes via `configListSafe`
   (`scoring/action-score.metta`); quote strips on evaluation, so
   consumers always receive the plain tuple.
5. **Imports**: load your files world → primitives → episode →
   registration, after the scoring block (the registry's sentinel clauses
   are what let your late-loaded `actionDomain*` config clauses dispatch;
   bare-head op clauses need no sentinel — the engine reduce-dispatches
   them dynamically). Initial exemplars should be `and_seq`-rooted:
   `getCandidate`'s decode branch keys off the root symbol via
   `isActionOperator`.
