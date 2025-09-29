;; ================================================================================
;; EDA Parameters Management
;; ================================================================================
;;
;; This file implements the EDA parameters management system.
;; Equivalent to parameter configuration in the C++ EDA implementation.
;;
;; Key Components:
;; - EDAParameters type definition
;; - Parameter creation and access functions
;; - Default parameter values
;;
;; Data Structures:
;; - EDAParameters: mkEDAParameters (selection tournamentSize selectionRatio replacementRatio modelComplexity)
;;
;; Parameters:
;; - selection: Tournament size (integer, default: 2)
;; - selectionRatio: Fraction of population to select for learning (float, default: 1.0)
;; - replacementRatio: Fraction of population to replace each generation (float, default: 0.5)
;; - modelComplexity: Model complexity control (float, default: 1.0, unused in univariate)

;; ================================================================================
;; Type Definitions
;; ================================================================================

;; EDA Parameters
(: EDAParameters Type)
(: mkEDAParameters (-> Number Number Number Number (EDAParameters)))

;; ================================================================================
;; EDA Parameters Management
;; ================================================================================

;; Create EDA parameters
(= (mkEDAParameters $selection $selectionRatio $replacementRatio $modelComplexity)
   (mkEDAParameters $selection $selectionRatio $replacementRatio $modelComplexity))

;; Getter functions for EDA parameters
; (: getSelection (-> (EDAParameters) Number))
(= (getSelection (mkEDAParameters $selection $selectionRatio $replacementRatio $modelComplexity)) $selection)

; (: getSelectionRatio (-> (EDAParameters) Number))
(= (getSelectionRatio (mkEDAParameters $selection $selectionRatio $replacementRatio $modelComplexity)) $selectionRatio)

; (: getReplacementRatio (-> (EDAParameters) Number))
(= (getReplacementRatio (mkEDAParameters $selection $selectionRatio $replacementRatio $modelComplexity)) $replacementRatio)

; (: getModelComplexity (-> (EDAParameters) Number))
(= (getModelComplexity (mkEDAParameters $selection $selectionRatio $replacementRatio $modelComplexity)) $modelComplexity)

;; Default EDA parameters
(= (defaultEdaParameters) (mkEDAParameters 2 1.0 0.5 1.0))
