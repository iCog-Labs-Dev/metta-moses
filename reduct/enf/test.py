from operator import itemgetter
from DataStructures.Trees import findAndRemoveChild
from Tests import *
from Utilities.HelperFunctions import print_constraint_tree
from Utilities.ReduceToElegance import ReductionSignal, reduceToElegance

result = oneConstraintComplementSubtractionTestCase()

current, parentOfCurrent, dominantSet, commandSet, constraint, constraint2 = itemgetter(
    "current",
    "parentOfCurrent",
    "dominantSet",
    "commandSet",
    "constraint",
    "constraint2",
)(result)

print_constraint_tree(constraint)
# action = reduceToElegance(constraint, constraint, [], [])
action = reduceToElegance(parentOfCurrent, current, commandSet, dominantSet)
match action:
    # case ReductionSignal.DELETE:
    #     parentOfCurrent.children = findAndRemoveChild(parentOfCurrent.children, current)
    case ReductionSignal.DISCONNECT:
        parentOfCurrent.children = findAndRemoveChild(parentOfCurrent.children, current)
print(action)
print_constraint_tree(constraint)
print_constraint_tree(constraint2)
print(compareTrees(constraint, constraint2))
