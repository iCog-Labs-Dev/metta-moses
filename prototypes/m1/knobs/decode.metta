;; ============================================================================
;; knobs/decode.metta -- getting from a vector of numbers back to a program.
;;
;; Three steps, and it is worth knowing why they are three:
;;
;;   instance  --getCandidateRec-->  tree  --cleanTree-->  tree
;;             --preOrderExp-->  runnable  --evaluator-->  result
;;
;; The instance is what the search moves in. The tree is what everything else
;; would inspect (complexity, reduction). The runnable form is what the
;; evaluator dispatches on -- and it is also what the demos print, so what you
;; read is exactly what runs.
;; ============================================================================

;; --- 1. read the vector -----------------------------------------------------
;; Each knob looks up ITS OWN index in the vector. That is why one shared
;; counter matters: a wrong index reads someone else's setting and produces a
;; perfectly well-formed but different program.
(= (getCandidateRec $inst (mkKnob $subtree (mkLSK $settings $default) $index))
   (let $setting (index-atom $inst $index)
     (if (== $setting 0)
         ()
         (if (== $setting 1)
             (getCandidateRec $inst $subtree)
             (negated (getCandidateRec $inst $subtree))))))

(= (getCandidateRec $inst (mkKnob $subtree (mkASK $settings $default $perms) $index))
   (let $setting (index-atom $inst $index)
     (if (== $setting 0) () (index-atom $perms (- $setting 1)))))

;; A tunable number reads its `depth` consecutive slots as a WALK and answers
;; the number that walk arrives at. It is the one knob that can never answer ()
;; -- there is no absent setting, because all-Stop already means "the number it
;; was built with" rather than "no number". classic says the same thing as
;; contin_knob::in_exemplar() { return true; }.
(= (getCandidateRec $inst (mkKnob $subtree (mkCTK $mean $step $expansion $depth) $index))
   (let $trits (map-atom (rangeTo $depth) $i (index-atom $inst (+ $index $i)))
     (leafOf (continWalk $trits $mean $step $expansion))))

(= (getCandidateRec $inst (mkNullVex ()))        ())
(= (getCandidateRec $inst (mkNullVex ($subtree))) (getCandidateRec $inst $subtree))

(= (getCandidateRec $inst (mkTree $node $children))
   (let $decoded (filter-atom (map-atom $children $child (getCandidateRec $inst $child))
                              $child (!= $child ()))
     (mkTree $node $decoded)))

;; --- 2. tidy up -------------------------------------------------------------
;; The builder leaves empty AND/OR nodes lying around as places to grow into.
;; If the search did not use one, it is scaffolding and comes out.
;;
;; But only when it sits INSIDE another boolean node. An empty conjunction
;; that is itself a whole condition means "no test", which is a legitimate
;; thing to say, and dropping it would leave the conditional short of a child
;; and score it worst -- biasing the search against ever turning a condition
;; off.
(= (cleanTreeNode $tree $insideBoolean)
   (let* (($symbol  (nodeSymOf $tree))
          ($cleaned (filter-atom
                      (map-atom (kidsOf $tree) $child (cleanTreeNode $child (isJunctor $symbol)))
                      $child (!= $child ()))))
     (if (and (and (== $cleaned ()) (isJunctor $symbol)) $insideBoolean)
         ()
         (mkTree (mkNode $symbol) $cleaned))))

(= (cleanTree $tree) (cleanTreeNode $tree False))

;; --- 3. make it runnable ----------------------------------------------------
;; Every node becomes (op (children)) -- leaves included, as (op ()) -- so the
;; evaluator needs no special cases. This is the production tree's preOrderExp,
;; and it is the ONLY rendering of a program in this prototype: the demos print
;; it, so there is no pretty-printed second version that could drift from what
;; actually runs.
;;
;; `quote` matters here: these symbols are live operators, and writing the term
;; without it would CALL them while the term is still being assembled.
(= (preOrderExp (mkTree (mkNode $symbol) ()))
   (if (isGroundLiteral $symbol) $symbol (quote ($symbol ()))))
(= (preOrderExp (mkTree (mkNode $symbol) (cons $child $rest)))
   (let $compiled (filter-atom (map-atom (cons $child $rest) $c (preOrderExp $c))
                               $c (!= $c ()))
     (quote ($symbol $compiled))))

;; --- the whole pipeline, in one line ----------------------------------------
;; The scorer is passed in: deciding what a program is WORTH is the domain's
;; business, so no domain is named here. (classic: complexity_based_scorer,
;; minus the complexity term, which this prototype does not have.)
(= (getCandidate $rep $inst) (cleanTree (getCandidateRec $inst $rep)))
(= (scoreInstance $scorer $rep $inst) ($scorer (preOrderExp (getCandidate $rep $inst))))


;; ============================================================================
;; Looking at a representation from outside: how many knobs, how wide each is,
;; and where the search starts. Classic keeps these in a field_set; here they
;; are read back off the tree.
;; ============================================================================
;; NOTE these recurse INTO the controlled subtree as well. Once conditions
;; nest, a knob's subtree contains further knobs, and missing them means the
;; instance vector comes out too short.
(= (knobSpecs (mkKnob $subtree (mkLSK $settings $default) $index))
   (union-atom (($index $settings $default)) (knobSpecs $subtree)))
(= (knobSpecs (mkKnob $subtree (mkASK $settings $default $perms) $index))
   (union-atom (($index $settings $default)) (knobSpecs $subtree)))
;; A tunable number owns `depth` CONSECUTIVE slots, so it contributes `depth`
;; specs rather than one -- a 3-setting trit each, every one defaulting to 0
;; (Stop). That default is what makes the exemplar instance decode back to the
;; number the representation was built with.
;;
;; No recursion into the subtree here, unlike LSK and ASK: a CTK's subtree is a
;; numeric leaf, so there is nothing under it that could hold a knob.
(= (knobSpecs (mkKnob $subtree (mkCTK $mean $step $expansion $depth) $index))
   (map-atom (rangeTo $depth) $i ((+ $index $i) 3 0)))
(= (knobSpecs (mkNullVex $placeholder)) ())   ;; a placeholder holds no knobs
(= (knobSpecs (mkTree $node $children))
   (foldl-atom $children () $found $child (union-atom $found (knobSpecs $child))))

(= (knobKindIdx (mkKnob $subtree (mkLSK $settings $default) $index))
   (union-atom (($index LSK)) (knobKindIdx $subtree)))
(= (knobKindIdx (mkKnob $subtree (mkASK $settings $default $perms) $index))
   (union-atom (($index ASK)) (knobKindIdx $subtree)))
(= (knobKindIdx (mkKnob $subtree (mkCTK $mean $step $expansion $depth) $index))
   (map-atom (rangeTo $depth) $i ((+ $index $i) CTK)))
(= (knobKindIdx (mkNullVex $placeholder)) ())
(= (knobKindIdx (mkTree $node $children))
   (foldl-atom $children () $found $child (union-atom $found (knobKindIdx $child))))

;; Both lookups are a filter on the index followed by taking the first hit --
;; the earlier collapse/superpose version had to let-bind its collection first,
;; because superpose does not evaluate its argument and would otherwise
;; superpose over the unevaluated call and quietly find nothing.
(= (specField $specs $index $field)
   (let $hit (filter-atom $specs $spec (== (car-atom $spec) $index))
     (index-atom (car-atom $hit) $field)))

(= (kindAt $rep $index)
   (let* (($kinds (knobKindIdx $rep))
          ($hit   (filter-atom $kinds $pair (== (car-atom $pair) $index))))
     (lastOf (car-atom $hit))))

(= (knobCountOf $rep) (size-atom (knobSpecs $rep)))

;; how many settings each knob has, in INDEX order (classic: disc_spec::multy)
(= (knobMultiplicities $rep)
   (let $specs (knobSpecs $rep)
     (map-atom (rangeTo (size-atom $specs)) $index (specField $specs $index 1))))

;; the instance that reproduces the program we started from
;; (classic: representation::exemplar_inst)
(= (exemplarInst $rep)
   (let $specs (knobSpecs $rep)
     (map-atom (rangeTo (size-atom $specs)) $index (specField $specs $index 2))))
