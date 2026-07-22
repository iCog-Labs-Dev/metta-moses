;; ---------------------------------------------------------------------------
;; Probe 6 (zipform Phase 1, probe gate). Both runtimes. Builds a 4096-row,
;; 2-column table programmatically (recursive generator, alternating
;; booleans), builds a 7-level nested zip term over it (a chain, since the
;; table only has 2 columns), and evaluates with a minimal (non-memoized)
;; recursive term evaluator, watching for stack/depth errors. Reports
;; column length + spot-checked cells; timing observed externally via
;; `bash time`.
;;
;; Column construction: colX alternates True,False,True,False,... (True at
;; even row index); colY alternates False,True,False,True,... (False at
;; even index) -- i.e. colY = NOT colX at every row, always.
;;
;; The 7-level chain alternates op (and/or) and leaf label (x/y) by depth:
;;   buildNested(0, L, _)   = (col L)
;;   buildNested(d, L, Op)  = (zipWith Op (buildNested(d-1, other(L), other(Op))) (col L))
;; Because colY = NOT colX everywhere, level 1 = (colY and colX) = False
;; everywhere already; every subsequent level alternates False-OR-colY=colY
;; then colY-AND-colX=False again, so the FINAL (level 7, an `and` level)
;; column is False at EVERY row -- a clean, hand-verifiable expected value
;; for the spot-check (rather than a per-cell hand computation over 4096
;; rows).
;; ---------------------------------------------------------------------------

!(import! &self ../common/list-helpers)

;; --- 4096-row column generator (recursive, alternating boolean) -----------
;; NOTE: an earlier version used two overlapping equations `(genCol 0 $b)`
;; / `(genCol $n $b)` -- this is a real hazard (found while building this
;; probe, see buildNested below for the reproduction): a literal-pattern
;; clause and a variable-pattern clause for the SAME head both match at the
;; base case, and this system does not have "most-specific-clause-wins" cut
;; semantics -- exhaustive backtracking into the general (variable) clause
;; at the base case recurses with `(- 0 1)` = -1, -2, ... forever, blowing
;; the Prolog stack. Fix: ONE clause, guarded by an explicit `if`
;; (structural-shape-guard-then-destructure convention, see
;; petta-switch-construct), never two overlapping equations differing only
;; in a literal-vs-variable head position.
(= (flipBool True) False)
(= (flipBool False) True)
(= (genCol $n $b)
   (if (== $n 0)
       ()
       (cons $b (genCol (- $n 1) (flipBool $b)))))

(= (colLookup x) (genCol 4096 True))
(= (colLookup y) (genCol 4096 False))

;; --- 7-level nested zip term builder (zipWith/col are pure data tags,
;; never given a clause definition anywhere in this file, so literal
;; occurrences built here stay inert until evalZip below dispatches them) --
(= (otherLabel x) y)
(= (otherLabel y) x)
(= (otherOp and) or)
(= (otherOp or) and)

;; Same fix as genCol: one clause, guarded by `if`, not two overlapping
;; equations (literal 0 vs variable $d) -- the overlap reproduces the
;; runaway-backtracking hazard: `buildNested(-41330148, y, or, ...)` /
;; "Stack limit (8.0Gb) exceeded" was the observed crash with the
;; overlapping-equations version.
(= (buildNested $d $label $op)
   (if (== $d 0)
       (col $label)
       (zipWith $op (buildNested (- $d 1) (otherLabel $label) (otherOp $op)) (col $label))))

;; --- minimal (non-memoized) recursive term evaluator ------------------------
(= (evalZip $t)
   (let $h (car-atom $t)
     (if (== $h col)
         (let (col $label) $t (colLookup $label))
         (if (== $h zipWith)
             (let (zipWith $f $a $b) $t (List.zipWith $f (evalZip $a) (evalZip $b)))
             (Error $t "evalZip: unknown head")))))

(= (deepTerm) (buildNested 7 x and))
!(println! (DEEP_TERM_HEAD_ONLY (buildNested 1 x and)))

(= (deepResult) (evalZip (deepTerm)))

!(println! (LENGTH (List.length (deepResult))))
!(test (List.length (deepResult)) 4096)

!(println! (CELL_0 (index-atom (deepResult) 0)))
!(test (index-atom (deepResult) 0) False)

!(println! (CELL_1 (index-atom (deepResult) 1)))
!(test (index-atom (deepResult) 1) False)

!(println! (CELL_2000 (index-atom (deepResult) 2000)))
!(test (index-atom (deepResult) 2000) False)

!(println! (CELL_4095 (index-atom (deepResult) 4095)))
!(test (index-atom (deepResult) 4095) False)

;; whole-column check against the expected all-False constant column
(= (expectedAllFalse) (List.repeat 4096 False))
!(test (deepResult) (expectedAllFalse))
