!(import! &self ../general-helpers)
!(import! &self ../ordered-multimap)

;; Testcase MultiMap.insert
!(println! ("testing: MultiMap.insert"))
!(assertEqual (MultiMap.insert (4 d) (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ())))))
!(assertEqual (MultiMap.insert (2 b) ()) (cons (2 b)  ()))
!(assertEqual (MultiMap.insert (1 e) (cons (1 a) (cons (2 b) (cons (3 c) ()))) ==) (cons (1 e) (cons (1 a) (cons (2 b) (cons (3 c) ())))))
!(assertEqual (MultiMap.insert (2 e) (cons (1 a) ()) >) (cons (2 e) (cons (1 a) ())))
!(assertEqual (MultiMap.insert (1 b) (cons (1 a) (cons (2 b) (cons (3 c) ()))) <) (cons (1 a) (cons (1 b) (cons (2 b) (cons (3 c) ())))))

;; Testcase for MultiMap.findOne
!(println! ("testing: MultiMap.findOne"))
!(assertEqual (MultiMap.findOne 1 (cons (1 a) (cons (2 b) (cons (3 c) ())))) a)
!(assertEqual (MultiMap.findOne 2 (cons (1 a) (cons (2 b) (cons (2 c) ())))) b)
!(assertEqual (MultiMap.findOne 6 (cons (1 a) (cons (2 b) (cons (3 c) ())))) (Error 6 "not found"))

;; Testcase for MultiMap.findAll
!(println! ("testing: MultiMap.finaAll"))
!(assertEqual (MultiMap.findAll 1 (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons a ()))
!(assertEqual (MultiMap.findAll 2 (cons (1 a) (cons (2 b) (cons (2 c)(cons (2 b) (cons (2 d) ())))))) (cons b (cons c (cons b (cons d ())))))
!(assertEqual (MultiMap.findAll 6 (cons (1 a) (cons (2 b) (cons (3 c) ())))) ())

;; Testcase for MultiMap.removeOne
!(println! ("testing: MultiMap.removeOne"))
!(assertEqual (MultiMap.removeOne 5 (cons (1 a) (cons (2 b) (cons (3 c) ())))) (Error 5 "not found"))
!(assertEqual (MultiMap.removeOne 1 (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ()))))) (cons (2 b) (cons (3 c) (cons (4 d) ()))))
!(assertEqual (MultiMap.removeOne 2 (cons (1 a) (cons (2 b) (cons (2 c) ())))) (cons (1 a) (cons (2 c) ())))

;; Testcase for MultiMap.removeAll
!(println! ("testing: MultiMap.removeAll"))
!(assertEqual (MultiMap.removeAll 5 (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons (1 a) (cons (2 b) (cons (3 c) ()))))
!(assertEqual (MultiMap.removeAll 1 (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ()))))) (cons (2 b) (cons (3 c) (cons (4 d) ()))))
!(assertEqual (MultiMap.removeAll 2 (cons (1 a) (cons (2 b) (cons (2 c) ())))) (cons (1 a) ()))


;; Testcase for MultiMap.contains
!(println! ("testing: MultiMap.contains"))
!(assertEqual (MultiMap.contains 5 (cons (1 a) (cons (2 b) (cons (3 c) ())))) False)
!(assertEqual (MultiMap.contains 1 (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ()))))) True)
!(assertEqual (MultiMap.contains 2 (cons (1 a) (cons (2 b) (cons (3 c) ())))) True)

;; Testcase for MultiMap.checkValue
!(println! ("testing: MultiMap.checkValue"))
!(assertEqual (MultiMap.checkValue a (cons (1 a) (cons (2 b) (cons (3 c) ())))) True)
!(assertEqual (MultiMap.checkValue d (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) ()))))) True)
!(assertEqual (MultiMap.checkValue f (cons (1 a) (cons (2 b) (cons (3 c) ())))) False)

;; Testcase for Map.values
!(println! ("testing: MultiMap.values"))
!(assertEqual (MultiMap.values (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons a (cons b (cons c ()))))
!(assertEqual (MultiMap.values (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) (cons a (cons b (cons c (cons d (cons e (cons f (cons g (cons h (cons i ()))))))))))
!(assertEqual (MultiMap.values ()) ())

;; Testcase for MultiMap.keys
!(println! ("testing: MultiMap.keys"))
!(assertEqual (MultiMap.keys (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons 1 (cons 2 (cons 3 ()))))
!(assertEqual (MultiMap.keys (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) (cons 1 (cons 2 (cons 3 (cons 4 (cons 5 (cons 6 (cons 7 (cons 8 (cons 9 ()))))))))))
!(assertEqual (MultiMap.keys ()) ())

;; Testcase for MultiMap.items
!(println! ("testing: MultiMap.items"))
!(assertEqual (MultiMap.items (cons (1 a) (cons (2 b) (cons (3 c) ())))) (cons (1 a) (cons (2 b) (cons (3 c) ()))))
!(assertEqual (MultiMap.items (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d) (cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ()))))))))))
!(assertEqual (MultiMap.items ()) ())


;; Testcase for MultiMap.length
!(println! ("testing: MultiMap.length"))
!(assertEqual (MultiMap.length (cons (3 c) ())) 1)
!(assertEqual (MultiMap.length (cons (1 a) (cons (2 b) (cons (3 c) ())))) 3)
!(assertEqual (MultiMap.length (cons (1 a) (cons (2 b) (cons (3 c) (cons (4 d)(cons (5 e) (cons (6 f) (cons (7 g) (cons (8 h) (cons (9 i) ())))))))))) 9)

;; Testcase for MultiMap.checkElement
!(println! ("testing: MultiMap.checkElement"))
!(assertEqual (MultiMap.checkElement (1 a) (cons (1 a) (cons (2 b) (cons (3 c) ())))) True)
!(assertEqual (MultiMap.checkElement (3 a) (cons (1 a) (cons (2 b) (cons (3 c) ())))) False)

;; Testcase for MultiMap.equals
!(println! ("testing: MultiMap.equals"))
!(assertEqual (MultiMap.equals (cons (1 a) (cons (2 b) (cons (3 c) ())))
(cons (2 b) (cons (1 a) (cons (3 c) ())))) True)
!(assertEqual (MultiMap.equals (cons (1 b) (cons (2 b) (cons (3 c) ())))
(cons (2 b) (cons (1 a) (cons (3 c) ())))) False)
