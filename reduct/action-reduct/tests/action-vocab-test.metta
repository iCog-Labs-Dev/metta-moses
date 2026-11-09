!(import! &self ../../../utilities/general-helpers)
!(import! &self ../action-vocab)

;; alwaysSucceeds oracle — conservative defaults (no domain-specific overrides)
!(assertEqual (alwaysSucceeds turn_left) True)
!(assertEqual (alwaysSucceeds turn_right) True)
!(assertEqual (alwaysSucceeds move_forward) False)
!(assertEqual (alwaysSucceeds step_forward) False)
!(assertEqual (alwaysSucceeds action_success) False)
!(assertEqual (alwaysSucceeds action_failure) False)
!(assertEqual (alwaysSucceeds (goto_obj stick)) False)

;; referenceAntAlwaysSucceeds — C++ ant-domain parity for regression checks
!(assertEqual (referenceAntAlwaysSucceeds move_forward) True)
!(assertEqual (referenceAntAlwaysSucceeds turn_left) True)
!(assertEqual (referenceAntAlwaysSucceeds turn_right) True)
!(assertEqual (referenceAntAlwaysSucceeds step_forward) False)
!(assertEqual (referenceAntAlwaysSucceeds action_success) False)
