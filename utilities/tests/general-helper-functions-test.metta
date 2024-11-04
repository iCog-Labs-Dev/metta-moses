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

;; Tests for until function

;; These are functions used for testing until function.

;; It returns True only if the input is zero.
(: isZero (-> Number Bool))
(= (isZero $x) (== $x 0))

;; It will return True if greater than 10.
(: greaterThanTen (-> Number Bool))
(= (greaterThanTen $x) (> $x 10))

;; It will return True if input is unit atom.
(: isUnit (-> Atom Bool))
(= (isUnit $x) (== $x ()))

(: isSingleAtom (-> Atom Bool))
(= (isSingleAtom $x) (if (== (get-metatype $x) Expression) (== (cdr-atom $x) ()) False))

;; It will decrement the input by 1.
(: decrement (-> Number Number))
(= (decrement $x) (- $x 1))

;; It will increment the input by 1.
(: increment (-> Number Number))
(= (increment $x) (+ $x 1))

;; Test for dummy function of until
!(assertEqual (isZero 1) False)
!(assertEqual (isZero 0) True)

!(assertEqual (greaterThanTen 8) False)
!(assertEqual (greaterThanTen 11) True)

!(assertEqual (isUnit (foo bar bae)) False)
!(assertEqual (isUnit ()) True)

!(assertEqual (isSingleAtom (foo bar bae)) False)
!(assertEqual (isSingleAtom (foo)) True)
!(assertEqual (isSingleAtom ()) False)

!(assertEqual (decrement 1) 0)
!(assertEqual (decrement -1) -2)
!(assertEqual (decrement 100000) 99999)

!(assertEqual (increment 1) 2)
!(assertEqual (increment -1) 0)
!(assertEqual (increment 100000) 100001)

;; Test for actual until function

!(assertEqual (until isZero decrement 10) 0)
!(assertEqual (until greaterThanTen increment 0) 11)
!(assertEqual (until isUnit cdr-atom (foo bar bae)) ())
!(assertEqual (until isSingleAtom cdr-atom (foo bar bae)) (bae))
