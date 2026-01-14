;; LRU CACHE IMPLEMENTATION 
;; A Least Recently Used (LRU) cache implementation in MeTTa that automatically
;; evicts the least recently accessed items when the cache reaches capacity.

;; Space to store cache entries
!(bind! &cache (new-space))
; (: &cache hyperon::space::DynSpace)

;; State variables for cache management
!(bind! cacheSize (new-state 0))         ;; Current number of cached items
!(bind! maxCacheSize (new-state 10))     ;; Maximum cache capacity
!(bind! accessCounter (new-state 0))     ;; sequential counter for ordering

(= (DEFAULT_CACHE_SIZE) 60)

;; Function: cacheExists
;; Purpose: Check if a function call with given arguments exists in cache
; (: cacheExists (-> Symbol $a Bool))
(= (cacheExists $fn-name $args)
    (let $queryResult (collapse (match &cache (cacheEntry $fn-name $args $result $counter) $result))
        (not (== $queryResult ()))))

;; Function: accCounter  
;; Purpose: Generate next sequential number for cache ordering
; (: accCounter (-> Number))
(= (accCounter)
   (let* 
       (
           ($currentCounter (get-state accessCounter))
           ($nextCounter (+ $currentCounter 1))
           ($updatedState (change-state! accessCounter $nextCounter))
       )
       $nextCounter
    )
)

;; Function: getCached
;; Purpose: Retrieve cached result and update its access counter (move to front)
; (: getCached (-> Symbol $a $a))
(= (getCached $functionName $argument)
    (let $retrievedCache (collapse (match &cache (cacheEntry $functionName $argument $result $counter) ($result $counter)))       ;; Retrieve cached result and its counter from the single cacheEntry
        (if (= $retrievedCache ())
            (Error $functionName "Not Found")
            (let* 
                (
                    ((($cachedResult $oldCounter)) $retrievedCache)
                    ($newCounter (accCounter))
                    ;; update old cache entry with new access counter value
                    ($__ (update-atom &cache (cacheEntry $functionName $argument $cachedResult $oldCounter) (cacheEntry $functionName $argument $cachedResult $newCounter)))
                )
                $cachedResult
            ))))

;; Function: ltByLastAtom
;; Purpose: Comparison function for sorting cacheEntry atoms by counter (ascending) which is last element of function call cache space entries
;; it can aslo be used for general purpose less than comparsion using last element (has to be numeric) of two equal length expressions
(: ltByLastAtom (-> Expression Expression Bool))
(= (ltByLastAtom $x $y) 
    (let* (
        ($last-index (- (size-atom $x) 1))
        (($x-end $y-end) (map-atom ($x $y) $a (index-atom $a $last-index))))
        
        (< $x-end $y-end)))

;; Function: removeLeastRecentlyUsed
;; Purpose: Evict the least recently used cache entry to make room for new entry
; (: removeLeastRecentlyUsed (-> Symbol $a $a $a))
(= (removeLeastRecentlyUsed $funcs $arguments $results) 
    (let $allCacheEntries (collapse (match &cache (cacheEntry $fn $args $res $counter) (cacheEntry $fn $args $res $counter)))          ;; Get all cacheEntry atoms (each includes its counter at the last position)
        (if (== $allCacheEntries ())
            (Error $funcs "Cache Empty")
            (let*
                (
                    ;; Sort by counter to find least recently used (oldest)
                    ($sortedEntries (selectionSort $allCacheEntries (size-atom $allCacheEntries) ltByLastAtom))
                    ;; Extract least recently used entry details
                    ((cacheEntry $functionName $args $result $entryCounter) (index-atom $sortedEntries 0))
                    ;; Remove the least recently used cacheEntry
                    ($__ (remove-atom &cache (cacheEntry $functionName $args $result $entryCounter)))
                    ;; Update cache size
                    ($updatedState (change-state! cacheSize (- (get-state cacheSize) 1)))
                )
                ;; After eviction, add the new entry
                (cachePut $funcs $arguments $results)
            )
        )
    )
)

;; Function: cachePut
;; Purpose: Add a new entry to the cache, handling capacity limits
; (: cachePut (-> Symbol $a $a $a))
(= (cachePut $functionName $argument $result)
    (let* 
        (
            ($entryCounter (eval (accCounter))) 
            ($currentSize (get-state cacheSize))
            ($maxSize (get-state maxCacheSize))
        )
        (if (>= $currentSize $maxSize)
            ;; Cache is full, evict least recently used (which will call cachePut again to add)
            (removeLeastRecentlyUsed $functionName $argument $result)
            ;; Cache has space, add directly
            (let* 
                (
                    ;; Add cache entry (single atom holds result and counter)
                    ($__ (add-atom &cache (cacheEntry $functionName $argument $result $entryCounter)))
;                     ;; Update cache size
                    ($updatedCache (change-state! cacheSize (+ $currentSize 1)))
                )  
                $result
            )
        )
    )
)

;; Function: lruCache
;; Purpose: Main LRU cache interface - checks cache first, computes if needed
;;      $maxSize -- maximum size of the lru cache 
;;      (($fn-name) $args) -- the function call being cached in; as tuple ((function-name) (arguments)) 
;;      
(: lruCache (-> Number Expression $a))
(= (lruCache $maxSize (($fn-name) $args)) 
    (let $_ (change-state! maxCacheSize $maxSize)                         ;; Set cache size for this operation
        (if (eval (cacheExists $fn-name $args))                           ;; Check cache first
            (getCached $fn-name $args)                                    ;; Cache miss - compute and cache result
            (let $computedResult (eval (cons-atom $fn-name $args))        ;; Execute the function call
                (cachePut $fn-name $args (eval $computedResult))))))      ;; Cache the result