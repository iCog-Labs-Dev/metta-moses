! (register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)

!(assertEqualToResult (~= 1 2) (True))
!(assertEqualToResult (~= 1 1) (False))

!(assertEqualToResult (~= Something Nothing) (True))
!(assertEqualToResult (~= Something Something) (False))
!(assertEqualToResult (~= Something something) (True))

; tests for the function 'Not' 
  ! (assertEqualToResult (Not (Not (Not A))) ((NOT A)))
  ! (assertEqualToResult (Not (Not A)) (A))

; tests for the function 'isMember'
! (assertEqualToResult (isMember 1 (1 2 3)) (True))
! (assertEqualToResult (isMember 8 (1 2 3)) (False))
