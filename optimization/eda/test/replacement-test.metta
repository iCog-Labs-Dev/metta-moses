!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:optimization:eda/replacement)
!(import! &self metta-moses:optimization:eda/sampling)
!(import! &self metta-moses:utilities:general-helpers)
!(import! &self metta-moses:utilities:list-methods)
!(import! &self metta-moses:representation:instance)
!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:deme:create-deme)
!(import! &self metta-moses:utilities:tree)
!(import! &self metta-moses:utilities:nodeId)
!(import! &self metta-moses:utilities:map)
!(import! &self metta-moses:utilities:pair)
!(import! &self metta-moses:utilities:ordered-multimap)
!(import! &self metta-moses:utilities:ordered-set)



;; ================================================================================
;; Replacement Policy Tests
;; ================================================================================

;; Create test deme with instances
!(bind! test_deme (mkDeme 
  (mkRep 
    (mkKbMap 
      (mkDscKbMp (ConsMap ((mkNodeId (1)) 0) (ConsMap ((mkNodeId (2)) 1) NilMap))) 
      (mkDscMp (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) 
                        (ConsMMap ((mkDiscSpec 3) (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))) NilMMap)))) 
    (mkTree (mkNode AND) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil)))) 
  (mkSInstSet (Cons 
    (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) 
    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) 
    (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 0 2 1.0 0.0 -1.0))) 
    (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) Nil))))) 
  0))

;; Worst instance identification returns last 2 after sort-by-score (descending best first)
!(assertEqual 
  (get-worst-instances (getScoredInstances (getInstanceSet test_deme)) 2)
  (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 Nil))) (mkCscore -1 1 0.5 0.0 -1.5)))
        (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) Nil)))

;; Removing worst 2 keeps the better 2
!(assertEqual 
  (remove-worst-instances (getScoredInstances (getInstanceSet test_deme)) 2)
  (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 0 2 1.0 0.0 -1.0)))
        (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 Nil))) (mkCscore -1 1 0.5 0.0 -1.5))) Nil)))

;; sort-by-score sorts descending by penalized score then ascending complexity
!(assertEqual 
  (sort-by-score (getScoredInstances (getInstanceSet test_deme)))
  (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 0 2 1.0 0.0 -1.0)))
        (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 Nil))) (mkCscore -1 1 0.5 0.0 -1.5)))
              (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 Nil))) (mkCscore -1 1 0.5 0.0 -1.5)))
                    (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 2 Nil))) (mkCscore -3 1 0.5 0.0 -3.5))) Nil)))))

;; Replacement inserts new instances and removes worst (assert on instance set)
!(assertEqual 
  (getInstanceSet (replace-the-worst (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 2 Nil))) (mkCscore 1 2 1.0 0.0 0.0))) Nil)) test_deme))
  (mkSInstSet (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 1 Nil))) (mkCscore 0 2 1.0 0.0 -1.0)))
                   (Cons (mkSInst (mkPair (mkInst (Cons 1 (Cons 0 Nil))) (mkCscore -1 1 0.5 0.0 -1.5)))
                         (Cons (mkSInst (mkPair (mkInst (Cons 0 (Cons 1 Nil))) (mkCscore -1 1 0.5 0.0 -1.5)))
                               (Cons (mkSInst (mkPair (mkInst (Cons 2 (Cons 2 Nil))) (mkCscore 1 2 1.0 0.0 0.0))) Nil))))))
