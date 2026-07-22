!(import! &self (library lib_memo))

!(memoize idfn 1)
(= (idfn $x) $x)

!(clear-memoize)
!(clear-memoize-stats)

!(println! (idfn (AND (x (OR (y z))))))
!(println! (idfn (AND (x (OR (y z))))))
!(println! (get-memoize-stats))
