from ..DataStructures.Graphs import ConstraintGraphNode,GraphNodeType,NodeType
from .HelperFunctions import isConsistent,union
from typing import List,Union,Any

from ..DataStructures.Trees import BinaryConstraintTreeNode

def traverseGraphIterator(childrenList: List[Any], incomingSet: List[Any], selectionSet: List):
    if childrenList == []:
        return 
    else:
        traverseGraph(childrenList[0],incomingSet,selectionSet)
        traverseGraphIterator(childrenList[1:],incomingSet,selectionSet)
        return selectionSet

def traverseGraph(
        constraintGraphNode: Union[ConstraintGraphNode|None|BinaryConstraintTreeNode],
        incomingSet: List,selectionSet:List
    ) -> List:
    if constraintGraphNode == None:
        return selectionSet
    if constraintGraphNode.graphNodeType == GraphNodeType.START:
        traverseGraph(constraintGraphNode.next, incomingSet,selectionSet)
    elif constraintGraphNode.graphNodeType == GraphNodeType.INTERNAL:
        if constraintGraphNode.type == NodeType.AND and isConsistent(incomingSet):
            traverseGraph(constraintGraphNode.next, union(incomingSet,constraintGraphNode.guardSet), selectionSet)
        elif constraintGraphNode.type == NodeType.OR:
            traverseGraphIterator(constraintGraphNode.children,incomingSet,selectionSet)
    elif constraintGraphNode.graphNodeType == GraphNodeType.STOP:
        print("This is the incoming set: ", incomingSet)
        
        selectionSet.append(incomingSet)
        print("This is the selection set", selectionSet)
    return selectionSet

        
        
   
                
            
