;; LRU CACHE IMPLEMENTATION
;; A Least Recently Used (LRU) cache implementation in MeTTa that automatically
;; evicts the least recently accessed items when the cache reaches capacity.


;; Space to store cache entries and access times
!(bind! &cache (new-space))
; (: &cache hyperon::space::DynSpace) ;; this is how you define types for space

;; State variables for cache management
!(bind! cacheSize (new-state 0))         ;; Current number of cached items
!(bind! maxCacheSize (new-state 10))     ;; Maximum cache capacity
!(bind! accessCounter (new-state 0))     ;; counter for timestamps
; (: cacheSize StateMonad) ;; this is how you define types for states 

!(bind! DEFAULT_CACHE_SIZE 60)

;; Function: cacheExists
;; Purpose: Check if a function call with given arguments exists in cache
(: cacheExists (-> Symbol Any Bool))
(= (cacheExists $functionName $argument)
    (let* 
        (
            ; (() (println! (DEBUG Inside cacheExists $functionName $argument)))
            ($queryResult (collapse (match &cache (cacheEntry $functionName $argument $result $timestamp) $result)))
            ; (() (println! (DEBUG query Result: $queryResult)))
        )
        (not (== $queryResult ()))
    )
)

;; Function: nextTimestamp  
;; Purpose: Generate next sequential timestamp for cache ordering
(: nextTimestamp (-> Number))
(= (nextTimestamp)
   (let* 
       (
           ($currentCounter (get-state accessCounter))
        ;    (() (println! (DEBUG function currentCounter: $currentCounter (get-state accessCounter))))
           ($nextCounter (+ $currentCounter 1))
           ($updatedState (change-state! accessCounter $nextCounter))
        ;    (() (println! (DEBUG updated state $updatedState)))
       )
       $nextCounter
    )
)

;; Function: getCached
;; Purpose: Retrieve cached result and update its access time (move to front)
(: getCached (-> Symbol Any Any))
(= (getCached $functionName $argument)
    (let* 
        (
            ;; Retrieve cached result and its timestamp
            ($retrievedCache (collapse (match &cache (cacheEntry $functionName $argument $result $timestamp) ($result $timestamp))))
            ; (() (println! (DEBUG $argument cached Result: $retrievedCache)))
        )
        (if (== $retrievedCache ())
            (Error $functionName "Not Found")
            (let* 
                (
                    ((($cachedResult $oldTimeStamp)) $retrievedCache)
                    ($newTimeStamp (nextTimestamp))
                    ; (() (println! (DEBUG New Time Stamp: $newTimeStamp)))
                    ;; Remove old cache entries
                    (() (remove-atom &cache (cacheEntry $functionName $argument $cachedResult $oldTimeStamp)))
                    (() (remove-atom &cache (accessTime $functionName $argument $oldTimeStamp)))
                    ;; Add updated entries with new timestamp
                    (() (add-atom &cache (cacheEntry $functionName $argument $cachedResult $newTimeStamp)))
                    (() (add-atom &cache (accessTime $functionName $argument $newTimeStamp)))
                )
                $cachedResult
            )
        )
    )
)

;; Function: byLastAtom
;; Purpose: Comparison function for sorting access times (ascending order)
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
            ;; Get all access time entries
            ($allAccessTimes (collapse (match &cache (accessTime $fn $args $timestamp) (accessEntry $fn $args $timestamp))))
        )
        (if (== $allAccessTimes ())
            (Error "Cache Empty")
            (let*
                (
                    ; (() (println! (DEBUG all access Times: $allAccessTimes)))
                    ;; Sort by timestamp to find least recently used
                    ($sortedAccess (selectionSort $allAccessTimes (size-atom $allAccessTimes) byLastAtom))
                    ; (() (println! (DEBUG all Sorted Access: $sortedAccess)))
                    ;; Extract least recently used entry details
                    ((accessEntry $functionName $args $timeStamp) (index-atom $sortedAccess 0))
                    ;; Get the cached result for removal
                    ($result (match &cache (cacheEntry $functionName $args $answer $timeStamp) $answer))
                    ;; Remove both cache entry and access time entry
                    (() (remove-atom &cache (cacheEntry $functionName $args $result $timeStamp)))
                    (() (remove-atom &cache (accessTime $functionName $args $timeStamp)))
                    ;; Update cache size
                    ($updatedState (change-state! cacheSize (- (get-state cacheSize) 1)))
                    ; (() (println! (DEBUG all Updated state in remove LRU $updatedState)))
                )
                ;; Add the new entry
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
            ($timestamp (nextTimestamp))
            ; (() (println! (DEBUG function timestamp: $timestamp)))
            ($currentSize (get-state cacheSize))
            ($maxSize (get-state maxCacheSize))
            ; (() (println! (DEBUG function current size: $currentSize maxSize $maxSize $functionName $argument $result)))
        )
        (if (>= $currentSize $maxSize)
            ;; Cache is full, evict least recently used
            (removeLeastRecentlyUsed $functionName $argument $result)
            ;; Cache has space, add directly
            (let* 
                (
                    ;; Add cache entry and access time
                    (() (add-atom &cache (cacheEntry $functionName $argument $result $timestamp)))
                    (() (add-atom &cache (accessTime $functionName $argument $timestamp)))
                    ;; Update cache size
                    ($updatedCache (change-state! cacheSize (+ $currentSize 1)))
                    ; (() (println! (DEBUG Updated $updatedCache)))
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
            ; (() (println! (DEBUG changed max size: $setup)))
            ;; Parse function call structure
            (($funcExpr $argExpr) (decons-atom $functionCall))
            ($functionName (car-atom $funcExpr))
            ($argument (car-atom $argExpr))
            ; (() (println! (DEBUG function with argument: $functionName $argument)))
        )
        ;; Check cache first
        (if (cacheExists $functionName $argument)
            (getCached $functionName $argument)
            ;; Cache miss - compute and cache result
            (let* 
                (
                    ; (() (println! (DEBUG Inside Computation ($functionName $argument))))
                    ;; Execute the function call
                    ($computedResult (eval (cons-atom $functionName $argument)))
                    ; (() (println! (DEBUG Computed result: $computedResult $functionName $argument)))
                    ;; Cache the result
                    ($cachedResult (cachePut $functionName $argument $computedResult))
                )
                $cachedResult
            )
        )
    )
)
