!(import! &self ../general-helpers)
!(import! &self ../ordered-multimap)
!(import! &self ../list-methods)
!(import! &self ../map)
!(import! &self ../../representation/knob-representation)
!(import! &self ../ordered-set)
!(import! &self ../ordered-multiset)
!(import! &self ../../representation/instance)
!(import! &self ../../scoring/bscore)
!(import! &self ../../scoring/cscore)

; ; !(bind! &newSpace (new-space))
!(println! ("test ~= "))
!(assertEqual (~= 1 2) True)
!(assertEqual (~= 1 1) False)

!(assertEqual (~= Something Nothing) True)
!(assertEqual (~= Something Something) False)
!(assertEqual (~= Something something) True)


;; Tests for get-type-reduce
(: Bar (-> $a $b Type))
(: Foo (-> $a $b (Bar $a $b)))

!(assertEqual (get-type-reduce Bar) Type)
!(assertEqual (get-type-reduce (Foo "Chocolate" "Cake")) (Bar String String))
!(assertEqual (get-type-reduce (Foo 1 2)) (Bar Number Number))
!(assertEqual (get-type-reduce (Foo 1 "2")) (Bar Number String))

;; Tests for the function 'concatTuple' ;; FIX: Failing Test case
!(println! ("test appending instead of concat touples"))
!(assertEqual (append () (3 4)) (3 4))
!(assertEqual (append (1 2) (3 4)) (1 2 3 4))
!(assertEqual (append (1 2) ()) (1 2))
!(assertEqual (append () ()) ())
;; Tests for the function 'Not'
!(println! ("Tests for the function Not"))
!(assertEqual (Not (Not (Not A))) (Not A))
!(assertEqual (Not (Not A)) A)

;; Tests for the function 'is-member'
!(println! ("test is-member function to  replace isMember custom function"))
!(assertEqual (is-member 1 ()) False)
!(assertEqual (is-member 2 (2 3 4 5)) True)
!(assertEqual (is-member 3 (1 2 4 5)) False)

!(println! ("testing: setDifference "))
!(assertEqual (setDifference (AND a b (NOT a) c (OR a b)) (a b (NOT a) (OR a b)) ) (AND c))
!(assertEqual (setDifference (AND a b (NOT a) c (OR a b)) (a c (NOT c) (NOT a)) ) (AND b (OR a b)))
!(assertEqual (setDifference (AND a b (NOT a) c (OR a b)) (a) )  (AND b (NOT a) c (OR a b)))
!(assertEqual (setDifference (AND a b (NOT a) c (OR a b v) v) (b (NOT a) v) ) (AND a c (OR a b v)))

;; ;; Tests for findAndReplace function ;; FIX: Failing Test case
;; !(assertEqual (findAndReplace A Z (B C A (A B C) F G A)) (B C Z (A B C) F G Z))
;; !(assertEqual (findAndReplace (A B C) Z (B C A (A B C) F G A)) (B C A Z F G A))
;; !(assertEqual (findAndReplace G 1 (B C A (A B C) F G A)) (B C A (A B C) F 1 A))
;; !(assertEqual (findAndReplace Z 1 (B C A (A B C) F G A)) (B C A (A B C) F G A))
;; !(assertEqual (findAndReplace A Z (A C A (A B C) A G A)) (Z C Z (A B C) Z G Z))
;; !(assertEqual (findAndReplace F (A B C) (B C A (A B C) F G A)) (B C A (A B C) (A B C) G A))

;; Test for dummy function of until

!(println! "testing isZero ")
!(assertEqual (isZero 1) False)
!(assertEqual (isZero 0) True)

!(println! "testing greaterThanTen ")
!(assertEqual (greaterThanTen 8) False)
!(assertEqual (greaterThanTen 0) False)
!(assertEqual (greaterThanTen 11) True)

!(println! "testing isUnit ")
!(assertEqual (isUnit (foo bar bae)) False)
!(assertEqual (isUnit ()) True)

!(println! "testing decrement ")
!(assertEqual (decrement 1) 0)
!(assertEqual (decrement -1) -2)
!(assertEqual (decrement 100000) 99999)

!(println! "testing increament ")
!(assertEqual (increment 1) 2)
!(assertEqual (increment -1) 0)
!(assertEqual (increment 100000) 100001)

;; Test for actual until function
!(println! (println! ("testing until")))
!(assertEqual (until isZero decrement 10) 0)
!(assertEqual (until greaterThanTen increment 0) 11)

;; FIX: Failing Test case
!(println! ("failing test in until now working ✅"))
!(assertEqual (until isUnit cdr-atom (foo bar bae)) ())
!(assertEqual (until hasOneAtom cdr-atom (foo bar bae)) (bae))

; Test for map function
!(println! "testing map ")
!(assertEqual (map increment (1 2 3 4)) (2 3 4 5))
!(assertEqual (map decrement (1 2 3 4)) (0 1 2 3))
!(assertEqual (map transformToUnit (A B C (A C D) E)) (() () () () ()))
!(assertEqual (map isUnit (A B C (A C D) E)) (False False False False False))
!(assertEqual (map isUnit (map transformToUnit (A B C (A C D) E))) (True True True True True))
!(assertEqual (map isZero (map decrement (1 2 3 4))) (True False False False))
!(assertEqual (map isZero (1 2 3 4)) (False False False False))
!(assertEqual (map isZero (0 1 2 3 4)) (True False False False False))
!(assertEqual (map hasOneAtom (A B C (A C D) E)) (False False False False False))
!(assertEqual (map greaterThanTen (1 10 2 23 32 7 8 43 0 2)) (False False False True True False False True False False))
!(assertEqual (map greaterThanTen (1 10 2 23 32 7 8 43 0)) (False False False True True False False True False))

;; Test count atom function
!(println! ("test count"))
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
!(println! "testing sum ")
!(assertEqual (sum (1 2 3 4 5 6 7 8 9 10)) 55)
!(assertEqual (sum (1 1 1 1)) 4)
!(assertEqual (sum (1)) 1)

;; UNCOMMENT test below if curry works in petta 
;; Test curry function
!(println! ("testing: curry"))
!(assertEqual (((curry +) 1) 2) 3)
!(assertEqual (((curry -) 5) 4) 1)
;;
;; ;; Test case for curry 2 function
(: addThree (-> Number Number Number Number))
(= (addThree $x $y $z) (+ $x (+ $y $z)))

; !(assertEqual (get-type ((curry2 addThree) 1)) (-> Number Number Number))
; !(println! ("testing: curry2"))
; !(assertEqual (let $res (((curry2 addThree) 1) 2 3) (get-type $res)) Number)
!(assertEqual (((curry2 addThree) 1) 2 3) 6)
!(println! ("testing: curry and curry2"))
; !(assertEqual (get-type ((curry ((curry2 addThree) 1)) 2)) (-> Number Number))
!(assertEqual (((curry ((curry2 addThree) 1)) 2) 3) 6)
;;
;; ;; ;; Test filter function ;; FIX: Failing Test case
;; ;; !(assertEqual (collapse (filter isUnit (9 10 () 5 4 ()))) (() ()))
;; ;; !(assertEqual (collapse (filter hasOneAtom (9 10 (Hello) 5 4 (Nop) ()))) ((Hello) (Nop)))
;; ;; !(assertEqual (collapse (filter isZero (9 10 0 5 4 0))) (0 0))
;; ;; !(assertEqual (collapse (filter greaterThanTen (9 10 12 5 4 28))) (12 28))
;;
;; Test wrapper function for filter function
!(println! ("testig: wrapper "))
!(assertEqual (wrapper isZero 0) 0)
!(assertEqual (wrapper isZero 1) ())
!(assertEqual (wrapper isUnit 1) ())
!(assertEqual (wrapper isUnit ()) ())


;; Test for add list to space ;; it is the problem of add-reduct no add-reduct function in petta builtin. this function uses it
;; !(add-reduct &newSpace 1)
;; !(addListToSpace &newSpace (1 2 3 4 5))
;; !(get-atoms &newSpace)
;; !(println! ("testing addListToSpace "))
;; !(assertEqual (collapse (get-atoms &newSpace)) (1 2 3 4 5))
;; !(addListToSpace &newSpace (6 7 8))
;; !(assertEqual (collapse (get-atoms &newSpace)) (1 2 3 4 5 6 7 8))
;; !(addListToSpace &newSpace (9 10))
;; !(assertEqual (collapse (get-atoms &newSpace)) (1 2 3 4 5 6 7 8 9 10))

; ;; Test for checking the all function.
!(println! ("testig: all "))
!(assertEqual (all (True True True True)) True)
!(assertEqual (all (True True False True)) False)
!(assertEqual (all (True True True False)) False)


;; Test foldr function
!(println! ("testig: foldr "))
!(assertEqual (foldr + 0 (1 2 3)) 6)
!(assertEqual (foldr + 0 (1 2 3)) 6)

;; Test isSymbol function
!(println! ("testig: isSymbol "))
!(assertEqual (isSymbol A) True)
!(assertEqual (isSymbol (A)) False)
!(assertEqual (isSymbol ()) False)
!(assertEqual (isSymbol (A B)) False)

;; Test isExpression function
!(println! ("testig: isExpression "))
!(assertEqual (isExpression A) False)
!(assertEqual (isExpression (A)) True)
!(assertEqual (isExpression ()) True)
!(assertEqual (isExpression (A B)) True)

;; Test isUnit function
!(println! ("testig: isUnit "))
!(assertEqual (isUnit A) False)
!(assertEqual (isUnit (A)) False)
!(assertEqual (isUnit ()) True)
!(assertEqual (isUnit (A B)) False)

;; ;; Test hasOneAtom function ;; FIX: Failing Test case
;; !(assertEqual (hasOneAtom A) False)
;; !(assertEqual (hasOneAtom (A)) True)
;; !(assertEqual (hasOneAtom ()) False)
;; !(assertEqual (hasOneAtom (A B)) False)
;; !(assertEqual (hasOneAtom (foo bar bae)) False)
;; !(assertEqual (hasOneAtom (foo)) True)
;; !(assertEqual (hasOneAtom ()) False)


!(println! "testing  adding atom into space")
!(bind! &space (new-space))
!(add-atom &space A)
!(add-atom &space C)
!(add-atom &space C)

;; ;; FIX: Failing Test case
;; !(assertEqualToResult (let $_ (update-atom &space A B) (get-atoms &space)) (B C C))
;; !(assertEqualToResult (let $_ (update-atom &space D E) (get-atoms &space)) (B C C E))
;; !(assertEqualToResult (let $_ (update-atom &space C 1) (get-atoms &space)) (B 1 E))
;; !(assertEqualToResult (let $_ (clearSpace &space) (get-atoms &space)) ())

;; ;; FIX: Failing Test case
;; !(assertEqual (appendAtom 1 ()) (1))
;; !(assertEqual (appendAtom 1 (1 2)) (1 2 1))
;; !(assertEqual (appendAtom A (B C)) (B C A))
;; !(assertEqual (appendAtom (A) (B C)) (B C (A)))

;; unionAtom
!(println! "testing  union-atom")
!(assertEqual (union-atom () (1 2)) (1 2))
!(assertEqual (union-atom (0) (1 2)) (0 1 2))
!(assertEqual (union-atom (0 1) (2 3)) (0 1 2 3))

!(println! ("testing: max "))
!(assertEqual (max 1 2) 2)
!(assertEqual (max 2 4) 4)

; ;; FIX: Failing Test case

!(assertEqual (println! ("testing failing case in gen it's working ✅")))
!(assertEqual (gen 1 (0)) (1 0))
!(assertEqual (gen 3 (0)) (3 2 1 0))

; !(assertEqual (println! ("testing failing case in gen it's working ✅")))
; !(assertEqual (gen 1 (0)) (1 0))
; !(assertEqual (gen 3 (0)) (3 2 1 0))

!(println! ("testig: decons "))
!(assertEqual (decons (A B C)) (A (B C)))
!(assertEqual (decons (A)) (A ()))

; ;; ;; FIX: Failing Test case
!(println! ("zip failing test case"))
!(assertEqual (zip (A B C) (1 2 3)) ((A 1) (B 2) (C 3)))
!(assertEqual (zip (A B) (1 2 3)) ((A 1) (B 2)))
!(println! ("testig: zipWith "))
!(assertEqual (zipWith == (A B C) (A 2 3)) (True False False))
!(assertEqual (zipWith == (B C) (A 2 3)) (False False))
!(assertEqual (zipWith == () (A 2 3)) ())
!(assertEqual (zipWith == () ()) ())

;; ;; FIX: Failing Test case
!(println! ("testig: length "))
!(assertEqual (length (A B C D)) 4)
!(assertEqual (length ()) 0)
!(assertEqual (length (A)) 1)
; !(assertEqual (length A) 4) ;; Should return Error. !(assertEqual (replaceByIndex (A B C) 0 D) (D B C))

!(println! ("testig: replaceByIndex "))
!(assertEqual (replaceByIndex (1 2 3 4) 4 D) (1 2 3 4))
!(assertEqual (replaceByIndex (1 2 3 4) 3 D) (1 2 3 D))

!(println! ("testig: selectByIndex "))
!(assertEqual (selectByIndex (1 2 3 4) 2) 3)
!(assertEqual (selectByIndex (1 2 3 4) 3) 4)
!(assertEqual (selectByIndex (1 2 3 4) 0) 1)

!(println! ("testig: index-atom "))
!(assertEqual (index-atom (1 2 3 4) 2) 3)
!(assertEqual (index-atom (1 2 3 4) 3) 4)
!(assertEqual (index-atom (1 2 3 4) 0) 1)

;;!(println! ("testig: removeAtom "))  ; here the removeAtmom is not working because of if-decons-expre-custom it will be fixed soon
;;!(assertEqual (removeAtom 1 ()) ()) 
;;!(assertEqual (removeAtom 1 (1)) ()) 
;;!(assertEqual (removeAtom 1 (1 2)) (2)) 
;;!(assertEqual (removeAtom 1 (1 2 3)) (2 3))
;;!(assertEqual (removeAtom 1 (1 2 3 1 1)) (2 3 1 1)) 

!(println! ("testig: subtraction-atom "))
!(assertEqual (subtraction-atom (1 2 3) (4)) (1 2 3))
!(assertEqual (subtraction-atom (1 2 3) (1)) (2 3))
!(assertEqual (subtraction-atom (1 2 1 3 1) (1 2)) (1 3 1))

!(println! ("testig: compareElements "))
!(assertEqual (compareElements (A B C) (1 2 3)) (False False False))
!(assertEqual (compareElements (A B C) (A B C)) (True True True))
!(assertEqual (compareElements (1 2 3) (1 2 3)) (True True True))

!(println! ("testig: spilitAt "))
!(assertEqual (splitAt 2 (A B C D E)) ((A B) (C D E)))
!(assertEqual (splitAt 0 (A B C D E)) (() (A B C D E)))
!(assertEqual (splitAt 5 (A B C D E)) ((A B C D E) ()))

;; ;; FIX: Failing Test case.
!(println! ("testig: sort-atom "))
!(assertEqual (sort-atom (2 3 1 4)) (1 2 3 4))
!(assertEqual (reverse (sort-atom (2 3 1 4))) (4 3 2 1))

!(println! ("testig: take "))
!(assertEqual (take 1 (A B C)) (A))
!(assertEqual (take 2 (A B C)) (A B))
!(assertEqual (take 2 ()) ())

!(println! ("testig: drop "))
!(assertEqual (drop 1 (A B C)) (B C))
!(assertEqual (drop 2 (A B C)) (C))
!(assertEqual (drop 2 ()) ())
;; Test selectByIndex
!(println! ("testig: selectByIndex "))
!(assertEqual (selectByIndex (0 1 2 3 4) 2) 2)
!(assertEqual (selectByIndex (0 1 2 3 4) 3) 3)
!(assertEqual (selectByIndex (0 1 2 3 4) 5) (Error (Index out of range) ()))

;; Test unNest

!(println! ("testig: unNest "))
!(assertEqual (collapse (unNest (AND A (AND B C)))) (AND A AND B C))
!(assertEqual (collapse (unNest (1 2 (3 4 (5))))) (1 2 3 4 5))

;; Test cleanSpace

!(bind! &__ (new-space))

;; !(add-reduct &__ (superpose ((A B C) atom 2 4 (2 1))))
!(println! ("cleanspace "))
!(assertEqual 
        (let $_ (cleanSpace &__) 
            (collapse (get-atoms &__))) (collapse (empty)))

; ;; Test repeat
!(println! ("testig: repeat "))
!(assertEqual (repeat A 3) (A A A))
!(assertEqual (repeat (== 1 2) 0) ())
!(assertEqual (repeat (== 1 2) 2) (False False))
!(assertEqual (repeat 5 4) (5 5 5 5))
!(assertEqual (repeat 1 3) (1 1 1))

;; Test update-atom
!(println! ("testig: add-atom "))
!(add-atom &__ (A 2 3))
!(let $_ (collapse (update-atom  &__ (A 2 3) (A 3 4))) (assertEqual (match &__ $x $x) (A 3 4))) ;; FIX: Possibly failing test

;; Test flatten-list
!(println! ("testing flatten-list "))
!(assertEqual (flatten-list (AND A (AND A B))) (AND A AND A B))
!(assertEqual (flatten-list (AND A (AND (OR A (NOT C)) (OR B D)))) (AND A AND OR A (NOT C) OR B D))

;; Test notNt 
!(bind! NTS (new-state (start expr bop uop term)))

!(println! ("testing : notMember"))
!(assertEqual (notMember AND (get-state NTS)) True)
!(assertEqual (notMember A (get-state NTS)) True)
!(assertEqual (notMember expr (get-state NTS)) False) 

;; Test map`
!(println! ("testing map` "))
!(assertEqual (map` + 2 (1 2 3 4 5)) (3 4 5 6 7))
!(assertEqual (map` notMember (1 2 3) (2 4 1 3)) (False True False False))

;; Test isValidExp
!(println! ("testing isValidExp "))
!(assertEqual (isValidExp A (start expr bop uop term)) True)
!(assertEqual (isValidExp expr (start expr bop uop term)) False)
!(assertEqual (isValidExp (AND A B) (start expr bop uop term)) True)
!(assertEqual (isValidExp (OR (AND B null) (NOT B)) (start expr bop uop term)) True)

;; ;; Test for compose (.)
!(println! ("testing: compose instead of . "))
!(assertEqual ((compose not isEven) 4) False)
!(assertEqual ((compose isEven (compose decrement increment)) 4) True)
!(assertEqual ((compose decrement (compose increment increment)) 4) 5)
!(assertEqual ((compose greaterThanTen (compose decrement (compose increment increment))) 4) False)

;; Test for exprToList
!(println! ("testing exprToList "))
!(assertEqual (exprToList (AND A B)) (Cons AND (Cons A (Cons B Nil))))
!(assertEqual (exprToList (1 2 3 4)) (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))))

;; Test for expression pair (tuple)

!(println! ("testing first and second "))
!(assertEqual (first (1 2)) 1)
!(assertEqual (second (1 2)) 2)
!(assertEqual (first (second (1 (1 2)))) 1)

!(assertEqual (let $a (first (1 2)) (get-type $a)) Number)
!(assertEqual (let $a (second (1 2)) (get-type $a)) Number)
!(assertEqual (let $a (first (second (1 (1 2)))) (get-type $a)) Number)

; Test the add Function for Numbers wrapped within constructors
!(println! ("testing add "))
!(assertEqual (add (mkMultip 1) (mkMultip 2)) (mkMultip 3))
; !(assertEqual (add (mkMultip A) (mkMultip 1)) (Error (A or 1) "One of the argument is not a number"))
;; Test for expToMMap
;; !(println! ("testing expToMMap "))
;; !(assertEqual 
;; (expToMMap (((mkDiscSpec 1) (mkLsk1)) ((mkDiscSpec 2) (mkLsk2)) ((mkDiscSpec 3) (mkLsk3)))
;; NilMMap discSpec<=)
;; (ConsMMap ((mkDiscSpec 1) (mkLsk1)) (ConsMMap ((mkDiscSpec 2) (mkLsk2)) (ConsMMap ((mkDiscSpec 3) (mkLsk3)) NilMMap)))
;; )
;;
;; !(assertEqual (expToMMap () NilMMap discSpec<=) NilMMap)
;;
;; ;; Test for swapAndOr
!(println! ("testing swapAndOr"))
!(assertEqual (swapAndOr AND) OR)
!(assertEqual (swapAndOr OR) AND)
!(assertEqual (swapAndOr A) A)
;;
;; ;; Test for compose function
(: inc (-> Number Number) )
(= (inc $x) (+ $x 1))
;;
(: dec (-> Number Number) )
(= (dec $x) (- $x 1))

!(println! ("testing: compose "))
!(assertEqual (compose inc dec 1) 1)
!(assertEqual (compose (compose inc dec) (compose inc inc) 1) 3)
!(assertEqual ((compose (compose inc dec) inc) 1) 2)
!(assertEqual ((compose not isZero) 1) True)

;; Test cases -- Aproximate equality
!(println! ("testing isApproxEq "))
!(assertEqual (isApproxEq 0.0000005 0.0000006) True)
!(assertEqual (isApproxEq 1.0000005 1.0000006) True)
!(assertEqual (isApproxEq 1000000.1 1000000.2) True)
!(assertEqual (isApproxEq 1.0 1.1) False)

;; custom comparison functions for selectionSort

;; Function that compares the size of the two inputes and return True if the first is greater false otherwise
;(: bySize Expression Expression Bool)
(= (bySize $x $y) 
    (let* (
        ($xLen (size-atom $x))
        ($yLen (size-atom $y))
    )
    (> $xLen $yLen)
))

; Function that compares the second element (which is number) of the two inputes and return True if the first is greater false otherwise
; (: bySecondAtom (-> ($a Number) ($b Number) Bool))
(= (bySecondAtom $x $y) 
    (let* (
        ($xSecond (index-atom $x 1))
        ($ySecond (index-atom $y 1))
    )
    (> $xSecond $ySecond)
    ))

; Test cases -- bySize
!(println! ("testing bySize "))
!(assertEqual (bySize (w) (1 1 1)) False)
!(assertEqual (bySize (I c o g) (1 1 1)) True)

;; Test cases -- bySecondAtom
!(println! ("testing bySecondAtom "))
!(assertEqual (bySecondAtom (b 1) (a 2)) False) 
!(assertEqual (bySecondAtom (b 10) (a 2)) True) 

; ;; Test cases -- selectionSort
!(println! ("testing selectionSort "))
!(assertEqual (selectionSort (4 1 9 2 8 3 25 2 9 73) 2 <) (1 2 4 9 8 3 25 2 9 73))
!(assertEqual (selectionSort (5 2 9 1 73 2 3 9 8 34 25) 3 >) (73 34 25 5 2 9 1 2 3 9 8))
!(assertEqual (selectionSort (1 73 2 3 1 9 8 34 1 25 1) 4 <) (1 1 1 1 73 2 3 9 8 34 25))
!(assertEqual (selectionSort () 2 >) ())
!(assertEqual (selectionSort (1 2 3) 4 >) (3 2 1))

;; Test cases -- selectionSort with non numeric expressions
!(println! ("Test cases -- selectionSort with non numeric expressions"))
!(assertEqual (selectionSort ((a b) (a b c) (d) (m o s e s)) 1 bySize) ((m o s e s) (a b) (a b c) (d)))
!(assertEqual (selectionSort ((a 1) (b 2) (d 10) (l 8)) 2 bySecondAtom) ((d 10) (l 8) (a 1) (b 2)))

; ;; Test cases --  selector
!(println! ("testing selector "))
!(assertEqual (selector (11 20 3 4 32) 11 >) 32)
!(assertEqual (selector (11 20 3 4 32) <) 3)
!(assertEqual (selector ((a b) (a b c) (d) (m o s e s)) (a b) bySize) (m o s e s))
!(assertEqual (selector ((a 1) (b 2) (d 10) (l 8)) (a 1) bySecondAtom) (d 10))

;; Test cases -- concatT
!(println! ("testing concatT" ))
!(assertEqual (concatT(1 2 3) (4 5 6)) (1 2 3 4 5 6))
!(assertEqual (concatT (1 2 3) ()) (1 2 3))
!(assertEqual (concatT () (1 2 3)) (1 2 3))


;; --------------------------------
;; coll.length — List, Map, MMap, OS, OMS, wrappers
;; --------------------------------

!(println! ("coll.length — List, Map, MMap, OS, OMS, wrappers "))
!(println! ("testing coll.length"))
!(assertEqual (coll.length (Cons 1 (Cons 2 (Cons 3 Nil)))) 3)
!(assertEqual (coll.length Nil) 0)

;; --------------------------------
;; coll.contains — List, Map, MMap, OS, OMS, wrappers
;; --------------------------------
!(println! ("testing coll.contains"))
!(assertEqual (coll.contains (Cons 1 (Cons 2 (Cons 3 Nil))) 2) True)
!(assertEqual (coll.contains (Cons 1 (Cons 2 (Cons 3 Nil))) 4) False)

;; ;; --------------------------------
;; ;; coll.append/coll.insert — List, Map, MMap, OMS, wrappers; OS => error
;; ;; --------------------------------
!(println! ("testing coll.append and coll.remove"))
!(assertEqual (coll.append (Cons 1 (Cons 2 Nil)) 3) (Cons 1 (Cons 2 (Cons 3 Nil))))
!(assertEqual (coll.remove (Cons 1 (Cons 2 (Cons 1 Nil))) 1) (Cons 2 (Cons 1 Nil)))

;; ;; --------------------------------
;; ;; coll.getByIdx — List, Map, MMap, OS, OMS, wrappers
;; ;; --------------------------------
!(println! ("testing coll.getByIdx"))
!(assertEqual (coll.getByIdx (Cons 10 (Cons 20 (Cons 30 Nil))) 1) 20)

;; --------------------------------
;; Map — keys/values/items/find/getByKey/length/contains
;; --------------------------------
!(println! ("testing  coll.length"))
!(assertEqual (coll.length NilMap) 0)
!(assertEqual (coll.length (ConsMap (1 a) (ConsMap (2 b) NilMap))) 2)

!(assertEqual (coll.contains (ConsMap (1 a) (ConsMap (2 b) NilMap)) 2) True)
!(assertEqual (coll.keys (ConsMap (1 a) (ConsMap (2 b) NilMap))) (Cons 1 (Cons 2 Nil)))
!(assertEqual (coll.values (ConsMap (1 a) (ConsMap (2 b) NilMap))) (Cons a (Cons b Nil)))
!(assertEqual (coll.items (ConsMap (1 a) (ConsMap (2 b) NilMap))) (Cons (1 a) (Cons (2 b) Nil)))
!(assertEqual (coll.getByKey (ConsMap (1 a) (ConsMap (2 b) NilMap)) 2) b)
!(assertEqual (coll.find (ConsMap (1 a) (ConsMap (2 b) NilMap)) 2) 1)
!(assertEqual (coll.append (ConsMap (1 a) NilMap) (2 b)) (ConsMap (1 a) (ConsMap (2 b) NilMap)))
!(assertEqual (coll.remove (ConsMap (1 a) (ConsMap (2 b) NilMap)) 1) (ConsMap (2 b) NilMap))

;; --------------------------------
;; MultiMap — findOne/findAll/length/contains
;; --------------------------------
!(println! ("testing coll.length"))
!(assertEqual (coll.length NilMMap) 0)
!(assertEqual (coll.length (ConsMMap (1 a) (ConsMMap (2 b) NilMMap))) 2)
!(assertEqual (coll.contains (ConsMMap (1 a) (ConsMMap (2 b) NilMMap)) 2) True)
!(assertEqual (coll.findOne (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c) NilMMap))) 2) b)
!(assertEqual (coll.findAll (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c) NilMMap))) 2) (Cons b (Cons c Nil)))
!(assertEqual (coll.append (ConsMMap (1 a) NilMMap) (2 b)) (ConsMMap (1 a) (ConsMMap (2 b) NilMMap)))
!(assertEqual (coll.remove (ConsMMap (1 a) (ConsMMap (2 b) NilMMap)) 2) (ConsMMap (1 a) NilMMap))

;; ;; --------------------------------
;; ;; OrderedSet — contains/getByIdx/removeByIdx/takeN
;; ;; --------------------------------
!(println! ("testing coll.length "))
!(assertEqual (coll.length NilOS) 0)
!(assertEqual (coll.append NilOS 1) (Error (NilOS 1) "Use OS.insert with comparator"))
!(assertEqual (coll.contains (ConsOS 1 (ConsOS 2 NilOS)) 2) True)
!(assertEqual (coll.getByIdx (ConsOS 1 (ConsOS 2 NilOS)) 1) 2)
!(assertEqual (coll.removeByIdx (ConsOS 1 (ConsOS 2 NilOS)) 0) (ConsOS 2 NilOS))
!(assertEqual (coll.takeN 1 (ConsOS 5 (ConsOS 4 NilOS))) (OS.getTopN 1 (ConsOS 5 (ConsOS 4 NilOS))))

;; ;; --------------------------------
;; OrderedMultiset — length/append/contains/getByIdx/remove
;; --------------------------------

!(assertEqual (coll.length NilOMS) 0)
!(assertEqual (coll.append NilOMS 3) (ConsOMS 3 NilOMS))
!(assertEqual (coll.contains (ConsOMS 1 (ConsOMS 2 NilOMS)) 2) True)
!(assertEqual (coll.getByIdx (ConsOMS 1 (ConsOMS 2 NilOMS)) 0) 1)
!(assertEqual (coll.remove (ConsOMS 1 (ConsOMS 2 NilOMS)) 1) (ConsOMS 2 NilOMS))

;; Cscore comparisons via apply (inline mkCscore)
!(println! ("apply >="))
!(assertEqual
  (apply >= (mkCscore -2.0 3.0 1.0 0.5 -3.5)
               (mkCscore -3.0 2.0 1.0 0.5 -4.5))
  True)
!(println! ("apply <"))
!(assertEqual
  (apply <  (mkCscore -3.0 2.0 1.0 0.5 -4.5)
               (mkCscore -2.0 3.0 1.0 0.5 -3.5))
  True)

;; Tie-breaker on complexity: equal pen score but lower complexity is greater
!(println! ("apply >="))
!(assertEqual
  (apply >= (mkCscore -2.0 2.0 1.0 0.5 -3.5)
               (mkCscore -2.0 3.0 1.0 0.5 -3.5))
  True)
  !(println! ("apply <"))
!(assertEqual
  (apply <  (mkCscore -2.0 2.0 1.0 0.5 -3.5)
               (mkCscore -2.0 3.0 1.0 0.5 -3.5))
  False)

;; NaN penalized score ordering: NaN should be treated as very low

!(println! ("apply >="))
!(assertEqual
  (apply >= (mkCscore -2.0 3.0 1.0 0.5 -3.5)
               (mkCscore -1.0 2.0 1.0 0.5 nan))
  True)
!(println! ("apply <"))
!(assertEqual
  (apply <  (mkCscore -1.0 2.0 1.0 0.5 nan)
               (mkCscore -2.0 3.0 1.0 0.5 -3.5))
  True)

;; Approximate equality for Cscore via apply == (inline)
!(println! ("apply =="))
!(assertEqual
  (apply == (mkCscore 1.0000005 2.0 0.0 0.0 0.5)
               (mkCscore 1.0000006 2.0 0.0 0.0 0.5))
  True)

;; ScoredInstance comparisons via apply should project to inner Cscore (inline)
!(assertEqual
  (apply >=
    (mkSInst (mkPair (mkInst (Cons 1 (Cons 2 Nil))) (mkCscore -2.0 3.0 1.0 0.5 -3.5)))
    (mkSInst (mkPair (mkInst (Cons 3 Nil))               (mkCscore -3.0 2.0 1.0 0.5 -4.5))))
  True)


;; Test cases -- updateID
!(assertEqual (updateID (mkNodeId (0 1 2))) (mkNodeId (1 2)))
!(assertEqual (updateID (mkNodeId (1 2 3))) (mkNodeId (1 2 3)))

; test case for unify in space manipulation.
!(println! ("testing: unify"))
(hello world)
!(assertEqual (unify &self (hello world) Yes No) Yes)
!(assertEqual (unify &self (hello dream) Yes No) No)
