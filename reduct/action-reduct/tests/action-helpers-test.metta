!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)

;; ============================================================================
;; getActionResult tribool oracle
;; ============================================================================

;; Terminal constants
!(assertEqual (getActionResult action_success) True)
!(assertEqual (getActionResult action_failure) False)

;; exec_seq always succeeds statically
!(assertEqual (getActionResult (exec_seq)) True)

;; Primitive action dispatch via alwaysSucceeds
!(assertEqual (getActionResult move_forward) Unknown)
!(assertEqual (getActionResult step_forward) Unknown)
!(assertEqual (getActionResult turn_left) True)

;; action_while always fails statically
!(assertEqual (getActionResult (action_while action_success)) False)

;; action_not inverts known results, passes through Unknown
!(assertEqual (getActionResult (action_not action_success)) False)
!(assertEqual (getActionResult (action_not action_failure)) True)
!(assertEqual (getActionResult (action_not move_forward)) Unknown)

;; and_seq: needs all children statically True
!(assertEqual (getActionResult (and_seq action_success move_forward)) Unknown)
!(assertEqual (getActionResult (and_seq action_success action_failure)) False)

;; or_seq: succeeds at first statically True child
!(assertEqual (getActionResult (or_seq action_failure action_success)) True)
!(assertEqual (getActionResult (or_seq action_failure move_forward)) Unknown)
!(assertEqual (getActionResult (or_seq action_failure action_failure)) False)

;; Other operators: not statically reduced → Unknown
!(assertEqual (getActionResult (bool_while (near stick tree) step_forward)) Unknown)
!(assertEqual (getActionResult (bool_action_if move_forward A B)) Unknown)
!(assertEqual (getActionResult (contin_action_if move_forward A B)) Unknown)
!(assertEqual (getActionResult (and_seq (goto_obj stick))) Unknown)
!(assertEqual (getActionResult (action_action_if (goto_obj stick) step_forward turn_left)) Unknown)
!(assertEqual (getActionResult (or_seq (goto_obj stick) step_forward)) Unknown)

;; ============================================================================
;; flattenAssoc: flatten nested associative operators at the argument-list level
;; ============================================================================
!(assertEqual (flattenAssoc and_seq (A (and_seq B C) D)) (A B C D))
!(assertEqual (flattenAssoc or_seq (A (or_seq B C) D)) (A B C D))
!(assertEqual (flattenAssoc exec_seq (A (exec_seq B C) D)) (A B C D))
!(assertEqual (flattenAssoc and_seq (A (and_seq B (and_seq C D)))) (A B C D))

;; ============================================================================
;; pruneAndSeqArgs: remove action_success, truncate at action_failure
;; ============================================================================
!(assertEqual (pruneAndSeqArgs ()) ())
!(assertEqual (pruneAndSeqArgs (action_success)) ())
!(assertEqual (pruneAndSeqArgs (action_failure)) (action_failure))
!(assertEqual (pruneAndSeqArgs (action_success A action_failure B)) (A action_failure))
!(assertEqual (pruneAndSeqArgs (A action_success B)) (A B))

;; ============================================================================
;; pruneOrSeqArgs: remove action_failure, truncate at action_success
;; ============================================================================
!(assertEqual (pruneOrSeqArgs ()) ())
!(assertEqual (pruneOrSeqArgs (action_failure)) ())
!(assertEqual (pruneOrSeqArgs (action_success)) (action_success))
!(assertEqual (pruneOrSeqArgs (action_failure A action_success B)) (A action_success))
!(assertEqual (pruneOrSeqArgs (A action_failure B)) (A B))

;; ============================================================================
;; pruneExecSeqArgs: remove both action_success and action_failure
;; ============================================================================
!(assertEqual (pruneExecSeqArgs ()) ())
!(assertEqual (pruneExecSeqArgs (action_success)) ())
!(assertEqual (pruneExecSeqArgs (action_failure)) ())
!(assertEqual (pruneExecSeqArgs (action_success A action_failure B)) (A B))
!(assertEqual (pruneExecSeqArgs (A action_success B action_failure C)) (A B C))

;; ============================================================================
;; truncateAtAlwaysFails: keep args up to and including first statically False
;; ============================================================================
!(assertEqual (truncateAtAlwaysFails ()) ())
!(assertEqual (truncateAtAlwaysFails (turn_left move_forward action_failure B)) (turn_left move_forward action_failure))

;; ============================================================================
;; truncateAtAlwaysSucceeds: keep args up to and including first statically True
;; ============================================================================
!(assertEqual (truncateAtAlwaysSucceeds ()) ())
!(assertEqual (truncateAtAlwaysSucceeds (move_forward turn_left B)) (move_forward turn_left))
!(assertEqual (truncateAtAlwaysSucceeds (action_failure action_failure turn_left B)) (action_failure action_failure turn_left))

;; ============================================================================
;; smallestDivisor: smallest divisor > 1 (primes return themselves)
;; ============================================================================
!(assertEqual (smallestDivisor 2) 2)
!(assertEqual (smallestDivisor 3) 3)
!(assertEqual (smallestDivisor 4) 2)
!(assertEqual (smallestDivisor 9) 3)
!(assertEqual (smallestDivisor 15) 3)
!(assertEqual (smallestDivisor 17) 17)

;; ============================================================================
;; substituteCondInitInstant: condition substitution limited to initial instant
;; ============================================================================

;; Direct match
!(assertEqual (substituteCondInitInstant X X Y) Y)
;; Non-match passthrough
!(assertEqual (substituteCondInitInstant X Y Z) X)

;; and_seq: substitute only in first child
!(assertEqual (substituteCondInitInstant (and_seq X A) X Y) (and_seq Y A))
!(assertEqual (substituteCondInitInstant (and_seq A X) X Y) (and_seq A X))

;; or_seq: substitute only in first child
!(assertEqual (substituteCondInitInstant (or_seq X A) X Y) (or_seq Y A))

;; exec_seq: substitute only in first child
!(assertEqual (substituteCondInitInstant (exec_seq X A) X Y) (exec_seq Y A))

;; action_bool_if: substitute in condition and both branches
!(assertEqual (substituteCondInitInstant (action_bool_if X A B) X Y) (action_bool_if Y A B))

;; action_action_if: substitute in condition only, NOT in branches
!(assertEqual (substituteCondInitInstant (action_action_if X X X) X Y) (action_action_if Y X X))

;; Verify the difference between action_bool_if and action_action_if branch handling
!(assertEqual (substituteCondInitInstant (action_bool_if X X X) X Y) (action_bool_if Y Y Y))
