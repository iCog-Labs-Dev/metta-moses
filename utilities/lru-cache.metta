;; LRU CACHE IMPLEMENTATION (single cacheEntry with counter)
;; A Least Recently Used (LRU) cache implementation in MeTTa that automatically
;; evicts the least recently accessed items when the cache reaches capacity.

;; Space to store cache entries
!(bind! &cache (new-space))
; (: &cache hyperon::space::DynSpace)

;; State variables for cache management
!(bind! cacheSize (new-state 0))         ;; Current number of cached items
!(bind! maxCacheSize (new-state 10))     ;; Maximum cache capacity
!(bind! accessCounter (new-state 0))     ;; sequential counter for ordering

!(bind! DEFAULT_CACHE_SIZE 60)

;; Function: cacheExists
;; Purpose: Check if a function call with given arguments exists in cache
(: cacheExists (-> Symbol Any Bool))
(= (cacheExists $functionName $argument)
    (let* 
        (
            ($queryResult (collapse (match &cache (cacheEntry $functionName $argument $result $counter) $result)))
        )
        (not (== $queryResult ()))
    )
)

;; Function: counter  
;; Purpose: Generate next sequential number for cache ordering
(: counter (-> Number))
(= (counter)
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
(: getCached (-> Symbol Any Any))
(= (getCached $functionName $argument)
    (let* 
        (
            ;; Retrieve cached result and its counter from the single cacheEntry
            ($retrievedCache (collapse (match &cache (cacheEntry $functionName $argument $result $counter) ($result $counter))))
        )
        (if (== $retrievedCache ())
            (Error $functionName "Not Found")
            (let* 
                (
                    ((($cachedResult $oldCounter)) $retrievedCache)
                    ($newCounter (counter))
                    ;; Remove old cache entry
                    (() (remove-atom &cache (cacheEntry $functionName $argument $cachedResult $oldCounter)))
                    ;; Add updated cache entry with new counter
                    (() (add-atom &cache (cacheEntry $functionName $argument $cachedResult $newCounter)))
                )
                $cachedResult
            )
        )
    )
)

;; Function: byLastAtom
;; Purpose: Comparison function for sorting cacheEntry atoms by counter (ascending)
(: byLastAtom (-> Expression Expression Bool))
(= (byLastAtom $x $y) 
    (let* (
        ($xlastEl (- (size-atom $x) 1))
        ($ylastEl (- (size-atom $y) 1))
        ($xLast (index-atom $x $xlastEl))
        ($yLast (index-atom $y $ylastEl))
        )
      (< $xLast $yLast)
    )
)

;; Function: removeLeastRecentlyUsed
;; Purpose: Evict the least recently used cache entry to make room for new entry
(: removeLeastRecentlyUsed (-> Symbol Any Any Any))
(= (removeLeastRecentlyUsed $funcs $arguments $results) 
    (let* 
        (
            ;; Get all cacheEntry atoms (each includes its counter at the last position)
            ($allCacheEntries (collapse (match &cache (cacheEntry $fn $args $res $counter) (cacheEntry $fn $args $res $counter))))
        )
        
        (if (== $allCacheEntries ())
            (Error $funcs "Cache Empty")
            (let*
                (
                    ;; Sort by counter to find least recently used (oldest)
                    ($sortedEntries (selectionSort $allCacheEntries (size-atom $allCacheEntries) byLastAtom))
                    ;; Extract least recently used entry details
                    ((cacheEntry $functionName $args $result $entryCounter) (index-atom $sortedEntries 0))
                    ;; Remove the least recently used cacheEntry
                    (() (remove-atom &cache (cacheEntry $functionName $args $result $entryCounter)))
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
(: cachePut (-> Symbol Any Any Any))
(= (cachePut $functionName $argument $result)
    (let* 
        (
            ($entryCounter (counter))
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
                    (() (add-atom &cache (cacheEntry $functionName $argument $result $entryCounter)))
                    ;; Update cache size
                    ($updatedCache (change-state! cacheSize (+ $currentSize 1)))
                )  
                $result
            )
        )
    )
)

;; Function: lruCache
;; Purpose: Main LRU cache interface - checks cache first, computes if needed
(: lruCache (-> Number Expression Any))
(= (lruCache $maxSize $functionCall) 
    (let* 
        (
            ;; Set cache size for this operation
            ($setup (change-state! maxCacheSize $maxSize))
            ;; Parse function call structure
            (($funcExpr $argExpr) (decons-atom $functionCall))
            ($functionName (car-atom $funcExpr))
            ($argument (car-atom $argExpr))
        )
        ;; Check cache first
        (if (cacheExists $functionName $argument)
            (getCached $functionName $argument)
            ;; Cache miss - compute and cache result
            (let* 
                (
                    ;; Execute the function call
                    ($computedResult (eval (cons-atom $functionName $argument)))
                    ;; Cache the result
                    ($cachedResult (cachePut $functionName $argument $computedResult))
                )
                $cachedResult
            )
        )
    )
)
