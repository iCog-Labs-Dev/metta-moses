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
!(assertEqual (param hcMaxDistBoolean)      4)
!(assertEqual (param hcMinXoverNeighborsBoolean) 400)
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
