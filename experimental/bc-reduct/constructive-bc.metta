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

;; ;; Binary proof application
;; (= (bc $kb (S $k) (: ($prfabs $prfarg1 $prfarg2) $thrm))
;;    (let* (;; Recurse on binary rule
;;           ;; (() (println! (Binary rule called)))
;;           ((: $prfabs (-> $prfarg1 $prfarg2 $thrm))
;;            (bc $kb $k (: $prfabs (-> $prfarg1 $prfarg2 $thrm))))
;;           (() (println! (Binary Prfabs: $prfabs)))
;;           (() (println! (Prfarg1: $prfarg1)))
;;           (() (println! (Prfarg2: $prfarg2)))
;;
;;           ((: $prms1 $prfarg1) (bc $kb $k (: $prms1 $prfarg1)))
;;           ((: $prms2 $prfarg2) (bc $kb $k (: $prms2 $prfarg2)))
;;           )
;;      (: ($prfabs $prms1 $prms2) $thrm)))

;; ;; Ternary proof application
;; (= (bc $kb (S $k) (: ($prfabs $prfarg1 $prfarg2 $prfarg3) $thrm))
;;    (let* (;; Recurse on unary rule
;;           ((: $prfabs (-> $prfarg1 $prfarg2 $prfarg3 $thrm))
;;            (bc $kb $k (: $prfabs (-> $prfarg1 $prfarg2 $prfarg3 $thrm))))
;;
;;           ((: $prms1 $prfarg1) (bc $kb $k (: $prms1 $prfarg1)))
;;           ((: $prms2 $prfarg2) (bc $kb $k (: $prms2 $prfarg2)))
;;           ((: $prms3 $prfarg3) (bc $kb $k (: $prms3 $prfarg3)))
;;           )
;;      (: ($prfabs $prms1 $prms2 $prms3) $thrm)))

!(bind! &kb (new-space))

; !(add-atom &kb (: UnaryOrRule (-> (ReducesTo $x $y)
;                                   (ReducesTo (𝐨𝐫 (Cons $x Nil)) $y))))
;
; !(add-atom &kb (: NaryOrRule (-> (ReducesTo $head $head-r)
;                                  (ReducesTo (Cons $head $tail) (Cons $head-r $tail-r))
;                                  (ReducesTo (𝐨𝐫 (Cons $head $tail)) (𝐨𝐫 (Cons $head-r $tail-r))))))
;
; !(add-atom &kb (: TrueAxiom (ReducesTo 𝐓𝐫𝐮𝐞 𝐓𝐫𝐮𝐞)))
; !(add-atom &kb (: FalseAxiom (ReducesTo 𝐅𝐚𝐥𝐬𝐞 𝐅𝐚𝐥𝐬𝐞)))
; !(add-atom &kb (: zAxiom (ReducesTo z z)))
; !(add-atom &kb (: sAxiom (ReducesTo (s $xs) (s $xs))))
;
; !(add-atom &kb (: nilAxiom (ReducesTo Nil Nil)))
; !(add-atom &kb (: listAxiom (ReducesTo (Cons $head $tail) (Cons $head $tail))))
;
; !(add-atom &kb (: recurseList (-> (ReducesTo $head $head-r)
;                                   (ReducesTo $tail $tail-r)
;                                   (ReducesTo (Cons $head $tail) (Cons $head-r $tail-r)))))

;; ;; Failed attempt for list uniqueness
;; !(add-atom &kb (: uniqueList (-> (ReducesTo $head $head-r)
;;                                  (ReducesTo $head $head-r)
;;                                  (ReducesTo $tail $tail-r)
;;                                  (ReducesTo (Cons $head (Cons $head $tail)) (Cons $head-r $tail-r)))))

;; !(bc &kb (fromNumber 1) (: $prf (ReducesTo (𝐨𝐫 (Cons z Nil)) $y)))
;; (: $prfabs (-> $prfarg (ReducesTo (𝐨𝐫 z) $y))) => (: UnaryOrRule (-> (ReducesTo z $y) (ReducesTo (𝐨𝐫 z) $y)))

;; !(bc &kb (fromNumber 2) (: $prf (ReducesTo (𝐨𝐫 (Cons z (Cons z Nil))) $y)))


; !(add-atom &kb (: AbsorbFalse (-> (ReducesTo $lst $lst-r)
;                    (Elem 𝐅𝐚𝐥𝐬𝐞 $lst-r)
;                    (ReducesTo (𝐚𝐧𝐝 $lst) 𝐅𝐚𝐥𝐬𝐞))))

!(add-atom &kb (: ElemAxiom (Elem $head (Cons $head $tail))))

!(add-atom &kb (: ElemRule (-> (Elem $x $tail)
                               (Elem $x (Cons $head $tail)))))

!(bc &kb (fromNumber 2) (: $prf (Elem A (Cons B (Cons C (Cons A Nil))))))

;; !(bc &kb (fromNumber 2) (: $prf (Elem A (Cons B (Cons C (Cons A Nil))))))
;; !(bc &kb (fromNumber 0) (: $prf (Elem A (Cons A Nil))))
;; !(bc &kb (fromNumber 1) (: $prf (Elem A (Cons C (Cons A Nil)))))
