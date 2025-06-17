import re

class Node:
    def __init__(self, kind, value=None, children=None):
        self.kind = kind
        self.value = value
        self.children = children or []

    def __str__(self):
        def build_cons(nodes):
            if not nodes:
                return 'Nil'
            head = str(nodes[0])
            tail = build_cons(nodes[1:])
            return f"(Cons {head} {tail})"

        if self.kind == 'Tree':
            cons = build_cons(self.children)
            return f"(mkTree (mkNode {self.value}) {cons})"
        else:
            cons = build_cons(self.children)
            return f"(mkNullVex {cons})"

# Parser and utilities

def tokenize(s):
    return re.findall(r"\(|\)|Cons|mkTree|mkNode|mkNullVex|Nil|[A-Za-z0-9_]+", s)

class Parser:
    def __init__(self, tokens):
        self.tokens = tokens
        self.pos = 0
    def peek(self):
        return self.tokens[self.pos] if self.pos < len(self.tokens) else None
    def eat(self, tok=None):
        cur = self.peek()
        if tok and cur != tok:
            raise SyntaxError(f"Expected {tok} but got {cur}")
        self.pos += 1
        return cur
    def parse(self):
        if self.peek() == '(':
            self.eat('(')
            form = self.eat()
            if form == 'mkTree': node = self.parse_mkTree()
            elif form == 'mkNullVex': node = self.parse_mkNullVex()
            else: raise SyntaxError(f"Unknown form {form}")
            self.eat(')')
            return node
        elif self.peek() == 'Nil':
            self.eat('Nil')
            return None
        else:
            raise SyntaxError(f"Unexpected token: {self.peek()}")
    def parse_mkTree(self):
        self.eat('('); self.eat('mkNode'); value = self.eat(); self.eat(')')
        children = self.parse_cons()
        return Node('Tree', value, children)
    def parse_mkNullVex(self):
        children = self.parse_cons()
        return Node('Null', None, children)
    def parse_cons(self):
        if self.peek() == 'Nil': self.eat('Nil'); return []
        self.eat('('); self.eat('Cons')
        head = self.parse(); tail = self.parse_cons_item(); self.eat(')')
        return [head] + tail
    def parse_cons_item(self):
        if self.peek() == 'Nil': self.eat('Nil'); return []
        self.eat('('); self.eat('Cons')
        head = self.parse(); tail = self.parse_cons_item(); self.eat(')')
        return [head] + tail

# ID normalization

def normalize_id(id_input):
    if isinstance(id_input, str): parts = re.findall(r"\d+", id_input); nums = list(map(int, parts))
    elif isinstance(id_input, (list, tuple)): nums = [int(x) for x in id_input]
    elif isinstance(id_input, int): nums = [id_input]
    else: raise ValueError("Unsupported ID format")
    while len(nums) > 1 and nums[0] == 0: nums.pop(0)
    while len(nums) > 1 and nums[-1] == 0: nums.pop()
    return nums

# Core functions

def getById(tree_str, id_input):
    root = Parser(tokenize(tree_str)).parse()
    path = normalize_id(id_input)
    node = root
    if path == [0] or not path:
        return str(root)
    for idx in path:
        node = node.children[idx-1]
    return str(node)

def appendChild(tree_str, id_input, new_node_str):
    root = Parser(tokenize(tree_str)).parse()
    new_node = Parser(tokenize(new_node_str)).parse()
    path = normalize_id(id_input)
    target = root
    # Traverse to target
    if path != [0] and path:
        for idx in path:
            target = target.children[idx-1]
    # Append new node
    target.children.append(new_node)
    new_index = len(target.children)
    # Build new ID string wrapped in (mkNodeId ...)
    full_path = path + [new_index] if path and path != [0] else [new_index]
    new_id_str = f'(mkNodeId ({" ".join(str(i) for i in full_path)}))'
    return f"({str(root)} {new_id_str})"

def insertAbove(tree_str, id_input, new_node_str):
    root = Parser(tokenize(tree_str)).parse()
    new_node = Parser(tokenize(new_node_str)).parse()
    path = normalize_id(id_input)
    if path == [0] or not path:
        new_node.children.append(root)
        return str(new_node)
    parent = root
    for idx in path[:-1]:
        parent = parent.children[idx-1]
    target_idx = path[-1] - 1
    target = parent.children[target_idx]
    new_node.children.append(target)
    parent.children[target_idx] = new_node
    return str(root)

def replaceNode(tree_str, id_input, new_node_str):
    root = Parser(tokenize(tree_str)).parse()
    replacement = Parser(tokenize(new_node_str)).parse()
    path = normalize_id(id_input)
    if path == [0] or not path:
        replacement.children = root.children
        return str(replacement)
    parent = root
    for idx in path[:-1]:
        parent = parent.children[idx-1]
    orig = parent.children[path[-1]-1]
    replacement.children = orig.children
    parent.children[path[-1]-1] = replacement
    return str(root)

# if __name__ == "__main__":
#     tree = """(mkTree (mkNode AND)
#                 (Cons (mkTree (mkNode A) Nil) 
#                 (Cons (mkTree (mkNode B) Nil) 
#                 (Cons (mkTree (mkNode OR) 
#                     (Cons (mkTree (mkNode AND) 
#                         (Cons (mkTree (mkNode C) Nil) Nil)) 
#                         (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))"""

#     # Test getById
#     print("getById tests:")
#     print(getById(tree, '3'))  # Expected: (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil)))
#     print(getById(tree, '(3 1 1)'))  # Expected: (mkTree (mkNode C) Nil)

#     # Test appendChild
#     print("\nappendChild tests:")
#     print(appendChild(tree, '3', '(mkTree (mkNode E) Nil)'))  # Expected: ((mkTree (mkNode AND) (Cons ... (Cons (mkTree (mkNode E) Nil) Nil)))) (3 3))
#     print(appendChild(tree, '0', '(mkNullVex Nil)'))  # Expected: ((mkTree (mkNode AND) (Cons ... (Cons (mkNullVex Nil) Nil))) (4))

#     # Test insertAbove
#     print("\ninsertAbove tests:")
#     print(insertAbove(tree, '(3 1)', '(mkTree (mkNode XOR) Nil)'))  # Expected: (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode XOR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))
#     print(insertAbove(tree, '1', '(mkTree (mkNode NOT) Nil)'))  # Expected: (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))

#     # Test replaceNode
#     print("\nreplaceNode tests:")
#     print(replaceNode(tree, '3', '(mkTree (mkNode XOR) Nil)'))  # Expected: (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode XOR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode C) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))
#     print(replaceNode(tree, '(3 1 1)', '(mkTree (mkNode E) Nil)'))  # Expected: (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode E) Nil) Nil)) (Cons (mkTree (mkNode D) Nil) Nil))) Nil))))