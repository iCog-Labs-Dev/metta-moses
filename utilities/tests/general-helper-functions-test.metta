! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)

!(assertEqualToResult (~= 1 2) (True))
!(assertEqualToResult (~= 1 1) (False))

!(assertEqualToResult (~= Something Nothing) (True))
!(assertEqualToResult (~= Something Something) (False))
!(assertEqualToResult (~= Something something) (True))
