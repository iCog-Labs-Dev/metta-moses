from enum import Enum


class NodeType(Enum):
    AND = "AND"
    OR = "OR"
    NOT = "NOT"
    LITERAL = "LITERAL"
    ROOT = "ROOT"


class BinaryExpressionTreeNode:
    def __init__(self, value: str):
        self.left: BinaryExpressionTreeNode | None = None
        self.right: BinaryExpressionTreeNode | None = None
        self.value: str = value
        self.type: NodeType = NodeType.LITERAL


class TreeNode:
    def __init__(self, value: str, constraint: bool = False):
        self.value: str = value
        self.left: TreeNode | None = None
        self.right: TreeNode | None = None
        self.constraint: bool = constraint
        self.guardSet: list[TreeNode] = []
        self.children: list[TreeNode] = []
        self.type: NodeType = NodeType.LITERAL

    def __hash__(self):
        return hash((self.value, self.constraint, self.type))

    def __repr__(self):
        return f"TreeNode(value={self.value}, constraint={self.constraint}, type={self.type})"
    
    def __eq__(self, other: object) -> bool:
        if not isinstance(other, TreeNode):
            return NotImplemented
        return (
            self.value == other.value
            and self.constraint == other.constraint
            and self.type == other.type
        )
    def __repr__(self):
        return f"TreeNode(value={self.value}, constraint={self.constraint}, type={self.type})"

    # def __eq__(self, other: TreeNode):
    #     if self.value == other.value and self.constraint == other.constrant:
    #         return True
    #     return False

    # def __str__(self):
    #     return f"({self.value},{self.constraint})"

    # def __repr__(self):
    #     return f"({self.value},{self.constraint})"


def findAndRemoveChild(children: list[TreeNode], child: TreeNode) -> list[TreeNode]:
    if not children:
        return []

    result = []
    found = False

    for c in children:
        if not found and id(c) == id(child):
            found = True  # Skip the first occurrence of the child
        else:
            result.append(c)

    return result
