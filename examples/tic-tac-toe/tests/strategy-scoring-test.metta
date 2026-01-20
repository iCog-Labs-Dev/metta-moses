!(import! &self ../tic-tac-toe-helpers)
!(import! &self ../../../utilities/general-helpers)
!(import! &self ../random-player)
!(import! &self ../strategy-scoring)
!(import! &self ../minimax-player)
!(import! &self ../game-engine)

!(assertEqual (score-result X X) 1.0)
!(assertEqual (score-result X O) -1.0)
!(assertEqual (score-result Draw X) 0.0)

!(assertEqual (evaluate-strategy 5 X random-player minimax-player)
              (Cons -1.0 (Cons -1.0 (Cons -1.0 (Cons -1.0 (Cons -1.0 Nil))))))

!(assertEqual (evaluate-strategy 3 X random-player random-player)
              (Cons -1.0 (Cons -1.0 (Cons -1.0 Nil))))

!(assertEqual (evaluate-strategy 3 X minimax-player random-player)
              (Cons 1.0 (Cons 1.0 (Cons 1.0 Nil))))

!(assertEqual (score-strategy 3 minimax-player random-player) 
              (mkBScore (Cons 1.0 (Cons 1.0 (Cons 1.0 Nil)))))

!(assertEqual (score-strategy 3 random-player minimax-player) 
              (mkBScore (Cons -1.0 (Cons -1.0 (Cons -1.0 Nil)))))

!(assertEqual (score-strategy 3 minimax-player minimax-player) 
              (mkBScore (Cons 0.0 (Cons 0.0 (Cons 0.0 Nil)))))