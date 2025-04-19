!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:ordered-multimap)

;; Testcase MultiMap.insert
! (assertEqual (MultiMap.insert (4 d) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap)))))
! (assertEqual (MultiMap.insert (2 b) NilMMap) (ConsMMap (2 b)  NilMMap))
! (assertEqual (MultiMap.insert (1 e) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap))) ==) (ConsMMap (1 e) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))))
! (assertEqual (MultiMap.insert (2 e) (ConsMMap (1 a) NilMMap) >) (ConsMMap (2 e) (ConsMMap (1 a) NilMMap)))
! (assertEqual (MultiMap.insert (1 b) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap))) <) (ConsMMap (1 a) (ConsMMap (1 b) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))))

;; Testcase for MultiMap.findOne
! (assertEqual (MultiMap.findOne 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) a)
! (assertEqual (MultiMap.findOne 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c) NilMMap)))) b)
! (assertEqual (MultiMap.findOne 6 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (Error 6 "not found"))

;; Testcase for MultiMap.findAll
! (assertEqual (MultiMap.findAll 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (Cons a Nil))
! (assertEqual (MultiMap.findAll 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c)(ConsMMap (2 b) (ConsMMap (2 d) NilMMap)))))) (Cons b (Cons c (Cons b (Cons d Nil)))))
! (assertEqual (MultiMap.findAll 6 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) Nil)

;; Testcase for MultiMap.removeOne
! (assertEqual (MultiMap.removeOne 5 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (Error 5 "not found"))
! (assertEqual (MultiMap.removeOne 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))
! (assertEqual (MultiMap.removeOne 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c) NilMMap)))) (ConsMMap (1 a) (ConsMMap (2 c) NilMMap)))

;; Testcase for MultiMap.removeAll
! (assertEqual (MultiMap.removeAll 5 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap))))
! (assertEqual (MultiMap.removeAll 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))
! (assertEqual (MultiMap.removeAll 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c) NilMMap)))) (ConsMMap (1 a) NilMMap))


;; Testcase for MultiMap.contains
! (assertEqual (MultiMap.contains 5 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) False)
! (assertEqual (MultiMap.contains 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))) True)
! (assertEqual (MultiMap.contains 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) True)

;; Testcase for MultiMap.checkValue
! (assertEqual (MultiMap.checkValue a (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) True)
! (assertEqual (MultiMap.checkValue d (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))) True)
! (assertEqual (MultiMap.checkValue f (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) False)

;; Testcase for Map.values
! (assertEqual (MultiMap.values (ConsMultiMap (1 a) (ConsMultiMap (2 b) (ConsMultiMap (3 c) NilMMap)))) (a b c))
! (assertEqual (MultiMap.values (ConsMultiMap (1 a) (ConsMultiMap (2 b) (ConsMultiMap (3 c) (ConsMultiMap (4 d)(ConsMultiMap (5 e) (ConsMultiMap (6 f) (ConsMultiMap (7 g) (ConsMultiMap (8 h) (ConsMultiMap (9 i) NilMMap)))))))))) (a b c d e f g h i))
! (assertEqual (MultiMap.values NilMMap) ())

;; Testcase for MultiMap.keys
! (assertEqual (MultiMap.keys (ConsMultiMap (1 a) (ConsMultiMap (2 b) (ConsMultiMap (3 c) NilMMap)))) (1 2 3))
! (assertEqual (MultiMap.keys (ConsMultiMap (1 a) (ConsMultiMap (2 b) (ConsMultiMap (3 c) (ConsMultiMap (4 d)(ConsMultiMap (5 e) (ConsMultiMap (6 f) (ConsMultiMap (7 g) (ConsMultiMap (8 h) (ConsMultiMap (9 i) NilMMap)))))))))) (1 2 3 4 5 6 7 8 9))
! (assertEqual (MultiMap.keys NilMMap) ())

;; Testcase for MultiMap.items
! (assertEqual (MultiMap.items (ConsMultiMap (1 a) (ConsMultiMap (2 b) (ConsMultiMap (3 c) NilMMap)))) ((1 a) (2 b) (3 c)))
! (assertEqual (MultiMap.items (ConsMultiMap (1 a) (ConsMultiMap (2 b) (ConsMultiMap (3 c) (ConsMultiMap (4 d)(ConsMultiMap (5 e) (ConsMultiMap (6 f) (ConsMultiMap (7 g) (ConsMultiMap (8 h) (ConsMultiMap (9 i) NilMMap)))))))))) ((1 a) (2 b) (3 c) (4 d) (5 e) (6 f) (7 g) (8 h) (9 i)))
! (assertEqual (MultiMap.items NilMMap) ())


;; Testcase for MultiMap.length
! (assertEqual (MultiMap.length (ConsMMap (3 c) NilMMap)) 1)
! (assertEqual (MultiMap.length (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) 3)
! (assertEqual (MultiMap.length (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) 9)
