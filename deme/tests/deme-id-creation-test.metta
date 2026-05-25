!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../deme-id-creation)

; Test cases -- createDemeIds
!(assertEqual (createDemeIds 0 1) (cons (mkDemeId (numStr 1)) ()))  ;; changed to use numStr for type mismatch handling
!(assertEqual (createDemeIds 0 2) (cons (mkDemeId (1 . 0)) (cons (mkDemeId (1 . 1)) ())))
!(assertEqual (createDemeIds 0 3) (cons (mkDemeId (1 . 0)) (cons (mkDemeId (1 . 1)) (cons (mkDemeId (1 . 2)) ()))))
