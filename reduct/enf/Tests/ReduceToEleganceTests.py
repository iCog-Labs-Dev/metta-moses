import unittest

from DataStructures.Trees import (
    TreeNode,
    NodeType,
    findAndRemoveChild,
)
from Utilities.ReduceToElegance import (
    compareSets,
    commandSetIterator,
    containsTerminalAndNode,
    applyOrCut,
    applyAndCut,
    intersections,
    computeGrandChildGuardSet,
    orSubTreeElegance,
    andSubTreeElegance,
    orSubTreeIterator,
    andSubTreeIterator,
    iterator,
    reduceToElegance,
    ReductionSignal,
    IterationSignal,
)


class TestReduceToElegance(unittest.TestCase):
    def setUp(self):
        # Sample TreeNodes for testing
        self.node1 = TreeNode("A")
        self.node1.type = NodeType.LITERAL
        self.node1.value = "A"
        self.node1.constraint = True
        self.node1.guardSet = []

        self.node2 = TreeNode("B")
        self.node2.type = NodeType.LITERAL
        self.node2.value = "B"
        self.node2.constraint = True
        self.node2.guardSet = []

        self.node3 = TreeNode("C")
        self.node3.type = NodeType.LITERAL
        self.node3.value = "C"
        self.node3.constraint = True
        self.node3.guardSet = []

        self.node4 = TreeNode("D")
        self.node4.type = NodeType.AND
        self.node4.value = "D"
        self.node4.constraint = True
        self.node4.guardSet = [TreeNode("G1")]
        self.node4.children = []

        self.node5 = TreeNode("E")
        self.node5.type = NodeType.AND
        self.node5.value = "E"
        self.node5.constraint = True
        self.node5.guardSet = [TreeNode("G2")]
        self.node5.children = []

        self.node6 = TreeNode("F")
        self.node6.type = NodeType.OR
        self.node6.value = "F"
        self.node6.constraint = True
        self.node6.guardSet = []
        self.node6.children = [self.node4, self.node5]

        self.node7 = TreeNode("H")
        self.node7.type = NodeType.OR
        self.node7.value = "H"
        self.node7.constraint = True
        self.node7.guardSet = []
        self.node7.children = []

        self.node8 = TreeNode("I")
        self.node8.type = NodeType.AND
        self.node8.value = "I"
        self.node8.constraint = True
        self.node8.guardSet = [TreeNode("G3")]
        self.node8.children = [self.node7]

        self.node9 = TreeNode("J")
        self.node9.type = NodeType.OR
        self.node9.value = "J"
        self.node9.constraint = True
        self.node9.guardSet = []
        self.node9.children = [self.node8]

        self.node10 = TreeNode("K")
        self.node10.type = NodeType.AND
        self.node10.value = "K"
        self.node10.constraint = True
        self.node10.guardSet = []
        self.node10.children = [self.node9]

        self.node11 = TreeNode("L")
        self.node11.type = NodeType.AND
        self.node11.value = "L"
        self.node11.constraint = True
        self.node11.guardSet = []
        self.node11.children = []

        # Node with one child but a non-empty guardSet
        self.node12 = TreeNode("M")
        self.node12.type = NodeType.AND
        self.node12.value = "M"
        self.node12.constraint = True
        self.node12.guardSet = [TreeNode("G4")]
        self.node12.children = [self.node3]

        # Node with a non-empty guardSet and no children
        self.node13 = TreeNode("N")
        self.node13.type = NodeType.AND
        self.node13.value = "N"
        self.node13.constraint = True
        self.node13.guardSet = [TreeNode("G5")]
        self.node13.children = []

        # Node with children but no guardSet
        self.node14 = TreeNode("O")
        self.node14.type = NodeType.AND
        self.node14.value = "O"
        self.node14.constraint = True
        self.node14.guardSet = []
        self.node14.children = [self.node1, self.node2]

        self.node15 = TreeNode("P")
        self.node15.type = NodeType.AND
        self.node15.value = "P"
        self.node15.constraint = True
        self.node15.guardSet = []
        self.node15.children = []

        # Node with a guardSet that will intersect with a commandSet (for testing deletion)
        self.node16 = TreeNode("Q")
        self.node16.type = NodeType.AND
        self.node16.value = "Q"
        self.node16.constraint = True
        self.node16.guardSet = [TreeNode("G6")]
        self.node16.children = []

        # Node for testing OR-subtree iteration
        self.node17 = TreeNode("R")
        self.node17.type = NodeType.OR
        self.node17.value = "R"
        self.node17.constraint = True
        self.node17.guardSet = []
        self.node17.children = [self.node15, self.node16]

        # Node for testing AND-subtree iteration
        self.node18 = TreeNode("S")
        self.node18.type = NodeType.AND
        self.node18.value = "S"
        self.node18.constraint = True
        self.node18.guardSet = []
        self.node18.children = [self.node15, self.node16]

        self.node19 = TreeNode("C")
        self.node19.type = NodeType.LITERAL
        self.node19.value = "C"
        self.node19.constraint = False
        self.node19.guardSet = [
            TreeNode("G1", constraint=True),
            TreeNode("G2", constraint=False),
        ]
        self.node19.children = [TreeNode("D", constraint=True)]

        self.node20 = TreeNode("B")
        self.node20.type = NodeType.OR
        self.node20.value = "B"
        self.node20.constraint = False
        self.node20.guardSet = []
        self.node20.children = [self.node19]

        self.node21 = TreeNode("A")
        self.node21.type = NodeType.AND
        self.node21.value = "A"
        self.node21.constraint = True
        self.node21.guardSet = [TreeNode("G0", constraint=True)]
        self.node21.children = [TreeNode("E", constraint=False)]

        self.node22 = TreeNode("A")
        self.node22.type = NodeType.LITERAL
        self.node22.value = "A"
        self.node22.constraint = True
        self.node22.guardSet = []

        # AND Node with one terminal child and a single guardSet
        self.node23 = TreeNode("B")
        self.node23.type = NodeType.AND
        self.node23.value = "B"
        self.node23.constraint = False
        self.node23.guardSet = [self.node1]  # GuardSet with a single constraint (node1)
        self.node23.children = []

        # AND Node with children but no terminal node
        self.node24 = TreeNode("C")
        self.node24.type = NodeType.AND
        self.node24.value = "C"
        self.node24.constraint = False
        self.node24.guardSet = []
        self.node24.children = [
            self.node1
        ]  # Non-terminal child (node1 has no children)

        # OR Node with terminal child and guardSet
        self.node25 = TreeNode("D")
        self.node25.type = NodeType.OR
        self.node25.value = "D"
        self.node25.constraint = False
        self.node25.guardSet = [self.node1]
        self.node25.children = []

        # AND Node with no children and multiple guardSets
        self.node26 = TreeNode("E")
        self.node26.type = NodeType.AND
        self.node26.value = "E"
        self.node26.constraint = False
        self.node26.guardSet = [self.node1, self.node3]  # Multiple guardSets
        self.node26.children = []

        # AND Node with terminal child and no guardSet
        self.node27 = TreeNode("F")
        self.node27.type = NodeType.AND
        self.node27.value = "F"
        self.node27.constraint = False
        self.node27.guardSet = []
        self.node27.children = []

        self.nodeA = TreeNode("A")
        self.nodeA.type = NodeType.LITERAL
        self.nodeA.constraint = True

        self.nodeB = TreeNode("B")
        self.nodeB.type = NodeType.LITERAL
        self.nodeB.constraint = True

        self.nodeC = TreeNode("C")
        self.nodeC.type = NodeType.LITERAL
        self.nodeC.constraint = True

        self.nodeD = TreeNode("D")
        self.nodeD.type = NodeType.LITERAL
        self.nodeD.constraint = True

        # Child nodes with guardSets
        self.node28 = TreeNode("AND")
        self.node28.type = NodeType.AND
        self.node28.guardSet = [self.nodeA, self.nodeB]

        self.node29 = TreeNode("AND")
        self.node29.type = NodeType.AND
        self.node29.guardSet = [self.nodeA, self.nodeC]

        self.node30 = TreeNode("AND")
        self.node30.type = NodeType.AND
        self.node30.guardSet = [self.nodeB, self.nodeD]

    def test_empty_children(self):
        # Test with no children
        result = intersections([])  # Pass only the required argument
        self.assertEqual(result, [])

    def test_single_child(self):
        # Test with a single child
        result = intersections([self.node28])  # Pass only the required argument
        self.assertEqual(result, self.node28.guardSet)

    def test_all_nodes_intersect(self):
        # Test where there is a common intersection (e.g., nodeA)
        node4 = TreeNode("AND")
        node4.type = NodeType.AND
        node4.guardSet = [self.nodeA, self.nodeD]

        result = intersections(
            [self.node28, self.node29, node4]
        )  # Pass only the required argument
        self.assertEqual(result, [self.nodeA])

    def test_no_intersection(self):
        # Test where there is no intersection (no common node in guardSets)
        result = intersections(
            [self.node28, self.node30]
        )  # Pass only the required argument
        self.assertEqual(result, [self.nodeB])

    def test_partial_intersection(self):
        # Test where some but not all nodes intersect (e.g., nodeB)
        node4 = TreeNode("AND")
        node4.type = NodeType.AND
        node4.guardSet = [self.nodeB, self.nodeD]

        result = intersections([self.node28, node4])  # Pass only the required argument
        self.assertEqual(result, [self.nodeB])

    def test_single_terminal_and_node_with_single_guardset(self):
        self.assertTrue(
            containsTerminalAndNode([self.node23]),
            "Should return True for AND node with terminal child and single guardSet",
        )

    def test_single_and_node_with_non_terminal_child(self):
        self.assertFalse(
            containsTerminalAndNode([self.node24]),
            "Should return False for AND node with non-terminal child",
        )

    def test_single_or_node_with_terminal_child(self):
        self.assertFalse(
            containsTerminalAndNode([self.node25]),
            "Should return False for OR node even with terminal child",
        )

    def test_single_and_node_with_multiple_guardsets(self):
        self.assertFalse(
            containsTerminalAndNode([self.node26]),
            "Should return False for AND node with multiple guardSets",
        )

    def test_single_and_node_with_terminal_child_no_guardset(self):
        self.assertFalse(
            containsTerminalAndNode([self.node27]),
            "Should return False for AND node with no guardSet",
        )

    def test_multiple_children_with_one_matching(self):
        children = [self.node24, self.node23, self.node25]
        self.assertTrue(
            containsTerminalAndNode(children),
            "Should return True if any child matches the condition",
        )

    def test_multiple_children_none_matching(self):
        children = [self.node24, self.node25, self.node26]
        self.assertFalse(
            containsTerminalAndNode(children),
            "Should return False if no child matches the condition",
        )

    def test_orSubTreeElegance(self):
        # Adjust the dominantSet and localCommandSet to trigger DELETE
        dominantSet = [TreeNode("G7")]
        localCommandSet = [TreeNode("G6")]

        # Set node16's guardSet to intersect with localCommandSet for triggering DELETE
        self.node16.guardSet = [TreeNode("G6")]

        # Invoke orSubTreeElegance and check for DELETE outcome
        result = orSubTreeElegance(
            self.node17, self.node16, self.node17, dominantSet, localCommandSet
        )
        self.assertEqual(result, ReductionSignal.DISCONNECT)

    def test_andSubTreeElegance(self):
        handleSet = [TreeNode("G6")]
        commandSet = [TreeNode("G7")]
        result = andSubTreeElegance(
            self.node18, self.node16, self.node18, handleSet, commandSet
        )
        self.assertEqual(result, IterationSignal.ADVANCE)

    def test_orSubTreeIterator(self):
        dominantSet = [TreeNode("G5")]
        commandSet = [TreeNode("G6")]
        result = orSubTreeIterator(
            self.node15, self.node17.children[1:], self.node17, dominantSet, commandSet
        )
        self.assertEqual(
            result, ReductionSignal.DISCONNECT
        )  # Should return None at the end of iteration

    def test_andSubTreeIterator(self):
        handleSet = [TreeNode("G6")]
        commandSet = [TreeNode("G7")]
        result = andSubTreeIterator(
            self.node18, self.node18.children, self.node18, handleSet, commandSet
        )
        self.assertIsNone(result)  # Should return None if no ReductionSignal is found

    def test_iterator(self):
        dominantSet = [TreeNode("G5")]
        commandSet = [TreeNode("G6")]
        result = iterator(self.node17, self.node17, dominantSet, commandSet)
        self.assertIsNone(result)  # Should return None if no ReductionSignal is found

    def test_reduceToElegance(self):
        dominantSet = [TreeNode("G5")]
        commandSet = [TreeNode("G6")]
        result = reduceToElegance(self.node17, self.node16, dominantSet, commandSet)
        self.assertEqual(result, ReductionSignal.DISCONNECT)

    def test_applyAndCut_single_child_empty_guardSet(self):
        # Node with one child and empty guardSet
        result = applyAndCut(self.node14, self.node10)

        # Check that the function returns False since child should not be removed
        self.assertFalse(result)
        self.assertEqual(len(self.node10.children), 1)

    def test_applyAndCut_no_children_empty_guardSet(self):
        # Node with no children and an empty guardSet
        result = applyAndCut(self.node11, self.node10)

        # Should return False since grandChild has no children
        self.assertFalse(result)
        self.assertEqual(self.node10.children, [self.node9])

    def test_applyAndCut_non_empty_guardSet(self):
        # Node with one child but a non-empty guardSet
        result = applyAndCut(self.node12, self.node10)

        # Should return False as the guardSet is not empty
        self.assertFalse(result)

    def test_computeGrandChildGuardSet_difference(self):
        # Node with a non-empty guardSet
        resultSet = [TreeNode("G5")]
        computeGrandChildGuardSet(self.node13, resultSet)

        # GuardSet should now be empty after the difference
        self.assertEqual(self.node13.guardSet, [])

    def test_computeGrandChildGuardSet_no_difference(self):
        grandChild = TreeNode("G")
        grandChild.type = NodeType.LITERAL
        grandChild.guardSet = [self.node1]

        resultSet = [self.node2]

        computeGrandChildGuardSet(grandChild, resultSet)

        # The guardSet should remain unchanged as there's no intersection with resultSet
        self.assertEqual(grandChild.guardSet, [self.node1])

    def test_computeGrandChildGuardSet_empty_guardSet(self):
        grandChild = TreeNode("G")
        grandChild.type = NodeType.LITERAL
        grandChild.guardSet = []

        resultSet = [self.node2]

        computeGrandChildGuardSet(grandChild, resultSet)

        # The guardSet should remain empty
        self.assertEqual(grandChild.guardSet, [])

    def test_computeGrandChildGuardSet_basic(self):
        grandChild = TreeNode("G")
        grandChild.type = NodeType.LITERAL
        grandChild.guardSet = [self.node1, self.node2]

        resultSet = [self.node2]

        computeGrandChildGuardSet(grandChild, resultSet)

        # The guardSet should now only contain node1
        self.assertEqual(grandChild.guardSet, [self.node1])

    def test_applyOrCut_basic(self):
        # Testing applyOrCut with simple nodes
        current = TreeNode("L")
        current.type = NodeType.AND
        current.constraint = True
        current.guardSet = []
        current.children = [self.node8]

        applyOrCut(self.node8, current)

        # After applyOrCut, current's guardSet should remain empty because node7 has no guardSet
        self.assertEqual(current.guardSet, [])

        # After applyOrCut, current's children should still contain node8 because node7 doesn't change it
        self.assertEqual(current.children, [])

    def test_applyOrCut_multiple_children(self):
        # Testing applyOrCut when current has multiple children
        current = TreeNode("M")
        current.type = NodeType.AND
        current.constraint = True
        current.guardSet = []
        current.children = [self.node8, self.node9]

        applyOrCut(self.node8, current)

        # After applyOrCut, current's guardSet should include the guardSet of node8 (G3)
        self.assertEqual(current.guardSet, [])

        # After applyOrCut, the current node should still have two children: node8 and node9
        self.assertEqual(len(current.children), 1)

        # Check that the first child is still node8
        self.assertEqual(current.children[0].value, "J")

    def test_applyorcut(self):
        applyOrCut(self.node20, self.node21)

        # Create expected guardSet
        expected_guardSet = [
            TreeNode(value="G0", constraint=True),
            TreeNode(value="G1", constraint=True),
            TreeNode(value="G2", constraint=False),
        ]

        # Create expected children
        expected_children = [
            TreeNode(value="D", constraint=True),
            TreeNode(value="E", constraint=False),
        ]

        # Perform assertions
        self.assertEqual(self.node21.guardSet, expected_guardSet)
        self.assertEqual(self.node21.children, expected_children)

    def test_commandSetIterator_with_terminal_AND_node(self):
        children = [self.node4, self.node5, self.node6]
        result = commandSetIterator(self.node1, children, [])
        expected = [TreeNode("G1"), TreeNode("G2")]
        self.assertEqual(
            [node.value for node in result], [node.value for node in expected]
        )

    def test_commandSetIterator_without_terminal_AND_node(self):
        children = [self.node6]
        result = commandSetIterator(self.node1, children, [])
        self.assertEqual(result, [])

    def test_commandSetIterator_empty_children(self):
        result = commandSetIterator(
            self.node1, [], []
        )  # Passing node1 since it value doesn't really matter for this test
        self.assertEqual(result, [])

    def test_containsTerminalAndNode_true(self):
        children = [self.node4, self.node5]
        result = containsTerminalAndNode(children)
        self.assertTrue(result)

    def test_containsTerminalAndNode_false(self):
        children = [self.node6]
        result = containsTerminalAndNode(children)
        self.assertFalse(result)

    def test_containsTerminalAndNode_empty_children(self):
        result = containsTerminalAndNode([])
        self.assertFalse(result)

    def test_compareSets_identical_sets(self):
        set1 = [self.node1, self.node2, self.node3]
        set2 = [self.node1, self.node2, self.node3]
        result = compareSets(set1, set2)
        self.assertTrue(result)

    def test_compareSets_different_sets(self):
        set1 = [self.node1, self.node2, self.node3]
        set2 = [self.node1, self.node3]
        result = compareSets(set1, set2)
        self.assertFalse(result)

    def test_compareSets_empty_sets(self):
        set1 = []
        set2 = []
        result = compareSets(set1, set2)
        self.assertTrue(result)

    def test_compareSets_different_length(self):
        set1 = [self.node1, self.node2]
        set2 = [self.node1, self.node2, self.node3]
        result = compareSets(set1, set2)
        self.assertFalse(result)

    def test_findAndRemoveChild_found(self):
        children = [self.node1, self.node2, self.node3]
        result = findAndRemoveChild(children, self.node2)
        expected = [self.node1, self.node3]
        self.assertEqual(result, expected)

    def test_findAndRemoveChild_not_found(self):
        children = [self.node1, self.node3]
        result = findAndRemoveChild(children, self.node2)
        self.assertEqual(set(result), set(children))

    def test_findAndRemoveChild_empty_list(self):
        children = []
        result = findAndRemoveChild(children, self.node2)
        self.assertEqual(result, [])


if __name__ == "__main__":
    unittest.main()
