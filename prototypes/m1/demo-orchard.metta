;; ============================================================================
;; demo-orchard.metta -- TWO SENSES, each blind to what the other sees.
;;
;;   ( ulimit -v 8000000; timeout 900 \
;;       sh /home/yab/PeTTaV1/run.sh prototypes/m1/demo-orchard.metta -s )
;;
;; WORLD        two rings of cells. Each holds fresh fruit (FS), spoiled fruit
;;              (FX), or nothing (E).
;; CONTEXT      that orchard -- and the program CHANGES it. Picking empties a
;;              cell and spends fuel.
;; IT CAN DO    orchPick (eat what is here), orchWalk (move on).
;; IT CAN SEE   orchFruitHere -- SIGHT. Something is there. Fresh and spoiled
;;              fruit look alike, so it is true at FS and FX.
;;              orchNoRotHere -- SMELL. Nothing here smells of rot. True at FS,
;;              and also at E, because bare ground does not smell of rot either.
;;
;;                           FS      FX      E
;;              fruitHere    True    True    False
;;              noRotHere    True    False   True
;;                           ^^^^ only FS is both
;;
;; SCORE        fresh fruit +2, spoiled -3, an empty pick -1, over two rings.
;;              Higher is better; 12 is the ceiling.
;; THE POINT    neither sense is worth anything alone. Pick on sight and you eat
;;              the spoiled ones; pick on smell and you pick at bare ground --
;;              and an empty pick does not move you, so you do it for the rest
;;              of your fuel. Only the CONJUNCTION is a fresh fruit, and a
;;              conjunction is a thing the search has to BUILD out of two
;;              candidates rather than choose as one.
;;
;; demo.metta shows a program learning to look. This one shows it learning to
;; look at two things and combine them, which needs a different piece of the
;; machinery: candidates at a Bool slot, and a knob per candidate so more than
;; one can be switched on at a time.
;; ============================================================================
!(import! &self prototypes/m1/all)
!(import! &self prototypes/m1/domain/orchard)

!(m1Moses orchard (orchExemplar) orchScoreExp (orchBestScore))
