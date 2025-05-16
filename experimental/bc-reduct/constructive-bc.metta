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

(= (filterResultBc (: $prf (ReducesTo $x $y))) (if (== $x $y) (empty) (: $prf (ReducesTo $x $y))))


!(bind! &kb (new-space))

; !(add-atom &kb (: UnaryOrRule (-> (ReducesTo $x $y)
;                                   (ReducesTo (𝐨𝐫 (Cons $x Nil)) $y))))
;
; !(add-atom &kb (: NaryOrRule (-> (ReducesTo $head $head-r)
;                                  (ReducesTo $tail $tail-r)
;                                  (ReducesTo (𝐨𝐫 (Cons $head $tail)) (𝐨𝐫 (Cons $head-r $tail-r))))))
;
; !(add-atom &kb (: UnaryAndRule (-> (ReducesTo $x $y)
;                                    (ReducesTo (𝐚𝐧𝐝 (Cons $x Nil)) $y))))
;
; !(add-atom &kb (: NaryAndRule (-> (ReducesTo $head $head-r)
;                                   (ReducesTo $tail $tail-r)
;                                   (ReducesTo (𝐚𝐧𝐝 (Cons $head $tail)) (𝐚𝐧𝐝 (Cons $head-r $tail-r))))))
;
!(add-atom &kb (: TrueAxiom (ReducesTo 𝐓𝐫𝐮𝐞 𝐓𝐫𝐮𝐞)))
!(add-atom &kb (: FalseAxiom (ReducesTo 𝐅𝐚𝐥𝐬𝐞 𝐅𝐚𝐥𝐬𝐞)))
;
!(add-atom &kb (: zAxiom (ReducesTo z z)))
!(add-atom &kb (: sAxiom (ReducesTo (s $xs) (s $xs))))

!(add-atom &kb (: nilAxiom (ReducesTo Nil Nil)))
!(add-atom &kb (: listAxiom (ReducesTo (Cons $head $tail) (Cons $head $tail))))

; !(add-atom &kb (: recurseList (-> (ReducesTo $head $head-r)
;                                   (ReducesTo $tail $tail-r)
;                                   (ReducesTo (Cons $head $tail) (Cons $head-r $tail-r)))))
;
; !(add-atom &kb (: AbsorbFalse (-> (ReducesTo (Cons $head $tail) (Cons $head-r $tail-r))
;                                   (Elem 𝐅𝐚𝐥𝐬𝐞 (Cons $head-r $tail-r))
;                                   (ReducesTo (𝐚𝐧𝐝 (Cons $head $tail)) 𝐅𝐚𝐥𝐬𝐞))))
;
; !(add-atom &kb (: AbsorbTrue (-> (ReducesTo (Cons $head $tail) (Cons $head-r $tail-r))
;                                  (Elem 𝐓𝐫𝐮𝐞 (Cons $head-r $tail-r))
;                                  (ReducesTo (𝐨𝐫 (Cons $head $tail)) 𝐓𝐫𝐮𝐞))))

!(add-atom &kb (: dstNilAxiom (ReducesTo ($op Nil) Nil)))
!(add-atom &kb (: dstZAxiom (ReducesTo ($op z) ($op z))))
!(add-atom &kb (: dstSAxiom (ReducesTo ($op (s $xs)) ($op (s $xs)))))

!(add-atom &kb (: Distribute (-> (ReducesTo (𝐧𝐨𝐭 $head) $head-r)
                                 (ReducesTo (𝐧𝐨𝐭 $tail) $tail-r)
                                 (ReducesTo (𝐧𝐨𝐭 (Cons $head $tail)) (Cons $head-r $tail-r)))))


!(add-atom &kb (: ElemAxiom (Elem $head (Cons $head $tail))))

!(add-atom &kb (: ElemRule (-> (Elem $x $tail)
                               (Elem $x (Cons $head $tail)))))

;; FIX: Failing test case
;; !(add-atom &kb (: RemoveDuplicates (-> (Elem $head-r $tail-r)
;;                                       (ReducesTo (Cons $head $tail) $tail-r))))

!(add-atom &kb (: PropNot (-> (ReducesTo $head $head-r)
                              (ReducesTo $tail $tail-r)
                              (ReducesTo (𝐧𝐨𝐭 (Cons $head-r $tail-r)) $lst-r)
                              (ReducesTo (𝐧𝐨𝐭 (𝐚𝐧𝐝 (Cons $head $tail))) (𝐨𝐫 $lst-r)))))
                              ;; (ReducesTo (𝐧𝐨𝐭 (𝐚𝐧𝐝 (Cons $head $tail))) (𝐨𝐫 (𝐧𝐨𝐭 (Cons $head-r $tail-r)))))))

!(add-atom &kb (: PropNot (-> (ReducesTo $head $head-r)
                              (ReducesTo $tail $tail-r)
                              (ReducesTo (𝐧𝐨𝐭 (Cons $head-r $tail-r)) $lst-r)
                              (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons $head $tail))) (𝐚𝐧𝐝 $lst-r)))))
                              ;; (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons $head $tail))) (𝐚𝐧𝐝 (𝐧𝐨𝐭 (Cons $head-r $tail-r)))))))

;; !(bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (s z) Nil)))) $y))) ;; PropNot test case
;; !(bc &kb (fromNumber 6) (: $prf (ReducesTo (𝐧𝐨𝐭 (𝐨𝐫 (Cons z (Cons (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) Nil)))) $y))) ;; PropNot test case.

;; !(println! (filterResultBc (bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐨𝐫 (Cons z (Cons z Nil))) $y)))))
;; !(println! (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐨𝐫 (Cons (s z) (Cons z (Cons z Nil)))) $y)))))
;; !(println! (filterResultBc (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐨𝐫 (Cons z (Cons (s z) (Cons z Nil)))) $y))))) ;; Fails for this
;; !(println! (filterResultBc (bc &kb (fromNumber 2) (: $prf (ReducesTo (Cons z (Cons (s z) (Cons z Nil))) $y))))) ;; But this still works

;; !(println! (bc &kb (fromNumber 2) (: $prf (Elem A (Cons B (Cons C (Cons A Nil))))))) ;; Element check test
;; !(println! "")
;; !(println! (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons A (Cons B (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)))) $y)))) ;; Absorb false test
;; !(println! "")
;; !(println! (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐨𝐫 (Cons A (Cons B (Cons 𝐓𝐫𝐮𝐞 Nil)))) $y)))) ;; Absorb true test
;; !(println! "")
;; !(println! (bc &kb (fromNumber 3) (: $prf (ReducesTo (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) Nil)) $y)))) ;; absorb false and or cut test
;; !(println! "")
;; !(println! (bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐨𝐫 (Cons z Nil)) $y)))) ;; orcut test
;; !(println! "")
;; !(println! (bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons z Nil)) $y)))) ;; andcut test
;; !(println! "")
;; !(println! (bc &kb (fromNumber 5) (: $prf (ReducesTo (𝐚𝐧𝐝 (Cons z (Cons (𝐨𝐫 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) Nil))) $y)))) ;; recurse list test
