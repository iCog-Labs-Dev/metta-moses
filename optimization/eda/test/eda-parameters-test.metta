!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:optimization:eda/eda-parameters)

;; ================================================================================
;; EDA Parameters Tests
;; ================================================================================

;; Test EDA parameter creation and access
!(assertEqual (getSelection (mkEDAParameters 2 1.0 0.5 1.0)) 2)
!(assertEqual (getSelectionRatio (mkEDAParameters 2 1.0 0.5 1.0)) 1.0)
!(assertEqual (getReplacementRatio (mkEDAParameters 2 1.0 0.5 1.0)) 0.5)
!(assertEqual (getModelComplexity (mkEDAParameters 2 1.0 0.5 1.0)) 1.0)

; ;; Test default parameters
!(assertEqual (getSelection (default-eda-parameters)) 2)
!(assertEqual (getSelectionRatio (default-eda-parameters)) 1.0)
!(assertEqual (getReplacementRatio (default-eda-parameters)) 0.5)
!(assertEqual (getModelComplexity (default-eda-parameters)) 1.0)

; ;; Test parameter types
!(assertEqual (get-type (mkEDAParameters 2 1.0 0.5 1.0)) (EDAParameters))
!(assertEqual (let $params (default-eda-parameters) (get-type $params)) (EDAParameters))
