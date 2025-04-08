!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:ordered-multimap)

;; Testcase OMM.insert
! (assertEqual (OMM.insert (4 d) (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) (ConsOMM (4 d) NilOMM)))))
! (assertEqual (OMM.insert (1 e) (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) (ConsOMM (1 e) (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))))
! (assertEqual (OMM.insert (2 b) NilOMM) (ConsOMM (2 b)  NilOMM))

;; Testcase for OMM.findOne
! (assertEqual (OMM.findOne 1 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) a)
! (assertEqual (OMM.findOne 2 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (2 c) NilOMM)))) b)
! (assertEqual (OMM.findOne 6 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) (Error 6 "not found"))

;; Testcase for OMM.findAll
! (assertEqual (OMM.findAll 1 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) (a))
! (assertEqual (OMM.findAll 2 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (2 c)(ConsOMM (2 b) (ConsOMM (2 d) NilOMM)))))) (b c b d))
! (assertEqual (OMM.findAll 6 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) ())

;; Testcase for OMM.removeOne
! (assertEqual (OMM.removeOne 5 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) (Error 5 "not found"))
! (assertEqual (OMM.removeOne 1 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) (ConsOMM (4 d) NilOMM))))) (ConsOMM (2 b) (ConsOMM (3 c) (ConsOMM (4 d) NilOMM))))
! (assertEqual (OMM.removeOne 2 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (2 c) NilOMM)))) (ConsOMM (1 a) (ConsOMM (2 c) NilOMM)))

;; Testcase for OMM.removeAll
! (assertEqual (OMM.removeAll 5 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM))))
! (assertEqual (OMM.removeAll 1 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) (ConsOMM (4 d) NilOMM))))) (ConsOMM (2 b) (ConsOMM (3 c) (ConsOMM (4 d) NilOMM))))
! (assertEqual (OMM.removeAll 2 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (2 c) NilOMM)))) (ConsOMM (1 a) NilOMM))


;; Testcase for OMM.contains
! (assertEqual (OMM.contains 5 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) False)
! (assertEqual (OMM.contains 1 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) (ConsOMM (4 d) NilOMM))))) True)
! (assertEqual (OMM.contains 2 (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) True)

;; Testcase for OMM.checkValue
! (assertEqual (OMM.checkValue a (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) True)
! (assertEqual (OMM.checkValue d (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) (ConsOMM (4 d) NilOMM))))) True)
! (assertEqual (OMM.checkValue f (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) False)

;; Testcase for OMM.length
! (assertEqual (OMM.length (ConsOMM (3 c) NilOMM)) 1)
! (assertEqual (OMM.length (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) NilOMM)))) 3)
! (assertEqual (OMM.length (ConsOMM (1 a) (ConsOMM (2 b) (ConsOMM (3 c) (ConsOMM (4 d)(ConsOMM (5 e) (ConsOMM (6 f) (ConsOMM (7 g) (ConsOMM (8 h) (ConsOMM (9 i) NilOMM)))))))))) 9)
