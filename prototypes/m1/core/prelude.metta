;; ============================================================================
;; core/prelude.metta -- small helpers. Nothing here knows about MOSES.
;; ============================================================================

;; Is $x a tuple (as opposed to a bare symbol or a number)?
(= (isExpr $x) (== (get-metatype $x) Expression))

;; 0, 1, ... n-1.  ASCENDING -- several things below rebuild lists by mapping
;; over these indices, and a descending range would silently reverse them.
(= (rangeFrom $from $upto)
   (if (>= $from $upto) () (cons-atom $from (rangeFrom (+ $from 1) $upto))))
(= (rangeTo $upto) (rangeFrom 0 $upto))

(= (lastOf $items) (index-atom $items (- (size-atom $items) 1)))

;; $count copies of $item -- the production tree's List.repeat.
(= (repeat $item $count)
   (if (== $count 0)
       ()
       (let $rest (repeat $item (- $count 1)) (cons-atom $item $rest))))

;; `once` is not optional here: is-member succeeds once per matching element,
;; so on a list holding two copies of $wanted this would return two answers,
;; and every caller -- and every caller of every caller -- would come back
;; doubled.
(= (containsIn $items $wanted) (once (is-member $wanted $items)))

;; Every element of $items except those in $unwanted.
(= (without $items $unwanted)
   (filter-atom $items $item (not (containsIn $unwanted $item))))

;; Haskell's nub: drop repeats, keeping the first of each. The membership
;; test is doing the work -- union-atom CONCATENATES, it does not deduplicate.
(= (nub $items)
   (foldl-atom $items () $kept $item
     (if (containsIn $kept $item) $kept (union-atom $kept ($item)))))

;; Haskell's take: the first $count items, or all of them if there are fewer.
(= (takeFirst $count $items)
   (let $howMany (if (< $count (size-atom $items)) $count (size-atom $items))
     (map-atom (rangeTo $howMany) $i (index-atom $items $i))))

(= (maxOf $numbers) (foldl-atom $numbers -1000000 $best $n (if (> $n $best) $n $best)))


;; ---------------------------------------------------------------------------
;; Trees.  A program is a tree:
;;
;;     (mkTree (mkNode <symbol>) <tuple of child trees>)
;;
;; Two extra shapes appear once knobs are involved:
;;     (mkKnob <controlled subtree> <knob> <index>)   a knobbed position
;;     (mkNullVex (<subtree>))                        a position that is empty
;;                                                    unless its knob turns on
;;
;; There is no pretty-printer. A program is shown by COMPILING it (see
;; knobs/decode.metta), so what you read in a demo is the exact term the
;; evaluator is handed -- there is no second representation that could drift.
;; ---------------------------------------------------------------------------

(= (leafOf $symbol) (mkTree (mkNode $symbol) ()))
(= (nodeSymOf (mkTree (mkNode $symbol) $children)) $symbol)
(= (kidsOf (mkTree (mkNode $symbol) $children)) $children)
(= (isNullVex $subtree) (== (car-atom $subtree) mkNullVex))

;; Wrap $subtree in a negation node.
(= (negated $subtree) (mkTree (mkNode NOT) ($subtree)))
