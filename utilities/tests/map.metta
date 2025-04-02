!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:map)

;; Testcase map.add
! (assertEqual (map.add 4 d (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d) Nilmap)))))
! (assertEqual (map.add 1 e (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) (Error 1 "already exists"))
! (assertEqual (map.add 2 b (Consmap (1 a) (Consmap (3 c) (Consmap (4 d) Nilmap)))) (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d) Nilmap)))))

;; Testcase for map.remove
! (assertEqual (map.remove 5 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) (Error 5 "not found"))
! (assertEqual (map.remove 1 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d) Nilmap))))) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d) Nilmap))))
! (assertEqual (map.remove 2 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) (Consmap (1 a) (Consmap (3 c) Nilmap)))


;; Testcase for map.contains
! (assertEqual (map.contains 5 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) False)
! (assertEqual (map.contains 1 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d) Nilmap))))) True)
! (assertEqual (map.contains 2 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) True)

;; Testcase for map.valueAtKey
! (assertEqual (map.valueAtKey 1 a (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) True)
! (assertEqual (map.valueAtKey 3 a (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d) Nilmap))))) False)
! (assertEqual (map.valueAtKey 6 f (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) (Error 6 "not found"))


;; Testcase for map.replace
! (assertEqual (map.replace 1 (a d) (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) (Consmap (1 (a d)) (Consmap (2 b) (Consmap (3 c) Nilmap))))
! (assertEqual (map.replace 4 b (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d) Nilmap))))) (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 b) Nilmap)))))
! (assertEqual (map.replace 10 b (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) (Error 10 "not found"))

;; Testcase for map.getByIdx
! (assertEqual (map.getByKey 1 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) a)
! (assertEqual (map.getByKey 3 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) c)
! (assertEqual (map.getByKey 10 (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d)(Consmap (5 e) (Consmap (6 f) (Consmap (7 g) (Consmap (8 h) (Consmap (9 i) Nilmap)))))))))) (Error 10 "not found"))

;; Testcase for map.length
! (assertEqual (map.length (Consmap (3 c) Nilmap)) 1)
! (assertEqual (map.length (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) Nilmap)))) 3)
! (assertEqual (map.length (Consmap (1 a) (Consmap (2 b) (Consmap (3 c) (Consmap (4 d)(Consmap (5 e) (Consmap (6 f) (Consmap (7 g) (Consmap (8 h) (Consmap (9 i) Nilmap)))))))))) 9)
