import unittest
from .listMethods import exprToList, listToExpr


class TestListMethods(unittest.TestCase):
    
    def test_listToExpr(self):
        expected_result_1 = "(A B C)"
        received_result_1 = listToExpr("(Cons A (Cons B (Cons C Nil)))")
        expected_result_2 = "((mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (B) (C) D E)"  #"((mkInst (0 1 2)) (B) (C) D E)"
        received_result_2 = listToExpr("(Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (B) (Cons (C) (Cons D (Cons E Nil)))))")
        self.assertEqual(received_result_1, expected_result_1)
        self.assertEqual(received_result_2, expected_result_2)
    
    def test_exprToList(self):
        expected_result_1 = "(Cons A (Cons B (Cons C Nil)))"
        received_result_1 = exprToList("(A B C)")
        expected_result_2 = "(Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (B) (Cons (C) (Cons D (Cons E Nil)))))"
        received_result_2 = exprToList("((mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (B) (C) D E)")
        expected_result_3 = "(Cons (B C E) (Cons A (Cons D (Cons E Nil))))"
        received_result_3 = exprToList("(A (B C E) D E)")
        self.assertEqual(received_result_1, expected_result_1)
        self.assertEqual(received_result_2, expected_result_2)
        self.assertEqual(received_result_3, expected_result_3)
    