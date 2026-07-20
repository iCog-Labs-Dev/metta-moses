;; Structural action-operator semantics -- the action analog of
;; scoring/boolean-ops (AND/OR/NOT). These clauses are the SINGLE source of
;; structural action-operator semantics: adding an operator = adding ONE
;; bare-head clause here (plus registerActionOperator if the knob builder
;; should offer it); the evaluator (scoring/action-eval) is never touched.
;; The contract: one clause per operator, shaped
;;     (= (<op> $children $world) (mkARes Bool World'))
;; (Combinators here receive child subprograms, hence $children; domain
;; PRIMITIVES receive their parameters in the same slot and name it $params
;; -- see scoring/action-eval.metta's contract header.)
;; dispatched by the engine's `reduce` (evalActionNode) exactly like the
;; boolean clauses at fitness.metta:141-167 -- no sentinel needed.
;;
;; Quote rule (mirrors scoring/boolean-ops.metta:5-8): these clause names
;; double as data constructors. A hand-written wrapped node (op (children))
;; or any matching-arity tuple headed by one of them, placed in an evaluated
;; position of a module loaded after this one, compiles as a CALL (wrong
;; arity curries into an inert `partial` term; a matching shape FIRES the
;; clause) -- quote such data sites.
;;
;; Every clause receives its children UNEVALUATED in wrapped shape and calls
;; evalAction back per child, threading the (opaque) world -- evaluation
;; order and laziness live entirely in these clauses. Wrong child-count for
;; a fixed-arity op matches no clause, so the engine's unknown-op worst path
;; (mkARes False $world) applies -- malformed nodes are penalized, never
;; crash. Loads after scoring/action-eval (evalAction must have clauses when
;; these bodies compile).

;; ---- Sequential combinators (variadic, children as one wrapped tuple) ----
;; and_seq/or_seq (and the fuel-capped loops below) are Haskell's allM/anyM
;; -- Control.Monad.Extra's short-circuit monadic all/any -- instantiated at
;; the action-state monad, which is why allM/anyM live HERE and not in
;; list-methods: the (mkARes Bool World) threading is this file's protocol.

;; allM/anyM: $f : ($x $world) -> (mkARes Bool World'). allM stops at the
;; first False result (its world kept; empty -> True); anyM at the first
;; True (empty -> False). Once terminal, the fold walks the remaining
;; elements as plain data WITHOUT applying $f -- unevaluated children are
;; never run, the laziness contract pinned by the counter-world tests in
;; scoring/test/action-eval-test.
(= (allM $f $world $xs)
   (foldl-atom $xs (mkARes True $world) $acc $x
     (let (mkARes $v $w) $acc
          (if (== $v False) $acc ($f $x $w)))))

(= (anyM $f $world $xs)
   (foldl-atom $xs (mkARes False $world) $acc $x
     (let (mkARes $v $w) $acc
          (if (== $v True) $acc ($f $x $w)))))

;; evalActionStep: fold step for the no-short-circuit seq_exec -- evaluate
;; one child against the accumulator's world; the child's mkARes IS the
;; next accumulator.
(= (evalActionStep $child (mkARes $v $w)) (evalAction $child $w))

;; and_seq: children left->right, each against the world produced by the
;; previous child; first failure stops (its world is kept); empty -> success.
(= (and_seq $children $world)
   (if (== (get-metatype $children) Expression)
       (allM evalAction $world $children)
       (mkARes False $world)))   ;; malformed children (not a tuple) -> worst

;; or_seq: first success wins (its world is kept); the world threads through
;; failed children; empty -> failure.
(= (or_seq $children $world)
   (if (== (get-metatype $children) Expression)
       (anyM evalAction $world $children)
       (mkARes False $world)))

;; seq_exec: run ALL children regardless of status, thread the world,
;; always succeed with the final world.
(= (seq_exec $children $world)
   (if (== (get-metatype $children) Expression)
       (let (mkARes $v $w) (List.foldl evalActionStep (mkARes True $world) $children)
            (mkARes True $w))
       (mkARes False $world)))

;; ---- Conditionals ----

;; action_bool_if: evaluate the condition FIRST, then exactly ONE branch
;; against the condition's output world (the untaken branch never runs).
(= (action_bool_if ($cond $then $else) $world)
   (let (mkARes $cv $cw) (evalAction $cond $world)
        (if (== $cv True)
            (evalAction $then $cw)
            (evalAction $else $cw))))

;; action_not: invert the child's status, keep its world.
(= (action_not ($x) $world)
   (let (mkARes $v $w) (evalAction $x $world)
        (mkARes (not $v) $w)))

;; ---- Constants ----
(= (action_success () $world) (mkARes True $world))
(= (action_failure () $world) (mkARes False $world))

;; return_success: run the child, discard its status, succeed with its world.
(= (return_success ($x) $world)
   (let (mkARes $v $w) (evalAction $x $world)
        (mkARes True $w)))

;; ---- Loops (hard fuel cap: evolved trees must terminate) ----
(= (actionWhileCap) 25)

;; action_while: loop while the child succeeds; cap exhausted or child
;; failure -> (mkARes True $lastWorld). The loop is allM over $fuel copies
;; of the child: first failure stops (skipped copies are never evaluated),
;; then the status is forced to True.
;; actionWhileLoop stays a NAMED arity-3 helper: the totality assertions in
;; scoring/test/action-eval-test dispatch it as a wrong-arity symbol.
(= (action_while ($x) $world)
   (actionWhileLoop $x $world (actionWhileCap)))
(= (actionWhileLoop $x $world $fuel)
   (let (mkARes $v $w)
        (allM evalAction $world (List.repeat $fuel $x))
        (mkARes True $w)))

;; bool_while: while the condition holds, run the body and loop on the
;; body's world (body status does not stop the loop); same fuel cap;
;; always (mkARes True $w). allM over $fuel copies of the ($cond $body)
;; pair; one step = one cond test plus, when it holds, one body run -- a
;; False step result marks "condition failed", stopping the loop with the
;; condition's world.
(= (bool_while ($cond $body) $world)
   (let (mkARes $v $w)
        (allM boolWhileStep $world
              ;; cons-built pair: $cond/$body are live wrapped shapes, a
              ;; bare ($cond $body) literal here would be applied as a call
              (List.repeat (actionWhileCap) (cons $cond ($body))))
        (mkARes True $w)))
(= (boolWhileStep ($cond $body) $world)
   (let (mkARes $cv $cw) (evalAction $cond $world)
        (if (== $cv True)
            (let (mkARes $bv $bw) (evalAction $body $cw)
                 (mkARes True $bw))
            (mkARes False $cw))))

;; repeat_n: first child is a raw grounded number (read structurally, never
;; evaluated); run the body $n times threading the world, always succeed:
;; exactly seq_exec over $n copies of the body. Non-number count ->
;; defined-worst; a negative count is guarded to the empty run (List.repeat
;; would not terminate on it).
(= (repeat_n ($n $body) $world)
   (if (== (get-type $n) Number)
       (if (> $n 0)
           (seq_exec (List.repeat $n $body) $world)
           (mkARes True $world))
       (mkARes False $world)))

;; ---- Intentionally clauseless in phase 1 ----
;; bool_action_if / contin_action_if / action_action_if are registered in the
;; registry (knob layer may know them) but have NO operator clause yet:
;; candidates using them fall to the unknown-op worst path and score worst.
;; Adding their semantics later = adding clauses here; the engine is never
;; touched.
