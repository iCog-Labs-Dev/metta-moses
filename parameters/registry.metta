;; ============================================================
;;  Parameter accessor functions.
;;
;;  (param $name)            -> current value of $name, or () if
;;                              the parameter has never been set.
;;  (set-param $name $value) -> replaces any existing value for
;;                              $name with $value, returns $value.
;;
;;  Defaults are populated by parameters/defaults.metta.
;;  CLI overrides are applied by parameters/cli.metta.
;; ============================================================

;; Look up a parameter by name.
(= (param $name)
   (let $results (collapse (match &params ($name $val) $val))
        (if (== $results ())
            ()
            (car-atom $results))))

;; Replace any existing entry for $name with $newVal.
;; If no prior entry exists, this still installs the new value.
;; Calling remove-atom with an unbound second slot retracts every
;; matching atom in the space, which keeps the registry single-valued
;; even if duplicate atoms ever sneak in.
(= (set-param $name $newVal)
   (let* (
          ($_  (remove-atom &params ($name $oldVal)))
          ($__ (add-atom    &params ($name $newVal)))
         )
        $newVal))
