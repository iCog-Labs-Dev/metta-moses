!(import! &self ../tic-tac-toe-helpers)
!(import! &self ../../../utilities/general-helpers)
!(import! &self ../random-player)
!(import! &self ../minimax-player)
!(import! &self ../alpha-beta-minimax-player)
!(import! &self ../game-engine)

!(py-call (random.seed 42))
;; play a game between random and random stratagies
!(assertEqual (play-game random-player random-player) Draw)
;; play a game between minimax and random stratagies
!(assertEqual (play-game minimax-player random-player) X)
;; play a game between minimax and minimax stratagies
!(assertEqual (play-game minimax-player minimax-player) Draw)

!(assertEqual (play-game ab-minimax-player minimax-player) Draw)
!(assertEqual (play-game ab-minimax-player random-player) X)
