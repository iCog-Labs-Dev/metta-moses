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
              (cons -1.0 (cons -1.0 (cons -1.0 (cons -1.0 (cons -1.0 ()))))))

!(assertEqual (evaluate-strategy 3 X random-player random-player)
              (cons -1.0 (cons -1.0 (cons -1.0 ()))))

!(assertEqual (evaluate-strategy 3 X minimax-player random-player)
              (cons 1.0 (cons 1.0 (cons 1.0 ()))))

!(assertEqual (score-strategy 3 minimax-player random-player) 
              (mkBScore (cons 1.0 (cons 1.0 (cons 1.0 ())))))

!(assertEqual (score-strategy 3 random-player minimax-player) 
              (mkBScore (cons -1.0 (cons -1.0 (cons -1.0 ())))))

!(assertEqual (score-strategy 3 minimax-player minimax-player) 
              (mkBScore (cons 0.0 (cons 0.0 (cons 0.0 ())))))
