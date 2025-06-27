from enum import Enum
from typing import Union, List
from ..DataStructures.Trees import TreeNode, NodeType, findAndRemoveChild
from .HelperFunctions import (
    find_object,
    intersection,
    setDifference,
    union,
    isConsistent,
)


class ReductionSignal(Enum):
    DELETE = "DELETE"
    DISCONNECT = "DISCONNECT"
    KEEP = "KEEP"


class IterationSignal(Enum):
    ADVANCE = "ADVANCE"
    RESET = "RESET"


def compareSets(set1: list[TreeNode], set2: list[TreeNode], currentIndex=0) -> bool:
    if not (len(set1) == len(set2)):
        return False

    if len(set1) == 0:
        return True

    if currentIndex == len(set1):
        # This means the recursion finished with out finding a mismatch between the two
        return True

    currentElement = set1[0]
    if not find_object(set2, currentElement):
        return False
    else:
        set2 = findAndRemoveChild(set2, currentElement)
        return compareSets(set1[1:], set2, currentIndex + 1)


def commandSetIterator(
    child: TreeNode, children: List[TreeNode], localCommandSet: List[TreeNode]
):
    if children == []:
        return localCommandSet
    else:
        # Compare if siblings have terminal and node with one constraint in their guardset
        if (
            children[0].children == []
            and len(children[0].guardSet if children[0].guardSet else []) == 1
            and children
            and children[0].type == NodeType.AND
            and id(child) != id(children[0])
        ):
            tempResult = union(
                children[0].guardSet,
                commandSetIterator(child, children[1:], localCommandSet),
            )
            return setDifference(tempResult, child.guardSet)
        else:
            return commandSetIterator(child, children[1:], localCommandSet)


def containsTerminalAndNode(children: list[TreeNode]) -> bool:
    if len(children) == 0:
        return False
    firstChild = children[0]
    isAndNode = firstChild.type == NodeType.AND
    isTerminalNode = firstChild.children is None or len(firstChild.children) == 0
    hasSingleConstraint = firstChild.guardSet and len(firstChild.guardSet) == 1
    if isAndNode and isTerminalNode and hasSingleConstraint:
        return True
    else:
        return containsTerminalAndNode(children[1:])


def applyOrCut(child: TreeNode, current: TreeNode):
    if len(child.children) == 1:
        grandChild = child.children[0]
        current.guardSet = union(current.guardSet, grandChild.guardSet)
        current.children = grandChild.children + current.children
        current.children = findAndRemoveChild(current.children, grandChild)
        current.children = findAndRemoveChild(current.children, child)


def applyAndCut(grandChild: TreeNode, child: TreeNode):
    hasOneChild = len(grandChild.children) == 1
    emptyGuardSet = len(grandChild.guardSet) == 0

    if hasOneChild and emptyGuardSet:
        if grandChild.children[0].children:
            child.children = child.children + grandChild.children[0].children
            child.children = findAndRemoveChild(child.children, grandChild)
            return containsTerminalAndNode(grandChild.children[0].children)
    return False


def computeGrandChildGuardSet(grandChild: TreeNode, resultSet: list[TreeNode]):
    grandChild.guardSet = setDifference(grandChild.guardSet, resultSet)


def intersections(children: list[TreeNode]) -> list[TreeNode]:
    # Base case: If there's only one child or no children, return its guardSet or an empty list
    if not children:
        return []
    if len(children) == 1:
        return children[0].guardSet

    # Recursive case: Intersect the guardSet of the first child with the intersection of the rest
    first_child_guardSet = children[0].guardSet
    remaining_intersections = intersections(children[1:])

    # Intersect the current guardSet with the result of the recursive call
    return intersection(first_child_guardSet, remaining_intersections)


def orSubTreeElegance(
    parent: TreeNode,
    child: TreeNode,
    current: TreeNode,
    dominantSet: list[TreeNode],
    localCommandSet: list[TreeNode],
):
    outcome = reduceToElegance(parent, child, dominantSet, localCommandSet)

    match outcome:
        case ReductionSignal.DELETE:
            if len(current.children) > 0:
                current.children = findAndRemoveChild(current.children, child)
                return IterationSignal.ADVANCE
            else:
                return ReductionSignal.DELETE
        case ReductionSignal.DISCONNECT:
            return ReductionSignal.DISCONNECT
        case ReductionSignal.KEEP:
            return IterationSignal.ADVANCE


def andSubTreeElegance(
    parent: TreeNode,
    child: TreeNode,
    current: TreeNode,
    handleSet: list[TreeNode],
    commandSet: list[TreeNode],
):
    outcome = reduceToElegance(current, child, handleSet, commandSet)
    match outcome:
        case ReductionSignal.DELETE:
            current.children = []
            return ReductionSignal.DELETE

        case ReductionSignal.DISCONNECT:
            current.children = findAndRemoveChild(current.children, child)
            child.children = []
            return IterationSignal.ADVANCE

        case ReductionSignal.KEEP:
            resultSet = intersections(current.children)
            if len(resultSet) > 0:
                current.guardSet = union(current.guardSet, resultSet)
                list(
                    map(
                        lambda grandChild: computeGrandChildGuardSet(
                            grandChild, resultSet
                        ),
                        child.children,
                    )
                )
                list(
                    map(
                        lambda grandChild: applyAndCut(grandChild, child),
                        child.children,
                    )
                )

                return IterationSignal.RESET
            else:
                # Adding `list` here might not be necessary but just to be safe
                bools = list(
                    map(
                        lambda grandChild: applyAndCut(grandChild, child),
                        child.children,
                    )
                )
                containsTerminalAndNode = any(bools)

                # if no terminal AND node whose guard set contains one constraint was adopted as a grandchild by current advance the child pointer to current’s next child
                if not containsTerminalAndNode:
                    return IterationSignal.ADVANCE
                else:
                    return IterationSignal.RESET

        case _:
            return outcome


def updateGuardSet(node: TreeNode, guardSet: List[TreeNode]) -> TreeNode:
    node.guardSet = guardSet
    return node


def orSubTreeIterator(
    parent: TreeNode,
    children: list[TreeNode],
    currentNode: TreeNode,
    dominantSet: list[TreeNode],
    commandSet: list[TreeNode],
    currentChildIndex=0,
):
    if len(children) == 0:
        return None

    child = children[currentChildIndex]

    # This code is added here to prevent preserve the previous state until the update is complete.
    # The update is dependent on the currentNode's state before the function was called.
    # If the initial state changes while the function is executing, it will result in unexpected behavior.
    # After the update is complete, it will not be necessary any more.
    currentNodeTemp = TreeNode(currentNode.value)
    currentNodeTemp.type = currentNode.type
    currentNodeTemp.guardSet = currentNode.guardSet
    currentNodeTemp.children = currentNode.children
    currentNodeTemp.constraint = currentNode.constraint

    localCommandSet = commandSet
    localCommandSet = commandSetIterator(
        child, currentNodeTemp.children, localCommandSet
    )

    action = orSubTreeElegance(
        currentNode, child, currentNode, dominantSet, localCommandSet
    )

    match action:
        case IterationSignal.ADVANCE:
            if currentChildIndex + 1 < len(children):
                return orSubTreeIterator(
                    parent,
                    children,
                    currentNode,
                    dominantSet,
                    commandSet,
                    currentChildIndex + 1,
                )
            else:
                return None
        case IterationSignal.RESET:
            return orSubTreeIterator(
                parent, children, currentNode, dominantSet, commandSet
            )
        case _:
            return action


def andSubTreeIterator(
    parent: TreeNode,
    children: list[TreeNode],
    currentNode: TreeNode,
    handleSet: list[TreeNode],
    commandSet: list[TreeNode],
    currentChildIndex=0,
):
    if len(children) == 0:
        return None
    currentChild = children[currentChildIndex]
    action = andSubTreeElegance(
        currentNode, currentChild, currentNode, handleSet, commandSet
    )

    match action:
        case IterationSignal.ADVANCE:
            if currentChildIndex + 1 < len(children):
                return andSubTreeIterator(
                    parent,
                    children,
                    currentNode,
                    handleSet,
                    commandSet,
                    currentChildIndex + 1,
                )
            else:
                return None
        case IterationSignal.RESET:
            return andSubTreeIterator(
                parent, children, currentNode, handleSet, commandSet, 0
            )
        case _:
            return action


def iterator(
    parent: TreeNode,
    current: TreeNode,
    dominantSet: list[TreeNode],
    commandSet: list[TreeNode],
):
    previousGuardSet = current.guardSet
    handleSet = union(dominantSet, current.guardSet)

    # Determine if current is a site for inconsistent Handle
    if not isConsistent(handleSet):
        return ReductionSignal.DELETE

    # Reduce each child's subtree to relative elegance
    outcome = andSubTreeIterator(
        parent, current.children, current, handleSet, commandSet
    )

    # The subtree iterator returns a value different from None only if ReductionSignal has been found during the processing. If not it will always return None in the end
    if outcome:
        return outcome

    # Apply OR-CUT to each child of current, if possible
    list(map(lambda child: applyOrCut(child, current), current.children))

    if not compareSets(previousGuardSet, current.guardSet):
        return iterator(parent, current, dominantSet, commandSet)

    return None


def reduceToElegance(
    parent: TreeNode,
    current: Union[TreeNode, None],
    dominantSet: list[TreeNode],
    commandSet: list[TreeNode],
):
    if current == None:
        return
    match current.type:
        case NodeType.AND:
            # Keep previous state for some calculations
            currentTemp = TreeNode(current.value)
            currentTemp.type = current.type
            currentTemp.constraint = current.constraint
            currentTemp.children = current.children
            currentTemp.guardSet = current.guardSet

            # Apply Redundant to current, if possible
            current.guardSet = setDifference(current.guardSet, dominantSet)

            # Apply 1CCSubtract to current, if possible
            current.guardSet = setDifference(current.guardSet, commandSet)

            currentHasNoChild = len(current.children) == 0
            currentHasNoGuardSet = len(current.guardSet) == 0
            if currentHasNoChild and currentHasNoGuardSet:
                return ReductionSignal.DISCONNECT

            # Determine if current is a site for 1Subsume

            resultSet = intersection(currentTemp.guardSet, commandSet)

            if len(resultSet) != 0:
                return ReductionSignal.DELETE

            # Repeat until current's guardSet doesn't change
            action = iterator(parent, current, dominantSet, commandSet)

            if action:
                return action

            # Determine if current is a site for 0-Subsumption
            currentHasNoChild = len(current.children) == 0
            currentHasNoGuardSet = len(current.guardSet) == 0
            if currentHasNoChild and currentHasNoGuardSet:
                return ReductionSignal.DISCONNECT

            return ReductionSignal.KEEP
        case _:
            # Current type is OR

            # Promote child to parent's guardSet if possible
            commonToAllChildren = intersections(current.children)
            if len(commonToAllChildren) > 0:
                parent.guardSet += commonToAllChildren
                current.children = list(
                    map(
                        lambda child: updateGuardSet(
                            child, setDifference(child.guardSet, commonToAllChildren)
                        ),
                        current.children,
                    )
                )
                dominantSet += commonToAllChildren
                return IterationSignal.RESET

            action = orSubTreeIterator(
                parent,
                current.children,
                current,
                dominantSet,
                commandSet,
            )
            if action:
                return action

            return ReductionSignal.KEEP
