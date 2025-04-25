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

;; Blackbox rule reduction
(= (bc $kb $env $_ (: ((CondReduce $p $r) $cnd) $thrm))
   (when (is-closed $cnd)
     (if (== ($p $cnd) $r) (: ((CondReduce $p $r) $cnd) $thrm) (empty))))

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

!(bind! &rb (new-space))

;; Attempt to add more constraints on the reduct rules ;; WARN: This file isn't working yet.

;; ;; !(add-atom &rb (: CutOr (-> (: $x 𝐁𝐨𝐨𝐥) (: 𝐨𝐫 (-> (: $xs (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)))
;; !(add-atom &rb (: CutAnd (-> (: $x 𝐁𝐨𝐨𝐥) (: 𝐚𝐧𝐝 (-> (: $xs (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)))
;; !(add-atom &rb (: OrIden (-> (: $x 𝐁𝐨𝐨𝐥) (: 𝐨𝐫 (-> (: $xs (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)))
;; !(add-atom &rb (: AndIden (-> (: $x 𝐁𝐨𝐨𝐥) (: 𝐚𝐧𝐝 (-> (: $xs (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)))
;;
;; !(add-atom &rb (: CutOr (-> (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥) (: 𝐨𝐫 (-> (: $xs (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)) (: ($rule $child 𝐚𝐧𝐝) 𝐁𝐨𝐨𝐥)))) ;; return type should contain the resulting expression's type
;; !(add-atom &rb (: CutAnd (-> (: (𝐚𝐧𝐝 $x) 𝐁𝐨𝐨𝐥) (: 𝐚𝐧𝐝 (-> (: $xs (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)) (: ($rule $child 𝐨𝐫) 𝐁𝐨𝐨𝐥))))
;; !(add-atom &rb (: OrIden (-> (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥) (: 𝐨𝐫 (-> (: $xs (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)) (: ($rule $child 𝐚𝐧𝐝) 𝐁𝐨𝐨𝐥))))
;; !(add-atom &rb (: AndIden (-> (: (𝐚𝐧𝐝 $x) 𝐁𝐨𝐨𝐥) (: 𝐚𝐧𝐝 (-> (: $xs (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)) (: ($rule $child 𝐨𝐫) 𝐁𝐨𝐨𝐥))))


;; !(add-atom &rb (: CutOr (-> (: ((: $rule (-> (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)) $x) 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)))
;; !(add-atom &rb (: CutOr (-> (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥) (: $rule (-> (: $nc 𝐁𝐨𝐨𝐥) $nr)))))
;; !(add-atom &rb (: CutOr (-> (: $rule (-> (: (𝐚𝐧𝐝 $x) 𝐁𝐨𝐨𝐥) (: (𝐨𝐫 $x') 𝐁𝐨𝐨𝐥))) (: $rule (-> (: $nc 𝐁𝐨𝐨𝐥) $nr)))))
;; !(add-atom &rb (: CutOr (-> (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥) (: $x 𝐁𝐨𝐨𝐥))))
;; !(add-atom &rb (: CutOr (-> (: $rule (-> (: (𝐚𝐧𝐝 $x) 𝐁𝐨𝐨𝐥) (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥))) (: $x 𝐁𝐨𝐨𝐥))))

;; !(add-atom &rb (: CutAnd (-> (: (𝐚𝐧𝐝 $x) 𝐁𝐨𝐨𝐥) (: $rule (-> (: $nc 𝐁𝐨𝐨𝐥) $nr)))))
;; !(add-atom &rb (: CutAnd (-> (: $rule (-> (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥) (: (𝐚𝐧𝐝 $x') 𝐁𝐨𝐨𝐥))) (: $rule (-> (: $nc 𝐁𝐨𝐨𝐥) $nr)))))
;; !(add-atom &rb (: CutAnd (-> (: (𝐚𝐧𝐝 $x) 𝐁𝐨𝐨𝐥) (: $x 𝐁𝐨𝐨𝐥))))
;; !(add-atom &rb (: CutAnd (-> (: $rule (-> (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥) (: (𝐚𝐧𝐝 $x) 𝐁𝐨𝐨𝐥))) (: $x 𝐁𝐨𝐨𝐥))))
;; !(add-atom &rb (: OrIden (-> (: (𝐨𝐫 $x) 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)))
;; !(add-atom &rb (: AndIden (-> (: (𝐚𝐧𝐝 $x) 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥)))


;; Run the code if the condition is true, otherwise prune the branch
(: when (-> Bool $a $a))
(= (when $c $x) (if $c $x (empty)))

;; Return True iff $term is closed
(: is-closed (-> Atom Bool))
(= (is-closed $term)
   (case (get-metatype $term)
     ((Variable False)
      (Symbol True)
      (Grounded True)
      (Expression (if (== $term ())
                      True
                      (let* (($head (car-atom $term))
                             ($tail (cdr-atom $term)))
                        (and (is-closed $head) (is-closed $tail))))))))

(: any (-> (List 𝐁𝐨𝐨𝐥) 𝐁𝐨𝐨𝐥))
(= (any Nil) 𝐅𝐚𝐥𝐬𝐞)
(= (any (Cons $x $xs)) (if (== $x 𝐓𝐫𝐮𝐞) 𝐓𝐫𝐮𝐞 (any $xs)) )
;; (= (any (Cons $x $xs)) (trace! (Running X: $x check...) (if (== $x 𝐓𝐫𝐮𝐞) 𝐓𝐫𝐮𝐞 (any $xs))) )

(: all (-> (List $a) 𝐁𝐨𝐨𝐥))
(= (all Nil) 𝐓𝐫𝐮𝐞)
(= (all (Cons $x $xs)) (if (== $x 𝐅𝐚𝐥𝐬𝐞) 𝐅𝐚𝐥𝐬𝐞 (all $xs)))
;; (= (all (Cons $x $xs)) (trace! (Running X: $x check...) (if (== $x 𝐅𝐚𝐥𝐬𝐞) 𝐅𝐚𝐥𝐬𝐞 (all $xs))))

;; !(add-atom &rb (: 𝐚𝐧𝐝 (-> (: $x (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)))
;; !(add-atom &rb (: 𝐨𝐫 (-> (: $x (List 𝐁𝐨𝐨𝐥)) 𝐁𝐨𝐨𝐥)))

!(add-atom &rb (: CutOr (-> (: (𝐨𝐫 (Cons $x Nil)) 𝐁𝐨𝐨𝐥) (: $x 𝐁𝐨𝐨𝐥))))
!(add-atom &rb (: CutOr (-> (: ($rule $seq) (: (𝐨𝐫 (Cons $x Nil)) 𝐁𝐨𝐨𝐥)) (: $x 𝐁𝐨𝐨𝐥))))

!(add-atom &rb (: CutAnd (-> (: (𝐚𝐧𝐝 (Cons $x Nil)) 𝐁𝐨𝐨𝐥) (: $x 𝐁𝐨𝐨𝐥))))
!(add-atom &rb (: CutAnd (-> (: ($rule $seq) (: (𝐚𝐧𝐝 (Cons $x Nil)) 𝐁𝐨𝐨𝐥)) (: $x 𝐁𝐨𝐨𝐥))))

;; !(add-atom &rb (: OrIden (-> (: (𝐨𝐫 $xs) 𝐁𝐨𝐨𝐥) (: (if (== (any $xs) 𝐓𝐫𝐮𝐞) 𝐓𝐫𝐮𝐞 (empty)) 𝐁𝐨𝐨𝐥)))) ;; FIX: Rule runs before candidate is closed.
;; !(add-atom &rb (: OrIden (-> (: ($rule $seq) (: (𝐨𝐫 $xs) 𝐁𝐨𝐨𝐥)) (: (if (== (any $xs) 𝐓𝐫𝐮𝐞) 𝐓𝐫𝐮𝐞 (empty)) 𝐁𝐨𝐨𝐥))))
;; !(add-atom &rb (: OrIden (-> (: (𝐨𝐫 $xs) 𝐁𝐨𝐨𝐥) (: ((CondReduce any 𝐓𝐫𝐮𝐞) $xs) 𝐁𝐨𝐨𝐥)))) ;; FIX: Not working
;; !(add-atom &rb (: OrIden (-> (: ($rule $seq) (: (𝐨𝐫 $xs) 𝐁𝐨𝐨𝐥)) (: ((CondReduce any 𝐓𝐫𝐮𝐞) $xs) 𝐁𝐨𝐨𝐥))))

;; !(add-atom &rb (: AndIden (-> (: (𝐚𝐧𝐝 $xs) 𝐁𝐨𝐨𝐥) (: (if (== (all $xs) 𝐓𝐫𝐮𝐞) (empty) 𝐅𝐚𝐥𝐬𝐞) 𝐁𝐨𝐨𝐥))))
;; !(add-atom &rb (: AndIden (-> (: ($rule $seq) (: (𝐚𝐧𝐝 $xs) 𝐁𝐨𝐨𝐥)) (: (if (== (all $xs) 𝐓𝐫𝐮𝐞) (empty) 𝐅𝐚𝐥𝐬𝐞) 𝐁𝐨𝐨𝐥))))
;; !(add-atom &rb (: AndIden (-> (: (𝐚𝐧𝐝 $xs) 𝐁𝐨𝐨𝐥) (: ((CondReduce all 𝐅𝐚𝐥𝐬𝐞) $xs) 𝐁𝐨𝐨𝐥)))) ;; FIX: Not working
;; !(add-atom &rb (: AndIden (-> (: ($rule $seq) (: (𝐚𝐧𝐝 $xs) 𝐁𝐨𝐨𝐥)) (: ((CondReduce all 𝐅𝐚𝐥𝐬𝐞) $xs) 𝐁𝐨𝐨𝐥))))


!(add-atom &rb (: Id (-> (: $x 𝐁𝐨𝐨𝐥) (: $x 𝐁𝐨𝐨𝐥))))

!(add-atom &rb (: AndIden (-> (: (𝐚𝐧𝐝 $xs) 𝐁𝐨𝐨𝐥) (: ((CondReduce all 𝐅𝐚𝐥𝐬𝐞) $xs) 𝐁𝐨𝐨𝐥) (: 𝐅𝐚𝐥𝐬𝐞 𝐁𝐨𝐨𝐥))))
!(add-atom &rb (: AndIden (-> (: ($rule $seq) (: (𝐚𝐧𝐝 $xs) 𝐁𝐨𝐨𝐥)) (: ((CondReduce all 𝐅𝐚𝐥𝐬𝐞) $xs) 𝐁𝐨𝐨𝐥) (: 𝐅𝐚𝐥𝐬𝐞 𝐁𝐨𝐨𝐥))))

!(add-atom &rb (: OrIden (-> (: (𝐨𝐫 $xs) 𝐁𝐨𝐨𝐥) (: ((CondReduce any 𝐓𝐫𝐮𝐞) $xs) 𝐁𝐨𝐨𝐥) (: 𝐓𝐫𝐮𝐞 𝐁𝐨𝐨𝐥))))
!(add-atom &rb (: OrIden (-> (: ($rule $seq) (: (𝐨𝐫 $xs) 𝐁𝐨𝐨𝐥)) (: ((CondReduce any 𝐓𝐫𝐮𝐞) $xs) 𝐁𝐨𝐨𝐥) (: 𝐓𝐫𝐮𝐞 𝐁𝐨𝐨𝐥))))

!(println!
    (bc &rb
        ;; (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) Nil)) 𝐁𝐨𝐨𝐥) Nil) ;; CutOr and CutAnd
        ;; (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) Nil)) 𝐁𝐨𝐨𝐥) Nil) ;; CutOr and CutAnd
        ;; (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z Nil)) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥) Nil) ;; IdentityOr
        ;; (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) Nil)) 𝐁𝐨𝐨𝐥) Nil) ;; IdentityAnd
        ;; (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons z (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) Nil)) 𝐁𝐨𝐨𝐥) Nil) ;; IdentityAnd
        ;; (Cons (: (𝐨𝐫 (Cons (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons z Nil)) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) Nil)) 𝐁𝐨𝐨𝐥) Nil) ;; IdentityAnd
        ;; (Cons (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons z Nil)) (Cons 𝐅𝐚𝐥𝐬𝐞 Nil))) 𝐁𝐨𝐨𝐥) Nil) ;; IdentityAnd
        (Cons (: (𝐚𝐧𝐝 (Cons (𝐨𝐫 (Cons z Nil)) (Cons 𝐓𝐫𝐮𝐞 Nil))) 𝐁𝐨𝐨𝐥) Nil) ;; IdentityAnd
        ;; (Cons (: z 𝐁𝐨𝐨𝐥) Nil)
        (fromNumber 2)
        (: $reduct (: $x 𝐁𝐨𝐨𝐥)))
 )
