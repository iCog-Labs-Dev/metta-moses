!(import! &self ../../utilities/general-helpers)
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
;; action-score provides configListSafe -- create-representation's action
;; clause reads the config-clause vocabularies through it, so it must have
;; a clause BEFORE create-representation loads (mirrors moses.metta order)
!(import! &self ../../scoring/action-score)

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
!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
!(import! &self ../../representation/create-representation)

!(import! &self ../../deme/create-deme)

!(py-call (random.seed 12))

;; ============================================================
;; createRepresentation / createDeme for the tagged ACTION domain.
;; Inert test-local vocabulary declared through the domain-config clauses
;; (the single source since the M0 registry slimming; the per-primitive
;; registerDomainAction/registerDomainPerception API was deleted) --
;; createRepresentation must pick it up via (actionDomainActions crtDomain)
;; / (actionDomainPerceptions crtDomain) through configListSafe without any
;; domain package loaded. The tuples are quote-wrapped per the config-clause
;; contract (crt* symbols are inert here, but the convention is uniform).
;; ============================================================

(= (actionDomainActions crtDomain) (quote (crtGo crtTurn crtWait)))
(= (actionDomainPerceptions crtDomain) (quote (crtBlocked)))

;; the config clauses serve the test vocabulary through the shared unwrap
!(assertEqual (configListSafe (collapse (actionDomainActions crtDomain))) (crtGo crtTurn crtWait))
!(assertEqual (configListSafe (collapse (actionDomainPerceptions crtDomain))) (crtBlocked))

;; 2 demes -> 2 reps, each the 1-field (mkRep (mkKbMap (mkDscMp $m)) $t)
;; shape with a non-empty knob multimap
!(assertEqual
  (let $reps (createRepresentation 2 (mkTree (mkNode and_seq) ()) (mkActionDomain crtDomain))
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
                (mkActionDomain crtDomain))
    ((size-atom $demes)
     (map-atom $demes $d
       (let (mkDeme (mkRep (mkKbMap (mkDscMp $m)) $t) $instSet $id) $d
         ($id $instSet (> (MultiMap.length $m) 0))))))
  (2 (((mkDemeId "act1") (mkSInstSet ()) True)
      ((mkDemeId "act2") (mkSInstSet ()) True))))
