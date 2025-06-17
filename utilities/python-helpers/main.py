from .listMethods import *
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom


def py_exprToList(metta: MeTTa, expr):
    expr = str(expr)
    result = exprToList(expr)
    return metta.parse_all(result)


def py_listToExpr(metta: MeTTa, list):
    list = str(list)
    result = listToExpr(list)
    return metta.parse_all(result)


@register_atoms(pass_metta=True)
def main(metta):
    exprToList = OperationAtom(
        "py_exprToList",
        lambda expr: py_exprToList(metta, expr),
        ["Atom", "Atom"],
        unwrap=False,
    )
    listToExpr = OperationAtom(
        "py_listToExpr",
        lambda list_str: py_listToExpr(metta, list_str),
        ["Atom", "Atom"],
        unwrap=False,
    )

    return {
        r"py_exprToList": exprToList,
        r"py_listToExpr": listToExpr,
    }
