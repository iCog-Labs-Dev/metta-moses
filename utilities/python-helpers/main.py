from .treeMethods import *
from hyperon import *
from hyperon.ext import register_atoms
from hyperon.atoms import OperationAtom, V


def py_appendChild (metta:MeTTa, tree, nodeId, child):
    tree = str(tree)
    nodeId = str(nodeId)
    nodeId = nodeId[len("(mkNodeId "):-1]
    child = str (child)
    result = appendChild(tree, nodeId, child)
    return metta.parse_all(result)

def py_replace (metta:MeTTa, tree, nodeId, child):
    tree = str(tree)
    nodeId = str(nodeId)
    nodeId = nodeId[len("(mkNodeId "):-1]
    print("nodeId", nodeId)
    child = str (child)
    result = replaceNode(tree, nodeId, child)
    return metta.parse_all(result)

def py_getById (metta: MeTTa, tree , nodeId):
    tree = str(tree)
    nodeId = str(nodeId)
    nodeId = nodeId[len("(mkNodeId "):-1]
    result = getById(tree, nodeId)
    return metta.parse_all(result)

def py_insertAbove (metta: MeTTa, tree , nodeId, child):
    tree = str(tree)
    nodeId = str(nodeId)
    nodeId = nodeId[len("(mkNodeId "):-1]
    child = str (child)
    result = insertAbove (tree, nodeId, child)
    return metta.parse_all(result)

@register_atoms(pass_metta=True)
def main(metta):
    append = OperationAtom ( "py_appendChild",  lambda tree, nodeId, child: py_appendChild(metta,  tree, nodeId, child),
                             ['Atom', 'Atom' ,'Atom' ,'Atom'], unwrap=False)
    replace = OperationAtom ( "py_replace", lambda tree, nodeId , node: py_replace (metta, tree, nodeId, node),
                            ['Atom', 'Atom', 'Atom', 'Atom'], unwrap=False)

    getById = OperationAtom ( "py_getById", lambda tree, nodeId: py_getById (metta, tree, nodeId),
                            ['Atom', 'Atom', 'Atom'], unwrap=False)

    insertAbove = OperationAtom ( "py_insertAbove", lambda tree, nodeId, node: py_insertAbove (metta, tree, nodeId, node),
                            ['Atom', 'Atom', 'Atom', 'Atom'], unwrap=False)
    return {

        r"py_appendChild": append,
        r"py_replace": replace,
        r"py_getById": getById,
        r"py_insertAbove": insertAbove,
        }
