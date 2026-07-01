;; ---------------------------------------------------------------------------
;; Action Reduction Helpers
;; ---------------------------------------------------------------------------

;; These helpers support the action-reduction rules by answering two kinds of
;; questions:
;;   1. static action-result questions, using the tribool values True, False,
;;      and Unknown;
;;   2. tuple-shaping questions, such as flattening associative sequence nodes
;;      or pruning sequence constants while preserving child order.
;;
;; `alwaysSucceeds` is defined in action-vocab.metta. It marks primitive actions
;; whose success is known independent of runtime world state.

;; ---------------------------------------------------------------------------
;; getActionResult: evaluates the static success status of an action expression.
;; The result is a tribool: True, False, or Unknown. 
;; Important cases:
;; - action_not inverts only known results; Unknown remains Unknown.
;; - and_seq/or_seq delegate to sequence-specific folds below.
;; - exec_seq is statically successful because it does not depend on child
;;   success values in the action-reduction model.
;; - action_action_if can only reduce statically when the condition's action
;;   result is known; otherwise either branch may be taken at runtime.
;; ---------------------------------------------------------------------------

(= (getActionResult $expr)
   (if (== (get-metatype $expr) Expression)
       (if (== $expr ())
           Unknown
           (let ($op $args) (decons $expr)
             (case $op
               ((action_not
                 (let* (($child (car-atom $args))
                        ($r (getActionResult $child)))
                   (if (== $r True)
                       False
                       (if (== $r False) True Unknown))))
                (and_seq (getActionResultAnd $args))
                (or_seq  (getActionResultOr $args))
                (exec_seq True)
                (action_while False)
                (action_action_if
                 (let* (($cond (car-atom $args))
                        ($br1 (car-atom (cdr-atom $args)))
                        ($br2 (car-atom (cdr-atom (cdr-atom $args))))
                        ($cRes (getActionResult $cond)))
                   (if (== $cRes True)
                        (getActionResult $br1)
                        (if (== $cRes False) (getActionResult $br2) Unknown))))
                ($else Unknown)))))
       (case $expr
         ((action_success True)
           (action_failure False)
           ($else (if (alwaysSucceeds $expr) True Unknown))))))

;; getActionResultAnd: and_seq succeeds only when every child is statically
;; True; the first False or Unknown is enough to determine the static result.
(= (getActionResultAnd ()) True)
(= (getActionResultAnd $args)
   (let* ((($h $t) (decons $args))
          ($r (getActionResult $h)))
     (if (== $r True)
         (getActionResultAnd $t)
         $r)))

;; getActionResultOr: or_seq succeeds at the first statically True child.
;; If every child is False, the whole sequence is False. If no child is True
;; but at least one child is Unknown, the sequence remains Unknown.
(= (getActionResultOr $args) (getActionResultOrHelper $args False))

;; `$exists_indeterminate` records whether an earlier child was Unknown while
;; scanning for a True child. That lets the base case distinguish "all False"
;; from "no True, but at least one Unknown".
(= (getActionResultOrHelper () $exists_indeterminate)
   (if $exists_indeterminate Unknown False))
(= (getActionResultOrHelper $args $exists_indeterminate)
   (let* ((($h $t) (decons $args))
          ($r (getActionResult $h)))
     (if (== $r True)
         True
         (getActionResultOrHelper $t (or $exists_indeterminate (== $r Unknown))))))

;; ---------------------------------------------------------------------------
;; List/Tuple Simplification Helpers
;; ---------------------------------------------------------------------------

;; flattenAssoc: flattens nested occurrences of the associative operator $op.
;; For example, `(and_seq A (and_seq B C) D)` becomes `(A B C D)` at the
;; argument-list level; the caller reattaches the operator. This mirrors the C++
;; `level` rule, which splices children of the same associative parent into the
;; current sibling list.
;;
;; The helper recurses into matching child operators before concatenating so
;; deeper nests are flattened in one pass: f(a, f(b, f(c, d))) -> (a b c d).
;; Non-expression children, empty expressions, and expressions with a different
;; operator are preserved exactly in their original position.
(= (flattenAssoc $op $args)
   (if (== $args ())
       ()
       (let* ((($h $t) (decons $args))
              ($flatTail (flattenAssoc $op $t)))
         (if (and (== (get-metatype $h) Expression) (!= $h ()))
             (let ($childOp $childArgs) (decons $h)
               (if (== $childOp $op)
                   (concatTuple (flattenAssoc $op $childArgs) $flatTail)
                   (cons-atom $h $flatTail)))
             (cons-atom $h $flatTail)))))

;; pruneAndSeqArgs: simplify and_seq argument lists.
;; - `action_success` is the identity element for and_seq, so it is dropped.
;; - The first `action_failure` determines the whole and_seq result, so all
;;   later siblings are unreachable and the list is truncated there.
;; - Unknown/domain-dependent actions are kept in order.
(= (pruneAndSeqArgs $args)
   (if (== $args ())
       ()
       (let ($h $t) (decons $args)
         (if (== $h action_failure)
             (cons-atom action_failure ())
             (if (== $h action_success)
                 (pruneAndSeqArgs $t)
                 (cons-atom $h (pruneAndSeqArgs $t)))))))

;; pruneOrSeqArgs: simplify or_seq argument lists.
;; - `action_failure` is the identity element for or_seq, so it is dropped.
;; - The first `action_success` determines the whole or_seq result, so all later
;;   siblings are unreachable and the list is truncated there.
;; - Unknown/domain-dependent actions are kept in order.
(= (pruneOrSeqArgs $args)
   (if (== $args ())
       ()
       (let ($h $t) (decons-atom $args)
         (if (== $h action_success)
             (cons-atom action_success ())
             (if (== $h action_failure)
                 (pruneOrSeqArgs $t)
                 (cons-atom $h (pruneOrSeqArgs $t)))))))

;; pruneExecSeqArgs: simplify exec_seq argument lists.
;; exec_seq runs actions for their effects and does not branch on action result,
;; so both action_success and action_failure are no-op constants here. Other
;; actions are preserved in their original order.
(= (pruneExecSeqArgs $args)
   (if (== $args ())
       ()
       (let ($h $t) (decons-atom $args)
         (if (or (== $h action_success) (== $h action_failure))
             (pruneExecSeqArgs $t)
             (cons-atom $h (pruneExecSeqArgs $t))))))

;; truncateAtAlwaysFails: keep arguments up to and including the first child
;; whose static action result is False. This is useful for reductions where
;; later siblings cannot affect the result once a guaranteed failure appears.
(= (truncateAtAlwaysFails $args)
   (if (== $args ())
       ()
       (let* ((($h $t) (decons-atom $args))
              ($r (getActionResult $h)))
         (if (== $r False)
             (cons-atom $h ())
             (cons-atom $h (truncateAtAlwaysFails $t))))))

;; truncateAtAlwaysSucceeds: keep arguments up to and including the first child
;; whose static action result is True. This is the dual of
;; truncateAtAlwaysFails and supports or_seq-style early-exit reductions.
(= (truncateAtAlwaysSucceeds $args)
   (if (== $args ())
       ()
       (let* ((($h $t) (decons-atom $args))
              ($r (getActionResult $h)))
         (if (== $r True)
             (cons-atom $h ())
             (cons-atom $h (truncateAtAlwaysSucceeds $t))))))

;; ---------------------------------------------------------------------------
;; smallestDivisor: returns the smallest divisor greater than 1.
;; Prime numbers return themselves. The modular-argument reducer uses this for
;; simple factor-style normalization of numeric action parameters.
;; ---------------------------------------------------------------------------
(= (smallestDivisor $n) (smallestDivisorFrom $n 2))

;; Trial division from `$d` upward.
(= (smallestDivisorFrom $n $d)
   (if (>= $d $n)
       $n
       (if (== (% $n $d) 0)
           $d
           (smallestDivisorFrom $n (+ $d 1)))))

;; ---------------------------------------------------------------------------
;; substituteCondInitInstant: replaces occurrences of `$cond` with `$sub` only
;; where the condition is evaluated at the initial instant of an action program.
;;
;; The traversal is deliberately selective:
;; - sequence nodes (`and_seq`, `or_seq`, `exec_seq`) substitute only in the
;;   first child because that child is the only part known to run initially;
;; - action_bool_if substitutes through the condition and both branches because
;;   it is a boolean expression constructor;
;; - action_action_if substitutes only in its action condition, leaving action
;;   branches unchanged because they occur after the condition has executed.
;; ---------------------------------------------------------------------------

(= (substituteSeqInit $expr $op $args $cond $sub)
   (if (== $args ())
       $expr
       (let* ((($h $t) (decons $args))
              ($newH (substituteCondInitInstant $h $cond $sub)))
         (cons-atom $op (cons-atom $newH $t)))))

(= (substituteCondInitInstant $expr $cond $sub)
   (if (== $expr $cond)
       $sub
       (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
           (let ($op $args) (decons $expr)
             (case $op
                ((and_seq (substituteSeqInit $expr and_seq $args $cond $sub))
                 (or_seq (substituteSeqInit $expr or_seq $args $cond $sub))
                 (exec_seq (substituteSeqInit $expr exec_seq $args $cond $sub))
                 (action_bool_if
                  (let* (($c (car-atom $args))
                         ($b1 (car-atom (cdr-atom $args)))
                         ($b2 (car-atom (cdr-atom (cdr-atom $args)))))
                    (action_bool_if (substituteCondInitInstant $c $cond $sub)
                                    (substituteCondInitInstant $b1 $cond $sub)
                                    (substituteCondInitInstant $b2 $cond $sub))))
                 (action_action_if
                  (let* (($c (car-atom $args))
                         ($b1 (car-atom (cdr-atom $args)))
                         ($b2 (car-atom (cdr-atom (cdr-atom $args)))))
                    (action_action_if (substituteCondInitInstant $c $cond $sub)
                                      $b1
                                      $b2)))
                 ($else $expr))))
            $expr)))
