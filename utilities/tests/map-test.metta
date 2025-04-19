!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:map)

;; Testcase Map.insert
! (assertEqual (Map.insert (4 d) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap)))))
! (assertEqual (Map.insert (1 e) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (ConsMap (1 e) (ConsMap (2 b) (ConsMap (3 c) NilMap))))
! (assertEqual (Map.insert (2 b) (ConsMap (1 a) (ConsMap (3 c) (ConsMap (4 d) NilMap)))) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap)))))

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

;; Testcase for Map.values
! (assertEqual (Map.values (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (a b c))
! (assertEqual (Map.values (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (a b c d e f g h i))
! (assertEqual (Map.values NilMap) ())

;; Testcase for Map.keys
! (assertEqual (Map.keys (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (1 2 3))
! (assertEqual (Map.keys (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (1 2 3 4 5 6 7 8 9))
! (assertEqual (Map.keys NilMap) ())

;; Testcase for Map.items
! (assertEqual (Map.items (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) ((1 a) (2 b) (3 c)))
! (assertEqual (Map.items (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) ((1 a) (2 b) (3 c) (4 d) (5 e) (6 f) (7 g) (8 h) (9 i)))
! (assertEqual (Map.items NilMap) ())

;; Testcase for Map.length
! (assertEqual (Map.length (ConsMap (3 c) NilMap)) 1)
! (assertEqual (Map.length (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) 3)
! (assertEqual (Map.length (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) 9)
