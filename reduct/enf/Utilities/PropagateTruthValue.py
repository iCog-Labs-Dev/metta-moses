from typing import Union
from ..DataStructures.Trees import *


def propagateTruthValue(
    currentNode: BinaryExpressionTreeNode,
    truthValue: bool = True,
) -> Union[TreeNode, None]:
    """
    Propagates a truth value through a binary expression tree and modifies the tree based on the given truth value.

    Parameters
    ----------
    currentNode : BinaryExpressionTreeNode
        The current node in the binary expression tree from which to start propagation.
    truthValue : bool, optional
        The truth value to propagate, by default True.

    Returns
    -------
    Union[TreeNode, None]
        A new TreeNode with the propagated truth values, or None if no operation is performed.

    Behavior
    --------
    - If the node type is `ROOT`, the function sets up the `temporaryNode` as a root node,
      and continues to propagate the truth value to the right subtree if it exists.

    - If the node type is `NOT`, the function inverts the truth value (applies logical NOT)
      and continues propagation to the right subtree.

    - If the node type is `AND` or `OR`:
      - If the truth value is `False`, the function changes the node type to `OR` if it was `AND`, 
        and to `AND` if it was `OR`, reflecting the inversion of the operation. It then continues
        propagating the `False` value to both the left and right subtrees (if they exist).
      - If the truth value is `True`, the function maintains the current node type and propagates 
        the `True` value to both the left and right subtrees (if they exist).

    - If the node type is `LITERAL`, the function assigns the given truth value to the `constraint` 
      attribute of the `temporaryNode`.

    Raises
    ------
    ValueError
        If the current node type is not valid.
    """
    temporaryNode: TreeNode= TreeNode("")

    match currentNode.type:
        case NodeType.ROOT:
            temporaryNode.type = currentNode.type
            temporaryNode.value = currentNode.value
            if currentNode.right is not None:
                temporaryNode.right = propagateTruthValue(currentNode.right, truthValue)
            return temporaryNode

        case NodeType.NOT:
            if currentNode.right is not None:
                return propagateTruthValue(currentNode.right, not truthValue)

        case NodeType.AND | NodeType.OR:
            if truthValue == False:
                if currentNode.type == NodeType.AND:
                    temporaryNode.type = NodeType.OR
                    temporaryNode.value = "OR"
                else:
                    temporaryNode.type = NodeType.AND
                    temporaryNode.value = "AND"

            else:
                temporaryNode.value = currentNode.value
                temporaryNode.type = currentNode.type

            if currentNode.left is not None and currentNode.right is not None:
                temporaryNode.left = propagateTruthValue(currentNode.left, truthValue)
                temporaryNode.right = propagateTruthValue(currentNode.right, truthValue)
            return temporaryNode
        case _:
            temporaryNode.value = currentNode.value
            temporaryNode.type = currentNode.type
            temporaryNode.constraint = truthValue
            return temporaryNode
