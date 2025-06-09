!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:map)
! (import! &self metta-moses:representation:knob-representation)

;; Testcase Map.insert
! (assertEqual (Map.insert (4 d) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap)))))
! (assertEqual (Map.insert (1 e) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (ConsMap (1 e) (ConsMap (2 b) (ConsMap (3 c) NilMap))))
! (assertEqual (Map.insert (2 b) (ConsMap (1 a) (ConsMap (3 c) (ConsMap (4 d) NilMap)))) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap)))))

;;Testcase for Map.insertCounter
! (assertEqual (Map.insertCounter 1 (ConsMap (1 1) (ConsMap (2 2) (ConsMap (3 3) NilMap)))) (ConsMap (1 2) (ConsMap (2 2) (ConsMap (3 3) NilMap))))
! (assertEqual (Map.insertCounter 1 NilMap) (ConsMap (1 1) NilMap))
! (assertEqual (Map.insertCounter 2 (ConsMap (2 2) (ConsMap (3 3) NilMap))) (ConsMap (2 3) (ConsMap (3 3) NilMap)))
! (assertEqual (Map.insertCounter 7 (ConsMap (1 1) (ConsMap (2 2) (ConsMap (3 3) NilMap)))) (ConsMap (1 1) (ConsMap (2 2) (ConsMap (3 3) (ConsMap (7 1) NilMap)))))

;; Testcase for Map.remove
! (assertEqual (Map.remove 5 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (Error 5 "not found"))
! (assertEqual (Map.remove 1 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap))))) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap))))
! (assertEqual (Map.remove 2 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (ConsMap (1 a) (ConsMap (3 c) NilMap)))


;; Testcase for Map.contains
! (assertEqual (Map.contains 5 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) False)
! (assertEqual (Map.contains 1 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap))))) True)
! (assertEqual (Map.contains 2 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) True)

;; Testcase for Map.checkValue
! (assertEqual (Map.checkValue a (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) True)
! (assertEqual (Map.checkValue d (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap))))) True)
! (assertEqual (Map.checkValue f (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) False)

;; Testcase for Map.getByKey
! (assertEqual (Map.getByKey 1 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) a)
! (assertEqual (Map.getByKey 3 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) c)
! (assertEqual (Map.getByKey 10 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (Error 10 "not found"))

;; Testcase for Map.keys
! (assertEqual (Map.keys (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (Cons 1 (Cons 2 (Cons 3 Nil))))
! (assertEqual (Map.keys (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 (Cons 7 (Cons 8 (Cons 9 Nil))))))))))
! (assertEqual (Map.keys NilMap) Nil)

;; Testcase for Map.values
! (assertEqual (Map.values (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (Cons a (Cons b (Cons c Nil))))
! (assertEqual (Map.values (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (Cons a (Cons b (Cons c (Cons d (Cons e (Cons f (Cons g (Cons h (Cons i Nil))))))))))
! (assertEqual (Map.values NilMap) Nil)

;; Testcase for Map.items
! (assertEqual (Map.items (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (Cons (1 a) (Cons (2 b) (Cons (3 c) Nil))))
! (assertEqual (Map.items (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (Cons (1 a) (Cons (2 b) (Cons (3 c) (Cons (4 d) (Cons (5 e) (Cons (6 f) (Cons (7 g) (Cons (8 h) (Cons (9 i) Nil))))))))))
! (assertEqual (Map.items NilMap) Nil)

;; Testcase for Map.length
! (assertEqual (Map.length (ConsMap (3 c) NilMap)) 1)
! (assertEqual (Map.length (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) 3)
! (assertEqual (Map.length (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) 9)

;; Testcase for Map.insert which uses custom comparison functions
! (assertEqual (Map.insert ((mkNodeId (2 2)) 0) (ConsMap ((mkNodeId (2 1))  1) (ConsMap ((mkNodeId (2 3))  2) NilMap)) == nodeId<)
               (ConsMap ((mkNodeId (2 1)) 1) (ConsMap ((mkNodeId (2 2)) 0) (ConsMap ((mkNodeId (2 3)) 2) NilMap))))
! (assertEqual (Map.insert ((mkNodeId (2 2)) 0) NilMap == nodeId<) (ConsMap ((mkNodeId (2 2)) 0) NilMap))
