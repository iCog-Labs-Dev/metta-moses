;; ============================================================================
;; knobs/perms.metta -- the candidates offered at one position in a program.
;;
;; A CANDIDATE (a "perm") is one complete subtree the search may switch on
;; there. Two kinds, and the second is what gives the search any reach at all:
;;
;;   a single primitive                  m1Grab            m1FoodHere
;;   an operator with EVERY argument
;;   filled by a primitive of the type
;;   that argument asks for              (or_seq m1Grab m1Step)
;;                                       (action_bool_if m1FoodHere m1Grab m1Step)
;;                                       (OR (NOT m1FoodHere) m1FoodAhead)
;;
;; A partly filled operator is not a candidate. It becomes one only when the
;; last argument has been supplied -- which is why the types matter: a slot
;; that asks for a Bool is filled from the things that produce a Bool, and an
;; Act slot from the things that produce an Act, so no candidate is ever
;; nonsense.
;;
;; ONE CANDIDATE IS ONE KNOB -- always, whether it is a bare primitive or a
;; three-argument conditional. How many candidates there are and how many
;; settings a knob has are unrelated questions. A knob's settings are the ways
;; the SAME candidate can be handled:
;;
;;     an action candidate   drop it, or keep it                 2 settings
;;     a test candidate      drop it, keep it, or negate it      3 settings
;;
;; Counting candidates as settings of a single knob would be a different and
;; much weaker thing: the search could then hold at most one of them at a time.
;;
;; Nothing here is random. "An arbitrary operator with arbitrary arguments" is
;; a deterministic walk over the whole space of fillings, so a run reproduces
;; exactly; replace the index with a random draw and nothing else changes.
;; ============================================================================

;; How many children to give an operator that takes any number of them. Two --
;; one level of structure beyond a bare primitive, which is the point.
(= (seqArity) 2)

;; How many operator-headed candidates to sample per position. The full space
;; is much larger; this is the budget.
(= (permCount) 6)

;; What each argument slot of a sampled use of $op asks for.
(= (slotTypesOf $op)
   (let $a (argTypeOf $op)
     (if (== (car-atom $a) Seq)
         (let $t (index-atom $a 1) (map-atom (rangeTo (seqArity)) $k $t))
         $a)))

;; What may go IN one of those slots. Primitives of the right type -- and, for
;; a test, their negations too. There is no knob inside a candidate to flip a
;; polarity later, so both polarities have to be offered up front; this is what
;; makes (OR (NOT p) q) reachable.
(= (fillersOfType $t)
   (let $lits (map-atom (primsOfType $t) $s (leafOf $s))
     (if (== $t Bool) (union-atom $lits (map-atom $lits $l (negated $l))) $lits)))

(= (vocabsOf $op) (map-atom (slotTypesOf $op) $t (fillersOfType $t)))

;; --- walking the fillings ---------------------------------------------------
;; The $j-th way of filling the slots, counting like an odometer over the
;; vocabularies. The LAST slot turns fastest (hence the two reverses), so
;; consecutive j vary the arguments while holding the leading one steady --
;; with the first slot turning fastest a three-argument operator would repeat
;; its last two arguments for as long as the budget lasts.
(= (fillLeft $vocabs $j)
   (if (== $vocabs ()) ()
       (let* (($v (car-atom $vocabs))
              ($n (size-atom $v))
              ($here (index-atom $v (% $j $n)))
              ($rest (fillLeft (cdr-atom $vocabs) (floor-math (/ $j $n)))))
         (cons-atom $here $rest))))

(= (fillAt $vocabs $j) (reverse (fillLeft (reverse $vocabs) $j)))
(= (fillCount $vocabs) (foldl-atom $vocabs 1 $a $v (* $a (size-atom $v))))

;; Two slots holding the same test add nothing: (OR p p) is just p, and
;; (OR p (NOT p)) is just true. So a filling is thrown away when two slots
;; share a base, polarity ignored.
(= (baseOf $t) (if (== (nodeSymOf $t) NOT) (car-atom (kidsOf $t)) $t))

(= (allDistinct ()) True)
(= (allDistinct (cons $x $rest))
   (if (containsIn $rest $x) False (allDistinct $rest)))

(= (usableFill $args) (allDistinct (map-atom $args $a (baseOf $a))))

;; --- sampling ---------------------------------------------------------------
;; The $i-th candidate: operators taken in turn, so a small budget spends
;; itself across all of them instead of exhausting the first.
(= (compoundAt $ops $i)
   (let* (($n (size-atom $ops))
          ($op (index-atom $ops (% $i $n)))
          ($args (fillAt (vocabsOf $op) (floor-math (/ $i $n)))))
     (if (usableFill $args) (mkTree (mkNode $op) $args) ())))

;; how far the walk can go before every operator has run out of fillings
(= (permLimit $ops)
   (* (size-atom $ops)
      (foldl-atom $ops 1 $a $o (let $f (fillCount (vocabsOf $o)) (if (> $f $a) $f $a)))))

;; Walk until $n candidates have been collected, skipping the unusable ones and
;; any repeat (operators with few fillings come round again).
(= (sampleCompounds $ops $i $limit $n $acc)
   (if (>= $i $limit) $acc
   (if (<= $n 0) $acc
       (let $p (compoundAt $ops $i)
         (if (== $p ())
             (sampleCompounds $ops (+ $i 1) $limit $n $acc)
             (if (containsIn $acc $p)
                 (sampleCompounds $ops (+ $i 1) $limit $n $acc)
                 (sampleCompounds $ops (+ $i 1) $limit (- $n 1)
                                  (union-atom $acc ($p)))))))))

;; Which operators may head a candidate for a slot of type $t sitting under
;; $parent. Not the parent's own operator -- (and_seq (and_seq ...)) says
;; nothing new, and for tests this is exactly the AND/OR alternation: the
;; candidates offered inside an AND are ORs and vice versa. Not the negator
;; either; that is a knob setting.
(= (permOpsFor $parent $t)
   (filter-atom (opsOfType $t) $o (if (== $o $parent) False (not (isNegator $o)))))

;; Every candidate for a slot of type $t under $parent.
(= (permsFor $parent $t)
   (let* (($lits (map-atom (primsOfType $t) $s (leafOf $s)))
          ($ops  (permOpsFor $parent $t))
          ($comp (if (== $ops ())
                     ()
                     (sampleCompounds $ops 0 (permLimit $ops) (permCount) ()))))
     (union-atom $lits $comp)))

;; the boolean case is the same question asked of type Bool
(= (logicalPerms $op) (permsFor $op Bool))
