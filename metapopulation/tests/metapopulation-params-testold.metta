! (register-module! ../../../metta-moses)
! (import! &self metta-moses:metapopulation:metapopulation-params)

;; Get initial values
! (assertEqual (getMpParam &params capCoef) 50)
! (assertEqual (getMpParam &params discardDominated) False)

;; Set new values and verify
! (setMpParam &params capCoef 60)
! (assertEqual (getMpParam &params capCoef) 60)
! (setMpParam &params maxCandPerDeme 20)
! (assertEqual (getMpParam &params maxCandPerDeme) 20)
! (setMpParam &params complexityTemperature 8)
! (assertEqual (getMpParam &params complexityTemperature) 8)

;; Try getting an unregistered parameter 
(: fakeParam MetapopParams)
! (assertEqual (getMpParam &params fakeParam) (empty))
