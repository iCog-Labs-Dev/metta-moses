! (register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:moses-types)

;output test
! (assertEqual (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (0))) AND)
! (assertEqual (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (1))) (OR A B))
! (assertEqual (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (1 2))) B)
! (assertEqual (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (2 2))) (AND D E))
! (assertEqual (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (2 2 2))) E)

;type test
! (assertEqual (get-type (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (0)))) Node)
! (assertEqual (get-type (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (1)))) Node)
! (assertEqual (get-type (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (1 2)))) Node)
! (assertEqual (get-type (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (2 2)))) Node)
! (assertEqual (get-type (getNodeById (AND (OR A B) (OR C (AND D E))) (mkNodeId (2 2 2)))) Node)
