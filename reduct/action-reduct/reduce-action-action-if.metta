;; ---------------------------------------------------------------------------
;; action_action_if structural and result-based reductions
;; ---------------------------------------------------------------------------
;;
;; action_action_if(A B C) is an action-conditional: it runs A, and if A
;; succeeds, runs B; if A fails, runs C. Unlike action_bool_if, the condition
;; is itself an action, so its *execution* is always part of the outcome.

;; reduceActionActionIfSameBranch (C++ reduce_action_action_if):
;; When both branches are identical, the choice between them doesn't matter,
;; but the condition A *must still be executed* because it may have side effects.
;; The semantics are preserved by discarding the if-wrapper and running A for
;; its side-effects, then unconditionally running the common branch B:
;;
;;   action_action_if(A B B) -> and_seq(exec_seq(A) B)
;;
;; exec_seq wraps A so that A's success/failure does not short-circuit the and_seq;
;; B is always reached regardless of A's result.

(= (reduceActionActionIfSameBranch $expr)
    (unify $expr (action_action_if $cond $br $br) (and_seq (exec_seq $cond) $br) $expr))

;; reduceActionActionIf:
;; First tries the same-branch rule above. If that does not fire, checks the
;; static result of the condition A via getActionResult:
;;
;;   action_action_if(A B C)  when getActionResult(A) == True
;;     -> and_seq(A B)           ; A always succeeds: result is B, C unreachable
;;                               ; (C++ reduce_action_action_if_always_succeeds)
;;
;;   action_action_if(A B C)  when getActionResult(A) == False
;;     -> exec_seq(A C)          ; A always fails: result is C, B unreachable
;;                               ; (C++ reduce_action_action_if_always_fails)
;;
;; When getActionResult returns Unknown the expression is left unchanged.

(= (reduceActionActionIf $expr)
   (let $sameBranch (reduceActionActionIfSameBranch $expr)
     (if (!= $expr $sameBranch)
         $sameBranch
         (unify $expr (action_action_if $cond $br1 $br2)
            (let $r (getActionResult $cond)
                (if (== $r True)
                    (and_seq $cond $br1)
                    (if (== $r False)
                        (exec_seq $cond $br2)
                        $expr)))
            $expr))))
