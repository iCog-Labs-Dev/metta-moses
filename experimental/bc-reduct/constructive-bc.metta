;; Define Nat
(: Nat Type)
(: Z Nat)
(: S (-> Nat Nat))

;; Define cast functions between Nat and Number
(: fromNumber (-> Number Nat))
(= (fromNumber $n) (if (<= $n 0) Z (S (fromNumber (- $n 1)))))
(: fromNat (-> Nat Number))
(= (fromNat Z) 0)
(= (fromNat (S $k)) (+ 1 (fromNat $k)))

;;;;;;;;;;;;;;;;;;;;;
;; De Bruijn Index ;;
;;;;;;;;;;;;;;;;;;;;;

;; Define DeBruijn type
(: DeBruijn Type)

;; Define DeBruijn constructors
(: z DeBruijn)                        ; Zero
(: s (-> DeBruijn DeBruijn))          ; Successor
(: List (-> $a Type))
(: Nil (List $a))
(: Cons (-> $a (List $a) (List $a)))

;; Similar to match but takes a list of terms instead of a space.
(: match' (-> (List Atom) $a $a $a))
(= (match' Nil $pattern $rewrite) (empty))
(= (match' (Cons $head $tail) $pattern $rewrite) (let $pattern $head $rewrite))
(= (match' (Cons $head $tail) $pattern $rewrite) (match' $tail $pattern $rewrite))


;;;;;;;;;;;;;;;;;;;;;;
;; Backward chainer ;;
;;;;;;;;;;;;;;;;;;;;;;

;; Backward Chainer with environment.  There is no explicit support
;; for lambda abstraction due to the combinatorial explosion resulting
;; from combining lambda abstractions and applications.  Instead,
;; variables are added to the environment manually.  So for instance,
;; if the program to synthesize has the following type signature
;;
;; 𝐁𝐨𝐨𝐥 -> 𝐁𝐨𝐨𝐥 -> 𝐁𝐨𝐨𝐥
;;
;; meaning it is a binary boolean function, thus has 2 arguments, we
;; add the following two declarations in the environment
;;
;; (: z 𝐁𝐨𝐨𝐥)
;; (: (s z) 𝐁𝐨𝐨𝐥)
;;
;; where z and (s z) represents the variables associated with the two
;; arguments.
;;
;; The arguments of the backward chainer are:
;;
;; * Knowledge base: reference to a space containing axioms and rules
;;   in the format (: <NAME> <RULE>).  Rules may or may not be curried
;;   depending on the convenience of the situation.
;;
;; * Environment: a list of typing relationships such as
;;
;;   (Cons (: z 𝐁𝐨𝐨𝐥) (Cons (: (s z) 𝐁𝐨𝐨𝐥) Nil))
;;
;; * Maximum depth: maximum depth of the generated proof tree.
;;
;; * Query: a metta term of the form (: <PROOF> <THEOREM>) where
;;   <PROOF> and <THEOREM> may contain free variables that may be
;;   filled by the backward chainer.
(: bc (-> $a                            ; Knowledge base space
          Nat                           ; Maximum depth
          $c                            ; Query
          $c))                          ; Result

;; Base cases
;; Match the knowledge base
(= (bc $kb $_ (: $prf $thrm))
   (let*
      (
        ; (() (println! ""))
        ; (() (println! (At Depth $_ Matching Proof: (: $prf $thrm))))
        ((: $prf $thrm) (match $kb (: $prf $thrm) (: $prf $thrm)))
        ; (() (println! (At Depth $_ Found Proof: (: $prf $thrm))))
        ; (() (println! ""))
      )
      (: $prf $thrm)
   )
   ;; (match $kb (: $prf $thrm) (: $prf $thrm))
)

;; Recursive steps
;; Unary proof application
(= (bc $kb (S $k) (: ($prfabs $prfarg) $thrm))
   (let* (;; Recurse on unary rule
          ((: $prfabs (-> $prms $thrm))
           (bc $kb $k (: $prfabs (-> $prms $thrm))))
          ((: $prfarg $prms) (bc $kb $k (: $prfarg $prms)))
          )
     (: ($prfabs $prfarg) $thrm)))

;; Binary proof application
(= (bc $kb (S $k) (: ($prfabs $prfarg1 $prfarg2) $thrm))
   (let* (;; Recurse on binary rule
          ((: $prfabs (-> $prms1 $prms2 $thrm))
           (bc $kb $k (: $prfabs (-> $prms1 $prms2 $thrm))))

          ((: $prfarg1 $prms1) (bc $kb $k (: $prfarg1 $prms1)))
          ((: $prfarg2 $prms2) (bc $kb $k (: $prfarg2 $prms2)))
          )
     (: ($prfabs $prfarg1 $prfarg2) $thrm)))

;; Ternary proof application
(= (bc $kb (S $k) (: ($prfabs $prfarg1 $prfarg2 $prfarg3) $thrm))
   (let* (;; Recurse on unary rule
          ((: $prfabs (-> $prms1 $prms2 $prms3 $thrm))
           (bc $kb $k (: $prfabs (-> $prms1 $prms2 $prms3 $thrm))))

          ((: $prfarg1 $prms1) (bc $kb $k (: $prfarg1 $prms1)))
          ((: $prfarg2 $prms2) (bc $kb $k (: $prfarg2 $prms2)))
          ((: $prfarg3 $prms3) (bc $kb $k (: $prfarg3 $prms3)))
          )
     (: ($prfabs $prfarg1 $prfarg2 $prfarg3) $thrm)))

(= (filterResultBc (: $prf ($op $x $y))) (if (== $x $y) (empty) (: $prf ($op $x $y))))


!(bind! &kb (new-space))

!(add-atom &kb (: UnaryOrRule (-> (ReducesTo $x $y)
                                  (ReducesTo (𝐨𝐫 (Cons $x Nil)) $y))))

!(add-atom &kb (: NaryOrRule (-> (ReducesTo $head $head-r)
                                 (ReducesTo $tail $tail-r)
                                 (ReducesTo (𝐨𝐫 (Cons $head $tail)) (𝐨𝐫 (Cons $head-r $tail-r))))))

!(add-atom &kb (: UnaryAndRule (-> (ReducesTo $x $y)
                                   (ReducesTo (𝐚𝐧𝐝 (Cons $x Nil)) $y))))

!(add-atom &kb (: NaryAndRule (-> (ReducesTo $head $head-r)
                                  (ReducesTo $tail $tail-r)
                                  (ReducesTo (𝐚𝐧𝐝 (Cons $head $tail)) (𝐚𝐧𝐝 (Cons $head-r $tail-r))))))

!(add-atom &kb (: TrueAxiom ($rule 𝐓𝐫𝐮𝐞 𝐓𝐫𝐮𝐞)))
!(add-atom &kb (: FalseAxiom ($rule 𝐅𝐚𝐥𝐬𝐞 𝐅𝐚𝐥𝐬𝐞)))
;
!(add-atom &kb (: zAxiom ($rule z z)))
!(add-atom &kb (: sAxiom ($rule (s $xs) (s $xs))))

!(add-atom &kb (: nilAxiom ($rule Nil Nil)))
!(add-atom &kb (: listAxiom ($rule (Cons $head $tail) (Cons $head $tail))))

!(add-atom &kb (: recurseList (-> (ReducesTo $head $head-r)
                                  (ReducesTo $tail $tail-r)
                                  (ReducesTo (Cons $head $tail) (Cons $head-r $tail-r)))))

!(add-atom &kb (: AbsorbFalse (-> (ReducesTo (Cons $head $tail) (Cons $head-r $tail-r))
                                  (Elem 𝐅𝐚𝐥𝐬𝐞 (Cons $head-r $tail-r))
                                  (ReducesTo (𝐚𝐧𝐝 (Cons $head $tail)) 𝐅𝐚𝐥𝐬𝐞))))

!(add-atom &kb (: AbsorbTrue (-> (ReducesTo (Cons $head $tail) (Cons $head-r $tail-r))
                                 (Elem 𝐓𝐫𝐮𝐞 (Cons $head-r $tail-r))
                                 (ReducesTo (𝐨𝐫 (Cons $head $tail)) 𝐓𝐫𝐮𝐞))))

!(add-atom &kb (: dstNilAxiom (ReducesTo ($op Nil) Nil)))
!(add-atom &kb (: dstZAxiom (ReducesTo ($op z) ($op z))))
!(add-atom &kb (: doubleNotAxiom (ReducesTo (𝐧𝐨𝐭 (𝐧𝐨𝐭 $x)) $x)))
!(add-atom &kb (: dstSAxiom (ReducesTo ($op (s $xs)) ($op (s $xs)))))

!(add-atom &kb (: Distribute (-> (ReducesTo (𝐧𝐨𝐭 $head) $head-r)
                                 (ReducesTo (𝐧𝐨𝐭 $tail) $tail-r)
                                 (ReducesTo (𝐧𝐨𝐭 (Cons $head $tail)) (Cons $head-r $tail-r)))))


!(add-atom &kb (: istcNilAxiom (Intersection Nil $list Nil)))

!(add-atom &kb (: IntersectHeadRule (-> (Elem $head $list)
                                         (Intersection $tail $list $tail-r)
                                         (Intersection (Cons $head $tail) $list (Cons $head $tail-r)))))

!(add-atom &kb (: IntersectTailRule (-> (Intersection $tail $list $tail-r)
                                         (Intersection (Cons $head $tail) $list $tail-r))))



!(add-atom &kb (: ElemAxiom (Elem $head (Cons $head $tail))))

!(add-atom &kb (: ElemRule (-> (Elem $x $tail)
                               (Elem $x (Cons $head $tail)))))

;; Test list intersection
;; WARN: The result is excess. The only relevant result is the first one.
;; However, due to the nature of the rules, we cannot avoid generating those excess results.

!"===== Testing list intersection ====="
!(assertEqualToResult
   (bc &kb (fromNumber 2) (: $prf (Intersection (Cons z (Cons (s z) Nil)) (Cons (s z) (Cons z (Cons (s (s z)) Nil))) $intersection)))
   (
      (: (IntersectHeadRule (ElemRule ElemAxiom) (IntersectHeadRule ElemAxiom istcNilAxiom)) (Intersection (Cons z (Cons (s z) Nil)) (Cons (s z) (Cons z (Cons (s (s z)) Nil))) (Cons z (Cons (s z) Nil))))
      (: (IntersectTailRule (IntersectTailRule istcNilAxiom)) (Intersection (Cons z (Cons (s z) Nil)) (Cons (s z) (Cons z (Cons (s (s z)) Nil))) Nil))
      (: (IntersectTailRule (IntersectHeadRule ElemAxiom istcNilAxiom)) (Intersection (Cons z (Cons (s z) Nil)) (Cons (s z) (Cons z (Cons (s (s z)) Nil))) (Cons (s z) Nil)))
      (: (IntersectHeadRule (ElemRule ElemAxiom) (IntersectTailRule istcNilAxiom)) (Intersection (Cons z (Cons (s z) Nil)) (Cons (s z) (Cons z (Cons (s (s z)) Nil))) (Cons z Nil)))))

!(assertEqualToResult
   (bc &kb (fromNumber 2) (: $prf (Intersection (Cons z (Cons (s z) Nil)) (Cons (s z) Nil) $intersection)))
   (
     (: (IntersectTailRule (IntersectTailRule istcNilAxiom)) (Intersection (Cons z (Cons (s z) Nil)) (Cons (s z) Nil) Nil))
     (: (IntersectTailRule (IntersectHeadRule ElemAxiom istcNilAxiom)) (Intersection (Cons z (Cons (s z) Nil)) (Cons (s z) Nil) (Cons (s z) Nil)))))

!(add-atom &kb (: UniqueHead (-> (Unique $tail $tail-r)
                                 (Elem $head $tail-r)
                                 (Unique (Cons $head $tail) $tail-r))))

!(add-atom &kb (: UniqueTail (-> (Unique $tail $tail-r)
                                 (Unique (Cons $head $tail) (Cons $head $tail-r)))))

;; Test list uniqueness

;; WARN: The result is excess. The only relevant result is the first one.
;; However, due to the nature of the rules, we cannot avoid generating those excess results.
;; This is could be simplified by rewriting the rules to avoid redundency.

!"===== Testing list unique rule ====="
!(assertEqualToResult 
   (filterResultBc (bc &kb (fromNumber 2) (: $prf (Unique (Cons z (Cons z (Cons (s z) Nil))) $y))))
   (
     (: (UniqueHead listAxiom ElemAxiom) (Unique (Cons z (Cons z (Cons (s z) Nil))) (Cons z (Cons (s z) Nil))))
     (: (UniqueHead (UniqueTail listAxiom) ElemAxiom) (Unique (Cons z (Cons z (Cons (s z) Nil))) (Cons z (Cons (s z) Nil))))))

!(assertEqualToResult
   (filterResultBc (bc &kb (fromNumber 2) (: $prf (Unique (Cons (s z) (Cons z (Cons z Nil))) $y))))
   (
     (: (UniqueTail (UniqueHead listAxiom ElemAxiom)) (Unique (Cons (s z) (Cons z (Cons z Nil))) (Cons (s z) (Cons z Nil))))))

!(assertEqualToResult 
   (filterResultBc (bc &kb (fromNumber 2) (: $prf (Unique (Cons z (Cons (s z) (Cons z Nil))) $y))))
   (
     (: (UniqueHead listAxiom (ElemRule ElemAxiom)) (Unique (Cons z (Cons (s z) (Cons z Nil))) (Cons (s z) (Cons z Nil))))
     (: (UniqueHead (UniqueTail listAxiom) (ElemRule ElemAxiom)) (Unique (Cons z (Cons (s z) (Cons z Nil))) (Cons (s z) (Cons z Nil))))))

!(assertEqualToResult
   (filterResultBc (bc &kb (fromNumber 3) (: $prf (Unique (Cons z (Cons (s z) (Cons (s z) Nil))) $y))))
   (
     (: (UniqueTail (UniqueHead listAxiom ElemAxiom)) (Unique (Cons z (Cons (s z) (Cons (s z) Nil))) (Cons z (Cons (s z) Nil))))
     (: (UniqueTail (UniqueHead (UniqueTail nilAxiom) ElemAxiom)) (Unique (Cons z (Cons (s z) (Cons (s z) Nil))) (Cons z (Cons (s z) Nil))))))

!(assertEqualToResult 
   (filterResultBc (bc &kb (fromNumber 3) (: $prf (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) $y))))
   (
     (: (UniqueHead (UniqueHead listAxiom ElemAxiom) ElemAxiom) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) Nil)))
     (: (UniqueHead (UniqueHead (UniqueTail nilAxiom) ElemAxiom) ElemAxiom) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) Nil)))
     (: (UniqueHead listAxiom ElemAxiom) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) (Cons (s z) Nil))))
     (: (UniqueHead listAxiom (ElemRule ElemAxiom)) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) (Cons (s z) Nil))))
     (: (UniqueHead (UniqueTail listAxiom) ElemAxiom) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) (Cons (s z) Nil))))
     (: (UniqueHead (UniqueTail listAxiom) (ElemRule ElemAxiom)) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) (Cons (s z) Nil))))
     (: (UniqueHead (UniqueTail (UniqueTail nilAxiom)) ElemAxiom) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) (Cons (s z) Nil))))
     (: (UniqueHead (UniqueTail (UniqueTail nilAxiom)) (ElemRule ElemAxiom)) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) (Cons (s z) Nil))))
     (: (UniqueTail (UniqueHead listAxiom ElemAxiom)) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) (Cons (s z) Nil))))
     (: (UniqueTail (UniqueHead (UniqueTail nilAxiom) ElemAxiom)) (Unique (Cons (s z) (Cons (s z) (Cons (s z) Nil))) (Cons (s z) (Cons (s z) Nil))))))

!(add-atom &kb (: PropNot (->  (ReducesTo $head $head-r)
                               (ReducesTo $tail $tail-r)
                               (ReducesTo (𝐧𝐨𝐭 (Cons $head-r $tail-r)) $lst-r)
                               (ReducesTo (𝐧𝐨𝐭 (𝐚𝐧𝐝 (Cons $head $tail))) (𝐨𝐫 $lst-r)))))
                              ;; (ReducesTo (𝐧𝐨𝐭 (𝐚𝐧𝐝 (Cons $head $tail))) (𝐨𝐫 (𝐧𝐨𝐭 (Cons $head-r $tail-r)))))))

!(add-atom &kb (: PropNot (->  (ReducesTo $head $head-r)
                               (ReducesTo $tail $tail-r)
                               (ReducesTo (𝐧𝐨𝐭 (Cons $head-r $tail-r)) $lst-r)
                               (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons $head $tail))) (𝐚𝐧𝐝 $lst-r)))))
                              ;; (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons $head $tail))) (𝐚𝐧𝐝 (𝐧𝐨𝐭 (Cons $head-r $tail-r)))))))

;; Test case for Propagate not test case
! "===== Test case for propagate not rule ====="
;; WARN: The result is exess. Primarily because of many different ways to proof the reduction.
!(assertEqualToResult 
   (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (s z) Nil)))) $y))))
   (
     (: (PropNot zAxiom listAxiom (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (s z) Nil)))) (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil)))))
     (: (PropNot zAxiom (recurseList dstZAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (s z) Nil)))) (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil)))))
     (: (PropNot zAxiom (recurseList sAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (s z) Nil)))) (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil)))))))

!(assertEqualToResult (filterResultBc (bc &kb (fromNumber 6) (: $prf (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil)))) $y))))
   (
     (: (PropNot zAxiom listAxiom (Distribute dstZAxiom (Distribute (PropNot zAxiom listAxiom (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom listAxiom (Distribute dstZAxiom (Distribute (PropNot zAxiom (recurseList dstZAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo 
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom listAxiom (Distribute dstZAxiom (Distribute (PropNot zAxiom (recurseList sAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo 
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom listAxiom) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom listAxiom (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo 
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom listAxiom) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom (recurseList dstZAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo 
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom listAxiom) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom (recurseList sAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo 
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom (recurseList dstZAxiom nilAxiom)) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom listAxiom (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo 
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom (recurseList dstZAxiom nilAxiom)) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom (recurseList dstZAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom (recurseList dstZAxiom nilAxiom)) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom (recurseList sAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo 
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom (recurseList sAxiom nilAxiom)) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom listAxiom (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo 
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom (recurseList sAxiom nilAxiom)) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom (recurseList dstZAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))
     (: (PropNot zAxiom (recurseList (NaryAndRule zAxiom (recurseList sAxiom nilAxiom)) nilAxiom) (Distribute dstZAxiom (Distribute (PropNot zAxiom (recurseList sAxiom nilAxiom) (Distribute dstZAxiom (Distribute dstSAxiom dstNilAxiom))) dstNilAxiom)))
        (ReducesTo
           (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))))
           (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (𝐨𝐫 (Cons (𝐧𝐨𝐭 z) (Cons (𝐧𝐨𝐭 (s z)) Nil))) Nil)))))))

;; !(add-atom &kb (: delInconNilAxiom (ReducesTo (𝐚𝐧𝐝 Nil) (𝐚𝐧𝐝 Nil))))
;; !(add-atom &kb (: delInconNilAxiom (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) $tail)) (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) $tail)))))

!(add-atom &kb (: delInconHeadRule (-> (ReducesTo (𝐧𝐨𝐭 $tail) $tail-r)
                                       (Intersection $tail-r $children (Cons $i $is))
                                       (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 $children) $tail-o)) $tail)) (𝐚𝐧𝐝 (Cons (𝐨𝐫 $tail-o) $tail))))))

!(add-atom &kb (: delInconTailRule (-> (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 $tail-o) $tail)) (𝐚𝐧𝐝 (Cons (𝐨𝐫 $tail-o-r) $tail)))
                                       (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons $head $tail-o)) $tail)) (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons $head $tail-o-r)) $tail))))))

!(add-atom &kb (: delInconRecurseRule (-> (ReducesTo (𝐚𝐧𝐝 $tail) (𝐚𝐧𝐝 $tail-r))
                                          (ReducesTo (𝐚𝐧𝐝 (Cons $head $tail)) (𝐚𝐧𝐝 (Cons $head $tail-r))))))

;; Del inconsistent test cases
!(println! (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐧𝐨𝐭 (Cons (𝐧𝐨𝐭 z) Nil)) $tail-r))))

!(println! "")
!(println! (bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) (Cons (𝐧𝐨𝐭 z) Nil))) $y))))

!(println! "")
!(println! (bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil)) (Cons (𝐧𝐨𝐭 z) Nil))) $y))))

!(println! "")
!(println! (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) (Cons (s z) (Cons (𝐧𝐨𝐭 z) Nil)))) $y))))

!(println! "")
!(println! (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons (s z) (Cons z Nil))) Nil)) (Cons (𝐧𝐨𝐭 z) Nil))) $y))))

!(println! "")
!(println! (bc &kb (fromNumber 4) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons (s z) (Cons z Nil))) Nil)) (Cons (s z) (Cons (𝐧𝐨𝐭 z) Nil)))) $y))))

!(println! "")
!(println! (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (s z) (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil))) (Cons (𝐧𝐨𝐭 z) Nil))) $y)))))

!(println! "")
!(println! (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (s z) (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil))) (Cons (𝐧𝐨𝐭 z) Nil))) $y)))))

!(println! "")
!(println! (filterResultBc (bc &kb (fromNumber 4) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (s z) (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil))) (Cons (s z) (Cons (𝐧𝐨𝐭 z) Nil)))) $y)))))

!(println! "")
!(println! (filterResultBc (bc &kb (fromNumber 4) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (s z) (Cons (𝐚𝐧𝐝 (Cons (s z) (Cons z Nil))) Nil))) (Cons (𝐧𝐨𝐭 z) Nil))) $y)))))

!(println! "")
!(println! (filterResultBc (bc &kb (fromNumber 5) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (s z) (Cons (𝐚𝐧𝐝 (Cons (s z) (Cons z Nil))) Nil))) (Cons (s z) (Cons (𝐧𝐨𝐭 z) Nil)))) $y)))))

!(println! (filterResultBc (bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐨𝐫 (Cons z (Cons z Nil))) $y)))))

!(println! (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐨𝐫 (Cons (s z) (Cons z (Cons z Nil)))) $y)))))

!(println! (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐨𝐫 (Cons z (Cons (s z) (Cons z Nil)))) $y))))) ;; Fails for this

!(println! (filterResultBc (bc &kb (fromNumber 2) (: $prf (ReducesTo (Cons z (Cons (s z) (Cons z Nil))) $y))))) ;; But this still works

;; Element check test
! "===== Test case Element check rule ====="
!(assertEqual (bc &kb (fromNumber 2) (: $prf (Elem A (Cons B (Cons C (Cons A Nil)))))) (: (ElemRule (ElemRule ElemAxiom)) (Elem A (Cons B (Cons C (Cons A Nil))))))

;; Absorb false test
! "===== Test case absorb false rule ====="
!(assertEqual (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons A (Cons B (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)))) $y)))) (: (AbsorbFalse listAxiom (ElemRule (ElemRule ElemAxiom))) (ReducesTo (𝐚𝐧𝐝 (Cons A (Cons B (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)))) 𝐅𝐚𝐥𝐬𝐞)))

;; Absorb true test
! "===== Test case absorb true rule ====="
!(assertEqual (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐨𝐫 (Cons A (Cons B (Cons 𝐓𝐫𝐮𝐞 Nil)))) $y)))) (: (AbsorbTrue listAxiom (ElemRule (ElemRule ElemAxiom))) (ReducesTo (𝐨𝐫 (Cons A (Cons B (Cons 𝐓𝐫𝐮𝐞 Nil)))) 𝐓𝐫𝐮𝐞)))

;; Absorb false and or cut test
! "===== Test case absorb false and or cut rule ====="
!(assertEqualToResult
   (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) $y))))
   (
     (: (NaryOrRule (AbsorbFalse listAxiom ElemAxiom) nilAxiom) (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) (𝐨𝐫 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))))
     (: (NaryOrRule (AbsorbFalse (recurseList FalseAxiom nilAxiom) ElemAxiom) nilAxiom) (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) (𝐨𝐫 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))))
     (: (NaryOrRule (UnaryAndRule FalseAxiom) nilAxiom) (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) (𝐨𝐫 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))))
     (: (UnaryOrRule (AbsorbFalse listAxiom ElemAxiom)) (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) 𝐅𝐚𝐥𝐬𝐞))
     (: (UnaryOrRule (AbsorbFalse (recurseList FalseAxiom nilAxiom) ElemAxiom)) (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) 𝐅𝐚𝐥𝐬𝐞))
     (: (UnaryOrRule (NaryAndRule FalseAxiom nilAxiom)) (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))))
     (: (UnaryOrRule (UnaryAndRule FalseAxiom)) (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) 𝐅𝐚𝐥𝐬𝐞))))

;; Orcut test
! "===== Test case or cut rule ====="
!(assertEqual (filterResultBc (bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐨𝐫 (Cons z Nil)) $y)))) (: (UnaryOrRule zAxiom) (ReducesTo (𝐨𝐫 (Cons z Nil)) z)))

;; Andcut test
! "===== Test case and cut rule ====="
!(assertEqual (filterResultBc (bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons z Nil)) $y)))) (: (UnaryAndRule zAxiom) (ReducesTo (𝐚𝐧𝐝 (Cons z Nil)) z)))

;; recurse list test
! "===== Test case recurse list rule ====="
!(assertEqualToResult
   (filterResultBc (bc &kb (fromNumber 5) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons z (Cons (𝐨𝐫 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) Nil))) $y))))
   (
     (: (NaryAndRule zAxiom (recurseList (AbsorbTrue listAxiom (ElemRule ElemAxiom)) nilAxiom)) (ReducesTo (𝐚𝐧𝐝 (Cons z (Cons (𝐨𝐫 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) Nil))) (𝐚𝐧𝐝 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil)))))
     (: (NaryAndRule zAxiom (recurseList (AbsorbTrue (recurseList zAxiom listAxiom) (ElemRule ElemAxiom)) nilAxiom)) (ReducesTo (𝐚𝐧𝐝 (Cons z (Cons (𝐨𝐫 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) Nil))) (𝐚𝐧𝐝 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil)))))
     (: (NaryAndRule zAxiom (recurseList (AbsorbTrue (recurseList zAxiom (recurseList TrueAxiom nilAxiom)) (ElemRule ElemAxiom)) nilAxiom)) (ReducesTo (𝐚𝐧𝐝 (Cons z (Cons (𝐨𝐫 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) Nil))) (𝐚𝐧𝐝 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil)))))
     (: (delInconRecurseRule (NaryAndRule (AbsorbTrue listAxiom (ElemRule ElemAxiom)) nilAxiom)) (ReducesTo (𝐚𝐧𝐝 (Cons z (Cons (𝐨𝐫 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) Nil))) (𝐚𝐧𝐝 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil)))))
     (: (delInconRecurseRule (NaryAndRule (AbsorbTrue (recurseList zAxiom listAxiom) (ElemRule ElemAxiom)) nilAxiom)) (ReducesTo (𝐚𝐧𝐝 (Cons z (Cons (𝐨𝐫 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) Nil))) (𝐚𝐧𝐝 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil)))))
     (: (delInconRecurseRule (NaryAndRule (AbsorbTrue (recurseList zAxiom (recurseList TrueAxiom nilAxiom)) (ElemRule ElemAxiom)) nilAxiom)) (ReducesTo (𝐚𝐧𝐝 (Cons z (Cons (𝐨𝐫 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) Nil))) (𝐚𝐧𝐝 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil)))))))
