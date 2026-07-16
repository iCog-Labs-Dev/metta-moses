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
   five numbered sections every domain provides).

## Adding a new action domain (e.g. ant trail)

1. **World**: a constructor `(mk<Dom>World ...)` plus accessors. The world
   is opaque to the engine and to all structural ops — only your domain
   clauses inspect it. Encode per-turn/budget bookkeeping (like TTT's
   `moved` latch) inside it.
2. **Primitives**: ONE clause per action/perception, following the
   contract from `scoring/action-ops.metta`:
   `(= (actionOp <name> $children $world) (mkARes <Bool> <World'>))`.
   Children arrive unevaluated; leaves ignore them. Prefix names with your
   domain (`ant...`, `ttt...`) to avoid clause collisions — every domain's
   clauses share the single `actionOp` predicate. Unknown ops score worst
   automatically; you never touch the engine.
3. **Episode runner**: run a compiled tree in your world and return a
   Number (higher = better). Decide failure semantics explicitly — TTT
   forfeits (-1.0) on any turn where the tree places no mark, which also
   closes the empty-exemplar (`(and_seq ())`) loophole.
4. **Registration file**: copy `ttt-action-registration.metta`'s five
   numbered sections — (1) `registerDomainAction` / `registerDomainPerception`
   per primitive, (2) `actionDomainActions` / `actionDomainPerceptions` /
   `actionDomainOpponents` clauses, (3) `actionDomainRunEpisode` (the
   expression arrives already compiled), (4) `actionDomainBestScore`,
   (5) `registerActionDomain`. Quote-wrap the opponents tuple —
   `(quote (<opp> ...))` — whenever any entry names a loaded function
   (opponent policies usually do): a bare tuple compiles as a call, the
   clause silently yields nothing, and the domain scores as misconfigured.
   The scoring layer unwraps the quote.
5. **Imports**: load your files world → primitives → episode →
   registration, after the scoring block (the registry's sentinel clauses
   are what let your late-loaded `actionOp` / `actionDomain*` clauses
   dispatch). Initial exemplars should be `and_seq`-rooted:
   `getCandidate`'s decode branch keys off the root symbol via
   `isActionOperator`.
