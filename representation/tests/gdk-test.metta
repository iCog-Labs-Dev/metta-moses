!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/tree)

!(import! &self ../knob-representation)
!(import! &self ../lsk)

!(import! &self ../../deme/expand-deme)

;; ── Accessors on bare mkGDK ──────────────────────────────────────────────────

!(assertEqual
   (getDiscKnob (mkGDK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (cons OR (cons AND ()))))
   (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))

!(assertEqual
   (getKnobMultip (mkGDK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (cons OR (cons AND ()))))
   (mkMultip 3))

!(assertEqual
   (getKnobLoc (mkGDK (mkDiscKnob (mkKnob (mkNodeId (1 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (cons OR (cons AND ()))))
   (mkNodeId (1 2)))

!(assertEqual
   (getNodeId (mkGDK (mkDiscKnob (mkKnob (mkNodeId (2 3))) (mkMultip 4) (mkDiscSpec 0) (mkDiscSpec 0) ()) (cons OR (cons AND (cons NOT ())))))
   (mkNodeId (2 3)))

!(assertEqual
   (getKnobSpec (mkGDK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (cons OR (cons AND ()))))
   (mkDiscSpec 3))

;; ── getKnobDefault ───────────────────────────────────────────────────────────

!(assertEqual
   (getKnobDefault (mkGDK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (cons OR (cons AND ()))))
   (mkDiscSpec 0))

!(assertEqual
   (getKnobDefault (mkGDK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()) (cons OR ())))
   (mkDiscSpec 1))

;; ── generalDiscreteKnob constructor ─────────────────────────────────────────
;;
;; Tree: AND(A)  →  target root (0)  →  NullVex appended as 2nd child → id (2)
;; updateID (mkNodeId (2)) = (mkNodeId (2))  (no leading zero)

!(assertEqual
   (generalDiscreteKnob
      (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ()))
      (mkNodeId (0))
      (cons OR (cons AND ())))
   (
      (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkNullVex ()) ())))
      (mkGDK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (cons OR (cons AND ())))
   ))

;; ── appendToGDK ──────────────────────────────────────────────────────────────

(= (gdk1) (mkGDK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()) (cons OR (cons AND ()))))
(= (exemplar1) (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkNullVex ()) ()))))

;; Setting 0: absent — candidate unchanged
!(assertEqual
   (appendToGDK (exemplar1) (gdk1) (mkNullVex ()) (mkNodeId (0)) 0)
   ((mkNullVex ()) (mkNodeId (0)) (mkNodeId (0))))

;; Setting 1: append first domain atom (OR) as leaf
!(assertEqual
   (appendToGDK (exemplar1) (gdk1) (mkNullVex ()) (mkNodeId (0)) 1)
   ((mkTree (mkNode OR) ()) (mkNodeId (2)) (mkNodeId (0))))

;; Setting 2: append second domain atom (AND) as leaf
!(assertEqual
   (appendToGDK (exemplar1) (gdk1) (mkNullVex ()) (mkNodeId (0)) 2)
   ((mkTree (mkNode AND) ()) (mkNodeId (2)) (mkNodeId (0))))

;; Setting > domain size: error
!(assertEqual
   (appendToGDK (exemplar1) (gdk1) (mkNullVex ()) (mkNodeId (0)) 3)
   (Error 3 "Invalid GDK setting: exceeds domain size."))
