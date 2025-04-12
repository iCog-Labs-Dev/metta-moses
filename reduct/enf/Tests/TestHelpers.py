import itertools

from Utilities.BuildTree import BuildTree
from Utilities.ReduceToElegance import ReductionSignal, compareSets, reduceToElegance
from Utilities.GatherJunctors import gatherJunctors
from Utilities.PropagateTruthValue import propagateTruthValue
from DataStructures.Trees import NodeType, TreeNode, BinaryExpressionTreeNode


def compare_tables(table1, table2):
    """Compares two truth tables, even if they have different numbers of variables.

    Args:
        table1: The first truth table, a list of tuples.
        table2: The second truth table, a list of tuples.

    Returns:
        A tuple containing:
        - True if the truth tables are equivalent, False otherwise.
        - A list of tuples, where each tuple represents an entry where the truth values differ.
    """

    # Ensure both tables are sorted for consistent comparison
    table1.sort(key=lambda x: tuple(x[0].values()))
    table2.sort(key=lambda x: tuple(x[0].values()))

    # Find the table with the most variables
    longer_table = table1 if len(table1[0][0]) > len(table2[0][0]) else table2
    shorter_table = table1 if longer_table == table2 else table2

    # Extend the shorter table with extra variables using itertools.product
    extended_shorter_table = []
    for entry in shorter_table:
        input_dict = entry[0]
        missing_keys = set(longer_table[0][0]) - set(input_dict)
        for missing_values in itertools.product(
            [True, False], repeat=len(missing_keys)
        ):
            extended_input_dict = {
                **input_dict,
                **dict(zip(missing_keys, missing_values)),
            }
            extended_entry = (extended_input_dict, entry[1])
            extended_shorter_table.append(extended_entry)

    extended_shorter_table.sort(key=lambda x: tuple(x[0].values()))

    # Compare corresponding entries in the longer table
    differences = []
    for i, (input_dict, output) in enumerate(longer_table):
        matching_entry = next(
            (e for e in extended_shorter_table if e[0] == input_dict), None
        )
        if matching_entry is not None and matching_entry[1] != output:
            differences.append((i, (input_dict, output), matching_entry))

    return True if not differences else False, differences


def collectLiterals(cTree):
    literals = []

    def dfs(node, acc):
        if node.type == NodeType.AND:
            for gs in node.guardSet:
                acc.append(gs.value)
        if node is None:
            return acc
        for child in node.children:
            if child.type == NodeType.AND:
                for gs in child.guardSet:
                    acc.append(gs.value)
            dfs(child, acc)
        return acc

    literals = dfs(cTree, [])

    return sorted(set(literals))


def generateTruthTableValues(literals):
    combinations = list(itertools.product([True, False], repeat=len(literals)))

    result = []
    for combination in combinations:
        result.append(dict(zip(literals, combination)))

    return result


def evaluateBinaryExpressionTreeNode(currentNode, truthValues):
    match currentNode.type:
        case NodeType.NOT:
            if currentNode.right is not None:
                return not evaluateBinaryExpressionTreeNode(
                    currentNode.right, truthValues
                )
        case NodeType.AND:
            if currentNode.left is not None and currentNode.right is not None:
                return evaluateBinaryExpressionTreeNode(
                    currentNode.left, truthValues
                ) and evaluateBinaryExpressionTreeNode(currentNode.right, truthValues)
        case NodeType.OR:
            if currentNode.left is not None and currentNode.right is not None:
                return evaluateBinaryExpressionTreeNode(
                    currentNode.left, truthValues
                ) or evaluateBinaryExpressionTreeNode(currentNode.right, truthValues)
        case NodeType.LITERAL:
            if currentNode.value is not None and currentNode.value in truthValues:
                return truthValues[currentNode.value]


def evaluateReducedConstraintTree(constraintTree, truthValues):
    truthValue = None
    match constraintTree.type:
        case NodeType.AND:
            if constraintTree.guardSet == [] and constraintTree.children == []:
                return True
            if constraintTree.guardSet != []:
                for literal in constraintTree.guardSet:
                    if literal.value is not None and literal.value in truthValues:
                        literalTruthValue = truthValues[literal.value]

                        if not literal.constraint:
                            literalTruthValue = not literalTruthValue

                        if truthValue is None:
                            truthValue = literalTruthValue
                        else:
                            truthValue = truthValue and literalTruthValue

            if constraintTree.children != []:
                for orNode in constraintTree.children:
                    if truthValue is None:
                        truthValue = evaluateReducedConstraintTree(orNode, truthValues)
                    else:
                        truthValue = truthValue and evaluateReducedConstraintTree(
                            orNode, truthValues
                        )
            return truthValue
        case NodeType.OR:
            for andNode in constraintTree.children:
                if truthValue is None:
                    truthValue = evaluateReducedConstraintTree(andNode, truthValues)
                else:
                    truthValue = truthValue or evaluateReducedConstraintTree(
                        andNode, truthValues
                    )
            return truthValue


def generateExpressionTruthTable(tree, literals):
    truthTable = []
    for generatedTruthValues in generateTruthTableValues(literals):
        outcome = evaluateBinaryExpressionTreeNode(tree, generatedTruthValues)
        truthTable.append((generatedTruthValues, outcome))
    return truthTable


def generateReducedTruthTable(constraintTree, literals):
    reducedTruthTable = []
    for generatedTruthValues in generateTruthTableValues(literals):
        outcome = evaluateReducedConstraintTree(constraintTree, generatedTruthValues)
        reducedTruthTable.append((generatedTruthValues, outcome))
    return reducedTruthTable


def generateTautology(literals):
    reducedTruthTable = []
    for generatedTruthValues in generateTruthTableValues(literals):
        reducedTruthTable.append((generatedTruthValues, True))
    return reducedTruthTable


def generateContradiction(literals):
    reducedTruthTable = []
    for generatedTruthValues in generateTruthTableValues(literals):
        reducedTruthTable.append((generatedTruthValues, False))
    return reducedTruthTable


def compareTrees(tree1: TreeNode, tree2: TreeNode):
    """
    A function that takes two constraint trees and compares them for equality.

    Args:
        tree1: The first constraint tree.
        tree2: The second constraint tree.

    Returns:
        True if the trees are equivalent, False otherwise.
    """

    if tree1.type != tree2.type:
        return False

    if tree1.value != tree2.value:
        return False

    if not compareSets(tree1.guardSet, tree2.guardSet):
        return False

    if len(tree1.children) != len(tree2.children):
        return False

    for child1, child2 in zip(tree1.children, tree2.children):
        if not compareTrees(child1, child2):
            return False

    return True


def rteRunner(input: str):
    """
    A functions that takes boolean expression, builds a constraint tree from it,
    runs propagateTruthValue, gatherJunctors and reduceToElegance on the tree and returns the constraint tree.

    Args:
        input: A string representing a boolean expression. i.e. "|(&(A, B), |(&(A, C), &(A, D)))"
    Returns:
        constraintTree: The constraint tree that is in ENF format.
        table1: The truth table of the constraint tree before reduction.
        table2: The truth table of the constraint tree after reduction.
    """

    tree = BuildTree(input)

    root = BinaryExpressionTreeNode("Root")
    root.type = NodeType.ROOT
    root.right = tree

    constraintTree = TreeNode("ROOT")
    constraintTree.type = NodeType.ROOT

    binaryConstraintTree = propagateTruthValue(root)

    if binaryConstraintTree is not None:
        constraintTree = gatherJunctors(binaryConstraintTree, constraintTree)

    table1 = generateReducedTruthTable(constraintTree, collectLiterals(constraintTree))

    action = None
    table2 = None

    if constraintTree is not None:
        action = reduceToElegance(constraintTree, constraintTree, [], [])

        match action:
            case ReductionSignal.DELETE:
                constraintTree.children = []
                constraintTree.guardSet = []
                constraintTree.type = NodeType.ROOT
                constraintTree.value = "ROOT"

                table2 = generateContradiction(collectLiterals(constraintTree))

            case ReductionSignal.DISCONNECT:
                constraintTree.children = []

                table2 = generateTautology(collectLiterals(constraintTree))

    if not table2:
        table2 = generateReducedTruthTable(
            constraintTree, collectLiterals(constraintTree)
        )

    return constraintTree, table1, table2
