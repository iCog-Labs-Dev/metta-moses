import pytest
from listMethods import exprToList, listToExpr

def test_expr_to_list():
    assert exprToList("(A B C)") == "(Cons A (Cons B (Cons C Nil)))"
    assert exprToList("((mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (B) (C) D E)") == \
        "(Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (B) (Cons (C) (Cons D (Cons E Nil)))))"
    assert exprToList("(A (B C E) D E)") == "(Cons (B C E) (Cons A (Cons D (Cons E Nil))))"

def test_list_to_expr():
    assert listToExpr("(Cons A (Cons B (Cons C Nil)))") == "(A B C)"
    assert listToExpr("(Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (B) (Cons (C) (Cons D (Cons E Nil)))))") == \
    "((mkInst (0 1 2)) (B) (C) D E)"
    assert listToExpr("(Cons (B C E) (Cons A (Cons D (Cons E Nil))))") == "((B C E) A D E)"