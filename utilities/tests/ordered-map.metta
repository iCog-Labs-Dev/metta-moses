!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:ordered-map)

;; Testcase OrderedMap.add
! (assertEqual (OrderedMap.add 4 d (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d) NilOrderedMap)))))
! (assertEqual (OrderedMap.add 1 e (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) (Error 1 "already exists"))
! (assertEqual (OrderedMap.add 2 b (ConsOrderedMap (1 a) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d) NilOrderedMap)))) (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d) NilOrderedMap)))))

;; Testcase for OrderedMap.remove
! (assertEqual (OrderedMap.remove 5 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) (Error 5 "not found"))
! (assertEqual (OrderedMap.remove 1 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d) NilOrderedMap))))) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d) NilOrderedMap))))
! (assertEqual (OrderedMap.remove 2 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) (ConsOrderedMap (1 a) (ConsOrderedMap (3 c) NilOrderedMap)))


;; Testcase for OrderedMap.contains
! (assertEqual (OrderedMap.contains 5 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) False)
! (assertEqual (OrderedMap.contains 1 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d) NilOrderedMap))))) True)
! (assertEqual (OrderedMap.contains 2 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) True)

;; Testcase for OrderedMap.valueAtKey
! (assertEqual (OrderedMap.valueAtKey 1 a (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) True)
! (assertEqual (OrderedMap.valueAtKey 3 a (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d) NilOrderedMap))))) False)
! (assertEqual (OrderedMap.valueAtKey 6 f (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) (Error 6 "not found"))


;; Testcase for OrderedMap.replace
! (assertEqual (OrderedMap.replace 1 (a d) (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) (ConsOrderedMap (1 (a d)) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap))))
! (assertEqual (OrderedMap.replace 4 b (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d) NilOrderedMap))))) (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 b) NilOrderedMap)))))
! (assertEqual (OrderedMap.replace 10 b (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) (Error 10 "not found"))

;; Testcase for OrderedMap.getByIdx
! (assertEqual (OrderedMap.getByKey 1 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) a)
! (assertEqual (OrderedMap.getByKey 3 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) c)
! (assertEqual (OrderedMap.getByKey 10 (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d)(ConsOrderedMap (5 e) (ConsOrderedMap (6 f) (ConsOrderedMap (7 g) (ConsOrderedMap (8 h) (ConsOrderedMap (9 i) NilOrderedMap)))))))))) (Error 10 "not found"))

;; Testcase for OrderedMap.length
! (assertEqual (OrderedMap.length (ConsOrderedMap (3 c) NilOrderedMap)) 1)
! (assertEqual (OrderedMap.length (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) NilOrderedMap)))) 3)
! (assertEqual (OrderedMap.length (ConsOrderedMap (1 a) (ConsOrderedMap (2 b) (ConsOrderedMap (3 c) (ConsOrderedMap (4 d)(ConsOrderedMap (5 e) (ConsOrderedMap (6 f) (ConsOrderedMap (7 g) (ConsOrderedMap (8 h) (ConsOrderedMap (9 i) NilOrderedMap)))))))))) 9)
