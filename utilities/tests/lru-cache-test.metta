; !(register-module! ../../../metta-moses)
!(import! &self ../../../metta-moses/utilities/general-helpers)
!(import! &self ../../../metta-moses/feature-selection/feature-selection-helpers)
!(import! &self ../../../metta-moses/utilities/list-methods)
!(import! &self ../../../metta-moses/utilities/lru-cache)

; (: factorial (-> Number Number))
(= (factorial $x)
   (if (> $x 0)
       (* $x (factorial (- $x 1)))
       1))

; (: multiply (-> Number Number Number Number))
(= (multiply $a $b $c) (* (* $a $b) $c))

; (: cachedFactorial (-> Number Number))
(= (cachedFactorial $n)
   (lruCache (DEFAULT_CACHE_SIZE) ((factorial) ($n))))

; (: cachedMultiply (-> Number Number Number Number))
(= (cachedMultiply $a $b $c)
   (lruCache 3 ((multiply) ($a $b $c))))

; (: cachedMutualInformation (-> Expression Expression Number))
(= (cachedMutualInformation $inputColumn $outputColumn)
    (lruCache 3 ((mutualInformation) ($inputColumn $outputColumn))))

;; ---- Factorial Tests ----
!(assertEqual (cachedFactorial 5) 120)       ;; first call (cache miss, compute and store)
!(assertEqual (cacheExists factorial (5)) True)
!(assertEqual (getCached factorial (5)) 120) ;; confirm value stored in cache
!(assertEqual (cachedFactorial 5) 120)       ;; second call (cache hit)
!(assertEqual (cachedFactorial 4) 24)
!(assertEqual (cachedFactorial 3) 6)

!(assertEqual (cacheExists factorial (3)) True)
!(assertEqual (getCached factorial (3)) 6)

;; ---- Multiply Tests ----
!(assertEqual (cachedMultiply 2 3 4) 24)     ;; compute and store
!(assertEqual (cacheExists multiply (2 3 4)) True)
!(assertEqual (getCached multiply (2 3 4)) 24)
!(assertEqual (cachedMultiply 2 3 4) 24)     ;; cache hit
!(assertEqual (cachedMultiply 1 2 3) 6)
!(assertEqual (cachedMultiply 5 2 1) 10)

!(assertEqual (cacheExists multiply (5 2 1)) True)
!(assertEqual (getCached multiply (5 2 1)) 10)

;; ---- Mutual Information Tests ----
!(assertEqual 
   (cachedMutualInformation 
      (Cons A (Cons B (Cons C Nil))) 
      (Cons X (Cons Y (Cons Z Nil)))) 
   1.585)

;; Multiple calls to ensure cache hits
!(assertEqual 
   (cachedMutualInformation 
      (Cons A (Cons B (Cons C Nil))) 
      (Cons X (Cons Y (Cons Z Nil)))) 
   1.585) ;; cache hit
!(assertEqual 
   (cachedMutualInformation 
      (Cons A (Cons B (Cons C Nil))) 
      (Cons X (Cons Y (Cons Z Nil)))) 
   1.585) ;; another cache hit

;; Verify number of cached elements across functions
!(assertEqual 
   (let $cachedElements (collapse (get-atoms &cache)) 
        (size-atom $cachedElements)) 
   3)

;; ---- Manual Cache Operations ----
!(assertEqual (cachePut computationallyExpensiveFunction (arg1 arg2) someResult) someResult)
!(assertEqual (cacheExists computationallyExpensiveFunction (arg1 arg2)) True)
!(assertEqual (getCached computationallyExpensiveFunction (arg1 arg2)) someResult)

;; Remove least recently used (LRU) entry
!(assertEqual (removeLeastRecentlyUsed factorial (12) 479001600) 479001600)

;; After LRU eviction, confirm that "multiply (1 2 3)" entry is removed
!(assertEqual (cacheExists multiply (1 2 3)) False)
!(assertEqual (getCached multiply (1 2 3)) (Error multiply "Not Found"))

;; But factorial(12) should still exist
!(assertEqual (getCached factorial (12)) 479001600)

;; Confirm cache size remains stable after eviction
!(assertEqual 
   (let $cachedElements (collapse (get-atoms &cache)) 
        (size-atom $cachedElements)) 
   3)


;; Cache overwrite test: same key, updated value
!(assertEqual (cachePut factorial (3) 999) 999)
!(assertEqual (getCached factorial (3)) 999) ;; overwritten