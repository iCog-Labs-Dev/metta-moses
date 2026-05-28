!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/ordered-multimap)
!(import! &self ../../utilities/lazy-random-selector)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../knob-representation)
!(import! &self ../lsk)
!(import! &self ../logical-probe)
!(import! &self ../logical-canonize)
!(import! &self ../sample-logical-perms)
!(import! &self ../add-logical-knobs)
!(import! &self ../build-logical)
!(import! &self ../build-knobs)

;; ── getDiscreteDomain ──────────────────────────────────────────────

;; getDiscreteDomain returns empty list by default
!(assertEqual (getDiscreteDomain) ())

;; ── discreteProbe ─────────────────────────────────────────────────

;; empty domain → returns unchanged knobs and exemplar
!(assertEqual
  (discreteProbe (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) () True ())
  (() (mkTree (mkNode SELECTION) ())))

;; 2-item domain → GDK has multiplicity 3 (= 1 + len(domain))
!(assertEqual
  (getKnobMultip (index-atom (index-atom (discreteProbe (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) (cons A (cons B ())) True ()) 0) 0))
  (mkMultip 3))

;; 2-item domain → GDK spec = (mkDiscSpec 3) implies domain length = 2 and no disabled settings
!(assertEqual
  (getKnobSpec (index-atom (index-atom (discreteProbe (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) (cons A (cons B ())) True ()) 0) 0))
  (mkDiscSpec 3))

;; 2-item domain → GDK stores domain list of length 2
!(assertEqual
  (let (mkGDK $dk $domainList)
       (index-atom (index-atom (discreteProbe (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) (cons A (cons B ())) True ()) 0) 0)
       (List.length $domainList))
  2)

;; addIfInExemplar=False still adds knob when def=0 (not in exemplar)
!(assertEqual
  (getKnobMultip (index-atom (index-atom (discreteProbe (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) (cons A (cons B ())) False ()) 0) 0))
  (mkMultip 3))

;; probe modifies the tree (NullVex appended)
!(assertEqual
  (let* (
    (($knobs $updatedTree) (discreteProbe (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) (cons A (cons B ())) True ()))
  )
  (not (== $updatedTree (mkTree (mkNode SELECTION) ()))))
  True)

;; ── addDiscreteKnobs ──────────────────────────────────────────────

;; 2-item domain → exactly 1 entry in MMap
!(assertEqual
  (let* (
    (($updatedTree $mmp) (addDiscreteKnobs (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) True () (cons A (cons B ()))))
  )
  (== (MultiMap.length $mmp) 1))
  True)

;; the single MMap entry has spec (mkDiscSpec 3)
!(assertEqual
  (let* (
    (($updatedTree $mmp) (addDiscreteKnobs (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) True () (cons A (cons B ()))))
    (($spec $knob) (index-atom $mmp 0))
  )
  (== $spec (mkDiscSpec 3)))
  True)

;; ── buildDiscrete ─────────────────────────────────────────────────

;; empty domain → no-op
!(assertEqual
  (buildDiscrete (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) () ())
  ((mkTree (mkNode SELECTION) ()) ()))

;; leaf tree + 2-item domain → exactly 1 GDK in MMap
!(assertEqual
  (let* (
    (($updatedTree $mmp) (buildDiscrete (mkTree (mkNode SELECTION) ()) (mkNodeId (0)) () (cons A (cons B ()))))
  )
  (== (MultiMap.length $mmp) 1))
  True)

;; tree with 1 child + 2-item domain → 2 GDKs (root + child)
!(assertEqual
  (let* (
    (($updatedTree $mmp) (buildDiscrete
      (mkTree (mkNode SELECTION) (cons (mkTree (mkNode X) ()) ()))
      (mkNodeId (0)) () (cons A (cons B ()))))
  )
  (== (MultiMap.length $mmp) 2))
  True)

;; tree with 2 children + 2-item domain → 3 GDKs (root + 2 children)
!(assertEqual
  (let* (
    (($updatedTree $mmp) (buildDiscrete
      (mkTree (mkNode SELECTION) (cons (mkTree (mkNode X) ()) (cons (mkTree (mkNode Y) ()) ())))
      (mkNodeId (0)) () (cons A (cons B ()))))
  )
  (== (MultiMap.length $mmp) 3))
  True)

;; buildDiscrete modifies the tree (NullVex nodes added)
!(assertEqual
  (let* (
    ($tree (mkTree (mkNode SELECTION) ()))
    (($updatedTree $mmp) (buildDiscrete $tree (mkNodeId (0)) () (cons A (cons B ()))))
  )
  (not (== $updatedTree $tree)))
  True)
