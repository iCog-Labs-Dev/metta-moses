import unittest
from DataStructures.Trees import TreeNode, NodeType
from Utilities.GatherJunctors import gatherJunctors


def print_tree(node, level=0):
    if node is not None:
        indent = "  " * level
        print(f"{indent}{node.value} (Type: {node.type}, Constraint: {node.constraint})")
        
        if node.guardSet:
            print(f"{indent}  GuardSet:")
            for guard in node.guardSet:
                print(f"{indent}    - {guard.value} (Type: {guard.type})")
        
        if node.children:
            print(f"{indent}  Children:")
            for child in node.children:
                print_tree(child, level + 1)
        
        print_tree(node.left, level + 1)
        print_tree(node.right, level + 1)

# Example usage within your test case:

def compare_trees(node1, node2):
    if node1 is None and node2 is None:
        return True
    if node1 is None or node2 is None:
        print(f"Node mismatch: node1={node1}, node2={node2}")
        return False
    if node1.value != node2.value or node1.type != node2.type or node1.constraint != node2.constraint:
        print(f"Attribute mismatch: value1={node1.value}, value2={node2.value}, "
              f"type1={node1.type}, type2={node2.type}, "
              f"constraint1={node1.constraint}, constraint2={node2.constraint}")
        return False
    if len(node1.children) != len(node2.children):
        print(f"Children length mismatch: len1={len(node1.children)}, len2={len(node2.children)}")
        return False
    if len(node1.guardSet) != len(node2.guardSet):
        print(f"GuardSet length mismatch: len1={len(node1.guardSet)}, len2={len(node2.guardSet)}")
        return False
    for child1, child2 in zip(node1.children, node2.children):
        if not compare_trees(child1, child2):
            return False
    for guard1, guard2 in zip(node1.guardSet, node2.guardSet):
        if not compare_trees(guard1, guard2):
            return False
    return compare_trees(node1.left, node2.left) and compare_trees(node1.right, node2.right)


class TestGatherJunctors(unittest.TestCase):


    def testCase01(self):
        # Initial tree setup
        input_tree = TreeNode("ROOT")
        input_tree.type = NodeType.ROOT
        input_tree.children = []
        input_tree.guardSet = []
        input_tree.value = "ROOT"
        input_tree.constraint = False

        input_tree.left = None

        input_tree.right = TreeNode("OR")
        input_tree.right.type = NodeType.OR
        input_tree.right.value = "OR"
        input_tree.right.children = []
        input_tree.right.guardSet = []
        input_tree.right.constraint = False


        input_tree.right.left = TreeNode("A")
        input_tree.right.left.type = NodeType.LITERAL
        input_tree.right.left.value = "A"
        input_tree.right.left.children = []
        input_tree.right.left.guardSet = []
        input_tree.right.left.constraint = True

        input_tree.right.right = TreeNode("B")
        input_tree.right.right.type = NodeType.LITERAL
        input_tree.right.right.value = "B"
        input_tree.right.right.guardSet = []
        input_tree.right.right.children = []
        input_tree.right.right.constraint = True

        # Expected tree after gatherJunctors
        expected_tree = TreeNode("AND")
        expected_tree.type = NodeType.AND
        expected_tree.guardSet = []
        expected_tree.value = "AND"
        expected_tree.children = []
        expected_tree.constraint = False

        child_or = TreeNode("OR")
        child_or.type = NodeType.OR
        child_or.value = "OR"
        child_or.constraint = False
        child_or.guardSet = []

        node_A = TreeNode("A")
        node_A.type = NodeType.LITERAL
        node_A.value = "A"
        node_A.constraint = True
        node_A.children = []
        node_A.guardSet = []

        node_B = TreeNode("B")
        node_B.type = NodeType.LITERAL
        node_B.value = "B"
        node_B.constraint = True
        node_B.children = []
        node_B.guardSet = []

        guard_set_AND_A = TreeNode("AND")
        guard_set_AND_A.value = "AND"
        guard_set_AND_A.type = NodeType.AND
        guard_set_AND_A.guardSet = [node_A]
        guard_set_AND_A.children = []
        guard_set_AND_A.constraint = True

        guard_set_AND_B = TreeNode("AND")
        guard_set_AND_B.type = NodeType.AND
        guard_set_AND_B.value = "AND"
        guard_set_AND_B.children = []
        guard_set_AND_B.guardSet = [node_B]
        guard_set_AND_B.constraint = True

        child_or.children = [guard_set_AND_A, guard_set_AND_B]

        expected_tree.children.append(child_or)

        centerNode = TreeNode("ROOT")
        centerNode.type = NodeType.ROOT

        # Process tree using gatherJunctors
        result = gatherJunctors(input_tree, centerNode)

        # print("Expected Tree:")
        # print_tree(expected_tree)
        # print("\nResult Tree:")
        # print_tree(result)

        # Test
        self.assertTrue(compare_trees(result, expected_tree))
        

    def testCase02(self):
        # Initial tree setup
        # (AND (OR A B) C)
        input_tree = TreeNode("ROOT")
        input_tree.type = NodeType.ROOT
        input_tree.children = []
        input_tree.guardSet = []
        input_tree.value = "ROOT"
        input_tree.constraint = False

        input_tree.left = None

        input_tree.right = TreeNode("AND")
        input_tree.right.type = NodeType.AND
        input_tree.right.value = "AND"
        input_tree.right.constraint = False
        input_tree.right.guardSet = []
        input_tree.right.children = []


        input_tree.right.left = TreeNode("OR")
        input_tree.right.left.type = NodeType.OR
        input_tree.right.left.value = "OR"
        input_tree.right.left.constraint = False
        input_tree.right.left.guardSet = []
        input_tree.right.left.children = []


        input_tree.right.left.left = TreeNode("A")
        input_tree.right.left.left.type = NodeType.LITERAL
        input_tree.right.left.left.value = "A"
        input_tree.right.left.left.constraint = True
        input_tree.right.left.left.guardSet = []
        input_tree.right.left.left.children = []


        input_tree.right.left.right = TreeNode("B")
        input_tree.right.left.right.type = NodeType.LITERAL
        input_tree.right.left.right.value = "B"
        input_tree.right.left.right.constraint = True
        input_tree.right.left.right.guardSet = []
        input_tree.right.left.right.children = []


        input_tree.right.right = TreeNode("C")
        input_tree.right.right.type = NodeType.LITERAL
        input_tree.right.right.value = "C"
        input_tree.right.right.constraint = True
        input_tree.right.right.guardSet = []
        input_tree.right.right.children = []


        # Expected tree after gatherJunctors
        expected_tree = TreeNode("AND")
        expected_tree.type = NodeType.AND
        expected_tree.value = "AND"
        expected_tree.constraint = False
        expected_tree.guardSet = []
        expected_tree.children = []

        child_or = TreeNode("OR")
        child_or.type = NodeType.OR
        child_or.value = "OR"
        child_or.constraint = False
        child_or.guardSet = []

        node_A = TreeNode("A")
        node_A.type = NodeType.LITERAL
        node_A.value = "A"
        node_A.constraint = True
        node_A.guardSet = []

        node_B = TreeNode("B")
        node_B.type = NodeType.LITERAL
        node_B.value = "B"
        node_B.constraint = True
        node_B.guardSet = []

        guard_set_A = TreeNode("AND")
        guard_set_A.value = "AND"
        guard_set_A.type = NodeType.AND
        guard_set_A.children = []
        guard_set_A.guardSet = [node_A]
        guard_set_A.constraint = True

        guard_set_B = TreeNode("AND")
        guard_set_B.value = "AND"
        guard_set_B.type = NodeType.AND
        guard_set_B.children = []
        guard_set_B.guardSet = [node_B]
        guard_set_B.constraint = True

        child_or.guardSet = []
        child_or.children = [guard_set_A, guard_set_B]

        expected_tree.children.append(child_or)
        expected_tree.guardSet.append(input_tree.right.right)

        # Process tree using gatherJunctors
        centerNode = TreeNode("ROOT")
        centerNode.type = NodeType.ROOT

        result = gatherJunctors(input_tree, centerNode)

        # print("Expected Tree:")
        # print_tree(expected_tree)
        # print("\nResult Tree:")
        # print_tree(result)

        # Test
        # print("\n\n before running assert")
        self.assertTrue(compare_trees(result, expected_tree))

        # print("\n\n after running assert")


    def testCase03(self):
        # Initial tree setup
        input_tree = TreeNode("ROOT")
        input_tree.type = NodeType.ROOT
        input_tree.children = []
        input_tree.guardSet = []
        input_tree.value = "ROOT"
        input_tree.constraint = False

        input_tree.left = None

        input_tree.right = TreeNode("AND")
        input_tree.right.type = NodeType.AND
        input_tree.right.value = "AND"
        input_tree.right.constraint = False
        input_tree.right.guardSet = []

        input_tree.right.left = TreeNode("AND")
        input_tree.right.left.type = NodeType.AND
        input_tree.right.left.value = "AND"
        input_tree.right.left.constraint = False
        input_tree.right.left.guardSet = []

        input_tree.right.left.left = TreeNode("A")
        input_tree.right.left.left.type = NodeType.LITERAL
        input_tree.right.left.left.value = "A"
        input_tree.right.left.left.constraint = True
        input_tree.right.left.left.guardSet = []

        input_tree.right.left.right = TreeNode("B")
        input_tree.right.left.right.type = NodeType.LITERAL
        input_tree.right.left.right.value = "B"
        input_tree.right.left.right.constraint = True
        input_tree.right.left.right.guardSet = []

        input_tree.right.right = TreeNode("OR")
        input_tree.right.right.type = NodeType.OR
        input_tree.right.right.value = "OR"
        input_tree.right.right.constraint = False
        input_tree.right.right.guardSet = []

        input_tree.right.right.left = TreeNode("C")
        input_tree.right.right.left.type = NodeType.LITERAL
        input_tree.right.right.left.value = "C"
        input_tree.right.right.left.constraint = True
        input_tree.right.right.left.guardSet = []

        input_tree.right.right.right = TreeNode("D")
        input_tree.right.right.right.type = NodeType.LITERAL
        input_tree.right.right.right.value = "D"
        input_tree.right.right.right.constraint = True
        input_tree.right.right.right.guardSet = []

        # Expected tree after gatherJunctors
        expected_tree = TreeNode("AND")
        expected_tree.type = NodeType.AND
        expected_tree.value = "AND"
        expected_tree.constraint = False
        expected_tree.guardSet = []
        expected_tree.children = []
        
        node_A = TreeNode("A")
        node_A.type = NodeType.LITERAL
        node_A.value = "A"
        node_A.constraint = True
        node_A.guardSet = []

        node_B = TreeNode("B")
        node_B.type = NodeType.LITERAL
        node_B.value = "B"
        node_B.constraint = True
        node_B.guardSet = []

        child_or = TreeNode("OR")
        child_or.type = NodeType.OR
        child_or.value = "OR"
        child_or.constraint = False
        child_or.guardSet = []

        node_C = TreeNode("C")
        node_C.type = NodeType.LITERAL
        node_C.value = "C"
        node_C.constraint = True
        node_C.guardSet = []

        node_D = TreeNode("D")
        node_D.type = NodeType.LITERAL
        node_D.value = "D"
        node_D.constraint = True
        node_D.guardSet = []

        node_and_C = TreeNode("AND")
        node_and_C.type = NodeType.AND
        node_and_C.value = "AND"
        node_and_C.constraint = True
        node_and_C.guardSet = [node_C]

        node_and_D = TreeNode("AND")
        node_and_D.type = NodeType.AND
        node_and_D.value = "AND"
        node_and_D.constraint = True
        node_and_D.guardSet = [node_D]


        child_or.guardSet = []
        child_or.children = [node_and_C, node_and_D]

        expected_tree.guardSet = [node_A, node_B]
        expected_tree.children.append(child_or)

        # Process tree using gatherJunctors
        centerNode = TreeNode("ROOT")
        centerNode.type = NodeType.ROOT

        result = gatherJunctors(input_tree, centerNode)

        # print("Expected Tree:")
        # print_tree(expected_tree)
        # print("\nResult Tree:")
        # print_tree(result)

        # Test
        # print("\n\n before running assert")
        self.assertTrue(compare_trees(result, expected_tree))
        # print("\n\n after running assert")


if __name__ == '__main__':
    unittest.main()
