!(import! &self (library lib_memo))

!(change-state! &probeState 1)

!(memoize readerFn 1)
(= (readerFn $x) (+ $x (get-state &probeState)))

!(clear-memoize)
!(clear-memoize-stats)

!(println! (readerFn 10))
!(change-state! &probeState 99)
!(println! (readerFn 10))
!(clear-memoize)
!(println! (readerFn 10))
!(println! (get-memoize-stats))
