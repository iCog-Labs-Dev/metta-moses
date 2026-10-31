!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)
!(import! &self ../../representation/lsk)
!(import! &self ../../scoring/action-registry)
!(import! &self ../../representation/knob-representation)
!(import! &self ../../representation/logical-probe)
!(import! &self ../../representation/sample-logical-perms) 


;; logicalProbe tests
!(assertEqual (logicalProbe
      (mkTree (mkNode AND)     
        (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ())))())))
      ((mkTree (mkNode B) ()) (mkTree (mkNode A) ()))    
      True)
      ( ((mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
        (mkTree (mkNode AND) ((mkTree (mkNode OR) ((mkTree (mkNode B) ()) (mkTree (mkNode C) ()))) (mkKnob (mkNullVex ((mkTree (mkNode B) ()))) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ())) 0) (mkKnob (mkTree (mkNode A) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 1)))))

!(resetState &knobCount)

!(assertEqual 
    (logicalProbe
          (mkTree (mkNode OR)
                      (cons (mkTree (mkNode B) ())
                      (cons (mkTree (mkNode C) ()) ())))
          ((mkTree (mkNode B) ()))    
          True
    )
    (
      ((mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
      (mkTree (mkNode OR) ((mkTree (mkNode C) ()) (mkKnob (mkTree (mkNode B) ()) (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())) 0)))))

;; Tests for actionProbe / simpleActionProbe (action-domain version).
;; These replace the retired per-move subtree-probe cases with the same ttt
;; vocabulary as inert action symbols. Key delta: actionProbe makes ONE ASK
;; holding all supplied perms and appends a single knob, whereas the old
;; per-move probe built one subtree-knob per perm.
(= (pwTree) (mkTree (mkNode playwin) ()))
(= (pbTree) (mkTree (mkNode playblock) ()))
(= (pcTree) (mkTree (mkNode playcenter) ()))
(= (pcrTree) (mkTree (mkNode playcorner) ()))
(= (pfTree) (mkTree (mkNode playfork) ()))

;; actionProbe test 1: two perms at the root append one ASK-controlled knob as
;; the new (3rd) child, its mkNullVex holding BOTH perms, multip |perms|+1 = 3.
!(assertEqual
    (actionProbe
      (mkTree (mkNode and_seq) ((pcTree) (pcrTree)))
      (mkNodeId (0))
      ((pbTree) (pcTree))
      True
      ())
    ( ((mkASK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) ((pbTree) (pcTree))))
      (mkTree (mkNode and_seq)
        ((pcTree) (pcrTree)
         (mkKnob (mkNullVex ((pbTree) (pcTree)))
                 (mkASK (mkDiscKnob (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) ((pbTree) (pcTree)))
                 0)))))

;; simpleActionProbe test: the node at (2) is wrapped in place (not appended),
;; multip 2, default 1 (present), perms = the single wrapped subtree.
!(assertEqual
    (simpleActionProbe
      (mkTree (mkNode and_seq) ((pcTree) (pcrTree)))
      (mkNodeId (2))
      True
      ())
    ( ((mkASK (mkDiscKnob (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()) ((pcrTree))))
      (mkTree (mkNode and_seq)
        ((pcTree)
         (mkKnob (pcrTree)
                 (mkASK (mkDiscKnob (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()) ((pcrTree)))
                 0)))))

;; Empty perms: no knob, tree unchanged.
!(assertEqual
    (actionProbe
      (mkTree (mkNode and_seq) ((pcTree)))
      (mkNodeId (0))
      ()
      True
      ())
    (() (mkTree (mkNode and_seq) ((pcTree)))))

;; actionProbe with a single perm and diverse moves: one knob appended as the
;; new (3rd) child, mkNullVex holding the lone perm, multip |perms|+1 = 2.
!(assertEqual
    (actionProbe
      (mkTree (mkNode and_seq) ((pwTree) (pfTree)))
      (mkNodeId (0))
      ((pbTree))
      True
      ())
    ( ((mkASK (mkDiscKnob (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) ((pbTree))))
      (mkTree (mkNode and_seq)
        ((pwTree) (pfTree)
         (mkKnob (mkNullVex ((pbTree)))
                 (mkASK (mkDiscKnob (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) ((pbTree)))
                 0)))))

;; Multiplicity law: the ASK multip is |perms|+1, so 1 perm -> 2, 2 perms -> 3.
!(assertEqual
    (let* (
        (($knobs1 $t1) (actionProbe (mkTree (mkNode and_seq) ((pcTree))) (mkNodeId (0)) ((pbTree)) True ()))
        (($knobs2 $t2) (actionProbe (mkTree (mkNode and_seq) ((pcTree))) (mkNodeId (0)) ((pbTree) (pcTree)) True ()))
      )
      ((getKnobMultip (car-atom $knobs1)) (getKnobMultip (car-atom $knobs2))))
    ((mkMultip 2) (mkMultip 3)))
