;; ---------------------------------------------------------------------------
;; Shared combine/leaf-extraction logic for both scoring kernels (variant M:
;; kernel-memo.metta / lib_memo; variant S: kernel-space.metta / hand-rolled
;; space cache). Both kernels import this file so the two variants differ
;; ONLY in cache mechanism, never in what gets computed.
;;
;; NOTE: AND/OR/NOT are used here purely as data symbols compared with `==`
;; -- they are never defined as functions/clauses anywhere in this prototype
;; (per the verified PR-165 probe: undefined heads compile as inert data,
;; which keeps wrapped node expressions like (AND (x (OR (y z)))) usable
;; UNQUOTED as memoize cache keys).
;; ---------------------------------------------------------------------------

;; --- Per-row boolean ops (True/False are Grounded booleans from the table) ---
(= (and2 $a $b) (if (and (== $a True) (== $b True)) True False))
(= (or2  $a $b) (if (or  (== $a True) (== $b True)) True False))
(= (colNot $col) (map-atom $col $b (if (== $b True) False True)))

;; --- Column-level zip folds used to combine child columns ---
(= (colZipAnd $childCol $acc) (List.zipWith and2 $childCol $acc))
(= (colZipOr  $childCol $acc) (List.zipWith or2  $childCol $acc))

;; combineOp: op symbol x list-of-child-columns x row count -> column.
;; AND folds zipWith and2 over children seeded with an all-True column ($n
;; long); OR seeds all-False; NOT takes its single child column. Folding an
;; empty child-column list over the seed naturally reproduces the identity
;; column (List.foldl over () returns the seed unchanged), matching
;; production semantics: (AND ()) -> all-True, (OR ()) -> all-False.
(= (combineOp $op $childCols $n)
   (if (== $op AND)
       (List.foldl colZipAnd (List.repeat $n True) $childCols)
       (if (== $op OR)
           (List.foldl colZipOr (List.repeat $n False) $childCols)
           (if (== $op NOT)
               (colNot (car-atom $childCols))
               (Error $op "combineOp: unknown operator")))))

;; varColumn: extract a label's column from the row-major table. Unknown
;; label -> loud Error (malformed input); index-atom skips a per-cell
;; re-scan. Port of scoring/fitness.metta:131-135.
(= (varColumn (mkITable $rows $labels) $label)
   (let $idx (List.index $labels $label)
        (if (== $idx -1)
            (Error $label "varColumn: label not found in table")
            (map-atom $rows $r (index-atom $r $idx)))))
