from functools import reduce

from DataStructures.Trees import NodeType, TreeNode
from Utilities.HelperFunctions import intersection, union


def ruleOne(node: TreeNode, branch_set: list[TreeNode] | None = None) -> bool:
    """
    ENf Rule #1: All branch sets are consistent.

    The function gathers guard sets and constraints from the root to each leaf and check for consistency.

    Args:
        - node: TreeNode: The root node of the tree.
        - branch_set [Optional]: list[TreeNode]: The branch set to be checked for consistency. Defalue is None.

    Returns:
        - bool: True if the branch set is consistent, False otherwise.

    Branch Set: is the union of the guard sets of the AND nodes which are in the branch.

    """

    def check_branch_set_consistency(branch_set: list[TreeNode]) -> bool:
        """Check if a branch set is consistent."""
        literals = set()
        negated_literals = set()

        for node in branch_set:
            if node.type == NodeType.LITERAL:
                if node.constraint:
                    literals.add(node.value)
                else:
                    negated_literals.add(node.value)

        # Check for any literal that is both in literals and negated_literals
        for literal in literals:
            if literal in negated_literals:
                return False

        return True

    if branch_set is None:
        branch_set = []

    # If it's an AND node, we gather guard sets from it
    if node.type == NodeType.AND:
        # Convert guard sets to TreeNode and add to branch set
        branch_set = union(
            branch_set,
            [TreeNode(guard.value, guard.constraint) for guard in node.guardSet],
        )

    # If we reach a leaf node, check for consistency
    if not node.children:
        return check_branch_set_consistency(branch_set)

    # Recursively check  all childrens
    for child in node.children:
        if not ruleOne(child, branch_set.copy()):
            return False

    return True


def ruleTwo(node: TreeNode):
    """
    ENF Rule #2: All terminal AND nodes have non empty guard sets.

    Args:
        - node: TreeNode: The root node of the tree.

    Returns:
        - bool: True if the rule is satisfied, False otherwise.

    Conditions that must be fulfilled to return True:
        - The node must be of type AND.
        - The node must be terminal (Have no children).
        - All such nodes must have non-empty guard sets.
    """

    if node.type == NodeType.AND and not node.children:
        return len(node.guardSet) > 0
    for child in node.children:
        if not ruleTwo(child):
            return False
    return True


def ruleThree(node: TreeNode) -> bool:
    """
    ENF Rule #3: All OR nodes have at least two children.

    Args:
        - node: TreeNode: The root node of the tree.

    Returns:
        - bool: True if the rule is satisfied, False otherwise.

    Conditions that must be fulfilled to return True:
        - The node must be of type OR.
        - All such nodes must have at least two children.
    """

    # Base Case: If a node is OR type and has less than 2 children, then it is not ENF.
    if node.type == NodeType.OR and len(node.children) < 2:
        return False

    # recursive case: check all children
    for child in node.children:
        if not ruleThree(child):
            return False

    return True


def ruleFour(tree: TreeNode, is_root=True) -> bool:
    """
    ENF Rule #4: All non-terminal AND nodes, which are not the root node,
    and which have empty guard sets, have at least two children.

    Args:
        - tree: TreeNode: The root node of the tree.
        - is_root [Optional]: bool: True if the node is the root node, False otherwise. Default is True.
    Returns :
        - bool: True if the rule is satisfied, False otherwise.

    Conditions that must be fulfilled to return True:
     - The node must be of type AND.
     - The node must not be the root node.
     - The node must have empty guard sets.
     - The node must be non-terminal node.
     - All such nodes must have at least two children.
    """

    # Base Case
    if (
        tree.type == NodeType.AND
        and not is_root
        and not tree.guardSet
        and tree.children
        and len(tree.children) < 2
    ):
        return False

    # Recursive Case: Check all children
    for child in tree.children:
        if not ruleFour(child, False):
            return False

    return True


def ruleFive(tree):
    """
    ENF Rule #5: For each OR node, the intersection of the guard sets of the children of the node is empty.

    Args:
        - tree: TreeNode: The root node of the tree.

    Returns :
        - bool: True if the rule is satisfied, False otherwise.

    Conditions that must be fulfilled to return True:
     - The node must be of type OR.
     - The intersection of the guard sets of the children of this node is empty.

    """

    def traverse(node, level=0):
        for child in node.children:
            if child.type == NodeType.OR:
                if child.children:
                    guardsets = []
                    for gs in child.children:
                        guardsets.append(gs.guardSet)
                    assert (
                        len(reduce(intersection, guardsets, [])) == 0
                    ), "Not in ENF Form, case 5 Failed"

            traverse(child, level + 1)

    try:
        traverse(tree)
        return True
    except AssertionError:
        return False


def ruleSix(tree):
    """
    ENF Rule #6: For each AND node, the intersection of its guard set and its dominant set is empty.

    Args:
        - tree: TreeNode: The root node of the tree.

    Returns :
        - bool: True if the rule is satisfied, False otherwise.

    Conditions that must be fulfilled to return True:
     - The node must be of type AND.
     - The intersection of its guard sets and its dominant set is empty.

    A is said to dominate node B:
        - If A and B are distinct
        - A and B are in the same branch
        - A is closer to the root of the tree than is B.
    Dominant set: of a node is the union of the guard sets of the AND nodes which dominate that node.

    """

    def dominantSetIterator(children, level, localDominantSet, target, targetNodeLevel):
        if children == []:
            return localDominantSet
        if children[0].value == target.value and children[0].type == target.type:
            return localDominantSet
        else:
            if children[0].type == NodeType.AND and level < targetNodeLevel:
                return union(
                    children[0].guardSet,
                    dominantSetIterator(
                        children[1:], level, localDominantSet, target, targetNodeLevel
                    ),
                )
            else:
                return dominantSetIterator(
                    children[1:], level + 1, localDominantSet, target, targetNodeLevel
                )

    def traverse(root, node, level=0):
        for child in node.children:
            if child.type == NodeType.AND:
                assert (
                    len(
                        intersection(
                            child.guardSet,
                            dominantSetIterator(root.children, 0, [], child, level),
                        )
                    )
                    == 0
                ), "Not in ENF, case 6 failed"
            traverse(root, child, level + 1)

    try:
        traverse(tree, tree)
        return True
    except AssertionError:
        return False


def ruleSeven(tree):
    """
    ENF Rule #6: For each AND node, the intersection of its guard set and its command set is empty.

    Args:
        - tree: TreeNode: The root node of the tree.

    Returns :
        - bool: True if the rule is satisfied, False otherwise.

    Conditions that must be fulfilled to return True:
     - The node must be of type AND.
     - The intersection of its guard sets and its command set is empty.

    A commands B if:
      - If A is a childless AND node having only one constraint in its guard set.
      - A is a child of an ancestor of B.
      - A and B are not in the same branch.
    Command set: of a node is the union of the guard sets of all nodes that command it.

    """

    def commandSetIterator(children, level, localCommandSet, target, targetNodeLevel):
        if children == []:
            return localCommandSet
        if children[0].value == target.value and children[0].type == target.type:
            return localCommandSet
        else:
            if (
                children[0].children == []
                and len(children[0].guardSet if children[0].guardSet else []) == 1
                and children
                and children[0].type == NodeType.AND
            ):
                return union(
                    children[0].guardSet,
                    commandSetIterator(
                        children[1:], level, localCommandSet, target, targetNodeLevel
                    ),
                )
            else:
                return commandSetIterator(
                    children[1:], level + 1, localCommandSet, target, targetNodeLevel
                )

    def traverse(root, node, level=0):
        for child in node.children:
            if child.type == NodeType.AND:
                commandSetIterator(root.children, 0, [], child, level)
                assert (
                    len(
                        intersection(
                            child.guardSet,
                            commandSetIterator(root.children, 0, [], child, level),
                        )
                    )
                    == 0
                ), "Not in ENF, case 7 failed"

            traverse(root, child, level + 1)

    try:
        traverse(tree, tree)
        return True
    except AssertionError:
        return False
