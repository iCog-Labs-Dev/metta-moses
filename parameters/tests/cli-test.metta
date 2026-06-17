!(import! &self ../../utilities/general-helpers)
!(import! &self ../registry)
!(import! &self ../defaults)
!(import! &self ../cli)

;; PeTTa's parser tokenizes anything not separated by whitespace or
;; parentheses as a single atom. We can therefore write CLI strings
;; bare (no quotes) — `--capCoef=100` is read as one atom, identical
;; to what argv would deliver at runtime.

;; ---- parse-flag with well-formed input ----
!(println! ("testing: parse-flag accepts --name=value"))
!(assertEqual (parse-flag (atom_chars --capCoef=100)) (flag capCoef 100))
!(assertEqual (parse-flag (atom_chars --maxDist=6))   (flag maxDist 6))
!(assertEqual (parse-flag (atom_chars --ratio=3.5))   (flag ratio 3.5))
!(assertEqual (parse-flag (atom_chars --flag=True))   (flag flag true))
!(assertEqual (parse-flag (atom_chars --name=smd))    (flag name smd))

;; ---- parse-flag rejects malformed input ----
!(println! ("testing: parse-flag rejects non-flag inputs"))
!(assertEqual (parse-flag (atom_chars capCoef=100)) ()) ;; no leading --
!(assertEqual (parse-flag (atom_chars -x=1))        ()) ;; single dash
!(assertEqual (parse-flag (atom_chars --name))      ()) ;; no '='
!(assertEqual (parse-flag (atom_chars --name=))     ()) ;; empty value
!(assertEqual (parse-flag (atom_chars --=value))    ()) ;; empty name
!(assertEqual (parse-flag (atom_chars plain-arg))   ())

;; ---- try-apply-flag drives set-param when a flag is well-formed ----
!(println! ("testing: try-apply-flag applies the override"))
!(try-apply-flag --capCoef=77)
!(assertEqual (param capCoef) 77)

!(try-apply-flag --complexityRatio=1.5)
!(assertEqual (param complexityRatio) 1.5)

;; ---- try-apply-flag silently ignores non-flag input ----
!(println! ("testing: try-apply-flag is a no-op for non-flag arguments"))
!(try-apply-flag something-else)
!(assertEqual (param capCoef) 77)   ;; unchanged from above
