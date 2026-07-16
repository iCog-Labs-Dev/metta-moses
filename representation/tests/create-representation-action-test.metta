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
;; Inert test-local vocabulary registered through the registry API --
;; createRepresentation must pick it up via registeredDomainActions /
;; registeredDomainPerceptions without any domain package loaded.
;; ============================================================

!(registerDomainAction crtGo)
!(registerDomainAction crtTurn)
!(registerDomainAction crtWait)
!(registerDomainPerception crtBlocked)

;; the registry now serves the test vocabulary
!(assertEqual (registeredDomainActions) (crtGo crtTurn crtWait))
!(assertEqual (registeredDomainPerceptions) (crtBlocked))

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
