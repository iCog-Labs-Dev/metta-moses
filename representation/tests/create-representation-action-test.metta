!(import! &self ../../utilities/general-helpers)
;; parameters load FIRST (mirrors moses.metta): create-representation's
;; action clause reads (param actions)/(param perceptions), and
;; PeTTa gates reduction on load order.
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/map)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/boolean-ops)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cacheSpace)
!(import! &self ../../scoring/action-registry)

!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/lsk)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/sample-logical-perms)
!(import! &self ../../representation/add-logical-knobs)
!(import! &self ../../representation/build-logical)
!(import! &self ../../representation/logical-canonize)
!(import! &self ../../representation/build-action)
!(import! &self ../../representation/build-knobs)
!(import! &self ../../representation/knob-mapper)
!(import! &self ../../representation/representation)
!(import! &self ../../feature-selection/feature-selection-helpers)
!(import! &self ../../representation/create-representation)

!(import! &self ../../deme/create-deme)

!(py-call (random.seed 12))

;; ============================================================
;; createRepresentation / createDeme action clauses: the vocabulary rides
;; as ORDINARY ARGUMENTS (arity routes the dispatch -- no tag), so the
;; representation layer is a pure function of its inputs. In a full run
;; the one (param actions)/(param perceptions) read happens at the deme
;; boundary (expand-deme.metta's action overload); this test passes the
;; tuples directly. crt* symbols are inert, so plain literals are safe;
;; quote-wrap the params in a real experiment where the primitives head
;; live clauses.
;; ============================================================

;; the params-boundary shape: set-param then read serves plain tuples back
;; (what expand-deme's boundary read receives before forwarding as args)
!(set-param actions (quote (crtGo crtTurn crtWait)))
!(set-param perceptions (quote (crtBlocked)))
!(assertEqual (param actions) (crtGo crtTurn crtWait))
!(assertEqual (param perceptions) (crtBlocked))

;; 2 demes -> 2 reps, each the 1-field (mkRep (mkKbMap (mkDscMp $m)) $t)
;; shape with a non-empty knob multimap
!(assertEqual
  (let $reps (createRepresentation 2 (mkTree (mkNode and_seq) ())
                                   (crtGo crtTurn crtWait) (crtBlocked))
    ((size-atom $reps)
     (map-atom $reps $r
       (let (mkRep (mkKbMap (mkDscMp $m)) $t) $r
         (> (MultiMap.length $m) 0)))))
  (2 (True True)))

;; createDeme wraps each rep in an empty-instance-set mkDeme, ids in order
!(assertEqual
  (let $demes (createDeme 2
                (cons (mkDemeId "act1") (cons (mkDemeId "act2") ()))
                (mkTree (mkNode and_seq) ())
                (crtGo crtTurn crtWait) (crtBlocked))
    ((size-atom $demes)
     (map-atom $demes $d
       (let (mkDeme (mkRep (mkKbMap (mkDscMp $m)) $t) $instSet $id) $d
         ($id $instSet (> (MultiMap.length $m) 0))))))
  (2 (((mkDemeId "act1") (mkSInstSet ()) True)
      ((mkDemeId "act2") (mkSInstSet ()) True))))
