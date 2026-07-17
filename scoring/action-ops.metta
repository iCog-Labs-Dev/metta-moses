;; Structural action-operator semantics -- the action analog of
;; scoring/boolean-ops (AND/OR/NOT). These clauses are the SINGLE source of
;; structural action-operator semantics: adding an operator = adding ONE
;; bare-head clause here (plus registerActionOperator if the knob builder
;; should offer it); the evaluator (scoring/action-eval) is never touched.
;; The contract: one clause per operator, shaped
;;     (= (<op> $children $world) (mkARes Bool World'))
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

;; and_seq: children left->right, each against the world produced by the
;; previous child; first failure stops (its world is kept); empty -> success.
(= (and_seq $children $world) (seqAll $children $world))
(= (seqAll $children $world)
   (if (== (get-metatype $children) Expression)
       (if (== $children ())
           (mkARes True $world)
           (let* ((($child $rest) (decons-atom $children))
                  ((mkARes $v $w) (evalAction $child $world)))
             (if (== $v True)
                 (seqAll $rest $w)
                 (mkARes False $w))))
       (mkARes False $world)))   ;; malformed children (not a tuple) -> worst

;; or_seq: first success wins (its world is kept); the world threads through
;; failed children; empty -> failure.
(= (or_seq $children $world) (seqAny $children $world))
(= (seqAny $children $world)
   (if (== (get-metatype $children) Expression)
       (if (== $children ())
           (mkARes False $world)
           (let* ((($child $rest) (decons-atom $children))
                  ((mkARes $v $w) (evalAction $child $world)))
             (if (== $v True)
                 (mkARes True $w)
                 (seqAny $rest $w))))
       (mkARes False $world)))

;; seq_exec: run ALL children regardless of status, thread the world,
;; always succeed with the final world.
(= (seq_exec $children $world) (seqRun $children $world))
(= (seqRun $children $world)
   (if (== (get-metatype $children) Expression)
       (if (== $children ())
           (mkARes True $world)
           (let* ((($child $rest) (decons-atom $children))
                  ((mkARes $v $w) (evalAction $child $world)))
             (seqRun $rest $w)))
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
;; failure -> (mkARes True $lastWorld).
(= (action_while ($x) $world)
   (actionWhileLoop $x $world (actionWhileCap)))
(= (actionWhileLoop $x $world $fuel)
   (if (== $fuel 0)
       (mkARes True $world)
       (let (mkARes $v $w) (evalAction $x $world)
            (if (== $v True)
                (actionWhileLoop $x $w (- $fuel 1))
                (mkARes True $w)))))

;; bool_while: while the condition holds, run the body and loop on the
;; body's world (body status does not stop the loop); same fuel cap;
;; always (mkARes True $w).
(= (bool_while ($cond $body) $world)
   (boolWhileLoop $cond $body $world (actionWhileCap)))
(= (boolWhileLoop $cond $body $world $fuel)
   (if (== $fuel 0)
       (mkARes True $world)
       (let (mkARes $cv $cw) (evalAction $cond $world)
            (if (== $cv True)
                (let (mkARes $bv $bw) (evalAction $body $cw)
                     (boolWhileLoop $cond $body $bw (- $fuel 1)))
                (mkARes True $cw)))))

;; repeat_n: first child is a raw grounded number (read structurally, never
;; evaluated); run the body $n times threading the world, always succeed.
;; Non-number count -> defined-worst.
(= (repeat_n ($n $body) $world)
   (if (== (get-type $n) Number)
       (repeatNRun $body $world $n)
       (mkARes False $world)))
(= (repeatNRun $body $world $n)
   (if (> $n 0)
       (let (mkARes $v $w) (evalAction $body $world)
            (repeatNRun $body $w (- $n 1)))
       (mkARes True $world)))

;; ---- Intentionally clauseless in phase 1 ----
;; bool_action_if / contin_action_if / action_action_if are registered in the
;; registry (knob layer may know them) but have NO operator clause yet:
;; candidates using them fall to the unknown-op worst path and score worst.
;; Adding their semantics later = adding clauses here; the engine is never
;; touched.
