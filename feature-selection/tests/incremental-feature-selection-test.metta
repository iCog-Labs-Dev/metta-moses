!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/feature-selection/incremental-feature-selection)
!(import! &self ../../../metta-moses/moses/demo-problems)

(= (clear-lru)
   (let $r1 (collapse (match &self (lru-entry $k $v $t) (remove-atom &self (lru-entry $k $v $t))))
        (let $r2 (collapse (match &self (lru-tick $t) (remove-atom &self (lru-tick $t))))
             (let $r3 (collapse (match &self (lru-capacity $c) (remove-atom &self (lru-capacity $c))))
                  True))))

(= (andTable)
   (mkITable
     (cons (cons True (cons True (cons True ())))
     (cons (cons True (cons False (cons False ())))
     (cons (cons False (cons True (cons False ())))
     (cons (cons False (cons False (cons False ()))) ()))))
     (cons A (cons B (cons Output ())))))


!(clear-lru)

;; Test Initialization
!(lru-init 2)
!(test (lru-get-capacity) 2)

;; Test Sequential Inserts (Misses)
;; We use (andTable) for scoring. 
;; Current Cache: []
!(cached-mi-score (andTable) (0)) ;; Miss: adds (0), tick=1
!(cached-mi-score (andTable) (2)) ;; Miss: adds (1), tick=2

!(test (lru-size) 2)

;; Test Cache Hit Logic (Recency Update)
;; Accessing (0) again should mark it as recently used by advancing its tick to 3.
;; Current Cache: {(0)@tick:1, (1)@tick:2} -> Hit -> {(1)@tick:2, (0)@tick:3}
!(cached-mi-score (andTable) (0)) 
!(test (lru-size) 2)

;; Test LRU Eviction Policy
;; Capacity is 2. (1) is currently the oldest at tick 2.
;; Adding a new entry (2) should trigger eviction of (1).
!(cached-mi-score (andTable) (2)) ;; Miss: evicts (1), adds (2)@tick:4

; !(match &self (lru-entry $K $V $T) $T)

;; Verify (1) was evicted
!(test (collapse (match &self (lru-entry (1) $s $t) found)) ())

;; Verify (0) and (2) remain in cache
!(test (lru-size) 2)
!(test (List.contains (0) (collapse (match &self (lru-entry (0) $s $t) (0)))) True)
!(test (List.contains (2) (collapse (match &self (lru-entry (2) $s $t) (2)))) True)

;; Integration Verification
;; Verify it works within the context of the IFS algorithm
!(clear-lru)
!(lru-init 128)

!(test (simple-incremental-selection (parity3) 0.0 0.0 3)
       ((cons 1.0 (cons (0 1 2) ()))))

;; Binary search converges; triple is only informative group → exactly 3.
!(test (adaptive-incremental-selection  (parity3) 3 0.0 3 0.0 1.0 0.01)
       ((cons 1.0 (cons (0 1 2) ()))))

!(test (incremental-feature-selection (parity3) 0.0 0 0.0 3 0.01)
       ((cons 1.0 (cons (0 1 2) ()))))

;; --- Path 2: target_size > 0 — delegates to adaptive ----------------------
;; parity3 target 3
!(test (incremental-feature-selection (parity3) 0.0 3 0.0 3 0.01)
       ((cons 1.0 (cons (0 1 2) ()))))

!(clear-lru)
!(lru-init 128)

;; --- parity4 target 4 -------------------------------------------------
!(test (adaptive-incremental-selection  (parity4) 4 0.0 4 0.0 1.0 0.01)
       ((cons 1.0 (cons (0 1 2 3) ()))))

!(clear-lru)
!(lru-init 128)

;; --- parity4 ----------------------------------------------------------
;; XOR(X1,X2,X3,X4). Only the 4-tuple is informative.
;; Requires max_interaction=4.
!(test(simple-incremental-selection (parity4) 0.0 0.0 4)
       ((cons 1.0 (cons (0 1 2 3) ()))))

;; parity4 target 4
!(test (incremental-feature-selection (parity4) 0.0 4 0.0 4 0.01)
       ((cons 1.0 (cons (0 1 2 3) ()))))
!(clear-lru)
!(lru-init 128)

;; --- disjunction3 -----------------------------------------------------
;; OR(X1,X2,X3). Each feature individually has MI ≈ 0.138.
;; All three are selected at interaction level 1.
!(test (simple-incremental-selection (disjunction3) 0.1 0.0 2)
       ((cons 0.5435644431995965 (cons (0 1 2) ()))))

!(test (incremental-feature-selection (disjunction3) 0.1 0 0.0 2 0.01)
       ((cons 0.5435644431995965 (cons (0 1 2) ()))))

!(clear-lru)
!(lru-init 128)

;; --- majority3 --------------------------------------------------------
;; (A∧B)∨(A∧C)∨(B∧C). Each feature individually informative (~0.189).
;; All three selected at level 1. Joint MI = 1.0.
!(test (simple-incremental-selection (majority3) 0.1 0.0 2)
       ((cons 1.0 (cons (0 1 2) ()))))

;; --- majority3 target 3 -----------------------------------------------
!(test (adaptive-incremental-selection  (majority3) 3 0.0 2 0.0 1.0 0.01)
       ((cons 1.0 (cons (0 1 2) ()))))

;; majority3: 3 features, joint MI = 1.0
!(test (incremental-feature-selection (majority3) 0.0 0 0.0 2 0.01)
       ((cons 1.0 (cons (0 1 2) ()))))

;; majority3: all 3 features selected at level 1
!(test (incremental-feature-selection (majority3) 0.1 0 0.0 2 0.01)
       ((cons 1.0 (cons (0 1 2) ()))))

!(clear-lru)
!(lru-init 128)

;; --- majority5 --------------------------------------------------------
;; 5-input majority. All features individually informative.
;; All five selected at level 1.
!(test (simple-incremental-selection (majority5) 0.1 0.0 2)
       ((cons 1.0 (cons (0 1 2 3 4) ()))))

!(clear-lru)
!(lru-init 128)

;; --- mux3 -------------------------------------------------------------
;; 1-bit mux: Addr selects between D0 and D1.
;; Addr(0) and D0(1) are most informative at threshold=0.1 level 1,
;; D1(2) picked up at interaction level. MI of subset (1 2) = 0.5
!(test (simple-incremental-selection (mux3) 0.1 0.0 3)
       ((cons 0.5 (cons (1 2) ()))))

;; mux3 threshold=0.1 — Addr(0) not informative alone, D0+D1 selected
!(test (incremental-feature-selection (mux3) 0.1 0 0.0 3 0.01)
       ((cons 0.5 (cons (1 2) ()))))

;; Addr + D0 + D1 are all needed to fully determine output.
!(test (adaptive-incremental-selection  (mux3) 3 0.0 3 0.0 1.0 0.01)
       ((cons 1.0 (cons (0 1 2) ()))))

;; mux3 target 3 — all 3 features needed
!(test (incremental-feature-selection (mux3) 0.0 3 0.0 3 0.01)
       ((cons 1.0 (cons (0 1 2) ()))))

!(clear-lru)
!(lru-init 128)

;; --- mux6 threshold=0.18 (selects all 6 via interaction) -------------
;; At threshold 0.18, no single feature passes alone, interactions needed.
;; Algorithm picks all 6 features via higher-order interactions.
!(test (simple-incremental-selection (mux6) 0.18 0.0 3)
       ((cons 1.0 (cons (0 1 2 3 4 5) ()))))

;; --- mux6 threshold=0.1 (all features individually informative) ------
!(test (simple-incremental-selection (mux6) 0.1 0.0 3)
       ((cons 1.0 (cons (0 1 2 3 4 5) ()))))

;; Targets 2 features (ideally the 2 address bits A0, A1).
;; Note: due to symmetric MI tie among data bits, the binary search
;; converges to the best approximation — all 6 features or 0.
!(test (adaptive-incremental-selection  (mux6) 2 0.0 3 0.0 1.0 0.01)
       ((cons 1.0 (cons (0 1 2 3 4 5) ()))))

;; mux6 target 2 — search converges to all 6 (tied MI among data bits)
!(test (incremental-feature-selection (mux6) 0.0 2 0.0 3 0.01)
       ((cons 1.0 (cons (0 1 2 3 4 5) ()))))
