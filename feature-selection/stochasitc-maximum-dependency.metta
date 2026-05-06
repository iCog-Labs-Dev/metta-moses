;; --- Stochastic Maximum Dependency Feature Selection Algorithm ---

;; --- Random Shuffling ---
;; random shuffling using random weight -- assign random weights to features and by sorting these random weights efffectively shuffling feature order
(= (insert-weight $w $h ()) (cons (cons $w (cons $h ())) ()))
(= (insert-weight $w $h (cons $hw-head $t))
   (let (cons $hw $rest) $hw-head
        (if (< $w $hw)
            (cons (cons $w (cons $h ())) (cons $hw-head $t))
            (cons $hw-head (insert-weight $w $h $t)))))

(= (shuffle-with-weights ()) ())
(= (shuffle-with-weights (cons $h $t))
   ; (insert-weight (random-float &rng 0.0 1.0) $h (shuffle-with-weights $t)))
   (insert-weight (py-call (random.random)) $h (shuffle-with-weights $t)))

(= (strip-weights ()) ())
(= (strip-weights (cons $hw-head $t))
   (let (cons $w (cons $h ())) $hw-head
        (cons $h (strip-weights $t))))

(= (shuffle-list $list)
   (strip-weights (shuffle-with-weights $list)))

;; insert pair (score feature-set) into sorted ranks list up to max-size
(= (insert-rank-bounded $pair () $max-size)
   (if (> $max-size 0) (cons $pair ()) ()))
(= (insert-rank-bounded $pair (cons $head-pair $t) $max-size)
   (if (<= $max-size 0)
       ()
       (let* (((cons $score (cons $fs ())) $pair)
              ((cons $h-score (cons $h-fs ())) $head-pair))
                 (if (== $fs $h-fs)
                     (cons $head-pair $t)
                     (if (> $score $h-score)
                         (let $next-max (- $max-size 1)
                              (cons $pair (take $next-max (cons $head-pair $t))))
                         (let $next-max (- $max-size 1)
                              (cons $head-pair (insert-rank-bounded $pair $t $next-max))))))))

(= (get-top-n () $ranks $n) $ranks)
(= (get-top-n (cons $pair $rest) $ranks $n)
    (get-top-n $rest (insert-rank-bounded $pair $ranks $n) $n))

;; insert feature into sorted list (keeps set sorted and unique)
(= (add-feature $f ()) (cons $f ()))
(= (add-feature $f (cons $h $t))
   (if (< $f $h)
       (cons $f (cons $h $t))
       (if (== $f $h)
           (cons $h $t)
           (cons $h (add-feature $f $t)))))

(= (expand-tops $Table $all-features $tops)
   (collapse (let (cons $score (cons $fs ())) (superpose $tops)
                  (let $f (superpose $all-features)
                       (if (List.contains $f $fs)
                           (empty)
                           (let* (($new-fs (add-feature $f $fs))
                                  ($new-score (cached-mi-score $Table $new-fs)))
                                     (cons $new-score (cons $new-fs ()))))))))
                                     
(= (smd-step $Table $all-features $num-features $threshold $top-size $current-i $previous-high-score $tops)
   (if (> $current-i $num-features)
       $tops
       (let* (($new-candidates (expand-tops $Table $all-features $tops))
              ($new-tops (get-top-n $new-candidates () $top-size)))
             (if (== $new-tops ())
                 $tops
                 (let* ((($high-score $ftre) (List.getByIdx $new-tops 0))
                        ($improvement (- $high-score $previous-high-score)))
                           (if (< $improvement $threshold)
                               $new-tops
                               (let $next-i (+ $current-i 1)
                                    (smd-step $Table $all-features $num-features $threshold $top-size $next-i $high-score $new-tops))))))))


(= (smd-feature-selection $Table $target-size $threshold $top-size $init-features)
   (if (<= $target-size 0)
       (let $all-features (range 0 (get-target-col $Table))
            (cons (cons (mi-score $Table $all-features) (cons $all-features ())) ()))
       (let* (($all-features (range 0 (get-target-col $Table)))
              ($shuffled-features (shuffle-list $all-features))
              ($actual-num-features (min $target-size (List.length $all-features)))
              ($init-score (cached-mi-score $Table $init-features))
              ($init-tops (cons (cons $init-score (cons $init-features ())) ())))
             (if (<= $actual-num-features 0)
                 $init-tops
                 (smd-step $Table $shuffled-features $actual-num-features $threshold $top-size (+ (size-atom $init-features) 1) $init-score $init-tops)))))