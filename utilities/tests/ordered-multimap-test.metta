!(import! &self ../general-helpers)
!(import! &self ../ordered-multimap)

;; Testcase MultiMap.insert
!(println! ("testing: MultiMap.insert"))
!(assertEqual (MultiMap.insert (4 d) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap)))))
!(assertEqual (MultiMap.insert (2 b) NilMMap) (ConsMMap (2 b)  NilMMap))
!(assertEqual (MultiMap.insert (1 e) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap))) ==) (ConsMMap (1 e) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))))
!(assertEqual (MultiMap.insert (2 e) (ConsMMap (1 a) NilMMap) >) (ConsMMap (2 e) (ConsMMap (1 a) NilMMap)))
!(assertEqual (MultiMap.insert (1 b) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap))) <) (ConsMMap (1 a) (ConsMMap (1 b) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))))

;; Testcase for MultiMap.findOne
!(println! ("testing: MultiMap.findOne"))
!(assertEqual (MultiMap.findOne 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) a)
!(assertEqual (MultiMap.findOne 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c) NilMMap)))) b)
!(assertEqual (MultiMap.findOne 6 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (Error 6 "not found"))

;; Testcase for MultiMap.findAll
!(println! ("testing: MultiMap.finaAll"))
!(assertEqual (MultiMap.findAll 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (cons a ()))
!(assertEqual (MultiMap.findAll 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c)(ConsMMap (2 b) (ConsMMap (2 d) NilMMap)))))) (cons b (cons c (cons b (cons d ())))))
!(assertEqual (MultiMap.findAll 6 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) ())

;; Testcase for MultiMap.removeOne
!(println! ("testing: MultiMap.removeOne"))
!(assertEqual (MultiMap.removeOne 5 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (Error 5 "not found"))
!(assertEqual (MultiMap.removeOne 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))
!(assertEqual (MultiMap.removeOne 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c) NilMMap)))) (ConsMMap (1 a) (ConsMMap (2 c) NilMMap)))

;; Testcase for MultiMap.removeAll
!(println! ("testing: MultiMap.removeAll"))
!(assertEqual (MultiMap.removeAll 5 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap))))
!(assertEqual (MultiMap.removeAll 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))
!(assertEqual (MultiMap.removeAll 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (2 c) NilMMap)))) (ConsMMap (1 a) NilMMap))


;; Testcase for MultiMap.contains
!(println! ("testing: MultiMap.contains"))
!(assertEqual (MultiMap.contains 5 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) False)
!(assertEqual (MultiMap.contains 1 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))) True)
!(assertEqual (MultiMap.contains 2 (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) True)

;; Testcase for MultiMap.checkValue
!(println! ("testing: MultiMap.checkValue"))
!(assertEqual (MultiMap.checkValue a (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) True)
!(assertEqual (MultiMap.checkValue d (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d) NilMMap))))) True)
!(assertEqual (MultiMap.checkValue f (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) False)

;; Testcase for Map.values
!(println! ("testing: MultiMap.values"))
!(assertEqual (MultiMap.values (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (cons a (cons b (cons c ()))))
!(assertEqual (MultiMap.values (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) (cons a (cons b (cons c (cons d (cons e (cons f (cons g (cons h (cons i ()))))))))))
!(assertEqual (MultiMap.values NilMMap) ())

;; Testcase for MultiMap.keys
!(println! ("testing: MultiMap.keys"))
!(assertEqual (MultiMap.keys (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (cons 1 (cons 2 (cons 3 ()))))
!(assertEqual (MultiMap.keys (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 (cons 6 (cons 7 (cons 8 (cons 9 ()))))))))))
!(assertEqual (MultiMap.keys NilMMap) ())

;; Testcase for MultiMap.items
!(println! ("testing: MultiMap.items"))
!(assertEqual (MultiMap.items (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) (cons (1 a) (cons (2 b) (cons (3 c) ()))))
!(assertEqual (MultiMap.items (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) (cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ()))))))))))
!(assertEqual (MultiMap.items NilMMap) ())


;; Testcase for MultiMap.length
!(println! ("testing: MultiMap.length"))
!(assertEqual (MultiMap.length (ConsMMap (3 c) NilMMap)) 1)
!(assertEqual (MultiMap.length (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) 3)
!(assertEqual (MultiMap.length (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) (ConsMMap (4 d)(ConsMMap (5 e) (ConsMMap (6 f) (ConsMMap (7 g) (ConsMMap (8 h) (ConsMMap (9 i) NilMMap)))))))))) 9)

;; Testcase for MultiMap.checkElement
!(println! ("testing: MultiMap.checkElement"))
!(assertEqual (MultiMap.checkElement (1 a) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) True)
!(assertEqual (MultiMap.checkElement (3 a) (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))) False)

;; Testcase for MultiMap.equals
!(println! ("testing: MultiMap.equals"))
!(assertEqual (MultiMap.equals (ConsMMap (1 a) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))
(ConsMMap (2 b) (ConsMMap (1 a) (ConsMMap (3 c) NilMMap)))) True)
!(assertEqual (MultiMap.equals (ConsMMap (1 b) (ConsMMap (2 b) (ConsMMap (3 c) NilMMap)))
(ConsMMap (2 b) (ConsMMap (1 a) (ConsMMap (3 c) NilMMap)))) False)
