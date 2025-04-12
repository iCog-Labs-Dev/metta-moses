from unittest import TestCase
from operator import itemgetter

from DataStructures.Trees import findAndRemoveChild
from Tests.TestHelpers import (
    collectLiterals,
    compare_tables,
    compareTrees,
    generateReducedTruthTable,
)

from Tests.TransformationTestCases import (
    deleteInconsistentHandleTestCase,
    promoteCommonConstraintsTestCase,
    subtractRedundantConstraintTestCase,
    cutUnnecessaryOrTestCase,
    cutUnnecessaryAndTestCase,
    zeroConstraintSubsumptionTestCase,
    oneConstraintSubsumptionTestCase,
    oneConstraintComplementSubtractionTestCase,
)

from Utilities.ReduceToElegance import ReductionSignal, reduceToElegance


class TestReduceToElegance(TestCase):
    def testInconsistentHandle(self):
        result = deleteInconsistentHandleTestCase()
        current, parentOfCurrent, dominantSet, commandSet, constraint, constraint2 = (
            itemgetter(
                "current",
                "parentOfCurrent",
                "dominantSet",
                "commandSet",
                "constraint",
                "constraint2",
            )(result)
        )

        table0 = generateReducedTruthTable(constraint, collectLiterals(constraint))

        action = reduceToElegance(parentOfCurrent, current, dominantSet, commandSet)
        match action:
            case ReductionSignal.DELETE:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )
            case ReductionSignal.DISCONNECT:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )

        table1 = generateReducedTruthTable(constraint, collectLiterals(constraint))
        table2 = generateReducedTruthTable(constraint2, collectLiterals(constraint2))

        self.assertTrue(
            compareTrees(constraint, constraint2),
            "Found tree doesn't match the Expected tree.",
        )
        self.assertEqual(
            compare_tables(table0, table1),
            (True, []),
            "Tree's semantic meaning changed after reduction.",
        )
        self.assertEqual(
            compare_tables(table1, table2),
            (True, []),
            "Tree's semantic meaning doesn't match the Expected tree.",
        )
        self.assertEqual(
            action, ReductionSignal.DELETE, "Action doesn't match the Expected action."
        )

    def testPromoteCommonConstraints(self):
        result = promoteCommonConstraintsTestCase()
        current, parentOfCurrent, dominantSet, commandSet, constraint, constraint2 = (
            itemgetter(
                "current",
                "parentOfCurrent",
                "dominantSet",
                "commandSet",
                "constraint",
                "constraint2",
            )(result)
        )

        table0 = generateReducedTruthTable(constraint, collectLiterals(constraint))

        action = reduceToElegance(parentOfCurrent, current, dominantSet, commandSet)
        match action:
            case ReductionSignal.DELETE:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )
            case ReductionSignal.DISCONNECT:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )

        table1 = generateReducedTruthTable(constraint, collectLiterals(constraint))
        table2 = generateReducedTruthTable(constraint2, collectLiterals(constraint2))
        self.assertTrue(
            compareTrees(constraint, constraint2),
            "Found tree doesn't match the Expected tree.",
        )
        self.assertEqual(
            compare_tables(table0, table1),
            (True, []),
            "Tree's semantic meaning changed after reduction.",
        )
        self.assertEqual(
            compare_tables(table1, table2),
            (True, []),
            "Tree's semantic meaning doesn't match the Expected tree.",
        )

    def testSubtractRedundantConstraint(self):
        result = subtractRedundantConstraintTestCase()
        current, parentOfCurrent, dominantSet, commandSet, constraint, constraint2 = (
            itemgetter(
                "current",
                "parentOfCurrent",
                "dominantSet",
                "commandSet",
                "constraint",
                "constraint2",
            )(result)
        )

        table0 = generateReducedTruthTable(constraint, collectLiterals(constraint))

        action = reduceToElegance(parentOfCurrent, current, dominantSet, commandSet)
        match action:
            case ReductionSignal.DISCONNECT:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )

        table1 = generateReducedTruthTable(constraint, collectLiterals(constraint))
        table2 = generateReducedTruthTable(constraint2, collectLiterals(constraint2))
        self.assertTrue(
            compareTrees(constraint, constraint2),
            "Found tree doesn't match the Expected tree.",
        )
        self.assertEqual(
            compare_tables(table0, table1),
            (True, []),
            "Tree's semantic meaning changed after reduction.",
        )
        self.assertEqual(
            compare_tables(table1, table2),
            (True, []),
            "Tree's semantic meaning doesn't match the Expected tree.",
        )
        self.assertEqual(
            action, ReductionSignal.DELETE, "Action doesn't match the Expected action"
        )

    def testCutUnnecessaryOr(self):
        result = cutUnnecessaryOrTestCase()
        current, parentOfCurrent, dominantSet, commandSet, constraint, constraint2 = (
            itemgetter(
                "current",
                "parentOfCurrent",
                "dominantSet",
                "commandSet",
                "constraint",
                "constraint2",
            )(result)
        )

        table0 = generateReducedTruthTable(constraint, collectLiterals(constraint))

        action = reduceToElegance(parentOfCurrent, current, dominantSet, commandSet)
        match action:
            case ReductionSignal.DELETE:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )
            case ReductionSignal.DISCONNECT:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )

        table1 = generateReducedTruthTable(constraint, collectLiterals(constraint))
        table2 = generateReducedTruthTable(constraint2, collectLiterals(constraint2))
        self.assertTrue(
            compareTrees(constraint, constraint2),
            "Found tree doesn't match the Expected tree.",
        )
        self.assertEqual(
            compare_tables(table0, table1),
            (True, []),
            "Tree's semantic meaning changed after reduction.",
        )
        self.assertEqual(
            compare_tables(table1, table2),
            (True, []),
            "Tree's semantic meaning doesn't match the Expected tree.",
        )

    def testCutUnnecessaryAnd(self):
        result = cutUnnecessaryAndTestCase()
        current, parentOfCurrent, constraint, constraint2 = itemgetter(
            "current",
            "parentOfCurrent",
            "constraint",
            "constraint2",
        )(result)

        table0 = generateReducedTruthTable(constraint, collectLiterals(constraint))

        action = reduceToElegance(constraint, constraint, [], [])
        match action:
            case ReductionSignal.DELETE:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )
            case ReductionSignal.DISCONNECT:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )

        table1 = generateReducedTruthTable(constraint, collectLiterals(constraint))
        table2 = generateReducedTruthTable(constraint2, collectLiterals(constraint2))
        self.assertTrue(
            compareTrees(constraint, constraint2),
            "Found tree doesn't match the Expected tree.",
        )
        self.assertEqual(
            compare_tables(table0, table1),
            (True, []),
            "Tree's semantic meaning changed after reduction.",
        )
        self.assertEqual(
            compare_tables(table1, table2),
            (True, []),
            "Tree's semantic meaning doesn't match the Expected tree.",
        )
        self.assertEqual(
            action, ReductionSignal.KEEP, "Action doesn't match the Expected action"
        )

    def testZeroConstraintSubsumption(self):
        result = zeroConstraintSubsumptionTestCase()
        current, parentOfCurrent, dominantSet, commandSet, constraint, constraint2 = (
            itemgetter(
                "current",
                "parentOfCurrent",
                "dominantSet",
                "commandSet",
                "constraint",
                "constraint2",
            )(result)
        )
        table0 = generateReducedTruthTable(constraint, collectLiterals(constraint))

        action = reduceToElegance(parentOfCurrent, current, dominantSet, commandSet)
        match action:
            case ReductionSignal.DELETE:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )
            case ReductionSignal.DISCONNECT:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )

        table1 = generateReducedTruthTable(constraint, collectLiterals(constraint))
        table2 = generateReducedTruthTable(constraint2, collectLiterals(constraint2))
        self.assertTrue(
            compareTrees(constraint, constraint2),
            "Found tree doesn't match the Expected tree.",
        )
        self.assertEqual(
            compare_tables(table0, table1),
            (True, []),
            "Tree's semantic meaning changed after reduction.",
        )
        self.assertEqual(
            compare_tables(table1, table2),
            (True, []),
            "Tree's semantic meaning doesn't match the Expected tree.",
        )
        self.assertEqual(
            action,
            ReductionSignal.DISCONNECT,
            "Action doesn't match the Expected action.",
        )

    def testOneConstraintSubsumption(self):
        result = oneConstraintSubsumptionTestCase()
        current, parentOfCurrent, dominantSet, commandSet, constraint, constraint2 = (
            itemgetter(
                "current",
                "parentOfCurrent",
                "dominantSet",
                "commandSet",
                "constraint",
                "constraint2",
            )(result)
        )

        table0 = generateReducedTruthTable(constraint, collectLiterals(constraint))

        action = reduceToElegance(parentOfCurrent, current, dominantSet, commandSet)
        match action:
            case ReductionSignal.DELETE:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )
            case ReductionSignal.DISCONNECT:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )

        table1 = generateReducedTruthTable(constraint, collectLiterals(constraint))
        table2 = generateReducedTruthTable(constraint2, collectLiterals(constraint2))
        self.assertTrue(
            compareTrees(constraint, constraint2),
            "Found tree doesn't match the Expected tree.",
        )
        self.assertEqual(
            compare_tables(table0, table1),
            (True, []),
            "Tree's semantic meaning changed after reduction.",
        )
        self.assertEqual(
            compare_tables(table1, table2),
            (True, []),
            "Tree's semantic meaning doesn't match the Expected tree.",
        )

    def testOneConstraintComplementSubtraction(self):
        result = oneConstraintComplementSubtractionTestCase()
        current, parentOfCurrent, dominantSet, commandSet, constraint, constraint2 = (
            itemgetter(
                "current",
                "parentOfCurrent",
                "dominantSet",
                "commandSet",
                "constraint",
                "constraint2",
            )(result)
        )

        table0 = generateReducedTruthTable(constraint, collectLiterals(constraint))

        action = reduceToElegance(parentOfCurrent, current, dominantSet, commandSet)
        match action:
            case ReductionSignal.DELETE:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )
            case ReductionSignal.DISCONNECT:
                parentOfCurrent.children = findAndRemoveChild(
                    parentOfCurrent.children, current
                )

        table1 = generateReducedTruthTable(constraint, collectLiterals(constraint))
        table2 = generateReducedTruthTable(constraint2, collectLiterals(constraint2))
        self.assertTrue(
            compareTrees(constraint, constraint2),
            "Found tree doesn't match the Expected tree.",
        )
        self.assertEqual(
            compare_tables(table0, table1),
            (True, []),
            "Tree's semantic meaning changed after reduction.",
        )
        self.assertEqual(
            compare_tables(table1, table2),
            (True, []),
            "Tree's semantic meaning doesn't match the Expected tree.",
        )
        self.assertEqual(
            action, ReductionSignal.KEEP, "Action doesn't match the Expected action."
        )
