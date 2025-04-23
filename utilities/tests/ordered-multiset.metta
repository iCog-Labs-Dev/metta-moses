!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:ordered-multiset)

;; Testcase OMS.insert
! (assertEqual (OMS.insert 4 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 (ConsOMS 4 NilOMS)))))
! (assertEqual (OMS.insert 1 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) (ConsOMS 1 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))))
! (assertEqual (OMS.insert 2 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) (ConsOMS 1 (ConsOMS 2 (ConsOMS 2 (ConsOMS 3 NilOMS)))))

;; Testcase for OMS.remove
! (assertEqual (OMS.remove 5 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS))))
! (assertEqual (OMS.remove 1 (ConsOMS 1 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS))))) (ConsOMS 2 (ConsOMS 3 NilOMS)))
! (assertEqual (OMS.remove 2 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) (ConsOMS 1 (ConsOMS 3 NilOMS)))

;; Testcase for OMS.contains
! (assertEqual (OMS.contains 5 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) False)
! (assertEqual (OMS.contains 1 (ConsOMS 1 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS))))) True)
! (assertEqual (OMS.contains 2 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) True)

;; Testcase for OMS.getByIdx
! (assertEqual (OMS.getByIdx 0 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) 1)
! (assertEqual (OMS.getByIdx 1 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 NilOMS)))) 2)
! (assertEqual (OMS.getByIdx 7 (ConsOMS 1 (ConsOMS 2 (ConsOMS 3 (ConsOMS 4 (ConsOMS 5 (ConsOMS 6 (ConsOMS 7 (ConsOMS 8 (ConsOMS 9 NilOMS)))))))))) 8)
