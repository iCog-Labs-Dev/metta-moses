from unittest import TestCase
from Tests.TestHelpers import compare_tables, rteRunner
from Tests.EnfRuleCheckers import (
    ruleOne,
    ruleTwo,
    ruleThree,
    ruleFour,
    ruleFive,
    ruleSix,
    ruleSeven,
)

EXPRESSIONS = [
    "!(a)",
    "!(!(a))",
    "!(&(a, b))",
    "!(|(a, b))",
    "!(!(&(a, b)))",
    "!(!(|(a, b)))",
    "!(&(|(a, b), &(c,d)))",
    "!(&(|(a, b), &(c,d)))",
    "&(a, a)",
    "&(a, &(a, c))",
    "&(&(a,b),|(c,d))",
    "&(a, &(b, &(c, &(d,c))))",
    "&(a, |(b, &(c, |(d, |(e, a)))))",
    "&(!(|(|(a, &(!(b), a)), c)), b)",  # Example from Holman paper (page 19)
    "&(a, |(b, &(c, |(d,&(e, !(a))))))",
    "&(a, &(b, &(a, &(a, a))))",
    "&(a, &(b, &(c, &(d, !(b)))))",
    "&(b, !(|(c, |(a, &(!(b), a)))))",
    "&(b, !(|(c, |(a, &(!(b), |(k,x))))))",
    "&(&(&(!(a), |(!(b), !(a))), !(c)), b)",  # Example from Holman paper (page 19)
    "&(b, !(|(c, |(a, &(&(b, &(c, d)), a)))))",
    "&(a, &(b, &(c, &(|(a, |(b, |(c, a))), &(b, &(&(a, a), !(a)))))))",
    "|(a, b)",
    "|(a, a)",
    "|(&(a, b), |(a, c))",
    "|(&(a, b), &(a, b))",
    "|(&(a, b), |(c, d))",
    "|(!(a), |(!(c), !(d)))",
    "|(&(a, |(!(b), !(c))), d)",
    "|(a, |(b, |(c, |(d, c))))",
    "|(a, &(b, &(c, &(d, c))))",
    "|(&(!(a), b), |(!(c), !(d)))",
    "|(a, |(b, |(c, |(d, !(c)))))",
    "|(&(a, b), |(&(a, c), &(a, d)))",
    "|(&(a, b), &(a, &(c, |(d, &(e, a)))))",
    "|(&(a, b), &(a, &(c, |(d, |(e, a)))))",
    "|(&(a, b), &(a, &(c, |(d, |(e, !(a))))))",
    "|(&(a, b), &(a, &(c, |(d, &(e, !(a))))))",
    "|(|(!(a), &(a, &(b,c))), &(b, &(c, !(b))))",
    "|(|(!(a), &(a, &(b, c))), &(b, &(c, !(b))))",
    "|(|(!(a), &(a, &(b, c))), &(c, &(b, !(b))))",
    "|(&(&(c, a), d), |(&(c, a), &(&(c, a), e)))",
    "|(|(&(a,b), &(a, &(c, d))), &(a, &(c, &(e, !(a)))))",
    "|(&(a, b), |(&(a, &(c, d)), |(&(a, &(c, e)), &(c, a))))",
    "|(g, &(a, &(b, &(|(!(c), |(!(d), e)), |(c, &(c, f))))))",  # Example from Mosh's paper. Expected output: "|(g,&(a, &(b, &(c, |(!(d), e)))))"
    "|(g,&(a, &(b, &(c, |(!(d), e)))))",  # Reduced form of the above expression from Mosh's paper.
]


class GeneralTests(TestCase):
    def testSemanticMeaning(self):
        for index, input in enumerate(EXPRESSIONS):
            constraintTree, table1, table2 = rteRunner(input)

            self.assertTrue(
                compare_tables(table1, table2),
                f"Test case {index} failed. {input} changed its semantic meaning after algorithm application.",
            )

    def testEnfRules(self):
        for index, input in enumerate(EXPRESSIONS):
            constraintTree, table1, table2 = rteRunner(input)
            if constraintTree:
                enfRules = [
                    ruleOne,
                    ruleTwo,
                    ruleThree,
                    ruleFour,
                    ruleFive,
                    ruleSix,
                    ruleSeven,
                ]

                for ruleIndex, rule in enumerate(enfRules):
                    self.assertTrue(
                        rule(constraintTree),
                        f"Test case {index} failed. Enf Rule {ruleIndex} failed.",
                    )
