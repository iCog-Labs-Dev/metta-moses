import unittest
from .treeMethods import getById, appendChild, insertAbove, replaceNode


class TestTreeMethods(unittest.TestCase):
    
    def setUp(self):
        self.tree =  """(mkTree (mkNode AND) 
                            (Cons (mkTree (mkNode A) Nil) 
                            (Cons (mkTree (mkNode B) Nil) 
                            (Cons (mkTree (mkNode OR) 
                                (Cons (mkTree (mkNode AND) 
                                    (Cons (mkTree (mkNode C) Nil) Nil)) 
                                    (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"""


    def test_getByID(self):
        expected_result_1 = "(mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil)))"
        received_result_1 =  getById(self.tree, '3')
        expected_result_2 = "(mkTree (mkNode C) Nil)"
        received_result_2 = getById(self.tree, '(3 1 1)')

        self.assertEqual(expected_result_1, received_result_1)
        self.assertEqual(expected_result_2, received_result_2)


    def test_appendChild(self):
        expected_result_1 = "((mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil)))) Nil)))) (mkNodeId (3 3)))"
        received_result_1 = appendChild(self.tree, '3', '(mkTree (mkNode E) Nil)')
        expected_result_2 = "((mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) (Cons (mkNullVex Nil) Nil))))) (mkNodeId (4)))"        
        received_result_2 = appendChild(self.tree, '0', '(mkNullVex Nil)')

        self.assertEqual(expected_result_1, received_result_1)
        self.assertEqual(expected_result_2, received_result_2)
    
    
    def test_insertAbove(self):
        expected_result_1 = "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode XOR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"
        received_result_1 = insertAbove(self.tree, '(3 1)', '(mkTree (mkNode XOR) Nil)')
        expected_result_2 = "(mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"
        received_result_2 = insertAbove(self.tree, '1', '(mkTree (mkNode NOT) Nil)')

        self.assertEqual(expected_result_1, received_result_1)
        self.assertEqual(expected_result_2, received_result_2)
    
    
    def test_replaceNode(self):
        expected_result_1 = "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode XOR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"
        received_result_1 = replaceNode(self.tree, '3', '(mkTree (mkNode XOR) Nil)')
        received_result_2 = replaceNode(self.tree, '(3 1 1)', '(mkTree (mkNode E) Nil)')
        expected_result_2 = "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode E) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"

        self.assertEqual(expected_result_1, received_result_1)
        self.assertEqual(expected_result_2, received_result_2)
