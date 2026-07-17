!(import! &self ../../utilities/general-helpers)
;; parameters load FIRST (mirrors moses.metta): create-representation's
;; action clause reads (param actionActions)/(param actionPerceptions), and
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
;; createRepresentation / createDeme for the mkActionRep-tagged clauses.
;; Inert test-local vocabulary bound through the GLOBAL PARAMS (the single
;; source since the params-based redesign; the per-domain config-clause
;; family was deleted) -- createRepresentation must pick it up via
;; (param actionActions) / (param actionPerceptions) with no experiment
;; package loaded. The tuples are quote-wrapped at the set-param sites per
;; the contract (crt* symbols are inert here, but the convention is
;; uniform; probe-verified: quote strips on set, the params hold the plain
;; tuples).
;; ============================================================

!(set-param actionActions (quote (crtGo crtTurn crtWait)))
!(set-param actionPerceptions (quote (crtBlocked)))

;; the params serve the test vocabulary back as plain tuples
!(assertEqual (param actionActions) (crtGo crtTurn crtWait))
!(assertEqual (param actionPerceptions) (crtBlocked))

;; 2 demes -> 2 reps, each the 1-field (mkRep (mkKbMap (mkDscMp $m)) $t)
;; shape with a non-empty knob multimap
!(assertEqual
  (let $reps (createRepresentation 2 (mkTree (mkNode and_seq) ()) mkActionRep)
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
                mkActionRep)
    ((size-atom $demes)
     (map-atom $demes $d
       (let (mkDeme (mkRep (mkKbMap (mkDscMp $m)) $t) $instSet $id) $d
         ($id $instSet (> (MultiMap.length $m) 0))))))
  (2 (((mkDemeId "act1") (mkSInstSet ()) True)
      ((mkDemeId "act2") (mkSInstSet ()) True))))
