from typing import Union
from ..DataStructures.Trees import *


def gatherJunctors(
    currentNode: TreeNode, centerNode: TreeNode
) -> Union[TreeNode, None]:
    """
    Restructures a binary expression tree by merging and organizing nodes of type AND and OR.

     This function processes a binary expression tree by converting and merging logical junctors 
    (AND, OR) into a normalized form. It modifies the tree in-place, adjusting the `type`, `guardSet`,
     and `children` attributes of nodes.

    Parameters
    ----------
    currentNode : TreeNode
        The current node in the binary tree being processed.
    
    centerNode : TreeNode
        The parent or center node around which the restructuring is taking place.

    Returns
    -------
    Union[TreeNode, None]
        Returns the modified root node if the current node is the root; otherwise, returns None.

    Behavior
    --------
    - If `currentNode` is of type `ROOT`, it is transformed into an `AND` node, and its right child
      is processed recursively.
    
    - If `currentNode` is of type `OR` or `AND`, the function checks if the type matches `centerNode`.
      If they match, the function processes the left and right children. Otherwise, it appends the 
      `currentNode` to `centerNode`'s `children` list and recursively processes its children.
    
    - If `currentNode` is of type `LITERAL`, it is either added to the `guardSet` of `centerNode` 
      (if `centerNode` is of type `AND`), or converted into an `AND` node and then added to the 
      `children` list of `centerNode`.
    
    """

    if currentNode.type == NodeType.ROOT:
        currentNode.type = NodeType.AND
        currentNode.value = "AND"
        currentNode.guardSet = []
        if currentNode.right is not None:
            gatherJunctors(currentNode.right, currentNode)

        currentNode.left = None
        currentNode.right = None

        return currentNode

    elif currentNode.type in [NodeType.OR, NodeType.AND]:
        if currentNode.type == centerNode.type:
            if currentNode.left is not None:
                gatherJunctors(currentNode.left, centerNode)

            if currentNode.right is not None:
                gatherJunctors(currentNode.right, centerNode)

        else:
            centerNode.children.append(currentNode)

            if currentNode.left:
                gatherJunctors(currentNode.left, currentNode)

            if currentNode.right:
                gatherJunctors(currentNode.right, currentNode)

            currentNode.left = None
            currentNode.right = None

        # if currentNode.type == NodeType.AND:
        #     currentNode.guardSet = []

        return None
    elif currentNode.type == NodeType.LITERAL:
        if centerNode.type == NodeType.AND:
            centerNode.guardSet.append(currentNode)

        else:
            currentNode.type = NodeType.AND

            temp = TreeNode(currentNode.value)
            temp.type = NodeType.LITERAL
            temp.constraint = currentNode.constraint

            currentNode.value = "AND"

            currentNode.guardSet = [temp]
            centerNode.children.append(currentNode)
    return None
