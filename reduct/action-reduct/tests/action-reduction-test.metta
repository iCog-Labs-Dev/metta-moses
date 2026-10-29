;; ---------------------------------------------------------------------------
;; Integration Tests for Action Reduction Dispatcher
;; ---------------------------------------------------------------------------

!(import! &self ../../../utilities/general-helpers)
!(import! &self ../../../utilities/tree)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../action-properties)
!(import! &self ../reduce-action-if)
!(import! &self ../reduce-action-action-if)
!(import! &self ../reduce-const-action-seq)
!(import! &self ../reduce-action-not)
!(import! &self ../reduce-action-while)
!(import! &self ../reduce-seq-result)
!(import! &self ../reduce-null-vertices)
!(import! &self ../reduce-action-properties)
!(import! &self ../action-reduction)

;; --- 1. applyActionRuleDownwards (downward rule pass) ---
!(assertEqual
  (applyActionRuleDownwards levelNode (and_seq A (and_seq B C) (or_seq D (or_seq E F)) (exec_seq G (exec_seq H I))))
  (and_seq A B C (or_seq D E F) (exec_seq G H I)))

;; --- 2. Integration: fixed-point reduction via actionReduce ---
!(assertEqual (actionReduce (and_seq action_success A action_failure B)) (and_seq A action_failure))
!(assertEqual (actionReduce (action_bool_if True (and_seq) X)) action_success)
!(assertEqual (applyDefaultRulesPass (and_seq action_success A action_failure B)) (and_seq A action_failure))
!(assertEqual
  (applyActionRuleDownwards reduceActionIf (and_seq (action_bool_if True A B) (action_bool_if False C D)))
  (and_seq A D))
!(assertEqual (preconditionsCheck (and_seq A B)) (and_seq A B))
!(assertEqual
  (actionReduce (or_seq action_failure move_forward B))
  (or_seq move_forward B))

;; --- 3. Public reducer does not apply standalone-only rules ---
!(assertEqual
  (actionReduce (action_bool_if (NOT (near stick tree)) A B))
  (action_bool_if (NOT (near stick tree)) A B))

!(assertEqual
  (actionReduce (action_action_if turn_left (goto_obj stick) move_forward))
  (action_action_if turn_left (goto_obj stick) move_forward))

;; --- 4. Integration: property-based reductions via actionReduce ---
!(assertEqual
  (actionReduce (exec_seq turn_left turn_right))
  action_success)

!(assertEqual
  (actionReduce (and_seq turn_left turn_right))
  (and_seq turn_left turn_right))

;; --- 5. Tree cleanup integration ---
!(assertEqual
  (preOrder (cleanActionTree (buildTree (exec_seq turn_left turn_right))))
  action_success)

!(assertEqual
  (preOrder (cleanActionTree (buildTree (and_seq))))
  action_success)

!(assertEqual
  (preOrder (cleanActionTree (buildTree (or_seq))))
  action_failure)

!(assertEqual
  (preOrder (cleanActionTree (buildTree (exec_seq))))
  action_success)

;; ---------------------------------------------------------------------------
;; The same reducer with the action evaluator loaded
;; ---------------------------------------------------------------------------
;; scoring/action-ops defines and_seq, or_seq, seq_exec, action_not, action_bool_if,
;; action_while, action_success and action_failure as evaluation clauses, and
;; moses.metta loads it after the reducer. In that context an action term that is
;; evaluated runs as an action: a 2-child and_seq becomes an mkARes result, and any
;; other arity becomes a partial call that the next step drops. The reducer must keep
;; every term it builds or returns as data. The expected values are the reducer's
;; results without the evaluator loaded.
;;
;; The cases above are compiled before these imports, so their bare action terms are
;; data. The cases below are compiled after them, so their inputs and expected values
;; are quoted: a bare action term here would itself be evaluated.

!(import! &self ../../../scoring/action-registry)
!(import! &self ../../../scoring/action-eval)
!(import! &self ../../../scoring/action-ops)

;; Default pipeline (actionReduce) and the production entry point (cleanActionTree).
!(assertEqual (actionReduce (quote (and_seq move_forward turn_left)))
              (quote (and_seq move_forward turn_left)))
!(assertEqual (actionReduce (quote (or_seq move_forward turn_left)))
              (quote (or_seq move_forward turn_left)))
!(assertEqual (actionReduce (quote (seq_exec move_forward turn_left)))
              (quote (seq_exec move_forward turn_left)))
!(assertEqual (actionReduce (quote (and_seq move_forward turn_left turn_right)))
              (quote (and_seq move_forward turn_left turn_right)))
!(assertEqual (actionReduce (quote (action_bool_if canwin move_forward turn_left)))
              (quote (action_bool_if canwin move_forward turn_left)))
!(assertEqual (actionReduce (quote (and_seq action_success move_forward action_failure turn_left)))
              (quote (and_seq move_forward action_failure)))
!(assertEqual (actionReduce (quote (action_while (and_seq move_forward move_forward move_forward))))
              (quote (action_while move_forward)))
!(assertEqual (actionReduce (quote (action_while move_forward)))
              (quote (action_while move_forward)))
!(assertEqual (actionReduce (quote (action_action_if canwin move_forward move_forward)))
              (quote (and_seq (exec_seq canwin) move_forward)))
!(assertEqual (actionReduce (quote (and_seq move_forward (action_while move_forward))))
              (quote (and_seq (action_while move_forward))))
!(assertEqual (cleanActionTree (actionExpressionToTree (quote (and_seq move_forward turn_left))))
              (quote (mkTree (mkNode and_seq) ((mkTree (mkNode move_forward) ()) (mkTree (mkNode turn_left) ())))))
!(assertEqual (actionReduce (quote (action_bool_if True move_forward turn_left)))
              move_forward)
!(assertEqual (actionReduce (quote (action_bool_if False move_forward turn_left)))
              turn_left)
!(assertEqual (actionReduce (quote (action_bool_if canwin move_forward move_forward)))
              move_forward)
!(assertEqual (actionReduce (quote (action_action_if action_success move_forward turn_left)))
              move_forward)
!(assertEqual (actionReduce (quote (action_action_if action_failure move_forward turn_left)))
              turn_left)
!(assertEqual (actionReduce (quote (action_bool_if True (and_seq move_forward turn_left) turn_right)))
              (quote (and_seq move_forward turn_left)))
!(assertEqual (actionReduce (quote (and_seq action_success move_forward)))
              (quote (and_seq move_forward)))

;; Rules and helpers outside the default pipeline, called directly.
!(assertEqual (reduceDoubleActionNot (quote (action_not (action_not (and_seq move_forward turn_left)))))
              (quote (and_seq move_forward turn_left)))
!(assertEqual (reduceNotCondActionBoolIf (quote (action_bool_if (NOT canwin) move_forward turn_left)))
              (quote (action_bool_if canwin turn_left move_forward)))
!(assertEqual (reduceBoolWhileDependCond (quote (bool_while True (and_seq move_forward turn_left))))
              (quote (and_seq move_forward turn_left)))
!(assertEqual (reduceBoolWhileDependCond (quote (bool_while False (and_seq move_forward turn_left))))
              action_success)
!(assertEqual (reduceActionWhileAlwaysFails (quote (action_while action_failure)))
              action_failure)
!(assertEqual (reduceActionWhileAlwaysFails (quote (action_while (and_seq move_forward turn_left))))
              (quote (action_while (and_seq move_forward turn_left))))
!(assertEqual (reduceActionActionIf (quote (action_action_if action_success move_forward turn_left)))
              (quote (and_seq action_success move_forward)))
!(assertEqual (reduceActionActionIf (quote (action_action_if action_failure move_forward turn_left)))
              (quote (exec_seq action_failure turn_left)))
!(assertEqual (reduceActionActionIf (quote (action_action_if canwin move_forward turn_left)))
              (quote (action_action_if canwin move_forward turn_left)))
!(assertEqual (reduceActionBoolIfSubCond (quote (action_bool_if canwin (and_seq move_forward turn_left) turn_left)))
              (quote (action_bool_if canwin (and_seq move_forward turn_left) turn_left)))
!(assertEqual (reduceBoolWhileSubCond (quote (bool_while canwin (and_seq move_forward turn_left))))
              (quote (bool_while canwin (and_seq move_forward turn_left))))
!(assertEqual (reduceEmptyArgSeq (quote (and_seq)))
              action_success)
!(assertEqual (reduceRepeatOutActionWhile (quote (and_seq move_forward turn_left (action_while (and_seq move_forward turn_left)))))
              (quote (and_seq (action_while (and_seq move_forward turn_left)))))
!(assertEqual (substituteCondInitInstant (quote (and_seq canwin move_forward)) canwin True)
              (quote (and_seq true move_forward)))
!(assertEqual (substituteCondInitInstant (quote (action_bool_if canwin (and_seq canwin move_forward) turn_left)) canwin True)
              (quote (action_bool_if true (and_seq true move_forward) turn_left)))
!(assertEqual (substituteCondInitInstant (quote (and_seq)) canwin True)
              (quote (and_seq)))
