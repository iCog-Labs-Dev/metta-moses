;; ============================================================
;;  Unit test: Exemplar Revisit Guard (C++ MOSES parity)
;; ============================================================

!(import! &self ../../parameters/registry)
!(import! &self ../../parameters/defaults)
!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/pair)
!(import! &self ../../utilities/ordered-set)
!(import! &self ../../utilities/tree)
!(import! &self ../../scoring/cscore)
!(import! &self ../../scoring/bscore)
!(import! &self ../../metapopulation/exemplar-type)
!(import! &self ../../metapopulation/exemplar-selection)
!(import! &self ../../metapopulation/metapopulation)
!(import! &self ../../deme/expand-deme)

!(callPredicate (Predicate (py_add_lib_dir "scripts" first)))

;; Exemplar fixtures
(= (candA)
   (mkExemplar (mkTree (mkNode A) ()) (mkDemeId "1") (mkCscore -8 0 3.5 0 -8) (mkBScore (-1 -1 -1 -1 -1 -1 -1 -1))))

(= (candB)
   (mkExemplar (mkTree (mkNode B) ()) (mkDemeId "2") (mkCscore -7 0 2.5 0 -7) (mkBScore (-1 -1 -1 -1 -1 -1 -1 -1))))

(= (singleMetaPop) ((candA)))
(= (twoMetaPop) ((candA) (candB)))

;; ------------------------------------------------------------
;; Test 1: Strict C++ default (revisit = 0: allow exactly 1 visit)
;; Direct selection records visit on selection (classic MOSES parity)
;; ------------------------------------------------------------
!(set-param revisit 0)
!(py-call (visited_tracker.reset))

;; Before visit: eligible
!(assertEqual (isExemplarEligible (candA)) True)

;; Selecting the exemplar records the visit immediately (classic MOSES parity)
!(assertEqual (selectExemplar (singleMetaPop)) (candA))

;; After 1 selection with revisit=0: no longer eligible
!(assertEqual (isExemplarEligible (candA)) False)

;; Single-candidate metapopulation returns NO_EXEMPLAR on next selection
!(assertEqual (selectExemplar (singleMetaPop)) (Error (singleMetaPop) (NO_EXEMPLAR)))

;; expandDeme cleanly returns NO_EXEMPLAR short-circuit
!(assertEqual
   (expandDeme (singleMetaPop) 0 1 False None () () () mi)
   (Error (singleMetaPop) (NO_EXEMPLAR)))

;; ------------------------------------------------------------
;; Test 2: Multi-candidate metapopulation exhaustion
;; ------------------------------------------------------------
!(py-call (visited_tracker.reset))
;; candA and candB both initially eligible
!(assertEqual (isExemplarEligible (candA)) True)
!(assertEqual (isExemplarEligible (candB)) True)

;; Select candA -> marks candA visited
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (isExemplarEligible (candA)) False)
!(assertEqual (isExemplarEligible (candB)) True)

;; Now select from twoMetaPop: only candB is eligible, so candB must be selected
!(assertEqual (selectExemplar (twoMetaPop)) (candB))
;; candB is now also visited and ineligible
!(assertEqual (isExemplarEligible (candB)) False)

;; Both candidates exhausted -> returns NO_EXEMPLAR
!(assertEqual (selectExemplar (twoMetaPop)) (Error (twoMetaPop) (NO_EXEMPLAR)))

;; expandDeme on exhausted multi-candidate metapop returns NO_EXEMPLAR
!(assertEqual
   (expandDeme (twoMetaPop) 0 1 False None () () () mi)
   (Error (twoMetaPop) (NO_EXEMPLAR)))

;; ------------------------------------------------------------
;; Test 3: Relaxation to revisit = 1 (allow 1 revisit, 2 visits total)
;; ------------------------------------------------------------
!(set-param revisit 1)
!(py-call (visited_tracker.reset))

;; Visit 1: eligible before, selected, still eligible after (count=1 <= 1)
!(assertEqual (isExemplarEligible (candA)) True)
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (isExemplarEligible (candA)) True)

;; Visit 2: selected again, now count=2 > 1 -> ineligible
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (isExemplarEligible (candA)) False)

;; Visit 3: exhausted
!(assertEqual (selectExemplar (singleMetaPop)) (Error (singleMetaPop) (NO_EXEMPLAR)))

;; ------------------------------------------------------------
;; Test 4: Unbounded revisit = -1 (guard disabled)
;; ------------------------------------------------------------
!(set-param revisit -1)
!(py-call (visited_tracker.reset))

;; Even after multiple selections, remains eligible
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (isExemplarEligible (candA)) True)

;; ------------------------------------------------------------
;; Test 5: Real runMoses exhaustion test
;; ------------------------------------------------------------
;; Setup: under revisit=0, an exhausted metapopulation passed to runMoses
;; with maxGen=10 must terminate immediately through (Termination: EXHAUSTED)
;; without recursing down to maxGen=0.
!(set-param revisit 0)
!(py-call (visited_tracker.reset))
;; Mark candA visited so that it reaches revisit limit
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (isExemplarEligible (candA)) False)

;; Call runMoses with maxGen=10 and nExpansion=1 (so no initial entry reset)
!(assertEqual
   (runMoses 10 0 (singleMetaPop) 1 1 (False None () ()) None)
   (singleMetaPop))

;; Verify exactly one exhaustion occurred (proving immediate termination without looping through maxGen)
!(assertEqual (py-call (visited_tracker.get_exhaustion_count)) 1)

;; ------------------------------------------------------------
;; Test 6: Reset-through-entry-point test (validates runMoses line 116)
;; ------------------------------------------------------------
;; Prior tests left candA at its visit limit (ineligible under revisit=0)
!(assertEqual (isExemplarEligible (candA)) False)

;; Call runMoses at entry point (nExpansion = 0).
;; Line 116 must automatically execute visited_tracker.reset().
!(runMoses 0 0 (singleMetaPop) 0 1 (False None () ()) None)

;; Validate that candA is now eligible again without any manual reset
!(assertEqual (isExemplarEligible (candA)) True)

;; A second run starting at nExpansion=0 can successfully select/expand candA again
!(assertEqual (selectExemplar (singleMetaPop)) (candA))

;; ------------------------------------------------------------
;; Test 7: Visit recording inside selectExemplar (Classic C++ MOSES parity)
;; ------------------------------------------------------------
;; In classic C++ MOSES, select_exemplar increments visit count immediately
;; upon candidate selection (e->visited++). Redundant calls in expandDeme were removed.
!(set-param revisit 0)
!(py-call (visited_tracker.reset))

;; Initially, candA has 0 visits in visited_tracker
!(assertEqual (py-call (visited_tracker.get_visit_count (preOrder (mkTree (mkNode A) ())))) 0)

;; selectExemplar directly calls recordExemplarVisit upon selecting candA
!(assertEqual (selectExemplar (singleMetaPop)) (candA))

;; Directly verify visited_tracker recorded the visit from selectExemplar alone
!(assertEqual (py-call (visited_tracker.get_visit_count (preOrder (mkTree (mkNode A) ())))) 1)

;; Under revisit=0, candA is immediately marked ineligible
!(assertEqual (isExemplarEligible (candA)) False)

;; ------------------------------------------------------------
;; Test 8: Unified metapopulation filtering (filterEligibleExemplars)
;; ------------------------------------------------------------
;; Single and multi-candidate metapopulations are processed through
;; filterEligibleExemplars, preventing PeTTa case-unification conflicts.
!(set-param revisit 0)
!(py-call (visited_tracker.reset))

;; 8a. Empty metapopulation returns ()
!(assertEqual (filterEligibleExemplars ()) ())

;; 8b. Single eligible candidate returns ((candA))
!(assertEqual (filterEligibleExemplars (singleMetaPop)) (singleMetaPop))

;; 8c. Select candA -> marks candA visited and ineligible
!(assertEqual (selectExemplar (singleMetaPop)) (candA))
!(assertEqual (isExemplarEligible (candA)) False)

;; 8d. Single ineligible candidate through filterEligibleExemplars yields ()
!(assertEqual (filterEligibleExemplars (singleMetaPop)) ())

;; 8e. Single exhausted candidate returns NO_EXEMPLAR without case-unification conflict
!(assertEqual (selectExemplar (singleMetaPop)) (Error (singleMetaPop) (NO_EXEMPLAR)))

;; 8f. Mixed multi-candidate pool filters only eligible exemplars
;; (candA ineligible, candB fresh)
!(assertEqual (filterEligibleExemplars (twoMetaPop)) ((candB)))
!(assertEqual (selectExemplar (twoMetaPop)) (candB))
;; After candB is selected, twoMetaPop is completely exhausted
!(assertEqual (filterEligibleExemplars (twoMetaPop)) ())
!(assertEqual (selectExemplar (twoMetaPop)) (Error (twoMetaPop) (NO_EXEMPLAR)))

!(println! "ALL EXEMPLAR REVISIT GUARD TESTS PASSED SUCCESSFULLY!")
