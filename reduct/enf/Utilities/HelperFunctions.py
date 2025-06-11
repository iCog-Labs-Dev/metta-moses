from typing import Union, List
from ..DataStructures.Trees import BinaryExpressionTreeNode, NodeType, TreeNode
import re

def print_constraint_tree(node: TreeNode, level=0, side=""):
    constraint = ""

    if node.value not in ["AND", "OR"]:
        constraint = f"{'+' if node.constraint else '-'}"

    if node is None:
        return

    if node.type == NodeType.AND:
        print("    " * level + f"[{side}{level}]", end="")
        print(" AND", end="")
        print("[", end="")
        list(map(lambda child: print_constraint(child), node.guardSet))
        print("]")
    else:
        print("    " * level + f"[{side}{level}]", f"{constraint}{node.value}")

    list(
        map(
            lambda child: print_constraint_tree(child, level + 1, "CHL"),
            node.children,
        )
    )


def print_constraint(node: TreeNode):
    if node.type not in ["AND", "OR"]:
        constraint = "+" if node.constraint else "-"
        print(f"{constraint}{node.value}", end=" ")
    else:
        print(node.value, end="")


def print_tree(node: Union[TreeNode, BinaryExpressionTreeNode, None], level=0, side=""):
    """
    Recursively prints the structure of a binary tree or a generic tree.

    The function prints each node's value along with its constraint (if applicable) and
    the position in the tree (indicated by `side` and `level`). The output is indented
    according to the depth of the node in the tree to represent the tree hierarchy visually.

    Parameters
    ----------
    node : Union[TreeNode, BinaryExpressionTreeNode, None]
        The root node of the tree (or subtree) to print. It can be of type TreeNode,
        BinaryExpressionTreeNode, or None.

    level : int, optional
        The current depth level in the tree, used for indentation (default is 0).

    side : str, optional
        A string indicating whether the current node is on the left or right side of its
        parent, or is a child node (`CHL`). This is used to label nodes in the output
        (default is an empty string).

    Returns
    -------
    None
        The function prints the tree structure and returns None.
    """
    constraint = ""
    if type(node) == TreeNode and node.type == NodeType.LITERAL:
        constraint = f"{'+' if node.constraint else '-'}"

    if node is None:
        return
    print("    " * level + f"[{side}{level}]", f"{constraint}{node.value}")

    if node.left is not None:
        print_tree(node.left, level + 1, "L")

    if node.right is not None:
        print_tree(node.right, level + 1, "R")


def eval(node: TreeNode) -> Union[bool, None]:
    if node is None:
        return
    if node.value == "AND":
        if node.left is not None and node.right is not None:
            return eval(node.left) and eval(node.right)
    elif node.value == "OR":
        if node.left is not None and node.right is not None:
            return eval(node.left) or eval(node.right)
    elif node.value == "NOT":
        if node.right is not None:
            return not eval(node.right)
    else:
        return node.constraint


def isConsistentForSingleValue(
    first_val: TreeNode, toBeChecked: List[TreeNode]
) -> bool:
    """
    Checks if a single TreeNode is consistent with a list of TreeNodes. Consistency
    is defined as having no TreeNode in the list with the same value but a different constraint.

    Parameters:
    -------------
        first_val: TreeNode
             The TreeNode to check for consistency.
        toBeChecked: List[TreeNode]
             The list of TreeNodes to check against.

    Returns:
        bool: True if consistent, False otherwise.
    """
    if toBeChecked == []:
        return True
    elif (
        first_val.value == toBeChecked[0].value
        and first_val.constraint != toBeChecked[0].constraint
    ):
        return False
    else:
        return isConsistentForSingleValue(first_val, toBeChecked[1:])


def isConsistent(toBeChecked: List[TreeNode]) -> bool:
    if toBeChecked == []:
        return True
    else:
        if not (isConsistentForSingleValue(toBeChecked[0], toBeChecked[1:])):
            return False
        else:
            return isConsistent(toBeChecked[1:])


def compareBCTNode(n1: TreeNode, n2: TreeNode) -> bool:
    return n1.value == n2.value and n1.constraint == n2.constraint


def find_object(
    objs_list: List[TreeNode],
    instance: TreeNode,
    index=0,
) -> bool:
    """
    Recursively checks if a given TreeNode instance exists within a list of TreeNode objects.
    This function compares two tree nodes based on their type, value and constraint attributes.
    Since all junctor nodes have the same value for all of the above, this comparing will only successfully compare
    nodes of type `NodeType.LITERAL`.

    Parameters
    ----------
    objs_list : List[TreeNode]
        A list of TreeNode objects to search within.

    instance : TreeNode
        The TreeNode instance to search for within objs_list.

    index : int, optional
        The current index in objs_list being checked (default is 0).

    Returns
    -------
    bool
        True if the instance is found in objs_list (based on value and constraint), False otherwise.
    """
    if index == len(
        objs_list
    ):  # no more objs_list(list of tree node) to compare with instance tree node
        return False
    elif (  # compare objs_list value and constraint with instance value and constraint, if both are equal return true
        instance.type == NodeType.LITERAL
        and objs_list[index].type == instance.type
        and objs_list[index].value == instance.value
        and objs_list[index].constraint == instance.constraint
    ):
        return True
    else:
        return find_object(
            objs_list, instance, index + 1
        )  # if one of them is not equal continue to the next element of the objs_list


def union(list1: List[TreeNode], list2: List[TreeNode]) -> List[TreeNode]:
    """
    Creates a union of two lists of TreeNode objects, ensuring that the resulting list
    contains unique TreeNode instances based on their value and constraint attributes.

    The function recursively checks each TreeNode in list1 to see if it is already present
    in list2. If it is not present, it adds the TreeNode to the result. The final result
    is a list that contains all unique TreeNode instances from both lists.

    Parameters
    ----------
    list1 : List[TreeNode]
        The first list of TreeNode objects to union with list2.

    list2 : List[TreeNode]
        The second list of TreeNode objects to union with list1.

    Returns
    -------
    List[TreeNode]
        A list of TreeNode objects that represents the union of list1 and list2,
        containing only unique elements based on value and constraint.

    Notes
    -----
    - This function assumes that each TreeNode object has `value` and `constraint` attributes.
    - The uniqueness of a TreeNode is determined by comparing these two attributes.
    - The order of the resulting list preserves the order from list1, followed by elements
      from list2 that were not present in list1.
    """
    # Start with all elements in list1
    result = list1[:]

    for node in list2:
        if not find_object(result, node):
            result.append(node)

    return result


def intersection(list1: List[TreeNode], list2: List[TreeNode]) -> List[TreeNode]:
    if not list1 or not list2:
        return []
    element = list1[0]

    if find_object(list2, element):
        return [element] + intersection(list1[1:], list2)
    else:
        return intersection(list1[1:], list2)


def setDifference(list1: List[TreeNode], list2: List[TreeNode]) -> List[TreeNode]:
    """
    Computes the set difference between two lists of TreeNode objects.
    Returns elements from list1 that are not found in list2.

    Parameters
    ----------
    list1 : List[TreeNode]
        The first list of TreeNode objects.

    list2 : List[TreeNode]
        The second list of TreeNode objects to compare against.

    Returns
    -------
    List[TreeNode]
        A list of TreeNode objects from list1 that are not found in list2 (based on value and constraint).
    """
    if not list1:  # if list1 is empty it returns empty list
        return []
    element = list1[0]  # taking the first element of the list

    if find_object(
        list2, element
    ):  # check is there is constraint and value similarity between element and list2
        return setDifference(
            list1[1:], list2
        )  # if yes go to the next element recursively

    return [element] + setDifference(
        list1[1:], list2
    )  # if there is no similarity either in constraint or value
    # we add that element and go to the next elelement of list1


## accepts constraint tree node and returns metta boolean expression
def constraint_tree_to_metta_expr(node) -> str:
    def parse_guard(guard):
        sign = "+" if guard.constraint else "-"
        name = guard.value.upper()
        return name if sign == "+" else f"(NOT {name})"

    def recurse(node):
        if node is None:
            return ""

        if node.type == NodeType.AND:
            guard_exprs = [parse_guard(g) for g in node.guardSet]
            child_exprs = [recurse(child) for child in node.children]
            args = guard_exprs + child_exprs
            return f"(AND {' '.join(args)})"
        
        elif node.type == NodeType.OR:
            child_exprs = [recurse(child) for child in node.children]
            return f"(OR {' '.join(child_exprs)})"

        else:
            name = node.value.upper()
            return name if node.constraint else f"(NOT {name})"

    return recurse(node)



## accepts Metta boolean expression and returns equivalent binary enf expression
## e.g 
##      (OR A B C D) -->  "|(a,|(b,|(c,d)))

def parse_metta_expression(expr: str) -> str:
    if not expr or not expr.strip():
        raise ValueError("Empty expression")
    
    def parse_tokens(tokens: list[str]) -> str:
        if not tokens:
            raise ValueError("Unexpected end of expression")
            
        token = tokens.pop(0)

        if token != '(':
            return token.lower()

        if not tokens:
            raise ValueError("Expected operator after '('")
            
        op = tokens.pop(0).upper()

        if op == ')':  # Handle empty parentheses
            raise ValueError("Empty parentheses are not allowed")

        if op == 'NOT':
            if not tokens:
                raise ValueError("NOT requires an argument")
            sub_expr = parse_tokens(tokens)
            if not tokens or tokens.pop(0) != ')':
                raise ValueError("Expected ')' after NOT expression")
            return f"!({sub_expr})"

        elif op in ('AND', 'OR'):
            symbol = '&' if op == 'AND' else '|'
            args = []
            while tokens and tokens[0] != ')':
                args.append(parse_tokens(tokens))
            
            if not tokens:
                raise ValueError("Expected ')' to close expression")
            tokens.pop(0)  # remove ')'
            
            if not args:
                # Handle empty AND/OR - you could return a default value or raise error
                if op == 'AND':
                    return "&"  # Identity for AND
                else:  # OR
                    return "|"  # Identity for OR

            def to_binary(args):
                if len(args) == 1:
                    return args[0]
                return f"{symbol}({args[0]},{to_binary(args[1:])})"
            
            return to_binary(args)

        else:
            raise ValueError(f"Unknown operator: {op}")

    # Updated regex to handle more cases
    tokens = re.findall(r'\(|\)|[A-Za-z][A-Za-z0-9]*', expr)
    if not tokens:
        raise ValueError("No valid tokens found")
        
    result = parse_tokens(tokens)
    
    if tokens:  # Check for leftover tokens
        raise ValueError("Unexpected tokens after expression")
        
    return result