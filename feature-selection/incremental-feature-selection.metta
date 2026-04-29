;; Incremental Feature Selection Algorithm

(= (get-column $n ()) ())
(= (get-column $n (cons $row $rows))
   (cons (List.getByIdx $row $n) (get-column $n $rows)))

(= (extract-features $indices $row)
   (if (== $indices ())
       ()
       (let (cons $idx $restIndices) $indices
            (cons (List.getByIdx $row $idx) (extract-features $restIndices $row)))))

(= (get-columns $indices ()) ())
(= (get-columns $indices (cons $row $rows))
   (cons (extract-features $indices $row) (get-columns $indices $rows)))

(= (unique-list ()) ())
(= (unique-list (cons $h $t))
   (let $u (unique-list $t)
        (if (List.contains $h $u) $u (cons $h $u))))

(= (count-eq $val ()) 0)
(= (count-eq $val (cons $h $t))
   (if (== $val $h)
       (+ 1 (count-eq $val $t))
       (count-eq $val $t)))

(= (map-prob () $z $n) ())
(= (map-prob (cons $h $t) $z $n)
   (cons (/ (count-eq $h $z) $n) (map-prob $t $z $n)))

(= (map-entropy-term ()) ())
(= (map-entropy-term (cons $p $t))
   (cons (* $p (log-math 2.0 $p)) (map-entropy-term $t)))

(= (entropy $z)
   (if (or (== $z Nil) (== $z ())) 0.0
       (let* (($n (List.length $z))
              ($uniqueZ (unique-list $z))
              ($probs (map-prob $uniqueZ $z $n)))
                (- 0.0 (List.sum (map-entropy-term $probs))))))

(= (get-target-col (mkITable $rows $features))
      (- (List.length $features) 1))

(= (get-rows (mkITable $rows $features)) $rows)

(= (mi-score $table $indices)
   (if (== $indices ()) 0.0
       (let* (($rows (get-rows $table))
              ($targetCol (get-target-col $table))
              ($y (get-column $targetCol $rows))
              ($x (get-columns $indices $rows))
              ($xy (List.zip $x $y)))
             (- (+ (entropy $x) (entropy $y)) (entropy $xy)))))

;; --- Incremental Feature Selection Algorithm ---
(= (comb $k $list)
   (if (== $k 0) ()
       (if (== $list ()) (empty)
           (let (cons $head $tail) $list
                (superpose (
                    (let $sub (comb (- $k 1) $tail)
                         (cons $head $sub))
                    (comb $k $tail)))))))

(= (flatten-unique ()) ())
(= (flatten-unique (cons $head $tail))
   (unique-atom (union-atom $head (flatten-unique $tail))))

(= (get-rel $table $tf $i $threshold)
   (let $fss (collapse (comb $i $tf))
        (let $relevantSubsets (collapse (let $fs (superpose $fss)
                                               (if (> (cached-mi-score $table $fs) $threshold) $fs (empty))))
             (flatten-unique $relevantSubsets))))

(= (max-score-subset $table ()) (empty))
(= (max-score-subset $table (cons $head ())) $head)
(= (max-score-subset $table (cons $head $tail))
   (let $bestTail (max-score-subset $table $tail)
        (if (> (mi-score $table $head) (mi-score $table $bestTail))
            $head
            $bestTail)))

(= (redundant-features $features $table $redThreshold $k)
   (if (== $k (List.length $features))
       ()
       (let $sfs (collapse (comb $k $features))
            (let $mit (max-score-subset $table $sfs)
                 (if (< (- (mi-score $table $features) (mi-score $table $mit)) $redThreshold)
                     (subtraction-atom $features $mit)
                     (redundant-features $features $table $redThreshold (+ $k 1)))))))

(= (get-redundant-features $features $table $redThreshold)
   (redundant-features $features $table $redThreshold 1))

(= (get-red $table $rel $i $redThreshold)
   (let $nrfss (collapse (comb (+ $i 1) $rel))
        (let $redSubsets (collapse (let $fs (superpose $nrfss)
                                         (get-redundant-features $fs $table $redThreshold)))
             (flatten-unique $redSubsets))))

(= (range $start $end)
   (if (>= $start $end) ()
       (cons $start (range (+ $start 1) $end))))


;; --- LRU Cache for mi-score ---
;; State atoms stored in &self:
;;   (lru-tick <N>)                    -- monotonic clock
;;   (lru-entry <Indices> <Score> <N>) -- cache entry with access time
;;   (lru-capacity <N>)                -- max entries allowed
;;
;; Initialize state (call once at the top of your script):
;;   !(lru-init 128)

(= (lru-init $capacity)
   (let* (($_ (add-atom &self (lru-tick 0)))
          ($_ (add-atom &self (lru-capacity $capacity))))
          True))

;; Advance the tick counter and return the new value
(= (lru-next-tick)
   (let $ticks (collapse (match &self (lru-tick $t) $t))
        (if (== $ticks ())
            (let $_ (add-atom &self (lru-tick 1)) 1) ; This branch is simple, can stay as let
            (let* (((cons $t $rest) $ticks)
                   ($nextT (+ $t 1))
                   ($_ (remove-atom &self (lru-tick $t)))
                   ($_ (add-atom &self (lru-tick $nextT))))
                  $nextT))))

;; Get cache capacity (default 128 if not initialized)
(= (lru-get-capacity)
   (let $caps (collapse (match &self (lru-capacity $c) $c))
        (if (== $caps ()) 128
            (let (cons $c $rest) $caps $c))))

;; Count current cache size
(= (lru-size)
   (List.length (collapse (match &self (lru-entry $k $v $t) $k))))

;; Evict the LRU entry if at capacity
(= (lru-maybe-evict)
   (let* (($size (lru-size))
          ($cap (lru-get-capacity)))
            (if (< $size $cap)
               True
               ;; Collect entries as (Tick Key) pairs for sorting
               (let $all (collapse (match &self (lru-entry $k $v $t) (cons $t $k)))
                  (if (== $all ()) 
                     True
                     ;; Use native msort to find the entry with the smallest tick
                     (let* (($sorted (msort $all))
                            ((cons (cons $_ $oldKey) $_) $sorted))
                           (match &self (lru-entry $oldKey $vs $ts)
                                  (remove-atom &self (lru-entry $oldKey $vs $ts)))))))))

;; Main cached mi-score using LRU policy
(= (cached-mi-score $table $indices)
   (let* (($sorted (msort $indices)) ;; Canonicalize key to handle permutations like (0 1) vs (1 0)
          ($hits (collapse (match &self (lru-entry $sorted $score $tick) (cons $score (cons $tick ())))))) 
            (if (== $hits ())
               ;; Cache MISS: compute, maybe evict oldest, insert new
                  (let* (($score (mi-score $table $sorted))
                        ($t (lru-next-tick))
                        ($_ (lru-maybe-evict))
                        ($_ (add-atom &self (lru-entry $sorted $score $t))))
                        $score)
               ;; Cache HIT: update timestamp to mark as recently used
               (let* (((cons (cons $score (cons $oldTick ())) $rest) $hits)
                     ($t (lru-next-tick))
                     ($_ (remove-atom &self (lru-entry $sorted $score $oldTick)))
                     ($a (add-atom &self (lru-entry $sorted $score $t))))
                     $score))))
   
(= (incremental-step $features $table $threshold $redThreshold $maxInteraction $i $currentRes $currentTf)
   (if (> $i $maxInteraction)
       $currentRes
       (let* (($rel (get-rel $table $currentTf $i $threshold))
              ($red (if (> $redThreshold 0.0)
                        (get-red $table $rel $i (* $threshold $redThreshold))
                        ()))
              ($newRes (unique-atom (union-atom $currentRes (subtraction-atom $rel $red))))
              ($newTf (subtraction-atom $currentTf $rel)))
             (incremental-step $features $table $threshold $redThreshold $maxInteraction (+ $i 1) $newRes $newTf))))

;; Unscored internal helper — runs the core algorithm, returns only the feature list.
;; Used by both simple and adaptive paths to avoid redundant mi-score calls.
(= (raw-incremental-selection $table $threshold $redThreshold $maxInteraction)
   (let $features (range 0 (get-target-col $table))
        (incremental-step $features $table $threshold $redThreshold $maxInteraction 1 () $features)))

;; Scored wrapper: runs raw selection then scores exactly once.
(= (simple-incremental-selection $table $threshold $redThreshold $maxInteraction)
   (let $fs (raw-incremental-selection $table $threshold $redThreshold $maxInteraction)
       (cons (cons (cached-mi-score $table $fs) (cons $fs ())) ())))

;; Adaptive binary search: calls raw selection at each step (no mi-score until convergence).
(= (adaptive-incremental-selection $table $featuresSizeTarget $redThreshold $maxInteraction $min $max $epsilon)
   (let* (($mean  (/ (+ $min $max) 2.0))
          ($res   (raw-incremental-selection $table $mean $redThreshold $maxInteraction))
          ($rsize (List.length $res)))
         (if (or (== $rsize $featuresSizeTarget) (<= (- $max $min) $epsilon))
             (cons (cons (cached-mi-score $table $res) (cons $res ())) ())  ;; score exactly once on convergence
             (let* (($nmin (if (< $rsize $featuresSizeTarget) $min $mean))
                    ($nmax (if (< $rsize $featuresSizeTarget) $mean $max)))
                   (adaptive-incremental-selection $table $featuresSizeTarget $redThreshold $maxInteraction $nmin $nmax $epsilon)))))

(= (incremental-feature-selection $table $threshold $targetSize $redThreshold $maxInteraction $epsilon)
   (if (and (<= $threshold 0.0) (<= $targetSize 0))
       (let $allFeatures (range 0 (get-target-col $table))
            (cons (cons (cached-mi-score $table $allFeatures) (cons $allFeatures ())) ()))
       (if (> $targetSize 0)
           ;; Use adaptive (binary search for target size) 
           (adaptive-incremental-selection $table $targetSize $redThreshold $maxInteraction 0.0 1.0 $epsilon)
           ;; Use plain incremental (threshold-based) 
           (simple-incremental-selection $table $threshold $redThreshold $maxInteraction))))
