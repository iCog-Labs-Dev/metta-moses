;; ============================================================================
;; knobs/decode.metta -- getting from a vector of numbers back to a program.
;;
;; Four steps, and it is worth knowing why they are four:
;;
;;   instance  --decodeInstance-->  tree  --cleanupTree-->  tree
;;             --compileTree-->  runnable  --evaluator-->  result
;;
;; The instance is what the search moves in. The tree is what everything else
;; would inspect (complexity, reduction, printing). The runnable form is what
;; the evaluator dispatches on. Collapsing them would give something that runs
;; but that nothing can look at.
;; ============================================================================

;; --- 1. read the vector -----------------------------------------------------
;; Each knob looks up ITS OWN index in the vector. That is why one shared
;; counter matters: a wrong index reads someone else's setting and produces a
;; perfectly well-formed but different program.
(= (decodeInstance $inst (mkKnob $sub (mkLSK $m $d) $i))
   (let $s (index-atom $inst $i)
     (if (== $s 0)
         ()
         (if (== $s 1)
             (decodeInstance $inst $sub)
             (negated (decodeInstance $inst $sub))))))

(= (decodeInstance $inst (mkKnob $sub (mkASK $m $d $perms) $i))
   (let $s (index-atom $inst $i)
     (if (== $s 0) () (index-atom $perms (- $s 1)))))

(= (decodeInstance $inst (mkNullVex ()))   ())
(= (decodeInstance $inst (mkNullVex ($t))) (decodeInstance $inst $t))

(= (decodeInstance $inst (mkTree $node $children))
   (let $new (filter-atom (map-atom $children $c (decodeInstance $inst $c)) $x (!= $x ()))
     (mkTree $node $new)))

;; --- 2. tidy up -------------------------------------------------------------
;; The builder leaves empty AND/OR nodes lying around as places to grow into.
;; If the search did not use one, it is scaffolding and comes out.
;;
;; But only when it sits INSIDE another boolean node. An empty conjunction
;; that is itself a whole condition means "no test", which is a legitimate
;; thing to say, and dropping it would leave the conditional short of a child
;; and score it worst -- biasing the search against ever turning a condition
;; off.
(= (cleanupNode $t $insideBoolean)
   (let* (($s (nodeSymOf $t))
          ($new (filter-atom
                  (map-atom (kidsOf $t) $c (cleanupNode $c (isJunctor $s)))
                  $x (!= $x ()))))
     (if (and (and (== $new ()) (isJunctor $s)) $insideBoolean)
         ()
         (mkTree (mkNode $s) $new))))

(= (cleanupTree $t) (cleanupNode $t False))

;; --- 3. make it runnable ----------------------------------------------------
;; Every node becomes (op (children)) -- leaves included, as (op ()) -- so the
;; evaluator needs no special cases. `quote` matters here: these symbols are
;; live operators, and writing the term without it would CALL them while the
;; term is still being assembled.
(= (compileTree (mkTree (mkNode $r) ()))
   (if (isGroundLiteral $r) $r (quote ($r ()))))
(= (compileTree (mkTree (mkNode $r) (cons $x $xs)))
   (let $ce (filter-atom (map-atom (cons $x $xs) $c (compileTree $c)) $y (!= $y ()))
     (quote ($r $ce))))

;; --- the whole pipeline, in one line ----------------------------------------
;; The scorer is passed in: deciding what a program is WORTH is the domain's
;; business, so no domain is named here.
(= (candidateOf $rep $inst) (cleanupTree (decodeInstance $inst $rep)))
(= (scoreInstance $scorer $rep $inst) ($scorer (compileTree (candidateOf $rep $inst))))


;; ============================================================================
;; Looking at a representation from outside: how many knobs, how wide each is,
;; and where the search starts.
;; ============================================================================
;; NOTE these recurse INTO the controlled subtree as well. Once conditions
;; nest, a knob's subtree contains further knobs, and missing them means the
;; instance vector comes out too short.
(= (knobSpecs (mkKnob $sub (mkLSK $m $d) $i))
   (union-atom (($i $m $d)) (knobSpecs $sub)))
(= (knobSpecs (mkKnob $sub (mkASK $m $d $p) $i))
   (union-atom (($i $m $d)) (knobSpecs $sub)))
(= (knobSpecs (mkNullVex $x)) ())   ;; a placeholder holds no knobs
(= (knobSpecs (mkTree $node $children))
   (foldl-atom $children () $a $c (union-atom $a (knobSpecs $c))))

(= (knobKindIdx (mkKnob $sub (mkLSK $m $d) $i))
   (union-atom (($i LSK)) (knobKindIdx $sub)))
(= (knobKindIdx (mkKnob $sub (mkASK $m $d $p) $i))
   (union-atom (($i ASK)) (knobKindIdx $sub)))
(= (knobKindIdx (mkNullVex $x)) ())
(= (knobKindIdx (mkTree $node $children))
   (foldl-atom $children () $a $c (union-atom $a (knobKindIdx $c))))

;; NOTE the let-binding before superpose in both lookups below: superpose does
;; not evaluate its argument, so passing a call there would superpose over the
;; unevaluated call itself and quietly find nothing.
(= (specField $specs $i $f)
   (let $hit (collapse (let ($j $m $d) (superpose $specs)
                            (if (== $j $i) ($j $m $d) (empty))))
     (index-atom (car-atom $hit) $f)))

(= (kindAt $rep $i)
   (let* (($pairs (knobKindIdx $rep))
          ($hit (collapse (let ($j $k) (superpose $pairs)
                               (if (== $j $i) $k (empty))))))
     (car-atom $hit)))

(= (knobCountOf $rep) (size-atom (knobSpecs $rep)))

;; how many settings each knob has, in INDEX order
(= (multsOf $rep)
   (let $s (knobSpecs $rep)
     (map-atom (rangeTo (size-atom $s)) $i (specField $s $i 1))))

;; the instance that reproduces the program we started from
(= (defaultInstance $rep)
   (let $s (knobSpecs $rep)
     (map-atom (rangeTo (size-atom $s)) $i (specField $s $i 2))))
