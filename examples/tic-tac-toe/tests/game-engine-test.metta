!(import! &self ../tic-tac-toe-helpers)
!(import! &self ../random-player)
!(import! &self ../minimax-player)
!(import! &self ../game-engine)

;; play a game between minimax and random stratagies
!(play-game minimax-player random-player)
;; play a game between random and random stratagies
!(play-game random-player random-player)
;; play a game between minimax and minimax stratagies
!(play-game minimax-player minimax-player)