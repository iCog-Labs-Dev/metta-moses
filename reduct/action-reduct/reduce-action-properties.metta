;; ---------------------------------------------------------------------------
;; Domain-specific and property-based action reduction rules
;; ---------------------------------------------------------------------------

;; A builtin action can be a leaf action symbol or an expression whose operator
;; is the action symbol and whose children are action arguments.

(= (actionName $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (car-atom $expr)
       $expr))

(= (actionArgs $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (cdr-atom $expr)
       ()))

(= (makeActionExpr $action $args)
   (if (== $args ())
       $action
       (cons-atom $action $args)))

(= (isActionSeqOp $op)
   (is-member $op (and_seq or_seq exec_seq)))

;; ---------------------------------------------------------------------------
;; reduceIdempotent (C++ reduce_idempotent)
;; ---------------------------------------------------------------------------
;;
;; An idempotent action has no additional effect when immediately repeated:
;; performing it twice in a row is the same as performing it once. The rule
;; collapses any run of adjacent equal idempotent actions to a single copy:
;;
;;   and_seq(... A A ...)  ->  and_seq(... A ...)   when isIdempotent(A)
;;
;; Works inside any action sequence operator (and_seq, or_seq, exec_seq).
;; Whether an action is idempotent is a domain fact declared in
;; action-properties.metta via the isIdempotent predicate.
;;
;; C++ note: the C++ rule operates on adjacent sibling pairs at the tree level,
;; not inside a seq wrapper; it fires when an action node's next sibling is
;; equal and idempotent. The MeTTa port checks this inside sequence arg lists

(= (reduceIdempotentArgs ()) ())
(= (reduceIdempotentArgs $args)
   (let ($h $t) (decons $args)
     (if (== $t ())
         (cons-atom $h ())
         (let* (($next (car-atom $t))
                ($rest (cdr-atom $t)))
           (if (and (== $h $next) (isIdempotent (actionName $h)))
               (reduceIdempotentArgs (cons-atom $h $rest))
               (cons-atom $h (reduceIdempotentArgs $t)))))))

(= (reduceIdempotent $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (isActionSeqOp $op)
             (cons-atom $op (reduceIdempotentArgs $args))
             $expr))
       $expr))

;; ---------------------------------------------------------------------------
;; reduceOpposite (C++ reduce_opposite)
;; ---------------------------------------------------------------------------
;;
;; A reversible action has a *reversal* (an undo action) such that doing A then
;; doing reversal(A) leaves the world state unchanged. Consecutive opposite
;; pairs are net-neutral and can be dropped *only inside exec_seq*, because in
;; exec_seq the result is always action_success and removing actions cannot
;; change the result type. In and_seq or or_seq, the result type of individual
;; actions determines short-circuit behaviour, so cancellation is unsafe there.
;;
;;   exec_seq(... A reversal(A) ...)  ->  exec_seq(... ...)
;;
;; Whether an action is reversible and what its reversal is declared in
;; action-properties.metta via isReversible / getReversal.

(= (areOppositeActions $a $b)
   (let* (($aName (actionName $a))
          ($bName (actionName $b)))
     (and (== (actionArgs $a) ())
          (and (== (actionArgs $b) ())
               (and (isReversible $aName)
                    (== (getReversal $aName) $bName))))))

(= (reduceOppositeArgs ()) ())
(= (reduceOppositeArgs $args)
   (let* ((($h $t) (decons-atom $args)))
     (if (== $t ())
         (cons-atom $h ())
         (let* (($next (car-atom $t))
                ($rest (cdr-atom $t)))
           (if (areOppositeActions $h $next)
               (reduceOppositeArgs $rest)
               (cons-atom $h (reduceOppositeArgs $t)))))))

(= (reduceOpposite $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (== $op exec_seq)
             (cons-atom exec_seq (reduceOppositeArgs $args))
             $expr))
       $expr))

;; ---------------------------------------------------------------------------
;; reduceAdditive (C++ reduce_additive)
;; ---------------------------------------------------------------------------
;;
;; Some actions have *additive* numeric arguments: performing action(x) then
;; action(y) is equivalent to performing action(x+y) in one step (think of
;; `step_forward(1.0)` followed by `step_forward(2.0)` being the same as
;; `step_forward(3.0)`). All non-additive arguments of the two adjacent calls
;; must be identical; additive ones are summed.
;;
;;   and_seq(... action(... x_i ...) action(... y_i ...) ...)
;;     ->  and_seq(... action(... (x_i + y_i) ...) ...)
;;                             for each additive argument index i
;;
;; Whether an argument is additive is declared via isAdditive in
;; action-properties.metta. The merged action retains the same operator and
;; the same values for non-additive arguments.

(= (addActionArgs $a $b)
   (if (and (== (get-type $a) Number) (== (get-type $b) Number))
       (+ $a $b)
       (plus $a $b)))

(= (canMergeAdditiveArgs $action $argsA $argsB $idx $seenAdditive)
   (if (and (== $argsA ()) (== $argsB ()))
       $seenAdditive
       (if (or (== $argsA ()) (== $argsB ()))
           False
           (let* ((($aHead $aTail) (decons-atom $argsA))
                  (($bHead $bTail) (decons-atom $argsB))
                  ($isAdditiveArg (isAdditive $action $idx)))
             (if $isAdditiveArg
                 (canMergeAdditiveArgs $action $aTail $bTail (+ $idx 1) True)
                 (if (== $aHead $bHead)
                     (canMergeAdditiveArgs $action $aTail $bTail (+ $idx 1) $seenAdditive)
                     False))))))

(= (canMergeAdditiveActions $a $b)
   (let* (($action (actionName $a))
          ($argsA (actionArgs $a))
          ($argsB (actionArgs $b)))
     (and (== $action (actionName $b))
          (canMergeAdditiveArgs $action $argsA $argsB 0 False))))

(= (mergeAdditiveArgs $action () () $idx) ())
(= (mergeAdditiveArgs $action $argsA $argsB $idx)
   (let* ((($aHead $aTail) (decons-atom $argsA))
          (($bHead $bTail) (decons-atom $argsB))
          ($mergedTail (mergeAdditiveArgs $action $aTail $bTail (+ $idx 1))))
     (if (isAdditive $action $idx)
         (cons-atom (addActionArgs $aHead $bHead) $mergedTail)
         (cons-atom $aHead $mergedTail))))

(= (mergeAdditiveActions $a $b)
   (let* (($action (actionName $a))
          ($mergedArgs (mergeAdditiveArgs $action (actionArgs $a) (actionArgs $b) 0)))
     (makeActionExpr $action $mergedArgs)))

(= (reduceAdditiveArgs ()) ())
(= (reduceAdditiveArgs $args)
   (let* ((($h $t) (decons-atom $args)))
     (if (== $t ())
         (cons-atom $h ())
         (let* (($next (car-atom $t))
                ($rest (cdr-atom $t)))
           (if (canMergeAdditiveActions $h $next)
               (reduceAdditiveArgs (cons-atom (mergeAdditiveActions $h $next) $rest))
               (cons-atom $h (reduceAdditiveArgs $t)))))))

(= (reduceAdditive $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (isActionSeqOp $op)
             (cons-atom $op (reduceAdditiveArgs $args))
             $expr))
       $expr))

;; ---------------------------------------------------------------------------
;; reduceZeroNeutral (C++ reduce_zero_neutral)
;; ---------------------------------------------------------------------------
;;
;; Some actions have *zero-neutral* arguments: if that argument equals 0.0, the
;; action has no physical effect and trivially succeeds. The rule replaces any
;; such action with action_success directly:
;;
;;   action(... 0.0 ...)  ->  action_success
;;                         when isZeroNeutral(action, arg_index)
;;
;; Example: step_forward(0.0) -> action_success  (moving zero distance is a no-op)
;;
;; Whether an argument position is zero-neutral is declared via isZeroNeutral in
;; action-properties.metta.

(= (hasZeroNeutralArg $action () $idx) False)
(= (hasZeroNeutralArg $action $args $idx)
   (let* ((($h $t) (decons-atom $args)))
     (if (and (isZeroNeutral $action $idx) (== $h 0))
         True
         (hasZeroNeutralArg $action $t (+ $idx 1)))))

(= (reduceZeroNeutral $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let* (($action (car-atom $expr))
              ($args (cdr-atom $expr)))
         (if (hasZeroNeutralArg $action $args 0)
             action_success
             $expr))
       $expr))

;; ---------------------------------------------------------------------------
;; reduceModularArgument (C++ reduce_modular_argument)
;; ---------------------------------------------------------------------------
;;
;; Some actions have *modular* (cyclic) numeric arguments, where the value is
;; taken modulo the range [min, max). For example, a rotation of 2π radians
;; is the same as 0 radians. The rule wraps any out-of-range constant argument
;; back into the canonical range:
;;
;;   action(... v ...)  ->  action(... v' ...)   when isModulo(action, i)
;;                         where v' = v wrapped into [moduloMin, moduloMax)
;;
;; If min == max, every value collapses to min (degenerate modular range).
;; If the argument is not a literal number, it is left unchanged.
;;
;; Example: rotate(6.28) -> rotate(0.0)  for a [0, 2π) modular rotation
;;
;; Modular properties are declared via isModulo / moduloMin / moduloMax in
;; action-properties.metta.

(= (reduceModuloValue $value $min $max)
   (if (== (get-type $value) Number)
       (if (== $min $max)
           $min
           (let $span (- $max $min)
             (if (< $value $min)
                 (+ (- $value (* $span (int (/ (- $value $min) $span)))) $span)
                 (if (>= $value $max)
                     (- $value (* $span (int (/ (- $value $min) $span))))
                     $value))))
       $value))

(= (reduceModularArg $action $value $idx)
   (if (isModulo $action $idx)
       (reduceModuloValue $value (moduloMin $action $idx) (moduloMax $action $idx))
       $value))

(= (reduceModularArgs $action () $idx) ())
(= (reduceModularArgs $action $args $idx)
   (let* ((($h $t) (decons-atom $args))
          ($reducedHead (reduceModularArg $action $h $idx))
          ($reducedTail (reduceModularArgs $action $t (+ $idx 1))))
     (cons-atom $reducedHead $reducedTail)))

(= (reduceModularArgument $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let* (($action (car-atom $expr))
              ($args (cdr-atom $expr)))
         (cons-atom $action (reduceModularArgs $action $args 0)))
       $expr))
