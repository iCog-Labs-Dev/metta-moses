!(import! &self ../../utilities/general-helpers)
!(import! &self ../registry)
!(import! &self ../defaults)

;; ---- Lookup of declared defaults ----
!(println! ("testing: param lookup against defaults"))
!(assertEqual (param capCoef)               50)
!(assertEqual (param complexityTemperature) 6)
!(assertEqual (param maxCandPerDeme)        100)
!(assertEqual (param minPoolSize)           20)
!(assertEqual (param nToKeep)               50)
!(assertEqual (param nEval)                 10000)
!(assertEqual (param maxCandOutput)         10)
!(assertEqual (param complexityRatio)       3.5)
!(assertEqual (param antSteps)              600)
!(assertEqual (param antFoodCount)          89)
;; Keep the registry regression aligned with the diagnostic Santa Fe baseline.
!(assertEqual (param antComplexityRatio)    0.16)
!(assertEqual (param antComplexityTemperature) 2000)
!(assertEqual (param antDiagnostics)        False)
!(assertEqual (param antDiscardDominated)   False)
!(assertEqual (param antRevisit)            0)
!(assertEqual (param hcMaxDistBoolean)      4)
!(assertEqual (param hcMinXoverNeighborsBoolean) 400)
!(assertEqual (param hcMaxDistAnt)          4)
!(assertEqual (param hcMinXoverNeighborsAnt) 400)
!(assertEqual (param hcMaxEvalsAnt)         2000)
!(assertEqual (param hcWidenSearch)         False)
!(assertEqual (param hcCrossover)           True)
!(assertEqual (param hcCrossoverPopSize)    120)
!(assertEqual (param hcFractionOfNN)        2.0)
!(assertEqual (param compxyTemp)            6)
!(assertEqual (param defaultCacheSize)      60)

;; ---- Unknown key returns () ----
!(println! ("testing: param lookup of unknown key returns ()"))
!(assertEqual (param thisKeyDoesNotExist) ())

;; ---- set-param overrides ----
!(println! ("testing: set-param updates value"))
!(set-param capCoef 99)
!(assertEqual (param capCoef) 99)

!(set-param complexityRatio 1.25)
!(assertEqual (param complexityRatio) 1.25)

;; ---- set-param installs a brand-new key ----
!(println! ("testing: set-param can introduce a new key"))
!(set-param myFreshKey 42)
!(assertEqual (param myFreshKey) 42)

;; ---- repeated set-param keeps registry single-valued ----
!(println! ("testing: repeated set-param replaces rather than appends"))
!(set-param capCoef 1)
!(set-param capCoef 2)
!(set-param capCoef 3)
!(assertEqual (param capCoef) 3)
