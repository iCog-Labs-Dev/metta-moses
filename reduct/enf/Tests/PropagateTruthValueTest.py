import unittest

from ..Utilities.PropagateTruthValue import propagateTruthValue
from ..DataStructures.Trees import BinaryExpressionTreeNode, TreeNode, NodeType

def print_tree(node, level=0):
        if node is not None:
            print(" " * (level * 4) + f"Value: {node.value}, Type: {node.type}, Constraint: {getattr(node, 'constraint', None)}, Children: {node.children}, GuardSet: {node.guardSet}")
            print_tree(node.left, level + 1)
            print_tree(node.right, level + 1)

class TestPropagateTruthValue(unittest.TestCase):
    
    def compare_trees(self, node1, node2):
        if node1 is None and node2 is None:
            return True
        if node1 is None or node2 is None:
            return False
        return (node1.value == node2.value and
                node1.type == node2.type and
                node1.children == node2.children and
                node1.constraint == node2.constraint and
                node1.guardSet == node2.guardSet and
                self.compare_trees(node1.left, node2.left) and
                self.compare_trees(node1.right, node2.right))
  

    def testCase01(self):
        # (OR(AND(A, B), OR(A, C)))

        input_tree = BinaryExpressionTreeNode("ROOT")
        input_tree.type = NodeType.ROOT
        input_tree.value = "ROOT"

        input_tree.left = None

        input_tree.right = BinaryExpressionTreeNode("OR")
        input_tree.right.type = NodeType.OR
        input_tree.right.value = "OR"

        input_tree.right.left = BinaryExpressionTreeNode("AND")
        input_tree.right.left.type = NodeType.AND
        input_tree.right.left.value = "AND"

        input_tree.right.left.left = BinaryExpressionTreeNode("A")
        input_tree.right.left.left.type = NodeType.LITERAL
        input_tree.right.left.left.value = "A"

        input_tree.right.left.right = BinaryExpressionTreeNode("B")
        input_tree.right.left.right.type = NodeType.LITERAL
        input_tree.right.left.right.value = "B"

        input_tree.right.right = BinaryExpressionTreeNode("OR")
        input_tree.right.right.type = NodeType.OR
        input_tree.right.right.value = "OR"

        input_tree.right.right.left = BinaryExpressionTreeNode("A")
        input_tree.right.right.left.type = NodeType.LITERAL
        input_tree.right.right.left.value = "A"

        input_tree.right.right.right = BinaryExpressionTreeNode("C")
        input_tree.right.right.right.type = NodeType.LITERAL
        input_tree.right.right.right.value = "C"

        result = propagateTruthValue(input_tree, True)

        expected_tree = TreeNode("ROOT")
        expected_tree.type = NodeType.ROOT
        expected_tree.constraint = False
        expected_tree.value = "ROOT"
        expected_tree.children = []
        expected_tree.guardSet = []

        expected_tree.left = None

        expected_tree.right = TreeNode("OR")
        expected_tree.right.type = NodeType.OR
        expected_tree.right.constraint = False
        expected_tree.right.value = "OR"
        expected_tree.right.children = []
        expected_tree.right.guardSet = []

        expected_tree.right.left = TreeNode("AND")
        expected_tree.right.left.value = "AND"
        expected_tree.right.left.type = NodeType.AND
        expected_tree.right.left.constraint = False
        expected_tree.right.left.children = []
        expected_tree.right.left.guardSet = []

        expected_tree.right.left.left = TreeNode("A")
        expected_tree.right.left.left.type = NodeType.LITERAL
        expected_tree.right.left.left.constraint = True
        expected_tree.right.left.left.value = "A"
        expected_tree.right.left.left.children = []
        expected_tree.right.left.left.guardSet = []

        expected_tree.right.left.right = TreeNode("B")
        expected_tree.right.left.right.type = NodeType.LITERAL
        expected_tree.right.left.right.constraint = True
        expected_tree.right.left.right.value = "B"
        expected_tree.right.left.right.children = []
        expected_tree.right.left.right.guardSet = []

        expected_tree.right.right = TreeNode("OR")
        expected_tree.right.right.type = NodeType.OR
        expected_tree.right.right.value = "OR"
        expected_tree.right.right.constraint = False
        expected_tree.right.right.children = []
        expected_tree.right.right.guardSet = []

        expected_tree.right.right.left = TreeNode("A")
        expected_tree.right.right.left.type = NodeType.LITERAL
        expected_tree.right.right.left.constraint = True
        expected_tree.right.right.left.value = "A"
        expected_tree.right.right.left.children = []
        expected_tree.right.right.left.guardSet = []

        expected_tree.right.right.right = TreeNode("C")
        expected_tree.right.right.right.type = NodeType.LITERAL
        expected_tree.right.right.right.constraint = True
        expected_tree.right.right.right.value = "C"
        expected_tree.right.right.right.children = []
        expected_tree.right.right.right.guardSet = []

        self.assertTrue(self.compare_trees(result, expected_tree))

    
    def testCase02(self):
        #(AND(A, B))


        input_tree = BinaryExpressionTreeNode("ROOT")
        input_tree.type = NodeType.ROOT
        input_tree.value = "ROOT"

        input_tree.left = None

        input_tree.right = BinaryExpressionTreeNode("AND")
        input_tree.right.type = NodeType.AND
        input_tree.right.value = "AND"



        input_tree.right.left = BinaryExpressionTreeNode("A")
        input_tree.right.left.type = NodeType.LITERAL
        input_tree.right.left.value = "A"

        input_tree.right.right = BinaryExpressionTreeNode("B")
        input_tree.right.right.type = NodeType.LITERAL
        input_tree.right.right.value = "B"


        
        result = propagateTruthValue(input_tree, True)
        
        expected_tree = TreeNode("ROOT")
        expected_tree.type = NodeType.ROOT
        expected_tree.constraint = False
        expected_tree.value = "ROOT"
        expected_tree.children = []
        expected_tree.guardSet = []

        expected_tree.left = None

        expected_tree.right = TreeNode("AND")
        expected_tree.right.type = NodeType.AND
        expected_tree.right.constraint = False
        expected_tree.right.value = "AND"
        expected_tree.right.children = []
        expected_tree.right.guardSet = []

        expected_tree.right.left = TreeNode("A")
        expected_tree.right.left.type = NodeType.LITERAL
        expected_tree.right.left.value = "A"
        expected_tree.right.left.constraint = True
        expected_tree.right.left.children = []
        expected_tree.right.left.guardSet = []

        expected_tree.right.right = TreeNode("B")
        expected_tree.right.right.type = NodeType.LITERAL
        expected_tree.right.right.value = "B"
        expected_tree.right.right.constraint = True
        expected_tree.right.right.children = []
        expected_tree.right.right.guardSet = []

        
        self.assertTrue(self.compare_trees(result, expected_tree))
    
    def testCase03(self):
        # (NOT(A))

        input_tree = BinaryExpressionTreeNode("ROOT")
        input_tree.type = NodeType.ROOT
        input_tree.value = "ROOT"

        input_tree.left = None

        input_tree.right = BinaryExpressionTreeNode("NOT")
        input_tree.right.type = NodeType.NOT
        input_tree.right.value = "NOT"

        input_tree.right.right = BinaryExpressionTreeNode("A")
        input_tree.right.right.type = NodeType.LITERAL
        input_tree.right.right.value = "A"

        result = propagateTruthValue(input_tree, True)

        expected_tree = TreeNode("ROOT")
        expected_tree.type = NodeType.ROOT
        expected_tree.value = "ROOT"
        expected_tree.children = []
        expected_tree.guardSet = []
        expected_tree.constraint = False

        expected_tree.left = None

        expected_tree.right = TreeNode("A")
        expected_tree.right.type = NodeType.LITERAL
        expected_tree.right.constraint = False
        expected_tree.right.value = "A"
        expected_tree.right.children = []
        expected_tree.right.guardSet = []

        self.assertTrue(self.compare_trees(result, expected_tree))


if __name__ == '__main__':
    unittest.main()
