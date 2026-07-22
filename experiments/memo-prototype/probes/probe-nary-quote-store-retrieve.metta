;; ---------------------------------------------------------------------------
;; Probe: does storing `(candidate $i (quote $formula))` into a space via
;; add-atom, then retrieving it with `(match ... (candidate $i (quote $e)) $e)`,
;; keep $e as INERT unfired data when AND/OR/NOT ARE live heads in this same
;; file (the variant-P condition) -- and does merely passing that $e onward
;; through let-destructure / car-atom / a consumer function call ALSO stay
;; inert (i.e. is the quote-then-match idiom the item-4 spec proposes safe)?
;;
;; Distinguishing marker: AND's clause below returns a tagged FIRED atom
;; instead of doing real boolean work, so any premature firing is loud and
;; unambiguous in the printed output.
;; ---------------------------------------------------------------------------

(= (AND $args) (PROBE_AND_FIRED $args))
(= (OR $args) (PROBE_OR_FIRED $args))
(= (NOT ($x)) (PROBE_NOT_FIRED $x))

!(bind! &probeSpace (new-space))
!(add-atom &probeSpace (candidate 1 (quote (AND (A B)))))
!(add-atom &probeSpace (streamLength 1))

;; --- Step 1: does merely loading/storing the quoted literal fire AND? ------
;; If it fired at load time, this print would show PROBE_AND_FIRED baked
;; into whatever got stored; we inspect the raw space contents directly.
!(println! (STEP1_RAW_SPACE_CONTENTS (collapse (match &probeSpace (candidate $i $rest) (candidate $i $rest)))))

;; --- Step 2: retrieval via quote-destructuring match -----------------------
!(println! (STEP2_MATCH_QUOTE_PATTERN (collapse (match &probeSpace (candidate $i (quote $e)) $e))))

;; --- Step 3: retrieval via plain (unquoted) match pattern, for comparison --
!(println! (STEP3_MATCH_PLAIN_PATTERN (collapse (match &probeSpace (candidate $i $e) $e))))

;; --- Step 4: consume the destructured var through let-based structural ----
;; access (mirrors rewriteTree's own `(let ($op $children) $exp ...)`),
;; WITHOUT ever literally writing (AND ...) as source text at the consumption
;; site -- this is the exact shape rewriteTreeNary's body uses.
(= (probeConsume $exp)
   (if (== (get-metatype $exp) Grounded)
       (STRUCT_GROUNDED $exp)
       (if (== (get-metatype $exp) Symbol)
           (STRUCT_LEAF $exp)
           (let ($op $children) $exp
             (STRUCT_NODE $op $children)))))

!(let $e (car-atom (collapse (match &probeSpace (candidate $i (quote $e)) $e)))
   (println! (STEP4_CONSUME_VIA_LET (probeConsume $e))))

;; --- Step 5: pass the destructured var as a direct function ARGUMENT into
;; a consumer (mirrors `(rewriteTreeNaryCached $e)` in the real driver) ------
!(let $e (car-atom (collapse (match &probeSpace (candidate $i (quote $e)) $e)))
   (println! (STEP5_CONSUME_VIA_ARG (probeConsume $e))))

;; --- Step 6: does the whole-file prescan interact with quote as expected --
;; oracle from probe-zip-quote-unfired.metta's verified convention: literal
;; quote at a call site stays inert even with AND live in this same file.
!(println! (STEP6_LITERAL_QUOTE_SITE (quote (AND (A B)))))
