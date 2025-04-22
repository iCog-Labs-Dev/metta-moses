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

;; Similar to match but takes a list of terms instead of a space.
(: match' (-> (List Atom) $a $a $a))
(= (match' Nil $pattern $rewrite) (empty))
(= (match' (Cons $head $tail) $pattern $rewrite) (let $pattern $head $rewrite))
(= (match' (Cons $head $tail) $pattern $rewrite) (match' $tail $pattern $rewrite))

;; Base cases
;; Match the knowledge base
(= (bc $kb $_ (: $prf $thrm))
   (match $kb (: $prf $thrm) (: $prf $thrm)))

;; Recursive steps
;; Binary proof application
(= (bc $kb (S $k) (: ($prfabs $prfarg1 $prfarg2) $thrm))
   (let* (;; Recurse on n-ary rule
          ((: $prfabs (-> (: $prfarg1 $prms1)
                          (: $prfarg2 $thrm)
                          $thrm))
           (bc $kb $k (: $prfabs (-> (: $prfarg1 $prms1)
                                          (: $prfarg2 $thrm)
                                          $thrm))))
          ;; Recurse on premise 1
          ((: $prfarg1 $prms1) (bc $kb $k (: $prfarg1 $prms1)))
          ;; Recurse on premise 2
          ((: $prfarg2 $thrm) (bc $kb $k (: $prfarg2 $thrm)))
          ;; ($arg2 (if (== $prfarg2 Nil) Nil (trace! (Deconsing $prfarg2) (let ($ructor $arg1 $arg2) $prfarg2 $arg1))))
          )
     ;; (if (== $prfarg1 $arg2) (empty) (: ($prfabs $prfarg1 $prfarg2) $thrm))))
     (: ($prfabs $prfarg1 $prfarg2) $thrm)))

!(bind! &kb (new-space))

!(add-atom &kb (: z 𝐁𝐨𝐨𝐥))
!(add-atom &kb (: (s z) 𝐁𝐨𝐨𝐥))
!(add-atom &kb (: (s (s z)) 𝐁𝐨𝐨𝐥))

;; !(add-atom &kb (: 𝐚𝐧𝐝 (-> (: $x (List 𝐁𝐨𝐨𝐥))  𝐁𝐨𝐨𝐥)))
;; !(add-atom &kb (: 𝐨𝐫 (-> (: $x (List 𝐁𝐨𝐨𝐥))  𝐁𝐨𝐨𝐥)))
;; !(add-atom &kb (: List (-> $a Type)))

!(add-atom &kb (: Nil (List $a)))
!(add-atom &kb (: Cons (-> (: $x $a) (: $xs (List $a)) (List $a))))


;; Generate all possible list of variables until length 2
!(println! (bc &kb (fromNumber 2) (: $cnd (List 𝐁𝐨𝐨𝐥))))

;; !(bc &kb (fromNumber 1) (: $cnd (List $a))) ;; Faulty list is being generated here.
