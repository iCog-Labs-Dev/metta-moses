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
!(assertEqual (param maxEvals)              25000)
!(assertEqual (param maxDist)               4)
!(assertEqual (param minXoverNeighbors)     400)
!(assertEqual (param steps)                 600)
!(assertEqual (param complexityRatio)       3.5)
!(assertEqual (param diagnostics)           False)
!(assertEqual (param discardDominated)      False)
!(assertEqual (param revisit)               0)
!(assertEqual (param hcWidenSearch)         False)
!(assertEqual (param hcCrossover)           True)
!(assertEqual (param hcCrossoverPopSize)    120)
!(assertEqual (param hcFractionOfNN)        2.0)
!(assertEqual (param defaultCacheSize)      60)

;; ---- Unknown key returns () ----
!(println! ("testing: param lookup of unknown key returns ()"))
!(assertEqual (param thisKeyDoesNotExist) ())

;; ---- Removed aliases stay absent ----
;; Problem-specific parameter families formerly made Boolean and action runs
;; enter different search pipelines. They are intentionally not compatibility
;; aliases: callers must configure the neutral keys above.
!(println! ("testing: obsolete problem-specific aliases are absent"))
!(assertEqual (param antMaxEvals) ())
!(assertEqual (param hcMaxEvals) ())
!(assertEqual (param hcMaxEvalsAnt) ())
!(assertEqual (param hcMaxDistBoolean) ())
!(assertEqual (param hcMaxDistFs) ())
!(assertEqual (param hcMaxDistStrategy) ())
!(assertEqual (param hcMaxDistAnt) ())
!(assertEqual (param hcMinXoverNeighborsBoolean) ())
!(assertEqual (param hcMinXoverNeighborsFs) ())
!(assertEqual (param hcMinXoverNeighborsStrategy) ())
!(assertEqual (param hcMinXoverNeighborsAnt) ())
!(assertEqual (param antSteps) ())
!(assertEqual (param antFoodCount) ())
!(assertEqual (param antComplexityRatio) ())
!(assertEqual (param antComplexityTemperature) ())
!(assertEqual (param antRevisit) ())
!(assertEqual (param antDiscardDominated) ())
!(assertEqual (param antDiagnostics) ())
!(assertEqual (param compxyTemp) ())

;; ---- set-param overrides ----
!(println! ("testing: set-param updates value"))
!(set-param capCoef 99)
!(assertEqual (param capCoef) 99)

!(set-param complexityRatio 1.25)
!(assertEqual (param complexityRatio) 1.25)

!(set-param maxEvals 1234)
!(assertEqual (param maxEvals) 1234)

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
