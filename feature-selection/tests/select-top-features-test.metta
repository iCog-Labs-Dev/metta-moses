!(register-module! ../../../metta-moses)
!(import! &self metta-moses:feature-selection:select-top-features)
!(import! &self metta-moses:feature-selection:similarity-scorers)
!(import! &self metta-moses:feature-selection:feature-selection-helpers)
!(import! &self metta-moses:scoring:cscore)
!(import! &self metta-moses:utilities:general-helpers)

;; Tests
! (assertEqual (rankFtSet 2 -1 False ja ((1 (0 2)) (0.4 (3 1)) (0.3 (1 2 3))) ()) ((0 2) (3 1) (1 2 3)))     
! (assertEqual (rankFtSet 2 -1 False mi ((1 (0 2)) (0.4 (3 1)) (0.3 (1 2 3))) ()) ((0 2) (3 1) (1 2 3)))    

! (assertEqual (selectTopFts -2 -1 False ja ((1 (0 2)) (0.4 (3 1)) (0.3 (1 2 3))) 2) ((0 2) (3 1)))
! (assertEqual (selectTopFts 2 -1 False mi ((1 (0 2)) (0.4 (3 1)) (0.3 (1 2 3))) 2) ((0 2) (3 1)))
! (assertEqual (selectTopFts 2 -1 False ja ((1 (0 2)) (0.8 (0 1)) (0.4 (3 1)) (0.3 (1 2 3))) 2) ((0 2) (3 1)))