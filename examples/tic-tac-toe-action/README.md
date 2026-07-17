# Tic-tac-toe as a generic ACTION experiment

This package expresses tic-tac-toe as an action experiment for the
pluggable generic action evaluator (`scoring/action-registry.metta`,
`scoring/action-eval.metta`, `scoring/action-ops.metta`). It is the
reference fitness package: candidate trees built from structural operators
(`and_seq`, `or_seq`, ...) plus the actions/perceptions below are executed
by `evalAction` against an opaque world, and a fitness function turns one
episode ordinal into a raw score. The existing strategy example in
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
4. `ttt-action-registration.metta` — THE fitness-package interface: the
   fitness function `tttActionFitness` (episode ordinal → opponent is
   private to it) and `tttActionBestScore`. It sets NO params; an
   experiment run binds them (see below).

## Adding a new action experiment (e.g. ant trail)

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
3. **Fitness function**: one clause `(= (<dom>Fitness $exp $i) <Number>)` —
   $exp arrives already compiled, $i is the episode ordinal 0..n-1; how
   ordinals map to opponents/trails/start worlds is entirely yours (TTT:
   even → random-player, odd → minimax-player). Add a best-score function
   `(= (<dom>BestScore $n) <Number>)`. Decide failure semantics explicitly
   — TTT forfeits (-1.0) on any turn where the tree places no mark, which
   also closes the empty-exemplar (`(and_seq ())`) loophole.
4. **Bind the experiment** via the four global params
   (`parameters/defaults.metta`); the file that defines the fitness sets
   NO params, the RUN does:

       !(set-param fitness <dom>Fitness)
       !(set-param bestScore <dom>BestScore)
       !(set-param actions (quote (<act> ...)))
       !(set-param perceptions (quote (<perc> ...)))

   The two function SYMBOLS can also ride the CLI
   (`--fitness=<dom>Fitness --bestScore=<dom>BestScore`); the
   vocabulary tuples cannot, so set them in-script. THE QUOTE RULE:
   quote-wrap BOTH vocabulary tuples at the set-param site — the
   primitives are live bare-head clauses, and an unquoted tuple headed by
   one curries into a `partial` term; quote strips on evaluation, so the
   params hold the plain tuples. The same rule applies to hand-written
   wrapped-shape literals in tests/playgrounds —
   `(evalAction (quote (and_seq (...))) <world>)`.
5. **Imports**: load your files world → primitives → episode →
   registration, after the scoring block (the scorer's var-head
   `($fn $exp $i)` dispatch finds fitness clauses loaded at any later
   time; bare-head op clauses need no sentinel — the engine
   reduce-dispatches them dynamically). Initial exemplars should be
   `and_seq`-rooted: `getCandidate`'s decode branch keys off the root
   symbol via `isActionOperator`.
