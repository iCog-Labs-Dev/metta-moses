import pytest
from treeMethods import getById, appendChild, insertAbove, replaceNode

tree = """(mkTree (mkNode AND) 
                (Cons (mkTree (mkNode A) Nil) 
                (Cons (mkTree (mkNode B) Nil) 
                (Cons (mkTree (mkNode OR) 
                    (Cons (mkTree (mkNode AND) 
                        (Cons (mkTree (mkNode C) Nil) Nil)) 
                        (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"""

def test_getById():
    assert getById(tree, '3') == "(mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil)))"
    assert getById(tree, '(3 1 1)') == "(mkTree (mkNode C) Nil)"

def test_appendChild():
    assert appendChild(tree, '3', '(mkTree (mkNode E) Nil)') == "((mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil)))) Nil)))) (mkNodeId (3 3)))"
    assert appendChild(tree, '0', '(mkNullVex Nil)') == "((mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) (Cons (mkNullVex Nil) Nil))))) (mkNodeId (4)))"

def test_insertAbove():
    assert insertAbove(tree, '(3 1)', '(mkTree (mkNode XOR) Nil)') == "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode XOR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"
    assert insertAbove(tree, '1', '(mkTree (mkNode NOT) Nil)') == "(mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"

def test_replaceNode():
    assert replaceNode(tree, '3', '(mkTree (mkNode XOR) Nil)') == "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode XOR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"
    assert replaceNode(tree, '(3 1 1)', '(mkTree (mkNode E) Nil)') == "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode E) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"