from hyperon import * 
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, V
from hyperon.ext import register_atoms

from .DataStructures.Trees import TreeNode, BinaryExpressionTreeNode, NodeType
from .Utilities.BuildTree import BuildTree
from .Utilities.HelperFunctions import constraint_tree_to_metta_expr, parse_metta_expression
from .Utilities.PropagateTruthValue import propagateTruthValue
from .Utilities.GatherJunctors import gatherJunctors
from .Utilities.ReduceToElegance import *


def reduce (metta: MeTTa, expr):
    expr = str(expr)

    input = parse_metta_expression(expr)  
    # if expr is op and doesn't have a child return AND
    if input == '&':
        return metta.parse_all('(AND)')
    elif input == '|':
        return metta.parse_all('(AND (OR))')
    
    tree = BuildTree(input)

    root = BinaryExpressionTreeNode("Root")
    root.type = NodeType.ROOT
    root.right = tree

    root2 = BinaryExpressionTreeNode("Root")
    root2.type = NodeType.ROOT

    binaryConstraintTree = propagateTruthValue(root)

    constraintTree = TreeNode("ROOT")
    constraintTree.type = NodeType.ROOT

    if binaryConstraintTree is not None:
        constraintTree = gatherJunctors(binaryConstraintTree, constraintTree)

    lastAction = None
    if constraintTree is not None:
        lastAction = reduceToElegance(constraintTree, constraintTree, [], [])
        match lastAction:
            case ReductionSignal.DELETE:
                constraintTree.children = []
                constraintTree.guardSet = []

            case ReductionSignal.DISCONNECT:
                constraintTree.children = []
                constraintTree.guardSet = []


    # # If the last action returned is a DELETE, that means the whole tree is a contradiction. Will always return False
    # # If the last action returned is a DISCONNECT, that means the whole tree is a tautology. Will always return True
    # # If the last action returned is a KEEP, that means the algorithm tried to reduce the tree as much as possible

    # print("Last action after reduction: ", lastAction)


    if constraintTree:
        # print("constraint Tree after reduction")
        # print_constraint_tree(constraintTree)
        
        return metta.parse_all(constraint_tree_to_metta_expr(constraintTree))
        
    
    return metta.parse_all(expr)

@register_atoms(pass_metta=True)
def main(metta):
    printer_var = OperationAtom(
        "reduce",
        lambda expr: reduce(metta, expr),
        ["Expression", "Expression"],
        unwrap=False,
    )

    return {r"reduce": printer_var}