;; ---------------------------------------------------------------------------
;; IF-reductions based on constant conditions
;; ---------------------------------------------------------------------------

(= (isActionResultIfOp $op)
   (is-member $op (action_action_if bool_action_if contin_action_if)))

;; reduceActionIf: constant-condition and identical-branch folding for
;; action_bool_if (the action analogue of a boolean if-then-else).
;;
;; Three patterns are reduced (C++ reduce_action_if):
;;
;;   action_bool_if(True  A B) -> A       ; condition statically true: take then-branch
;;   action_bool_if(False A B) -> B       ; condition statically false: take else-branch
;;   action_bool_if(C     A A) -> A       ; both branches equal: condition is irrelevant

(= (reduceActionIf $expr)
   (unify $expr (action_bool_if $cond $thenBranch $elseBranch)
     (if (== $cond True)
         $thenBranch
         (if (== $cond False)
             $elseBranch
             (if (== $thenBranch $elseBranch) $thenBranch $expr)))
     $expr))
;; reduceConstCondActionIf (C++ reduce_const_cond_action_if, Rule 3):
;; Folds X_action_if expressions whose condition is a *constant action result*.
;; Applies to action_action_if, bool_action_if, and contin_action_if (all three
;; share a condition of type action_result):
;;
;;   T_action_if(action_failure A B) -> B   ; condition always failed: take else-branch
;;   T_action_if(action_success  A B) -> A   ; condition always succeeded: take then-branch
;;
;; T in {action, bool, contin} — the output type of the conditional (not the condition).

(= (reduceConstCondActionIf $expr)
   (unify $expr ($ifOp action_failure $thenBranch $elseBranch)
     (if (isActionResultIfOp $ifOp) $elseBranch $expr)
      (unify $expr ($ifOp action_success $thenBranch $elseBranch)
         (if (isActionResultIfOp $ifOp) $thenBranch $expr)
         $expr)))

;; reduceNotCondActionBoolIf (C++ reduce_not_cond_action_boolean_if):
;; Normalises the condition of action_bool_if by pushing a leading NOT inside:
;;
;;   action_bool_if(NOT(A) B C) -> action_bool_if(A C B)
;;
;; Swapping the branches and removing the NOT produces the same semantics with
;; a simpler (canonical) condition node. This is the action analogue of the
;; logical rule that eliminates double-negation from if-conditions.
;;
;; NOTE: This standalone C++ action_rules mirror is NOT in the C++ default
;; pipeline (action_reduction.cc), which does not include
;; reduce_not_cond_action_boolean_if by default.

(= (reduceNotCondActionBoolIf $expr)
   (unify $expr (action_bool_if (NOT $cond) $thenBranch $elseBranch)
     (action_bool_if $cond $elseBranch $thenBranch)
     $expr))

;; reduceActionBoolIfSubCond (C++ reduce_action_boolean_if_sub_cond):
;; Inside the branches of action_bool_if(C A1 A2), any occurrence of C that
;; executes at the *same instant* as the if-condition can be replaced by its
;; known value (True in the then-branch, False in the else-branch), since the
;; guard has already been evaluated:
;;
;;   action_bool_if(C A1 A2)
;;     -> action_bool_if(C  A1[C -> True]  A2[C -> False])
;;
;; "Same instant" means before any action in A1 or A2 that has a side effect
;; that could change C. substituteCondInitInstant propagates the substitution
;; only into the first-action position of each sequencing node.
;;
;; NOTE: This standalone C++ action_rules mirror is not wired into the default
;; action_reduction.cc pipeline.

(= (reduceActionBoolIfSubCond $expr)
   (unify $expr (action_bool_if $cond $thenBranch $elseBranch)
     (action_bool_if $cond
                     (substituteCondInitInstant $thenBranch $cond True)
                     (substituteCondInitInstant $elseBranch $cond False))
     $expr))
