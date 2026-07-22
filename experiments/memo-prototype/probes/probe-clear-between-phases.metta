!(import! &self (library lib_memo))

!(change-state! &phaseState 1)

!(memoize phaseFn 1)
(= (phaseFn $x) (+ $x (get-state &phaseState)))

!(clear-memoize)
!(clear-memoize-stats)

; Phase 1: populate the cache.
!(println! (phaseFn 10))
!(println! (phaseFn 10))
!(println! (get-memoize-stats))

; Phase 2: mutate the backing state AND clear the memo cache.
!(change-state! &phaseState 500)
!(clear-memoize)
!(clear-memoize-stats)

; If clear-memoize fully reset (no stale replay), this must recompute
; with the NEW state value (510), not replay the old cached 11.
!(println! (phaseFn 10))
!(println! (get-memoize-stats))
