!(import! &self ../../utilities/list-methods)
!(import! &self ../deme-id-creation)
!(import! &self ../../utilities/general-helpers)

; Test cases -- createDemeIds
!(assertEqual (createDemeIds 0 1) (Cons (mkDemeId 1) Nil))
!(assertEqual (createDemeIds 0 2) (Cons (mkDemeId (1 . 0)) (Cons (mkDemeId (1 . 1)) Nil)))
!(assertEqual (createDemeIds 0 3) (Cons (mkDemeId (1 . 0)) (Cons (mkDemeId (1 . 1)) (Cons (mkDemeId (1 . 2)) Nil))))