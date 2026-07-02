;; ---------------------------------------------------------------------------
;; Action while and boolean while reduction rules
;; ---------------------------------------------------------------------------
;;
;; This file covers four rewrite rules that simplify while-loop and loop-body
;; redundancy in action programs.

;; Helper: take first N elements of a tuple
(= (take-n $n $tuple)
   (if (or (<= $n 0) (== $tuple ()))
       ()
       (let ($h $t) (decons-atom $tuple)
         (cons-atom $h (take-n (- $n 1) $t)))))

;; Helper: drop first N elements of a tuple
(= (drop-n $n $tuple)
   (if (or (<= $n 0) (== $tuple ()))
       $tuple
       (let ($h $t) (decons-atom $tuple)
         (drop-n (- $n 1) $t))))

;; Helper: check if list1 ends with list2
(= (endsWith $list1 $list2)
   (let* (($len1 (size-atom $list1))
          ($len2 (size-atom $list2)))
     (if (< $len1 $len2)
         False
         (== (drop-n (- $len1 $len2) $list1) $list2))))

;; Helper: remove list2 from end of list1
(= (removeEnd $list1 $list2)
   (let* (($len1 (size-atom $list1))
          ($len2 (size-atom $list2)))
     (take-n (- $len1 $len2) $list1)))

;; Helper: check if list ends with a single element
(= (endsWithSingle $list $elem)
   (let $len (size-atom $list)
     (if (== $len 0)
         False
         (== (car-atom (drop-n (- $len 1) $list)) $elem))))

;; Helper: remove single element from end of list
(= (removeEndSingle $list)
   (let $len (size-atom $list)
     (take-n (- $len 1) $list)))


;; reduceActionWhileAlwaysFails (C++ reduce_action_while_always_fails):
;; action_while runs its body repeatedly until the body fails. If the body
;; *always* fails (static result = False), the loop body will execute exactly
;; once and then stop. The while wrapper adds no looping benefit, so:
;;
;;   action_while(A)  ->  A       when getActionResult(A) == False
;;
;; Example: action_while(action_failure) -> action_failure

(= (reduceActionWhileAlwaysFails $expr)
   (unify $expr (action_while $body)
     (if (== (getActionResult $body) False) $body $expr)
     $expr))

;; reduceBoolWhileDependCond (C++ reduce_boolean_while_depend_condition):
;; bool_while(C A) runs body A repeatedly while condition C is true. Two
;; constant-condition cases can be folded immediately:
;;
;;   bool_while(True  A) -> A           ; always-true condition: never terminates
;;                                      ;   statically, but body runs forever —
;;                                      ;   reduced to A (the body's one-step form
;;                                      ;   if A always fails, consistent with C++)
;;   bool_while(False A) -> action_success  ; condition never holds: body never runs
;;
;; NOTE: ;; The C++ comment describes this in terms of eval(C), but the implementation
;; only checks literal logical_true/logical_false. This MeTTa port mirrors that
;; conservative structural behavior.

(= (reduceBoolWhileDependCond $expr)
   (unify $expr (bool_while True $body) $body
     (unify $expr (bool_while False $body) action_success $expr)))

;; Helper: find the smallest valid repeating period of a tuple.
;; A period d is valid when d divides the tuple length and every element matches
;; the element d positions later. The prefix/suffix equality below performs
;; that check compactly:
;;
;;   take(size - d, xs) == drop(d, xs)
;;
;; The original C++ rule only tested the period implied by
;; smallest_divisor(size). That misses valid larger periods, for example
;; `(A B C A B C)` has length 6 and period 3, but C++ only tests period 2.
;; This MeTTa version corrects that limitation by scanning all candidate
;; divisors from smallest to largest. Returning the full size is the sentinel
;; for "no repeated shorter period".

(= (findRepeatingPeriod $bodyArgs)
   (let $sz (size-atom $bodyArgs)
     (findRepeatingPeriodFrom $bodyArgs 1 $sz)))

(= (findRepeatingPeriodFrom $bodyArgs $d $sz)
   (if (>= $d $sz)
       $sz
       (if (and (== (% $sz $d) 0)
                (== (take-n (- $sz $d) $bodyArgs)
                    (drop-n $d $bodyArgs)))
           $d
           (findRepeatingPeriodFrom $bodyArgs (+ $d 1) $sz))))

;; reduceRepeatInActionWhile (C++ reduce_repeat_in_action_while):
;; If the body of action_while is and_seq whose children form a repeated pattern
;; of period d, the repeated copies are redundant because the while loop will
;; itself repeat the body:
;;
;;   action_while(and_seq(A A))         -> action_while(A)
;;   action_while(and_seq(A B A B A B)) -> action_while(and_seq(A B))   [period 2]
;;
;; Unlike the C++ implementation, findRepeatingPeriod searches all candidate
;; periods, so length-6 bodies with period 3 also reduce. If the helper returns
;; the full body length, no reduction is applied.

(= (reduceRepeatInActionWhile $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (== $op action_while)
             (let $body (car-atom $args)
               (if (and (== (get-metatype $body) Expression) (!= $body ()))
                   (let ($bodyOp $bodyArgs) (decons $body)
                     (if (== $bodyOp and_seq)
                         (let* (($sz (size-atom $bodyArgs))
                                ($period (findRepeatingPeriod $bodyArgs)))
                           (if (< $period $sz)
                               (if (== $period 1)
                                   (action_while (car-atom $bodyArgs))
                                   (action_while (cons-atom and_seq (take-n $period $bodyArgs))))
                               $expr))
                         $expr))
                   $expr))
             $expr))
       $expr))

;; reduceRepeatOutActionWhile (C++ reduce_repeat_out_action_while):
;; When an and_seq contains a prefix that duplicates the body of the immediately
;; following action_while, the prefix is redundant: the while loop will execute
;; that body at least once before looping, so the explicit first-copy can be
;; dropped:
;;
;;   and_seq(A  action_while(A))         -> and_seq(action_while(A))
;;   and_seq(A B action_while(and_seq(A B))) -> and_seq(action_while(and_seq(A B)))
;;
;; The rule scans from left to right; when it encounters an action_while node,
;; it checks whether the accumulated processed prefix ends with the while body
;; (for and_seq bodies) or with the single body action (for leaf bodies).
;; If so, that suffix of the prefix is removed.

(= (reduceRepeatOutWhile () $processed) $processed)
(= (reduceRepeatOutWhile $args $processed)
   (let ($h $t) (decons $args)
     (if (and (== (get-metatype $h) Expression) (!= $h ()))
         (let ($childOp $childArgs) (decons $h)
           (if (== $childOp action_while)
               (let $body (car-atom $childArgs)
                 (if (and (== (get-metatype $body) Expression) (!= $body ()))
                     (let ($bodyOp $bodyArgs) (decons $body)
                       (if (== $bodyOp and_seq)
                           (if (endsWith $processed $bodyArgs)
                               (reduceRepeatOutWhile $t (concatTuple (removeEnd $processed $bodyArgs) ($h)))
                               (reduceRepeatOutWhile $t (concatTuple $processed ($h))))
                           (if (endsWithSingle $processed $body)
                               (reduceRepeatOutWhile $t (concatTuple (removeEndSingle $processed) ($h)))
                               (reduceRepeatOutWhile $t (concatTuple $processed ($h))))))
                     (if (endsWithSingle $processed $body)
                         (reduceRepeatOutWhile $t (concatTuple (removeEndSingle $processed) ($h)))
                         (reduceRepeatOutWhile $t (concatTuple $processed ($h))))))
               (reduceRepeatOutWhile $t (concatTuple $processed ($h)))))
         (reduceRepeatOutWhile $t (concatTuple $processed ($h))))))

(= (reduceRepeatOutActionWhile $expr)
   (if (and (== (get-metatype $expr) Expression) (!= $expr ()))
       (let ($op $args) (decons $expr)
         (if (== $op and_seq)
             (let $newArgs (reduceRepeatOutWhile $args ())
               (cons-atom and_seq $newArgs))
             $expr))
       $expr))

;; reduceBoolWhileSubCond (C++ reduce_boolean_while_sub_cond):
;; Inside the body A of bool_while(C A), any occurrence of the condition C
;; that executes at the *same instant* as the loop guard (i.e. before the first
;; side-effecting action in A) can be replaced by True, because the loop guard
;; has already confirmed C == True when A starts:
;;
;;   bool_while(C A) -> bool_while(C A[C -> True])
;;
;; "Same instant" substitution is done by substituteCondInitInstant, which
;; propagates the substitution only into the first-action position of each
;; sequencing node and leaves branches that are reached later unchanged.

(= (reduceBoolWhileSubCond $expr)
   (unify $expr (bool_while $cond $body)
     (bool_while $cond (substituteCondInitInstant $body $cond True))
     $expr))
