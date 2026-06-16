;; ============================================================
;;  Command-line override parsing.
;;
;;  Reads command-line arguments of the form --name=value via
;;  PeTTa's argv/2 builtin and applies each as (set-param ...).
;;  Non-matching arguments (script name, -s, etc.) are ignored.
;;
;;  Usage:
;;    sh run.sh script.metta -s --capCoef=100 --maxDist=6
;;
;;  Invocation:
;;    The driver script should call !(apply-cli-overrides) once,
;;    after defaults.metta has loaded.
;; ============================================================

;; -------- Top-level entry --------
(= (apply-cli-overrides)
   (cli-loop 0))

;; Walk argv until we run out of indices.
;; (argv N) fails for out-of-bounds indices; we wrap it in collapse
;; so that the failing call gives () (empty list) rather than aborting.
(= (cli-loop $n)
   (let $maybe (collapse (argv $n))
        (if (== $maybe ())
            done
            (let* (
                   ($_  (try-apply-flag (car-atom $maybe)))
                   ($__ (cli-loop (+ $n 1)))
                  )
                  done))))

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
                         ($_                ignored)
                       ))))
      )))

;; -------- Help output --------
;; Iterates every entry in &params and prints it as `(-- name = value)`.
;; After printing, terminates the process via Prolog's halt(0) so that
;; --help short-circuits the rest of the script (no MOSES run is started).
(= (print-help-and-exit)
   (let* (
          ($_   (println! ""))
          ($__  (println! "MOSES MeTTa hyperparameters (override with --name=value):"))
          ($___ (println! ""))
          ;; collapse so the match's println! side effects fire for every
          ;; atom; the resulting list of `true`s is discarded.
          ($____ (collapse (match &params ($name $val)
                             (println! (-- $name = $val)))))
          ($_____ (println! ""))
          ;; halt(0) is a Prolog builtin; build the goal via Predicate and
          ;; invoke it through callPredicate to terminate the process.
          ($______ (callPredicate (Predicate (halt 0))))
         )
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
        ($_                      not-a-flag)
      )))

;; Walk chars after '--' accumulating the name atom until '='.
;; $nameAcc is None initially, then (Some <accumulated atom>).
(= (parse-name () $nameAcc) not-a-flag)
(= (parse-name (cons $h $rest) None)
   (if (== $h =)
       not-a-flag                              ;; empty name '--='
       (parse-name $rest (Some $h))))
(= (parse-name (cons $h $rest) (Some $acc))
   (if (== $h =)
       (parse-value $rest None $acc)
       (parse-name $rest (Some (atom_concat $acc $h)))))

;; Walk chars after '=' accumulating the value atom, then parse it.
;; parse/1 coerces strings like "100", "3.5", "True" into the
;; corresponding Number / Bool atoms; bare atoms come back unchanged.
(= (parse-value () None $name) not-a-flag)        ;; '--name='
(= (parse-value () (Some $acc) $name)
   (flag $name (parse $acc)))
(= (parse-value (cons $h $rest) None $name)
   (parse-value $rest (Some $h) $name))
(= (parse-value (cons $h $rest) (Some $acc) $name)
   (parse-value $rest (Some (atom_concat $acc $h)) $name))
