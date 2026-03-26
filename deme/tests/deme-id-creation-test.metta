!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../deme-id-creation)

; Test cases -- createDemeIds
!(assertEqual (createDemeIds 0 1) (Cons (mkDemeId (numStr 1)) Nil))  ;; changed to use numStr for type mismatch handling
!(assertEqual (createDemeIds 0 2) (Cons (mkDemeId (1 . 0)) (Cons (mkDemeId (1 . 1)) Nil)))
!(assertEqual (createDemeIds 0 3) (Cons (mkDemeId (1 . 0)) (Cons (mkDemeId (1 . 1)) (Cons (mkDemeId (1 . 2)) Nil))))
