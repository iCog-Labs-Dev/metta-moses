;; Ignored exemplar features are not kept in a separate ignore_ops set (classic
;; does that). Representation building subtracts them from the argument list.

;; createRepresentation -- calls on the representation building procedure
;; (: createRepresentation (-> Number (Tree $a) (ITable $a) Symbol Bool Expression Symbol Representation))
;; For boolean: createRepresentation($nDeme, $tree, $itable, $algo, $prune, $enforced, $scorer)

;; Boolean logic representation (7 parameters)
;; The eighth arg to `representation` is `$discProbeDisabled`, so we negate
;; the user-facing `discProbe` knob (True == enabled) when forwarding.
(= (createRepresentation $nDeme $tree (mkITable $table $labels) $algo $pruneExemplar $enforcedFts $scorerType)
   ;; Return the whole list. Binding one mkRep here makes one branch per
   ;; representation instead of one shared budget for all demes.
   (representation $nDeme $tree (mkITable $table $labels) $algo
                   $pruneExemplar $enforcedFts $scorerType
                   (not (param discProbe))))

;; Action representation (4 parameters): the action and perception vocabularies
;; are arguments; expand-deme.metta reads them from the parameters.
;; The 3-ary `representation` builds one rep per call, so the per-deme loop is here.
;; Knob sampling in buildAction is random, so the demes get different representations.
;; A single action knob leaves hill climbing with only one replacement
;; coordinate. Prefer a representation with at least two coordinates when
;; randomized construction can provide one; the bounded fallback preserves
;; valid one-knob domains.
(= (actionRepresentationHasSearchDepth (mkRep (mkKbMap (mkDscMp $mmp)) $tree))
   (> (MultiMap.length $mmp) 1))

(= (actionRepresentationWithKnobs $tree $actions $perceptions $attempt)
   (let  $rep (representation $tree $actions $perceptions)
     (if (or  (actionRepresentationHasSearchDepth $rep) (>= $attempt 7))
         $rep
         (actionRepresentationWithKnobs $tree $actions $perceptions (+ $attempt 1)))))

(= (createRepresentation $nDeme $tree $actions $perceptions)
   (let $demeNumbers (range 0 1 $nDeme)
     (map-atom $demeNumbers $x
       (actionRepresentationWithKnobs $tree $actions $perceptions 0))))
