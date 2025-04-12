import unittest

from Utilities.BuildTree import BuildTree
from DataStructures.Trees import BinaryExpressionTreeNode, NodeType

class TestBuildTree(unittest.TestCase):
    
    def compare_trees(self, node1, node2):
        if node1 is None and node2 is None:
            return True
        if node1 is None or node2 is None:
            return False
        return (node1.value == node2.value and
                self.compare_trees(node1.left, node2.left) and
                self.compare_trees(node1.right, node2.right))

    def testCase01(self):
        input_str = "|(&(A, B), |(A, C))"
        result = BuildTree(input_str)
        
        expected_tree = BinaryExpressionTreeNode("OR")
        expected_tree.left = BinaryExpressionTreeNode("AND")
        expected_tree.left.left = BinaryExpressionTreeNode("A")
        expected_tree.left.right = BinaryExpressionTreeNode("B")
        expected_tree.right = BinaryExpressionTreeNode("OR")
        expected_tree.right.left = BinaryExpressionTreeNode("A")
        expected_tree.right.right = BinaryExpressionTreeNode("C")
        
        self.assertTrue(self.compare_trees(result, expected_tree))
    
    def testCase02(self):
        input_str = "&(A, B)"
        result = BuildTree(input_str)
        
        expected_tree = BinaryExpressionTreeNode("AND")
        expected_tree.left = BinaryExpressionTreeNode("A")
        expected_tree.right = BinaryExpressionTreeNode("B")
        
        self.assertTrue(self.compare_trees(result, expected_tree))
    
    def testCase03(self):
        input_str = "|(A, B)"
        result = BuildTree(input_str)
        
        expected_tree = BinaryExpressionTreeNode("OR")
        expected_tree.left = BinaryExpressionTreeNode("A")
        expected_tree.right = BinaryExpressionTreeNode("B")
        
        self.assertTrue(self.compare_trees(result, expected_tree))

if __name__ == '__main__':
    unittest.main()
