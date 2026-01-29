!(import! &self ../../../utilities/general-helpers)
!(import! &self ../tic-tac-toe-helpers)
!(import! &self ../alpha-beta-minimax)

;; Plays at the center 
!(assertEqual (ab-minimax-player (E E E E E E E E E) X)  (E E E E X E E E E))

;; Wins immediately
!(assertEqual (ab-minimax-player (E X E E X E E E E) X) (E X E E X E E X E))
