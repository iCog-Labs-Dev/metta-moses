import unittest


def tokenizeExpr(expr: str):
    expr = expr.strip()
    stack = []
    matches = []

    begin = None

    for i, char in enumerate(expr):
        if char == "(":
            if begin is None:
                begin = i
            stack.append(char)
        elif char == ")":
            if stack:
                stack.pop()
                if not stack:
                    matches.append(expr[begin : i + 1])
                    begin = None

    return matches


def exprToList(expr: str):
    def tokenize(expr: str):
        expr = expr.strip()
        expr = expr[1:-1]

        matches = tokenizeExpr(expr)

        for substr in matches:
            expr = expr.replace(substr, "")

        return matches + expr.split()

    tokens = tokenize(expr)
    list = "Nil"

    for token in reversed(tokens):
        list = f"(Cons {token} {list})"

    return list


class TestListMethods(unittest.TestCase):
    def test_expr_to_list(self):
        self.assertEqual(exprToList("(A B C)"), "(Cons A (Cons B (Cons C Nil)))")
        self.assertEqual(
            exprToList("((A) (B) (C))"), "(Cons (A) (Cons (B) (Cons (C) Nil)))"
        )
        self.assertEqual(
            exprToList("((mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (B) (C) D E)"),
            "(Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (B) (Cons (C) (Cons D (Cons E Nil)))))",
        )
        self.assertEqual(
            exprToList("(A (B C E) D E)"),
            "(Cons (B C E) (Cons A (Cons D (Cons E Nil))))",
        )


# if __name__ == "__main__":
#     unittest.main()
