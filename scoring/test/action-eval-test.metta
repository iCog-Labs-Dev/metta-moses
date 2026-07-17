!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)
!(import! &self ../action-registry)
!(import! &self ../action-eval)
!(import! &self ../action-ops)

;; Generic action evaluator test. A synthetic counter world is defined HERE,
;; after the engine loaded -- proving domain primitives plug in as late
;; bare-head operator clauses without any engine edit (the engine's `reduce`
;; dispatch finds clauses loaded at any later time, no sentinel needed).
;;
;; Quote rule (scoring/action-ops.metta header): the operator names below are
;; live clause heads, so every hand-written wrapped-shape literal passed in an
;; evaluated position is quote-protected -- quote strips on evaluation, so
;; evalAction receives the raw expression.
;;
;; World: (mkCntWorld $n). cntInc succeeds and bumps the counter (the counter
;; is the witness for evaluation order/laziness); cntFail fails and leaves it;
;; cntBelow3 is a perception: truth = counter < 3, world untouched.
(= (cntInc $children (mkCntWorld $n)) (mkARes True (mkCntWorld (+ $n 1))))
(= (cntFail $children (mkCntWorld $n)) (mkARes False (mkCntWorld $n)))
(= (cntBelow3 $children (mkCntWorld $n)) (mkARes (< $n 3) (mkCntWorld $n)))

;; ---- 1. Leaf dispatch ----
!(assertEqual (evalAction (quote (cntInc ())) (mkCntWorld 0)) (mkARes True (mkCntWorld 1)))
;; bare-symbol leaf is normalized to a childless node
!(assertEqual (evalAction cntInc (mkCntWorld 0)) (mkARes True (mkCntWorld 1)))
!(assertEqual (evalAction (quote (cntFail ())) (mkCntWorld 4)) (mkARes False (mkCntWorld 4)))
!(assertEqual (evalAction (quote (cntBelow3 ())) (mkCntWorld 2)) (mkARes True (mkCntWorld 2)))
!(assertEqual (evalAction (quote (cntBelow3 ())) (mkCntWorld 3)) (mkARes False (mkCntWorld 3)))

;; ---- 2. Unknown operator / malformed shape -> defined-worst ----
!(assertEqual (evalAction (quote (noSuchOp ())) (mkCntWorld 5)) (mkARes False (mkCntWorld 5)))
!(assertEqual (evalAction noSuchOp (mkCntWorld 5)) (mkARes False (mkCntWorld 5)))
;; malformed node (size-3 expression, not (op (children)))
!(assertEqual (evalAction (quote (a b c)) (mkCntWorld 5)) (mkARes False (mkCntWorld 5)))
;; wrong child-count for a fixed-arity op matches no clause -> worst
!(assertEqual (evalAction (quote (action_not ())) (mkCntWorld 2)) (mkARes False (mkCntWorld 2)))
;; registered-but-clauseless phase-1 ops fall to the same path
!(assertEqual (evalAction (quote (bool_action_if ((cntBelow3 ()) (cntInc ()) (cntInc ())))) (mkCntWorld 0))
              (mkARes False (mkCntWorld 0)))
;; TOTALITY: a symbol heading clauses at some OTHER arity (actionWhileLoop
;; is an arity-3 engine helper) reduces to a runtime `partial` term, which
;; the in-collapse unification filters to the defined-worst -- the engine
;; yields a result, never zero results
!(assertEqual (evalAction actionWhileLoop (mkCntWorld 5)) (mkARes False (mkCntWorld 5)))
!(assertEqual (evalAction (quote (actionWhileLoop ())) (mkCntWorld 5)) (mkARes False (mkCntWorld 5)))
;; isARes guard itself
!(assertEqual (isARes (mkARes True (mkCntWorld 0))) True)
!(assertEqual (isARes (mkARes True)) False)
!(assertEqual (isARes someSymbol) False)

;; ---- 3. Grounded literal leaves ----
!(assertEqual (evalAction True (mkCntWorld 2)) (mkARes True (mkCntWorld 2)))
!(assertEqual (evalAction False (mkCntWorld 2)) (mkARes False (mkCntWorld 2)))

;; ---- 4. and_seq: sequencing + short-circuit OBSERVED THROUGH THE COUNTER ----
;; third child never runs: counter stops at 1
!(assertEqual (evalAction (quote (and_seq ((cntInc ()) (cntFail ()) (cntInc ())))) (mkCntWorld 0))
              (mkARes False (mkCntWorld 1)))
!(assertEqual (evalAction (quote (and_seq ((cntInc ()) (cntInc ()) (cntInc ())))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 3)))
;; empty and_seq -> success, world unchanged
!(assertEqual (evalAction (quote (and_seq ())) (mkCntWorld 7)) (mkARes True (mkCntWorld 7)))

;; ---- 5. or_seq: first success wins, world threads through failures ----
!(assertEqual (evalAction (quote (or_seq ((cntFail ()) (cntInc ()) (cntInc ())))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 1)))
!(assertEqual (evalAction (quote (or_seq ((cntFail ()) (cntFail ())))) (mkCntWorld 2))
              (mkARes False (mkCntWorld 2)))
!(assertEqual (evalAction (quote (or_seq ())) (mkCntWorld 7)) (mkARes False (mkCntWorld 7)))

;; ---- 6. seq_exec runs ALL children, always succeeds ----
!(assertEqual (evalAction (quote (seq_exec ((cntInc ()) (cntFail ()) (cntInc ())))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 2)))
!(assertEqual (evalAction (quote (seq_exec ())) (mkCntWorld 7)) (mkARes True (mkCntWorld 7)))

;; ---- 7. action_bool_if: condition first, exactly ONE branch runs ----
;; counter proves it: taken then-branch increments once, else-branch untouched
!(assertEqual (evalAction (quote (action_bool_if ((cntBelow3 ()) (cntInc ()) (cntFail ())))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 1)))
!(assertEqual (evalAction (quote (action_bool_if ((cntBelow3 ()) (cntInc ()) (cntFail ())))) (mkCntWorld 5))
              (mkARes False (mkCntWorld 5)))

;; ---- 8. action_not / constants / return_success ----
!(assertEqual (evalAction (quote (action_not ((cntFail ())))) (mkCntWorld 5)) (mkARes True (mkCntWorld 5)))
!(assertEqual (evalAction (quote (action_not ((cntInc ())))) (mkCntWorld 0)) (mkARes False (mkCntWorld 1)))
!(assertEqual (evalAction (quote (action_success ())) (mkCntWorld 3)) (mkARes True (mkCntWorld 3)))
!(assertEqual (evalAction (quote (action_failure ())) (mkCntWorld 3)) (mkARes False (mkCntWorld 3)))
!(assertEqual (evalAction action_success (mkCntWorld 3)) (mkARes True (mkCntWorld 3)))
;; return_success: child's status discarded, its world kept
!(assertEqual (evalAction (quote (return_success ((cntFail ())))) (mkCntWorld 2)) (mkARes True (mkCntWorld 2)))
!(assertEqual (evalAction (quote (return_success ((cntInc ())))) (mkCntWorld 2)) (mkARes True (mkCntWorld 3)))

;; ---- 9. action_while: loop while child succeeds; fuel-capped ----
;; child succeeds while counter<3 then fails: terminates at 3
!(assertEqual (evalAction (quote (action_while ((action_bool_if ((cntBelow3 ()) (cntInc ()) (cntFail ()))))))
                          (mkCntWorld 0))
              (mkARes True (mkCntWorld 3)))
;; always-succeeding child: the fuel cap (25) stops the loop
!(assertEqual (evalAction (quote (action_while ((cntInc ())))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 25)))

;; ---- bool_while: cond then body, loop on body's world; fuel-capped ----
!(assertEqual (evalAction (quote (bool_while ((cntBelow3 ()) (cntInc ())))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 3)))
;; body failure does not stop the loop; fuel does (world never changes here)
!(assertEqual (evalAction (quote (bool_while ((cntBelow3 ()) (cntFail ())))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 0)))
;; ALWAYS-TRUE condition: only the fuel cap (25) stops the loop; the body
;; runs once per fueled iteration, so the counter lands exactly on the cap
!(assertEqual (evalAction (quote (bool_while ((action_success ()) (cntInc ())))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 25)))

;; ---- 10. repeat_n: raw grounded count child ----
!(assertEqual (evalAction (quote (repeat_n (4 (cntInc ())))) (mkCntWorld 0)) (mkARes True (mkCntWorld 4)))
!(assertEqual (evalAction (quote (repeat_n (0 (cntInc ())))) (mkCntWorld 2)) (mkARes True (mkCntWorld 2)))
;; non-number count -> defined-worst
!(assertEqual (evalAction (quote (repeat_n (banana (cntInc ())))) (mkCntWorld 2)) (mkARes False (mkCntWorld 2)))

;; ---- 11. actionExp: Tree -> wrapped executable shape ----
;; symbol leaf becomes a childless node (unlike boolean leaves, which stay
;; bare labels: action leaves are ops, not table columns)
!(let $exp (quote (cntInc ()))
   (assertEqual (actionExp (mkTree (mkNode cntInc) ())) $exp))
;; grounded leaf stays bare (repeat_n's count rides through like this)
!(assertEqual (actionExp (mkTree (mkNode 4) ())) 4)
!(assertEqual (actionExp (mkTree (mkNode True) ())) True)
;; mkKnob/mkNullVex passthroughs mirror preOrderExp
!(assertEqual (actionExp (mkKnob (mkNullVex (mkTree (mkNode cntInc) ())) $lsk 0)) ())
!(let $exp (quote (cntInc ()))
   (assertEqual (actionExp (mkKnob (mkTree (mkNode cntInc) ()) $lsk 0)) $exp))
;; interior node over cons-list children
!(let $exp (quote (and_seq ((cntInc ()) (cntFail ()))))
   (assertEqual (actionExp (mkTree (mkNode and_seq)
                                   (cons (mkTree (mkNode cntInc) ())
                                         (cons (mkTree (mkNode cntFail) ()) ()))))
                $exp))
;; null-vertex knob children are dropped from the wrapped shape
!(let $exp (quote (and_seq ((cntInc ()))))
   (assertEqual (actionExp (mkTree (mkNode and_seq)
                                   (cons (mkKnob (mkNullVex (mkTree (mkNode cntFail) ())) $lsk 0)
                                         (cons (mkTree (mkNode cntInc) ()) ()))))
                $exp))
;; via buildTree (candidate syntax -> Tree -> wrapped shape); the candidate
;; literal is quote-protected too (arity-3 tuple headed by the live
;; action_bool_if clause), buildTree receives it raw
!(let $exp (quote (action_bool_if ((cntBelow3 ()) (cntInc ()) (cntFail ()))))
   (assertEqual (actionExp (buildTree (quote (action_bool_if cntBelow3 cntInc cntFail)))) $exp))

;; ---- 12. End-to-end: candidate -> buildTree -> actionExp -> evalAction ----
!(assertEqual (evalAction (actionExp (buildTree (quote (action_bool_if cntBelow3 cntInc cntFail)))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 1)))
!(assertEqual (evalAction (actionExp (buildTree (quote (action_bool_if cntBelow3 cntInc cntFail)))) (mkCntWorld 5))
              (mkARes False (mkCntWorld 5)))
!(assertEqual (evalAction (actionExp (buildTree (quote (and_seq cntInc (action_bool_if cntBelow3 cntInc cntFail)))))
                          (mkCntWorld 0))
              (mkARes True (mkCntWorld 2)))
!(assertEqual (evalAction (actionExp (buildTree (quote (repeat_n 4 cntInc)))) (mkCntWorld 0))
              (mkARes True (mkCntWorld 4)))

;; ---- 13. Registry ----
!(assertEqual (isRegisteredActionOperator and_seq) True)
!(assertEqual (isRegisteredActionOperator repeat_n) True)
!(assertEqual (isRegisteredActionOperator cntInc) False)
!(assertEqual (isRegisteredCleanupActionOp seq_exec) True)
!(assertEqual (isRegisteredCleanupActionOp action_not) False)
;; registerActionOperator adds a structural op
!(registerActionOperator myNewOp)
!(assertEqual (isRegisteredActionOperator myNewOp) True)
;; registration is idempotent (import! does not dedupe): registering an
;; already-registered structural op again leaves exactly ONE atom
!(registerActionOperator myNewOp)
!(assertEqual (collapse (match &actionRegistry (structuralActionOp myNewOp) myNewOp)) (myNewOp))
;; M0 registry slimming: the per-primitive registration API
;; (registerDomainAction / registerDomainPerception, the
;; registeredDomainActions / registeredDomainPerceptions listers,
;; isRegisteredDomainAction / isRegisteredDomainPerception, and
;; resetActionDomain) was DELETED -- per-domain vocabularies now live only
;; in the domain's config clauses (actionDomainActions /
;; actionDomainPerceptions, quoted tuples read via configListSafe in
;; scoring/action-score.metta). The assertions that exercised that API were
;; removed with it; structural-op membership is unaffected:
!(assertEqual (isRegisteredActionOperator and_seq) True)
;; action-domain NAME registration (CLI routing) survives the slimming
!(assertEqual (isRegisteredActionDomain ttt) False)
!(registerActionDomain ttt)
!(assertEqual (isRegisteredActionDomain ttt) True)
;; ...and is idempotent too: re-registering leaves exactly ONE atom
!(registerActionDomain ttt)
!(assertEqual (collapse (match &actionDomains (actionDomain ttt) ttt)) (ttt))
