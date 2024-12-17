!(register-module! ../../../metta-moses)

!(import! &self metta-moses:utilities:general-helpers)

!(assertEqualToResult (~= 1 2) (True))
!(assertEqualToResult (~= 1 1) (False))

!(assertEqualToResult (~= Something Nothing) (True))
!(assertEqualToResult (~= Something Something) (False))
!(assertEqualToResult (~= Something something) (True))

;; Tests for the function 'concatTuple'
!(assertEqualToResult (concatTuple () (3 4)) ((3 4)))
!(assertEqualToResult (concatTuple (1 2) (3 4)) ((1 2 3 4)))
!(assertEqualToResult (concatTuple (1 2) ()) ((1 2)))
!(assertEqualToResult (concatTuple () ()) (()))

;; Tests for the function 'Not'
!(assertEqualToResult (Not (Not (Not A))) ((NOT A)))
!(assertEqualToResult (Not (Not A)) (A))

;; Tests for the function 'isMember'
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

;; These are functions used for testing helper functions.

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

;; A function that turns every atom to unit
(: transformToUnit (-> Atom Atom))
(= (transformToUnit $x) ())

;; Test for dummy function of until
!(assertEqual (isZero 1) False)
!(assertEqual (isZero 0) True)

!(assertEqual (greaterThanTen 8) False)
!(assertEqual (greaterThanTen 0) False)
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

;; Test for map function

!(assertEqual (map increment (1 2 3 4)) (2 3 4 5))
!(assertEqual (map decrement (1 2 3 4)) (0 1 2 3))
!(assertEqual (map transformToUnit (A B C (A C D) E)) (() () () () ()))
!(assertEqual (map isUnit (A B C (A C D) E)) (False False False False False))
!(assertEqual (map isUnit (map transformToUnit (A B C (A C D) E))) (True True True True True))
!(assertEqual (map isZero (map decrement (1 2 3 4))) (True False False False))
!(assertEqual (map isZero (1 2 3 4)) (False False False False))
!(assertEqual (map isZero (0 1 2 3 4)) (True False False False False))
!(assertEqual (map isSingleAtom (A B C (A C D) E)) (False False False False False))
!(assertEqual (map greaterThanTen (1 10 2 23 32 7 8 43 0 2)) (False False False True True False False True False False))
!(assertEqual (map greaterThanTen (1 10 2 23 32 7 8 43 0)) (False False False True True False False True False))

;; Test count atom function
!(assertEqual (count expr (bop expr expr bop bop expr x y a expr u expr z a)) 5)
!(assertEqual (count bop (bop expr expr bop bop expr x y a expr u expr z a)) 3)
!(assertEqual (count x (bop expr expr bop bop expr x y a expr u expr z a)) 1)
!(assertEqual (count u (bop expr expr bop bop expr x y a expr u expr z a)) 1)
!(assertEqual (count f (bop expr expr bop bop expr x y a expr u expr z a)) 0)
!(assertEqual (count z (bop expr expr bop bop expr x y a expr u expr z a)) 1)
!(assertEqual (count expr ()) 0)
!(assertEqual (count expr (expr)) 1)
!(assertEqual (count expr (bop)) 0)

;; Test sum function
!(assertEqual (sum (1 2 3 4 5 6 7 8 9 10)) 55)
!(assertEqual (sum (1 1 1 1)) 4)
!(assertEqual (sum (1)) 1)

;; Test curry function
!(assertEqual (((curry +) 1) 2) 3)
!(assertEqual (((curry -) 5) 4) 1)

;; Test filter function
!(assertEqual (collapse (filter isUnit (9 10 () 5 4 ()))) (() ()))
!(assertEqual (collapse (filter isSingleAtom (9 10 (Hello) 5 4 (Nop) ()))) ((Hello) (Nop)))
!(assertEqual (collapse (filter isZero (9 10 0 5 4 0))) (0 0))
!(assertEqual (collapse (filter greaterThanTen (9 10 12 5 4 28))) (12 28))

;; Test wrapper function for filter function
!(assertEqual (wrapper isZero 0) 0)
!(assertEqual (wrapper isZero 1) (empty))
!(assertEqual (wrapper isUnit 1) (empty))
!(assertEqual (wrapper isUnit ()) ())

;; Test foldr function
!(assertEqual (foldr + 0 (1 2 3)) 6)
!(assertEqual (foldr + 0 (1 2 3)) 6)
