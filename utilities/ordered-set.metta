;; data structure for exemplars -- aka scored trees -- Xmplr
;; deme ID
(: demeID Type)
(: mkDemeID (-> Number demeID))

;; composite_score
(: cscore Type)
(: getCscore (-> tree cscore))
        
;; composite score components
(: scoreT Type)
(: cpxyT Type)

(: mkScoreT (-> Number scoreT))
(: mkCpxy (-> Number cpxyT))

;; composite score is composed of a raw score, comlexity score, a complexity penalty and a uniformity penalty score
(: mkCscore (-> scoreT cpxyT scoreT scoreT cscore))

;; behavioral_score
(: bscore Type)
(: mkBscore (-> Number bscore))

(: Xmplr Type)

(: mkXmplr (-> tree demeID cscore bscore Xmplr))

;; XXX - SUGGESTION -- for the exemplars, I have tried to follow the type definitions as they are defined in C++ MOSES
;; although now I don't exactly see the advantage using specific types for numerical values such as bscore, score ..
;; I say it is better better to uses these as Numbers without wrapper type definitions

;; data structures for the metapopulation
;; keeping the same naming convention as used in the definitio of the ordered multiset
;; Ordered set data structure -- OS

(: OS (-> $a Type))
(: mkOS (-> $a (OS $a)))

;; the metapopulation -- MP as an ordered set of exemplars (OS Xmplr)
(: MP (OS Xmplr))

(: mkMP (-> Xmplr (OS Xmplr) (OS Xmplr)))
(: NilXmplr (OS Xmplr))

;; compare two exemplars in a metapopulation using penalized score using complexity score to separate ties
;; G -- if first exemplar greater than the second in terms of penalized score or if this is the same lower complexity score 
;; E -- exemplars equal in both of the scores
;; L -- either lower in penalized score or higher complexity with equal penalized scores

(MP.XmplrCompare (-> Xmplr Xmplr Atom))
(= (MP.XmplrCompare $xmplr1 $xmplr2)
    (let*
        (
            (($p1 $p2) ((Xmplr.getPnzdScr $xmplr1) (Xmplr.getPnzdScr $xmplr2)))
            (($cs1 $cs2) ((Xmplr.getCpxyScore $xmplr1) (Xmplr.getCpxyScore $xmplr2))))
            
                (case ((> $p1 $p2) (== $p1 $p2) (< $cs1 $cs2) (== $cs1 $cs2))
                    
                    (((True $t $u $v) G)
                     ((False True True $v) G)
                     ((False True False True) E)
                     ((False True False False) L)
                     ((False False $u $v) L) ))))

;; get penalized score of an exemplar
(: Xmplr.getPnzdScr (-> Xmplr ScoreT))
(= (Xmplr.getPnzdScr $xmplr)
    (let ($tree $demeID ($s $cs $cp $up) $bscore) $xmplr  (- (- $s $cp) $up)))

;; get expression of probability values 
(: MP.getProbs (-> (OS Xmplr) (Exp ScoreT)))
(= (MP.getProbs $mp)
    (collapse 
        (let $xmplr (superpose $mp) (Xmplr.getPnzdScr $xmplr))))

;; insert an exemplar (Xmplr) in to the metapopulaion
(: MP.insert (-> Xmplr (OS Xmplr) (OS Xmplr)))
(= (MP.insert $xmplr $mp)
    (if (== $mp NilXmplr)
        ($xmplr)
        (let ($f $t) (decons-atom $mp)
            (case (MP.XmplrCompare $xmplr $f)
                ((G (cons-atom $xmplr $mp))
                 (E $mp) ;; mp unchanged
                 (L (if (== $t ())
                        (cons-atom $f ($xmplr))
                        (let $c (MP.insert $xmplr $t) ;; recursion
                            (cons-atom $f $c)))))))))