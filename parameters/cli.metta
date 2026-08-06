;; ============================================================
;; Command-line parameter override parsing.
;;
;; Reads command-line arguments of the form --name=value via
;; PeTTa's argv/2 builtin and applies recognized overrides through
;; (set-param ...).
;;
;; CLI arguments are optional: when no override is supplied, the
;; existing values from parameters/defaults.metta remain unchanged.
;;
;; Non-parameter arguments (script name, -s, etc.) are ignored.
;;
;; Usage:
;;   sh run.sh script.metta -s --capCoef=100 --maxDist=6
;;
;; Invocation:
;;   The driver script should call !(apply-cli-overrides) once,
;;   after defaults.metta has loaded.
;; ============================================================

;; -------- Top-level entry --------
;;
;; argv/2 is queried with an unbound index, allowing it to backtrack
;; over all command-line arguments. collapse collects those arguments
;; into a list.
;;
;; Each argument is then passed to try-apply-flag. Arguments that are
;; not recognized as CLI parameter overrides are ignored.
(= (apply-cli-overrides)
   (let* (
          ($args (collapse (argv $_)))
          ($_ (map-atom $args $arg (try-apply-flag $arg)))
         )
        ()))

;; -------- Flag dispatch --------

;; Tries to interpret $arg as --name=value; applies the override if so.
;; Recognizes --help / -h and prints all registered parameters before
;; halting the process. Anything else is silently ignored so unrelated
;; argv entries (the script path, the -s flag, etc.) don't cause errors.
(= (try-apply-flag $arg)
   (case $arg
      (
        (--help (print-help-and-exit))
        (-h     (print-help-and-exit))
        ($_     (let $chars (atom_chars $arg)
                     (case (parse-flag $chars)
                       (
                         ((flag $name $val) (set-param $name $val))
                         ($_                ignored))))))))

;; -------- Help output --------
;; Iterates every entry in &params and prints it as `(-- name = value)`.
;; After printing, terminates the process via Prolog's halt(0) so that
;; --help short-circuits the rest of the script (no MOSES run is started).
(= (print-help-and-exit)
   (let* (
          ($_ (println! ""))
          ($_ (println! "MOSES MeTTa hyperparameters (override with --name=value):"))
          ($_ (println! ""))
          ;; collapse so the match's println! side effects fire for every
          ;; atom; the resulting list of `true`s is discarded.
          ($__ (collapse (match &params ($name $val)
                             (println! (-- $name = $val)))))
          ($_ (println! ""))
          ;; halt(0) is a Prolog builtin; build the goal via Predicate and
          ;; invoke it through callPredicate to terminate the process.
          ($___ (callPredicate (Predicate (halt 0)))))
         done))

;; -------- Char-list parser --------
;; PeTTa exposes no string-split primitive, so we walk the character
;; list returned by atom_chars/2 by hand.
;;
;; parse-flag returns either:
;;     (flag NameAtom Value)   -- well-formed override
;;     not-a-flag              -- anything else
;;
;; Implemented as a single equation with case dispatch so that the
;; happy-path pattern and the catch-all are mutually exclusive (avoids
;; the Prolog backtracking-into-fallback-clause hazard).
(= (parse-flag $chars)
   (case $chars
      (
        ((cons - (cons - $rest)) (parse-name $rest None))
        ($_                      ()))))

;; Walk chars after '--' accumulating the name atom until '='.
;; $nameAcc is None initially, then (Some <accumulated atom>).
(= (parse-name () $nameAcc) ())
(= (parse-name (cons $h $rest) None)
   (if (== $h =)
       ()                              ;; empty name '--='
       (parse-name $rest (Some $h))))
(= (parse-name (cons $h $rest) (Some $acc))
   (if (== $h =)
       (parse-value $rest None $acc)
       (parse-name $rest (Some (atom_concat $acc $h)))))

;; -------- Value parser --------
;;
;; Walk chars after '=' accumulating the value atom.
;;
;; Scalar values preserve the existing behaviour:
;;
;;   100        -> 100
;;   3.5        -> 3.5
;;   True       -> True
;;   hc         -> hc
;;
;; Comma-separated values are interpreted as a tuple:
;;
;;   a,b,c      -> (a b c)
;;
;; The tuple is quoted because action/perception primitives are live
;; symbols. This preserves the same representation produced by:
;;
;;   !(set-param actions
;;       (quote (tttWin tttBlock tttCenter)))
;;
;; Empty values remain invalid, preserving the previous behaviour.
(= (parse-value () None $name) ())        ;; '--name='

(= (parse-value () (Some $acc) $name)
   (parse-value-atom $acc $name))

(= (parse-value (cons $h $rest) None $name)
   (parse-value $rest (Some $h) $name))

(= (parse-value (cons $h $rest) (Some $acc) $name)
   (parse-value $rest (Some (atom_concat $acc $h)) $name))


;; -------- Parsed value dispatch --------
;;
;; Decide whether the accumulated value is a scalar or a
;; comma-separated tuple.
;;
;; Scalar values are parsed normally:
;;
;;   --capCoef=100          -> 100
;;   --complexityRatio=3.5  -> 3.5
;;   --fitness=foo          -> foo
;;
;; Comma-separated values are converted into a tuple:
;;
;;   --actions=tttWin,tttBlock,tttCenter
;;       -> (tttWin tttBlock tttCenter)
;;
;; The resulting tuple is quoted so that action/perception symbols
;; are stored as data rather than evaluated as an expression.
;;
;; This produces the same parameter representation as:
;;
;;   !(set-param actions
;;       (quote (tttWin tttBlock tttCenter)))
(= (parse-value-atom $acc $name)
   (let $chars (atom_chars $acc)
        (case (contains-comma $chars)
           (
             (True
                (let $items (parse-comma-list $chars)
                     (flag $name (quote $items))))
             (False
                (flag $name (parse $acc)))))))


;; Check whether a character list contains a comma.
(= (contains-comma ()) False)
(= (contains-comma (cons $h $rest))
   (if (== $h ,)
       True
       (contains-comma $rest)))


;; -------- Comma-separated list parser --------
;;
;; Converts:
;;
;;   tttWin,tttBlock,tttCenter
;;
;; into:
;;
;;   (tttWin tttBlock tttCenter)
;;
;; Each element is independently passed through parse/1 so that
;; normal atom/number/bool conversion is preserved for list values.
;;
;; $current is the current element being accumulated.
;; $acc contains already-parsed elements in reverse order.
(= (parse-comma-list $chars)
   (parse-comma-list $chars None ()))


;; End of input: parse the final element and reverse the accumulated
;; elements so the original CLI ordering is preserved.
(= (parse-comma-list () None $acc)
   (reverse $acc))

(= (parse-comma-list () (Some $current) $acc)
   (reverse (cons-atom (parse $current) $acc)))

;; Comma terminates the current element.
(= (parse-comma-list (cons $h $rest) None $acc)
   (if (== $h ,)
       ()
       (parse-comma-list
          $rest
          (Some $h)
          $acc)))

(= (parse-comma-list (cons $h $rest) (Some $current) $acc)
   (if (== $h ,)
       (parse-comma-list
          $rest
          None
          (cons-atom (parse $current) $acc))
       (parse-comma-list
          $rest
          (Some (atom_concat $current $h))
          $acc)))