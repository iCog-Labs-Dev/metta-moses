import re
from typing import Union
from ..DataStructures.Trees import *


def BuildTree(input: str) -> BinaryExpressionTreeNode | None:
    """
    Convert a string of a Boolean expression into a binary expression tree structure.

    Parameters
    ----------
    input : str
        String of Boolean expression.
    
    Returns
    -------
    BinaryExpressionTreeNode | None
        The root node of the binary expression tree.
    
    Raises
    ------
    ValueError
        If the input format is invalid or there are insufficient arguments for a binary operator.
    """
    input = re.sub(r"\s+", "", input)
    tree = BinaryExpressionTreeNode("Null")
    first = input[0]
    
    match first:
        case "|" | "&":
            input = input[2 : len(input) - 1]
            firstArg, secondArg = splitArgs(input)

            if firstArg is None or secondArg is None:
                raise ValueError("Insufficient arguments for binary operator")

            tree.value = "AND" if first == "&" else "OR"
            tree.type = NodeType.AND if first == "&" else NodeType.OR
            tree.left = BuildTree(firstArg)
            tree.right = BuildTree(secondArg)
            return tree
        case "!":
            input = input[2 : len(input) - 1]
            tree.value = "NOT"
            tree.type = NodeType.NOT
            tree.right = BuildTree(input)
            return tree
        case "(" | ")":
            raise ValueError("Invalid Boolean expression format")
        case _:
            tree.value = first
            tree.type = NodeType.LITERAL
            return tree


def splitArgs(input: str) -> Union[tuple[str, str], tuple[None, None]]:
    """
    Split a string of a Boolean expression into two arguments.

    Parameters
    ----------
    input : str
        String of Boolean expression.
    
    Returns
    -------
    tuple[str, str] | tuple[None, None]
        A tuple containing the two arguments as strings if split is successful,
        otherwise a tuple of (None, None).
    """
    brackets = 0
    index = 0
    for c in input:
        match c:
            case "(":
                brackets += 1
            case ")":
                brackets -= 1
            case "," if brackets == 0:
                return input[:index], input[index + 1 :]
        index += 1
    return None, None
