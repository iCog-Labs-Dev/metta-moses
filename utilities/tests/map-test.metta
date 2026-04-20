!(import! &self ../general-helpers)
!(import! &self ../map)
!(import! &self ../../representation/knob-representation)

;; Testcase Map.insert
!(println! ("testing: Map.insert"))
!(assertEqual (Map.insert (4 d) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap)))))
!(assertEqual (Map.insert (1 e) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (ConsMap (1 e) (ConsMap (2 b) (ConsMap (3 c) NilMap))))
!(assertEqual (Map.insert (2 b) (ConsMap (1 a) (ConsMap (3 c) (ConsMap (4 d) NilMap)))) (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap)))))

;;Testcase for Map.insertCounter
!(println! ("testing: Map.insertCounter"))
!(assertEqual (Map.insertCounter 1 (ConsMap (1 1) (ConsMap (2 2) (ConsMap (3 3) NilMap)))) (ConsMap (1 2) (ConsMap (2 2) (ConsMap (3 3) NilMap))))
!(assertEqual (Map.insertCounter 1 NilMap) (ConsMap (1 1) NilMap))
!(assertEqual (Map.insertCounter 2 (ConsMap (2 2) (ConsMap (3 3) NilMap))) (ConsMap (2 3) (ConsMap (3 3) NilMap)))
!(assertEqual (Map.insertCounter 7 (ConsMap (1 1) (ConsMap (2 2) (ConsMap (3 3) NilMap)))) (ConsMap (1 1) (ConsMap (2 2) (ConsMap (3 3) (ConsMap (7 1) NilMap)))))

;; Testcase for Map.remove
!(println! ("testing: Map.remove"))
!(assertEqual (Map.remove 5 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (Error 5 "not found"))
!(assertEqual (Map.remove 1 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap))))) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap))))
!(assertEqual (Map.remove 2 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (ConsMap (1 a) (ConsMap (3 c) NilMap)))


;; Testcase for Map.contains
!(println! ("testing: Map.contains"))
!(assertEqual (Map.contains 5 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) False)
!(assertEqual (Map.contains 1 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap))))) True)
!(assertEqual (Map.contains 2 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) True)

; ;; Testcase for Map.checkValue
!(println! ("testing: Map.checkValue"))
!(assertEqual (Map.checkValue a (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) True)
!(assertEqual (Map.checkValue d (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d) NilMap))))) True)
!(assertEqual (Map.checkValue f (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) False)

;; Testcase for Map.getByKey
!(println! ("testing: Map.getByKey"))
!(assertEqual (Map.getByKey 1 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) a)
!(assertEqual (Map.getByKey 3 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) c)
!(assertEqual (Map.getByKey 10 (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (Error 10 "not found"))

;; Testcase for Map.keys
!(println! ("testing: Map.keys"))
!(assertEqual (Map.keys (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (cons 1 (cons 2 (cons 3 ()))))
!(assertEqual (Map.keys (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 (cons 6 (cons 7 (cons 8 (cons 9 ()))))))))))
!(assertEqual (Map.keys NilMap) ())

;; Testcase for Map.values
!(println! ("testing: Map.values"))
!(assertEqual (Map.values (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (cons a (cons b (cons c ()))))
!(assertEqual (Map.values (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (cons a (cons b (cons c (cons d (cons e (cons f (cons g (cons h (cons i ()))))))))))
!(assertEqual (Map.values NilMap) ())

;; Testcase for Map.items
!(println! ("testing: Map.items"))
!(assertEqual (Map.items (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) (cons (1 a) (cons (2 b) (cons (3 c) ()))))
!(assertEqual (Map.items (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) (cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ()))))))))))
!(assertEqual (Map.items NilMap) ())

;; Testcase for Map.length
!(println! ("testing: Map.length"))
!(assertEqual (Map.length (ConsMap (3 c) NilMap)) 1)
!(assertEqual (Map.length (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) NilMap)))) 3)
!(assertEqual (Map.length (ConsMap (1 a) (ConsMap (2 b) (ConsMap (3 c) (ConsMap (4 d)(ConsMap (5 e) (ConsMap (6 f) (ConsMap (7 g) (ConsMap (8 h) (ConsMap (9 i) NilMap)))))))))) 9)

;; Testcase for Map.insert which uses custom comparison functions
;; !(assertEqual (Map.insert ((mkNodeId (2 2)) 0) (ConsMap ((mkNodeId (2 1))  1) (ConsMap ((mkNodeId (2 3))  2) NilMap)) == nodeId<)
;;               (ConsMap ((mkNodeId (2 1)) 1) (ConsMap ((mkNodeId (2 2)) 0) (ConsMap ((mkNodeId (2 3)) 2) NilMap))))
!(assertEqual (Map.insert ((mkNodeId (2 2)) 0) NilMap == nodeId<) (ConsMap ((mkNodeId (2 2)) 0) NilMap))
