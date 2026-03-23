!(import! &self ../../../utilities/general-helpers) 
!(import! &self ../tic-tac-toe-helpers) 
!(import! &self ../moves)
!(import! &self ../moses-player)

!(assertEqual 
    (moses-player (PRIORITIZED-OR playside) (E E E E E E E E E) X)
    (E X E E E E E E E))
!(assertEqual 
    (moses-player (PRIORITIZED-OR playwin playside) (E E E E E E E E E) X)
    (E X E E E E E E E))
!(assertEqual 
    (moses-player (PRIORITIZED-OR playcorner playside) (E E E E E E E E E) X)
    (X E E E E E E E E))