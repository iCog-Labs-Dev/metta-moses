;; Probe: isolates evaluator-common.metta's `transposeCols` behavior on a
;; ZERO-column input (`(transposeCols ())`), the exact shape a nullary
;; zipWithN node (`(zipWithN AND ())`) would feed it. Finding: this FAILS
;; outright (zero solutions, no exception) against the unmodified (DO NOT
;; MODIFY) evaluator-common.metta -- `car-atom` on an empty expression has
;; no matching clause, so the base-case guard `(if (== (car-atom $cols) ())
;; ...)` never succeeds when $cols is itself the empty list (zero columns),
;; as opposed to transposeCols's assumed case of one-or-more non-empty
;; equal-length columns. See zipform/rewriter-nary.metta's header for the
;; consequence (a genuine nullary AND/OR formula cannot be scored by the
;; nary rewriter + the shared evaluator) and the grep confirming none of
;; the four capture logs ever produce one.
!(bind! &params (new-space))
!(import! &self ../../../parameters/registry)
!(import! &self ../common/list-helpers)
!(import! &self ../common/kernel-common)
!(import! &self ../zipform/evaluator-common)

!(println! (BEFORE))
!(println! (TC_EMPTY (transposeCols ())))
!(println! (AFTER))
;; Expected observed behavior: BEFORE and AFTER both print; TC_EMPTY prints
;; NOTHING (transposeCols(()) fails silently, zero solutions).
