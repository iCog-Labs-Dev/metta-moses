!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-vocab)
!(import! &self ../action-helpers)
!(import! &self ../reduce-const-action-seq)

;; ============================================================================
;; reduceEmptyArgSeq: empty sequences reduce to their identity constant
;; (Rule 4 base)
;; ============================================================================

!(assertEqual (reduceEmptyArgSeq (and_seq)) action_success)
!(assertEqual (reduceEmptyArgSeq (or_seq)) action_failure)
!(assertEqual (reduceEmptyArgSeq (exec_seq)) action_success)

;; ============================================================================
;; reduceConstActionSeq: prune statically-constant children from sequences
;; (Rule 4 & 5)
;; ============================================================================

;; and_seq collapses to action_failure when only failure remains
!(assertEqual (reduceConstActionSeq (and_seq action_failure)) action_failure)

;; or_seq collapses to action_success when only success remains
!(assertEqual (reduceConstActionSeq (or_seq action_success)) action_success)

;; and_seq: drop action_success, truncate at action_failure
!(assertEqual (reduceConstActionSeq (and_seq A action_success B)) (and_seq A B))
!(assertEqual (reduceConstActionSeq (and_seq A action_failure B)) (and_seq A action_failure))

;; or_seq: drop action_failure, truncate at action_success
!(assertEqual (reduceConstActionSeq (or_seq A action_success B)) (or_seq A action_success))
!(assertEqual (reduceConstActionSeq (or_seq A action_failure B)) (or_seq A B))

;; exec_seq: drop both constants
!(assertEqual (reduceConstActionSeq (exec_seq A action_success B action_failure)) (exec_seq A B))
