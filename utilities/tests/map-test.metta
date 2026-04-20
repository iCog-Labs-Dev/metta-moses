!(import! &self ../general-helpers)
!(import! &self ../map)
!(import! &self ../../representation/knob-representation)

;; Testcase Map.insert
!(println! ("testing: Map.insert"))
!(assertEqual (Map.insert (4 d) (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ())))))
!(assertEqual (Map.insert (1 e) (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons (1 e) (cons (2 b) (cons (3 c) ()))))
!(assertEqual (Map.insert (2 b) (cons (1 a) (cons (3 c) (cons (4 d) ())))) (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ())))))

;;Testcase for Map.insertCounter
!(println! ("testing: Map.insertCounter"))
!(assertEqual (Map.insertCounter 1 (cons (1 1) (cons (2 2) (cons (3 3) ())))) (cons (1 2) (cons (2 2) (cons (3 3) ()))))
!(assertEqual (Map.insertCounter 1 ()) (cons (1 1) ()))
!(assertEqual (Map.insertCounter 2 (cons (2 2) (cons (3 3) ()))) (cons (2 3) (cons (3 3) ())))
!(assertEqual (Map.insertCounter 7 (cons (1 1) (cons (2 2) (cons (3 3) ())))) (cons (1 1) (cons (2 2) (cons (3 3) (cons (7 1) ())))))

;; Testcase for Map.remove
!(println! ("testing: Map.remove"))
!(assertEqual (Map.remove 5 (cons (1 a) (cons (2 b) (cons (3 c) ())))) (Error 5 "not found"))
!(assertEqual (Map.remove 1 (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ()))))) (cons (2 b) (cons (3 c) (cons (4 d) ()))))
!(assertEqual (Map.remove 2 (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons (1 a) (cons (3 c) ())))


;; Testcase for Map.contains
!(println! ("testing: Map.contains"))
!(assertEqual (Map.contains 5 (cons (1 a) (cons (2 b) (cons (3 c) ())))) False)
!(assertEqual (Map.contains 1 (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ()))))) True)
!(assertEqual (Map.contains 2 (cons (1 a) (cons (2 b) (cons (3 c) ())))) True)

; ;; Testcase for Map.checkValue
!(println! ("testing: Map.checkValue"))
!(assertEqual (Map.checkValue a (cons (1 a) (cons (2 b) (cons (3 c) ())))) True)
!(assertEqual (Map.checkValue d (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ()))))) True)
!(assertEqual (Map.checkValue f (cons (1 a) (cons (2 b) (cons (3 c) ())))) False)

;; Testcase for Map.getByKey
!(println! ("testing: Map.getByKey"))
!(assertEqual (Map.getByKey 1 (cons (1 a) (cons (2 b) (cons (3 c) ())))) a)
!(assertEqual (Map.getByKey 3 (cons (1 a) (cons (2 b) (cons (3 c) ())))) c)
!(assertEqual (Map.getByKey 10 (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) (Error 10 "not found"))

;; Testcase for Map.keys
!(println! ("testing: Map.keys"))
!(assertEqual (Map.keys (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons 1 (cons 2 (cons 3 ()))))
!(assertEqual (Map.keys (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 (cons 6 (cons 7 (cons 8 (cons 9 ()))))))))))
!(assertEqual (Map.keys ()) ())

;; Testcase for Map.values
!(println! ("testing: Map.values"))
!(assertEqual (Map.values (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons a (cons b (cons c ()))))
!(assertEqual (Map.values (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) (cons a (cons b (cons c (cons d (cons e (cons f (cons g (cons h (cons i ()))))))))))
!(assertEqual (Map.values ()) ())

;; Testcase for Map.items
!(println! ("testing: Map.items"))
!(assertEqual (Map.items (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons (1 a) (cons (2 b) (cons (3 c) ()))))
!(assertEqual (Map.items (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) (cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ()))))))))))
!(assertEqual (Map.items ()) ())

;; Testcase for Map.length
!(println! ("testing: Map.length"))
!(assertEqual (Map.length (cons (3 c) ())) 1)
!(assertEqual (Map.length (cons (1 a) (cons (2 b) (cons (3 c) ())))) 3)
!(assertEqual (Map.length (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) 9)

;; Testcase for Map.insert which uses custom comparison functions
;; !(assertEqual (Map.insert ((mkNodeId (2 2)) 0) (cons ((mkNodeId (2 1))  1) (cons ((mkNodeId (2 3))  2) ())) == nodeId<)
;;               (cons ((mkNodeId (2 1)) 1) (cons ((mkNodeId (2 2)) 0) (cons ((mkNodeId (2 3)) 2) ()))))
!(assertEqual (Map.insert ((mkNodeId (2 2)) 0) () == nodeId<) (cons ((mkNodeId (2 2)) 0) ()))
