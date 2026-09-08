;; ---------------------------------------------------------------------------
;; Constant pruning and empty argument sequence reductions
;; ---------------------------------------------------------------------------
;;
;; These two rules clean up action sequences whose result is statically
;; determined by the presence of constant terminals (action_success /
;; action_failure) among the children.

;; reduceEmptyArgSeq (C++ reduce_empty_arg_seq):
;; Replaces a sequencing operator that has been left with no children with its
;; identity/absorbing constant:
;;
;;   and_seq()  -> action_success   ; vacuously succeeds (identity of and_seq)
;;   or_seq()   -> action_failure   ; vacuously fails   (identity of or_seq)
;;   exec_seq() -> action_success   ; vacuously succeeds (identity of exec_seq)
;;
;; Triggered after constant-pruning (reduceConstActionSeq) may have removed all
;; children from a sequence, or when the combiner was constructed empty.

(= (reduceEmptyArgSeq $expr)
   (unify $expr (and_seq) action_success
     (unify $expr (or_seq) action_failure
       (unify $expr (exec_seq) action_success $expr))))

;; reduceConstActionSeq (C++ reduce_const_action_seq):
;; Propagates constant action results through sequential combiners by
;; removing children whose inclusion cannot affect the observable outcome.
;;
;; and_seq (stop-on-failure sequential AND):
;;   - Drops any action_success children (they are transparent to and_seq).
;;   - Truncates at the first action_failure, keeping it but dropping everything
;;     after, because they can never be reached.
;;   - If only action_failure remains: collapses to action_failure.
;;
;; or_seq (stop-on-success sequential OR):
;;   - Drops any action_failure children (they are transparent to or_seq).
;;   - Truncates at the first action_success, keeping it but dropping everything
;;     after, because they can never be reached.
;;   - If only action_success remains: collapses to action_success.
;;
;; exec_seq (execute-all ignoring results):
;;   - Drops action_success and action_failure constants; their side-effects are
;;     nil and their results are irrelevant inside exec_seq.

(= (reduceConstActionSeq $expr)
   (if (== (get-metatype $expr) Expression)
       (if (== $expr ())
           $expr
           (let ($op $args) (decons $expr)
             (case $op
               ((and_seq (let $pruned (pruneAndSeqArgs $args)
                           (if (== $pruned (action_failure))
                               action_failure
                               (cons-atom and_seq $pruned))))
                (or_seq  (let $pruned (pruneOrSeqArgs $args)
                           (if (== $pruned (action_success))
                               action_success
                               (cons-atom or_seq $pruned))))
                (exec_seq (let $pruned (pruneExecSeqArgs $args)
                            (cons-atom exec_seq $pruned)))
                ($else $expr)))))
       $expr))
