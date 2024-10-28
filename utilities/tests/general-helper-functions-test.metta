! (register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:general-helpers)

!(assertEqualToResult (~= 1 2) (True))
!(assertEqualToResult (~= 1 1) (False))

!(assertEqualToResult (~= Something Nothing) (True))
!(assertEqualToResult (~= Something Something) (False))
!(assertEqualToResult (~= Something something) (True))

;;tests for the function 'concatTuple'
!(assertEqualToResult (concatTuple () (3 4)) ((3 4)))
!(assertEqualToResult (concatTuple (1 2) (3 4)) ((1 2 3 4)))
!(assertEqualToResult (concatTuple (1 2) ()) ((1 2)))
!(assertEqualToResult (concatTuple () ()) (()))

; tests for the function 'Not' 
  ! (assertEqualToResult (Not (Not (Not A))) ((NOT A)))
  ! (assertEqualToResult (Not (Not A)) (A))

; tests for the function 'isMember'
!(assertEqualToResult (isMember 1 ()) (False))
!(assertEqualToResult (isMember 2 (2 3 4 5)) (True))
!(assertEqualToResult (isMember 3 (1 2 4 5)) (False))


! (assertEqual (setDifference (AND a b (NOT a) c (OR a b)) (a b (NOT a) (OR a b)) ) (AND c))
! (assertEqual (setDifference (AND a b (NOT a) c (OR a b)) (a c (NOT c) (NOT a)) ) (AND b (OR a b)))
! (assertEqual (setDifference (AND a b (NOT a) c (OR a b)) (a) )  (AND b (NOT a) c (OR a b)))
! (assertEqual (setDifference (AND a b (NOT a) c (OR a b v) v) (b (NOT a) v) ) (AND a c (OR a b v)))

;; Tests for findAndReplace function

!(assertEqual (findAndReplace A Z (B C A (A B C) F G A)) (B C Z (A B C) F G Z))
!(assertEqual (findAndReplace (A B C) Z (B C A (A B C) F G A)) (B C A Z F G A))
!(assertEqual (findAndReplace G 1 (B C A (A B C) F G A)) (B C A (A B C) F 1 A))
!(assertEqual (findAndReplace Z 1 (B C A (A B C) F G A)) (B C A (A B C) F G A))
!(assertEqual (findAndReplace A Z (A C A (A B C) A G A)) (Z C Z (A B C) Z G Z))
!(assertEqual (findAndReplace F (A B C) (B C A (A B C) F G A)) (B C A (A B C) (A B C) G A))
