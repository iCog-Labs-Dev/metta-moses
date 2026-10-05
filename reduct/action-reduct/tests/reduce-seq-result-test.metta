!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../reduce-seq-result)

;; ============================================================================
;; reduceSeqAndAlwaysFails: truncate and_seq after first statically-False child
;; ============================================================================

;; Existing test: no statically-False child → no truncation
!(assertEqual
  (reduceSeqAndAlwaysFails (and_seq A move_forward action_failure B))
  (and_seq A move_forward action_failure))

;; Non-and_seq operator → passthrough unchanged
!(assertEqual
  (reduceSeqAndAlwaysFails (exec_seq A action_failure B))
  (exec_seq A action_failure B))

;; Empty and_seq → passthrough
!(assertEqual
  (reduceSeqAndAlwaysFails (and_seq))
  (and_seq))

;; ============================================================================
;; reduceSeqOrAlwaysSucceeds: truncate or_seq after first statically-True child
;; ============================================================================

;; Existing test: no statically-True child → no truncation
!(assertEqual
  (reduceSeqOrAlwaysSucceeds (or_seq A move_forward B))
  (or_seq A move_forward B))

;; Truncation at turn_left (alwaysSucceeds → True)
!(assertEqual
  (reduceSeqOrAlwaysSucceeds (or_seq A turn_left B))
  (or_seq A turn_left))

;; Truncation at action_success (getActionResult → True)
!(assertEqual
  (reduceSeqOrAlwaysSucceeds (or_seq A action_success B))
  (or_seq A action_success))

;; Non-or_seq operator → passthrough unchanged
!(assertEqual
  (reduceSeqOrAlwaysSucceeds (and_seq A action_success B))
  (and_seq A action_success B))

;; Empty or_seq → passthrough
!(assertEqual
  (reduceSeqOrAlwaysSucceeds (or_seq))
  (or_seq))
