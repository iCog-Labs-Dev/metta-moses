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
;; (: Nil (List $a))
;; (: Cons (-> $a (List $a) (List $a)))

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
          (List $b)                     ; Environment
          Nat                           ; Maximum depth
          $c                            ; Query
          $c))                          ; Result

;; Base cases
;; Match the knowledge base
(= (bc $kb $env $_ (: $prf $thrm))
   ;; (match $kb (: $prf $thrm) (if (< ((py-atom random.random)) 0.5) (empty) (: $prf $thrm) )))
   (match $kb (: $prf $thrm) (: $prf $thrm)))
;; Match the environment
(= (bc $kb $env $_ (: $prf $thrm))
   (match' $env (: $prf $thrm) (: $prf $thrm)))

;; Recursive steps
;; Unary proof application
(= (bc $kb $env (S $k) (: ($prfabs $prfarg) $thrm))
   (let* (;; Recurse on unary rule
          ((: $prfabs (-> (: $prfarg $prms) $thrm))
           (bc $kb $env $k (: $prfabs (-> (: $prfarg $prms) $thrm))))
          ;; Recurse on premise
          ((: $prfarg $prms) (bc $kb $env $k (: $prfarg $prms))))
     (: ($prfabs $prfarg) $thrm)))
;; Binary proof application
(= (bc $kb $env (S $k) (: ($prfabs $prfarg1 $prfarg2) $thrm))
   (let* (;; Recurse on binary rule
          ((: $prfabs (-> (: $prfarg1 $prms1)
                          (: $prfarg2 $prms2)
                          $thrm))
           (bc $kb $env $k (: $prfabs (-> (: $prfarg1 $prms1)
                                          (: $prfarg2 $prms2)
                                          $thrm))))
          ;; Recurse on premise 1
          ((: $prfarg1 $prms1) (bc $kb $env $k (: $prfarg1 $prms1)))
          ;; Recurse on premise 2
          ((: $prfarg2 $prms2) (bc $kb $env $k (: $prfarg2 $prms2))))
     (: ($prfabs $prfarg1 $prfarg2) $thrm)))

!(bind! &kb (new-space))

!(add-atom &kb (: 𝐚𝐧𝐝 (-> (: $x (List 𝐁𝐨𝐨𝐥))  𝐁𝐨𝐨𝐥))) ;; Using sigma type
!(add-atom &kb (: 𝐨𝐫 (-> (: $x (List 𝐁𝐨𝐨𝐥))  𝐁𝐨𝐨𝐥)))

;; !(add-atom &kb (: 𝐚𝐧𝐝 (-> (: $x 𝐁𝐨𝐨𝐥) (: $y 𝐁𝐨𝐨𝐥)  𝐁𝐨𝐨𝐥)))
;; !(add-atom &kb (: 𝐨𝐫 (-> (: $x 𝐁𝐨𝐨𝐥) (: $y 𝐁𝐨𝐨𝐥)  𝐁𝐨𝐨𝐥)))
!(add-atom &kb (: 𝐧𝐨𝐭 (-> (: $x 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)))
!(add-atom &kb (: 𝐓𝐫𝐮𝐞 𝐁𝐨𝐨𝐥))
!(add-atom &kb (: 𝐅𝐚𝐥𝐬𝐞 𝐁𝐨𝐨𝐥))

!(add-atom &kb (: z 𝐁𝐨𝐨𝐥))
!(add-atom &kb (: (s z) 𝐁𝐨𝐨𝐥))


!(add-atom &kb (: Nil (List $a)))
!(add-atom &kb (: Cons (-> (: $x $a) (: $xs (List $a)) (List $a))))

;; Generating Nary boolean reduct.

;; Generating all expressions starting with 𝐚𝐧𝐝.
! "==========Testing Expression Generation========"

!(assertEqualToResult
   (bc &kb Nil (fromNumber 3) (: (𝐚𝐧𝐝 $xs) 𝐁𝐨𝐨𝐥))
   ((: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 (s z)) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 (s z)) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 (s z)) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 (s z)) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 (s z)) Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 z) Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐅𝐚𝐥𝐬𝐞) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐅𝐚𝐥𝐬𝐞) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐅𝐚𝐥𝐬𝐞) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐅𝐚𝐥𝐬𝐞) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐅𝐚𝐥𝐬𝐞) Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐓𝐫𝐮𝐞) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐓𝐫𝐮𝐞) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐓𝐫𝐮𝐞) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐓𝐫𝐮𝐞) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐧𝐨𝐭 𝐓𝐫𝐮𝐞) Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐚𝐧𝐝 Nil) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐚𝐧𝐝 Nil) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐚𝐧𝐝 Nil) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐚𝐧𝐝 Nil) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (𝐚𝐧𝐝 Nil) Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (s z) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (s z) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (s z) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (s z) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons (s z) Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons z (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons z (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons z (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons z Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐓𝐫𝐮𝐞 (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐓𝐫𝐮𝐞 (Cons z Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐓𝐫𝐮𝐞 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐓𝐫𝐮𝐞 (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 (Cons 𝐓𝐫𝐮𝐞 Nil)) 𝐁𝐨𝐨𝐥)
    (: (𝐚𝐧𝐝 Nil) 𝐁𝐨𝐨𝐥)))

;; Generating all expressions starting with 𝐚𝐧𝐝.
!(assertEqualToResult
   (bc &kb Nil (fromNumber 2) (: (𝐚𝐧𝐝 $xs) 𝐁𝐨𝐨𝐥))
   (
      (: (𝐚𝐧𝐝 (Cons (s z) Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons z Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons 𝐓𝐫𝐮𝐞 Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 Nil) 𝐁𝐨𝐨𝐥)
   )
)

;; !(println! (bc &kb (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) 𝐁𝐨𝐨𝐥) Nil) (fromNumber 2) (: $x 𝐁𝐨𝐨𝐥)))

;; Generating nested expressions from environment.
!(assertEqualToResult 
    (bc &kb (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) 𝐁𝐨𝐨𝐥) Nil) (fromNumber 2) (: $x 𝐁𝐨𝐨𝐥))
    (
      (: (𝐧𝐨𝐭 (𝐧𝐨𝐭 (s z))) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 (𝐧𝐨𝐭 z)) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 (𝐧𝐨𝐭 𝐅𝐚𝐥𝐬𝐞)) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 (𝐧𝐨𝐭 𝐓𝐫𝐮𝐞)) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 (𝐧𝐨𝐭 (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)))) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 (𝐨𝐫 Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 (𝐚𝐧𝐝 Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 (s z)) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 z) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 𝐅𝐚𝐥𝐬𝐞) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 𝐓𝐫𝐮𝐞) 𝐁𝐨𝐨𝐥)
      (: (𝐧𝐨𝐭 (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐨𝐫 (Cons (s z) Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐨𝐫 (Cons z Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐨𝐫 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐨𝐫 (Cons 𝐓𝐫𝐮𝐞 Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐨𝐫 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐨𝐫 Nil) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (s z) Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons z Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons 𝐓𝐫𝐮𝐞 Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 Nil) 𝐁𝐨𝐨𝐥)
      (: (s z) 𝐁𝐨𝐨𝐥)
      (: z 𝐁𝐨𝐨𝐥)
      (: 𝐅𝐚𝐥𝐬𝐞 𝐁𝐨𝐨𝐥)
      (: 𝐓𝐫𝐮𝐞 𝐁𝐨𝐨𝐥)
      (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) 𝐁𝐨𝐨𝐥)))


;; Generating nested expressions from environemnt matching a pattern of and followed by or.
!(assertEqualToResult 
    (bc &kb (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) 𝐁𝐨𝐨𝐥) Nil) (fromNumber 2) (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 $x) $xs)) 𝐁𝐨𝐨𝐥))
    (
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) Nil)) 𝐁𝐨𝐨𝐥)))

;; Generating nested expressions from environemnt matching a pattern of and followed by or.
!(assertEqualToResult 
    (bc &kb (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) 𝐁𝐨𝐨𝐥) Nil) (fromNumber 3) (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 $x) $xs)) 𝐁𝐨𝐨𝐥))
    (
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) Nil)) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) Nil)) 𝐁𝐨𝐨𝐥)))


;; Generating nested expressions from environemnt matching a pattern of and followed by or.
!(assertEqualToResult
   (bc &kb Nil (fromNumber 3) (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 $x) $xs)) 𝐁𝐨𝐨𝐥)) 
   (
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons (s z) Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons z Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥)
      (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 Nil) Nil)) 𝐁𝐨𝐨𝐥)))

;; Generates empty when pattern is not found.
!(assertEqual (bc &kb Nil (fromNumber 2) (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 $x) $xs)) 𝐁𝐨𝐨𝐥)) (empty))


(: any (-> (List 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥))
(= (any Nil) 𝐅𝐚𝐥𝐬𝐞)
(= (any (Cons $x $xs)) (if (== $x 𝐓𝐫𝐮𝐞) 𝐓𝐫𝐮𝐞 (any $xs)))

(: all (-> (List $a) 𝐁𝐨𝐨𝐥))
(= (all Nil) 𝐓𝐫𝐮𝐞)
(= (all (Cons $x $xs)) (if (== $x 𝐅𝐚𝐥𝐬𝐞) 𝐅𝐚𝐥𝐬𝐞 (all $xs)))

;; Test any and all
!(assertEqual (any (Cons (: (s z) Bool) (Cons (: z Bool) (Cons 𝐓𝐫𝐮𝐞 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))))) 𝐓𝐫𝐮𝐞)
!(assertEqual (any (Cons (: (s z) Bool) (Cons (: z Bool) (Cons 𝐓𝐫𝐮𝐞 Nil)))) 𝐓𝐫𝐮𝐞)
!(assertEqual (all (Cons (: (s z) Bool) (Cons (: z Bool) (Cons 𝐓𝐫𝐮𝐞 (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))))) 𝐅𝐚𝐥𝐬𝐞)
!(assertEqual (all (Cons (: (s z) Bool) (Cons (: z Bool) (Cons 𝐓𝐫𝐮𝐞 Nil)))) 𝐓𝐫𝐮𝐞)



;; Reduction type to include the reduction sequence
;;  that led to a certain ENF boolean expression
;;  in the result.
(: Reduction Type)
;; (: mkReduct (-> Rule (: $a 𝐁𝐨𝐨𝐥) (: $b 𝐁𝐨𝐨𝐥) Reduction))
(: mkReduct (-> $rule $reduced Reduction))

;; (: Rule Type)
;; (: CutOr Rule)
;; (: CutAnd Rule)
;; (: OrIden Rule)
;; (: AndIden Rule)

(: orCut (-> $x 𝐁𝐨𝐨𝐥))
(= (orCut $expr)
   (case $expr
      (
        ;; ((𝐨𝐫 Nil) (mkReduct CutOr $expr 𝐓𝐫𝐮𝐞))
        ;; ((𝐨𝐫 (Cons $x Nil)) (mkReduct CutOr $expr $x))
        ((𝐨𝐫 Nil) 𝐓𝐫𝐮𝐞)
        ((𝐨𝐫 (Cons $x Nil)) $x)
        ((𝐨𝐫 (Cons $x $xs)) $expr)
        ($else (Error IncorrectExpression)))))

 (: andCut (-> $x 𝐁𝐨𝐨𝐥))
 (= (andCut $expr)
    (case $expr
       (
         ;; ((𝐚𝐧𝐝 Nil) (mkReduct CutAnd $expr 𝐅𝐚𝐥𝐬𝐞))
         ;; ((𝐚𝐧𝐝 (Cons $x Nil)) (mkReduct CutAnd $expr $x))
         ((𝐚𝐧𝐝 Nil) 𝐅𝐚𝐥𝐬𝐞)
         ((𝐚𝐧𝐝 (Cons $x Nil)) $x)
         ((𝐚𝐧𝐝 (Cons $x $xs)) $expr)
         ($else (Error IncorrectExpression)))))

 (: idenOr (-> $x 𝐁𝐨𝐨𝐥))
 (= (idenOr $expr)
    (case $expr
         (
           ;; ((𝐨𝐫 $xs) (if (== (any $xs) 𝐓𝐫𝐮𝐞) (mkReduct OrIden $expr 𝐓𝐫𝐮𝐞) (𝐨𝐫 $xs)))
           ((𝐨𝐫 $xs) (if (== (any $xs) 𝐓𝐫𝐮𝐞) 𝐓𝐫𝐮𝐞 (𝐨𝐫 $xs)))
           ($else (Error IncorrectExpression)))))

 (: idenAnd (-> $x 𝐁𝐨𝐨𝐥))
 (= (idenAnd $expr)
    (case $expr
         (
           ;; ((𝐚𝐧𝐝 $xs) (if (== (all $xs) 𝐅𝐚𝐥𝐬𝐞) (mkReduct AndIden 𝐅𝐚𝐥𝐬𝐞) (𝐚𝐧𝐝 $xs)))
           ((𝐚𝐧𝐝 $xs) (if (== (all $xs) 𝐅𝐚𝐥𝐬𝐞) 𝐅𝐚𝐥𝐬𝐞 (𝐚𝐧𝐝 $xs)))
           ($else (Error IncorrectExpression)))))

;; (AndIden (CutOr (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) Nil)))) => (AndIden (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)))) => 𝐅𝐚𝐥𝐬𝐞
(= (applyReduct $expr)
    (case $expr
          (
            ((CutOr $rest) (let $rest' (applyReduct $rest) (orCut $rest')))
            ((CutAnd $rest) (let $rest' (applyReduct $rest) (andCut $rest')))
            ((OrIden $rest) (let $rest' (applyReduct $rest) (idenOr $rest')))
            ((AndIden $rest) (let $rest' (applyReduct $rest) (idenAnd $rest')))
            ($else $expr)
          )
    )
)


!(bind! &rb (new-space))

!(add-atom &rb (: CutOr (-> (: $x 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)))
!(add-atom &rb (: CutAnd (-> (: $x 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)))
!(add-atom &rb (: OrIden (-> (: $x 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)))
!(add-atom &rb (: AndIden (-> (: $x 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)))

(= (reduce $rb $cnds $lvl)
      (let*
          (
            ((: $reductSeq 𝐁𝐨𝐨𝐥)
                  (bc $rb
                      $cnds
                      $lvl
                      ;; (: ($rule ($ctor $xs) $ctor) 𝐁𝐨𝐨𝐥))) ;; Attempt to add more constraint on the reduct rules.
                      (: $reduct 𝐁𝐨𝐨𝐥)))
            ($reduced (applyReduct $reductSeq))
          )
          ;; (mkReduct $reduced $reductSeq))))
          $reduced))

(= (testReduce $rb $cnds $lvl)
      (let*
        (
          ($atoms (collapse (reduce $rb $cnds (fromNumber $lvl))))
          ($uniqueAtoms (unique-atom $atoms)))
      (superpose $uniqueAtoms)))



        ;; (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) 𝐁𝐨𝐨𝐥) Nil) ;; CutOr and CutAnd (or (and z))
        ;; (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥) Nil) ;; IdentityOr (or (and z) True)
        ;; (Cons (: z 𝐁𝐨𝐨𝐥) Nil)

! "=======Testing bc reduct========"

;; Backward chaining (BC) output test without reducing

;; Test BC generating all possible combination of reduction rules at level 1
!(assertEqualToResult
    (bc &rb
        (Cons (: (s z) 𝐁𝐨𝐨𝐥) Nil)
        (fromNumber 1)
        (: $reduct 𝐁𝐨𝐨𝐥))
    (
      (: (AndIden (s z)) 𝐁𝐨𝐨𝐥)
      (: (OrIden (s z)) 𝐁𝐨𝐨𝐥)
      (: (CutAnd (s z)) 𝐁𝐨𝐨𝐥)
      (: (CutOr (s z)) 𝐁𝐨𝐨𝐥)
      (: (s z) 𝐁𝐨𝐨𝐥)))

;; Test BC generating all possible combination of reduction rules at level 2
!(assertEqualToResult
    (bc &rb
        (Cons (: (s z) 𝐁𝐨𝐨𝐥) Nil)
        (fromNumber 2)
        (: $reduct 𝐁𝐨𝐨𝐥))
    (
        (: (AndIden (AndIden (s z))) 𝐁𝐨𝐨𝐥)
        (: (AndIden (OrIden (s z))) 𝐁𝐨𝐨𝐥)
        (: (AndIden (CutAnd (s z))) 𝐁𝐨𝐨𝐥)
        (: (AndIden (CutOr (s z))) 𝐁𝐨𝐨𝐥)
        (: (AndIden (s z)) 𝐁𝐨𝐨𝐥)
        (: (OrIden (AndIden (s z))) 𝐁𝐨𝐨𝐥)
        (: (OrIden (OrIden (s z))) 𝐁𝐨𝐨𝐥)
        (: (OrIden (CutAnd (s z))) 𝐁𝐨𝐨𝐥)
        (: (OrIden (CutOr (s z))) 𝐁𝐨𝐨𝐥)
        (: (OrIden (s z)) 𝐁𝐨𝐨𝐥)
        (: (CutAnd (AndIden (s z))) 𝐁𝐨𝐨𝐥)
        (: (CutAnd (OrIden (s z))) 𝐁𝐨𝐨𝐥)
        (: (CutAnd (CutAnd (s z))) 𝐁𝐨𝐨𝐥)
        (: (CutAnd (CutOr (s z))) 𝐁𝐨𝐨𝐥)
        (: (CutAnd (s z)) 𝐁𝐨𝐨𝐥)
        (: (CutOr (AndIden (s z))) 𝐁𝐨𝐨𝐥)
        (: (CutOr (OrIden (s z))) 𝐁𝐨𝐨𝐥)
        (: (CutOr (CutAnd (s z))) 𝐁𝐨𝐨𝐥)
        (: (CutOr (CutOr (s z))) 𝐁𝐨𝐨𝐥)
        (: (CutOr (s z)) 𝐁𝐨𝐨𝐥)
        (: (s z) 𝐁𝐨𝐨𝐥)))


;; Testing Reduced outputs
!(assertEqual (testReduce &rb (Cons (: z 𝐁𝐨𝐨𝐥) Nil) 1) z)

;; OrCut and IdentityAnd (or (and z False))
!(assertEqualToResult 
   (testReduce &rb (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) Nil)) 𝐁𝐨𝐨𝐥) Nil) 2) 
   (
      (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil)))
      (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) Nil))
      𝐅𝐚𝐥𝐬𝐞))
 

;; OrCut and AndCut (or (and z))
!(assertEqualToResult 
    (testReduce &rb (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) 𝐁𝐨𝐨𝐥) Nil) 2)
    (
      z
      (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil))
      (𝐚𝐧𝐝 (Cons z Nil))))

;; IdentityOr (or (and z) True)
!(assertEqualToResult 
    (testReduce &rb (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥) Nil) 2) 
    (
      (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) (Cons 𝐓𝐫𝐮𝐞 Nil)))
      𝐓𝐫𝐮𝐞))

