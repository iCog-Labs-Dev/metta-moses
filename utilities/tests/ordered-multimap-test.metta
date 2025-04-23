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
! (assertEqual (MultiMap.values (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (Cons a (Cons b (Cons c Nil))))
! (assertEqual (MultiMap.values (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) (Cons a (Cons b (Cons c (Cons d (Cons e (Cons f (Cons g (Cons h (Cons i Nil))))))))))
! (assertEqual (MultiMap.values NilMMap) Nil)

;; Testcase for MultiMap.keys
! (assertEqual (MultiMap.keys (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (Cons 1 (Cons 2 (Cons 3 Nil))))
! (assertEqual (MultiMap.keys (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) (Cons 1 (Cons 2 (Cons 3 (Cons 4 (Cons 5 (Cons 6 (Cons 7 (Cons 8 (Cons 9 Nil))))))))))
! (assertEqual (MultiMap.keys NilMMap) Nil)

;; Testcase for MultiMap.items
! (assertEqual (MultiMap.items (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (Cons (1 a) (Cons (2 b) (Cons (3 c) Nil))))
! (assertEqual (MultiMap.items (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) (Cons (1 a) (Cons (2 b) (Cons (3 c) (Cons (4 d) (Cons (5 e) (Cons (6 f) (Cons (7 g) (Cons (8 h) (Cons (9 i) Nil))))))))))
! (assertEqual (MultiMap.items NilMMap) Nil)


;; Testcase for MultiMap.length
! (assertEqual (MultiMap.length (ConsMMap (3 c) NilMMap)) 1)
! (assertEqual (MultiMap.length (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) 3)
! (assertEqual (MultiMap.length (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) 9)

;; Testcase for MultiMap.checkElement
!(assertEqual (MultiMap.checkElement (1 a) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) True)
!(assertEqual (MultiMap.checkElement (3 a) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) False)

;; Testcase for MultiMap.equals
!(assertEqual (MultiMap.equals (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))
(ConsMMap (2 b) (ConsMMap (1 a) (ConsMMap (3 c) NilMMap)))) True)
!(assertEqual (MultiMap.equals (ConsMMap (1 b) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))
(ConsMMap (2 b) (ConsMMap (1 a) (ConsMMap (3 c) NilMMap)))) False)