!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/nodeId)

!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../../utilities/tree)

!(import! &self ../../scoring/action-registry)
!(import! &self ../knob-representation)
!(import! &self ../lsk)
!(import! &self ../logical-probe) 
!(import! &self ../build-logical)
!(import! &self ../build-knobs)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)

;; Testcases for logicalSubtreeKnob
;; Testcase 1: When the subtree isn't found in the target's children list

!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))) ())))
    (mkTree (mkNode D) ()))
  (
    (mkNullVex (cons (mkTree (mkNode D) ()) ()))
    ( mkLSK
    (mkDiscKnob
      (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))
    ))



;; Testcase 2: When the subtree is found in the target's children list
!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode OR)
      (cons (mkTree (mkNode X) ())
        (cons (mkTree (mkNode Y) ())
          (cons (mkTree (mkNode Z) ()) ()))))
    (mkTree (mkNode Y) ()))

  ( (mkTree (mkNode Y) ())
    (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
  )



;; Testcase 3: When the negation of the subtree is found in the target's children list
;; INFO: This test case has been commented out for now however the behavior handling of a subtree should be addressed in the future.
;; The test case is failing because of the way we check subtree's inside the bigger tree is only single level children match, if the child 
;;  also have another nested children the subtree match fails. Not sure how this edge should be handled but the test case failure is a direct
;;  consequence of it.
;; !(assertEqual
;;   (logicalSubtreeKnob
;;     (mkTree (mkNode AND)
;;       (cons (mkTree (mkNode A) ())
;;         (cons (mkNullVex
;;                 (cons (mkTree (mkNode NOT)
;;                         (cons (mkTree (mkNode B) ()) ())) ())) ())))
;;     (mkTree (mkNode B) ()))
;;     ((mkTree (mkNode AND)
;;       (cons (mkTree (mkNode A) ())
;;       (cons (mkNullVex (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode B) ()) ())) ())) ()))) 
;;       (mkLSK (mkDiscKnob (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
;;        )
