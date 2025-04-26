def tokenize(expr):
    return expr.replace('(', ' ( ').replace(')', ' ) ').split()

def parse_tree(tokens):
    id_map = {}
    tuple_map = {}
    id_counter = [0]
    parent_map = {}  # Maps node ID to (parent_id, position)

    def parse(index, parent=None, position=None):
        if index >= len(tokens) or tokens[index] != '(':
            return None, index

        index += 1  # skip (
        node_type = tokens[index]
        if node_type not in ('mkTree', 'mkNullVex'):
            return None, index
        index += 1  # skip node_type

        if node_type == 'mkTree':
            if index >= len(tokens) or tokens[index] != '(' or tokens[index + 1] != 'mkNode':
                return None, index
            index += 2  # skip ( mkNode
            node_val = tokens[index]
            index += 1  # skip node value
            if tokens[index] != ')':
                return None, index
            index += 1  # skip )
            node_str = f"(mkNode {node_val})"
        else:  # mkNullVex
            node_str = "mkNullVex"  # Placeholder for null vertex

        curr_id = id_counter[0]
        id_counter[0] += 1
        curr_tuple = (curr_id,)
        id_map[curr_id] = [node_str, []]
        tuple_map[curr_tuple] = id_map[curr_id]

        if parent is not None and position is not None:
            tuple_map[parent + (position,)] = id_map[curr_id]
            parent_map[curr_id] = (parent[0], position)

        # children
        if index < len(tokens) and tokens[index] == 'Nil':
            index += 1
        elif index < len(tokens) and tokens[index] == '(' and tokens[index + 1] == 'Cons':
            index += 1  # skip (
            children = []
            child_pos = 1
            while index < len(tokens) and (tokens[index] == 'Cons' or (tokens[index] == '(' and tokens[index + 1] == 'Cons')):
                if tokens[index] == '(':
                    index += 1
                index += 1  # skip 'Cons'
                child, index = parse(index, curr_tuple, child_pos)
                if child is None:
                    break
                children.append(child)
                id_map[curr_id][1].append(child)
                child_pos += 1
                if index < len(tokens) and tokens[index] == 'Nil':
                    index += 1
                    break
                elif index < len(tokens) and tokens[index] == ')':
                    index += 1
            if index < len(tokens) and tokens[index] == ')':
                index += 1

        if index < len(tokens) and tokens[index] == ')':
            index += 1

        return id_map[curr_id], index

    root, _ = parse(0)
    return root, id_map, tuple_map, parent_map

def to_tree_string(node):
    if not node[1]:
        if node[0] == "mkNullVex":
            return "(mkNullVex Nil)"
        return f"(mkTree {node[0]} Nil)"
    children = "Nil"
    for child in reversed(node[1]):
        children = f"(Cons {to_tree_string(child)} {children})"
    if node[0] == "mkNullVex":
        return f"(mkNullVex {children})"
    return f"(mkTree {node[0]} {children})"

def parse_child(child_str):
    tokens = tokenize(child_str)
    child_node, _, _, _ = parse_tree(tokens)
    return child_node

def append_child(tree_str, id_input, child_str):
    tokens = tokenize(tree_str)
    root, id_map, tuple_map, _ = parse_tree(tokens)

    # Determine ID key
    if id_input.startswith("("):
        id_key = tuple(int(x) for x in id_input.strip("()").split())
    else:
        id_key = int(id_input)

    if isinstance(id_key, tuple) and id_key[-1] == 0:
        id_key = id_key[0]

    target_node = id_map[id_key] if isinstance(id_key, int) else tuple_map[id_key]
    new_child = parse_child(child_str)
    target_node[1].append(new_child)

    return to_tree_string(root)

def replaceNode(tree_str, id_input, new_node_str):
    tokens = tokenize(tree_str)
    root, id_map, tuple_map, parent_map = parse_tree(tokens)

    # Parse id_input
    if id_input.startswith("("):
        id_key = tuple(int(x) for x in id_input.strip("()").split())
    else:
        id_key = int(id_input)

    # Handle operator tuple
    if isinstance(id_key, tuple) and id_key[-1] == 0:
        id_key = id_key[0]

    # Parse new node
    new_node = parse_child(new_node_str)

    # Replace node
    if id_key == 0:
        return to_tree_string(new_node)
    
    if isinstance(id_key, int):
        target_id = id_key
    else:
        for single_id, node in id_map.items():
            if node == tuple_map[id_key]:
                target_id = single_id
                break
        else:
            return to_tree_string(root)  # ID not found

    parent_id, position = parent_map[target_id]
    id_map[parent_id][1][position - 1] = new_node

    return to_tree_string(root)

def getNodeID(tree_str, id_input):
    """
    Process a tree representation and return the node corresponding to a given ID.
    
    Args:
        tree_str: A string representing the tree structure
        id_input: A string, either a single number or a tuple in parentheses
        
    Returns:
        The corresponding node as a string
    """
    tokens = tokenize(tree_str)
    root, id_map, tuple_map, _ = parse_tree(tokens)

    # Parse id_input
    if id_input.startswith('('):
        id_key = tuple(int(x) for x in id_input.strip('()').split())
    else:
        id_key = int(id_input)

    # Retrieve node
    if isinstance(id_key, int):
        if id_key in id_map:
            return to_tree_string(id_map[id_key])
    else:
        if id_key in tuple_map:
            return to_tree_string(tuple_map[id_key])
        # Special case for tuple ending in 0
        elif len(id_key) > 1 and id_key[-1] == 0 and id_key[0] in id_map:
            return to_tree_string(id_map[id_key[0]])

    return "ID not found"

def insert_above(tree_str, id_input, new_node_str):
    tokens = tokenize(tree_str)
    root, id_map, tuple_map, parent_map = parse_tree(tokens)

    # Parse id_input
    if id_input.startswith("("):
        id_key = tuple(int(x) for x in id_input.strip("()").split())
    else:
        id_key = int(id_input)

    # Handle operator tuple
    if isinstance(id_key, tuple) and id_key[-1] == 0:
        id_key = id_key[0]

    # Get target node
    target_node = None
    if isinstance(id_key, int):
        if id_key in id_map:
            target_node = id_map[id_key]
    else:
        if id_key in tuple_map:
            target_node = tuple_map[id_key]

    if not target_node:
        return to_tree_string(root)  # ID not found

    # Parse new node
    new_node = parse_child(new_node_str)
    # Append target node as child of new node
    new_node[1].append(target_node)

    # Replace node
    if id_key == 0:
        return to_tree_string(new_node)
    
    if isinstance(id_key, int):
        target_id = id_key
    else:
        for single_id, node in id_map.items():
            if node == tuple_map[id_key]:
                target_id = single_id
                break
        else:
            return to_tree_string(root)  # ID not found

    parent_id, position = parent_map[target_id]
    id_map[parent_id][1][position - 1] = new_node

    return to_tree_string(root)

# # Example usage
# if __name__ == "__main__":
#     tree = "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))"
#     t = "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode A) Nil) Nil)) (Cons (mkTree (mkNode B) Nil) Nil))) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) (Cons (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) Nil))))))) Nil))))"
#     new_node = "(mkTree (mkNode XOR) Nil)"
#     print("GetNodeID 0 (simple tree):")
#     print(getNodeID(tree, "0"))
#     print("GetNodeID 0 (complex tree with mkNullVex):")
#     print(getNodeID(t, "0"))
#     print("Insert above (2 1) (simple tree):")
#     print(insert_above(tree, "(2 1)", new_node))
# Example usage
if __name__ == "__main__":
    tree = "(mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))"
    child = "(mkTree (mkNode D) Nil)"
    new_node = "(mkTree (mkNode XOR) Nil)"
    t = "(mkTree (mkNode AND) (Cons (mkTree (mkNode X) Nil) (Cons (mkTree (mkNode OR)(Cons (mkTree (mkNode Y) Nil)(Cons (mkTree (mkNode Z) Nil) Nil))) Nil)))"

    # print("Append (2 0):")
    # print(append_child(tree, "(2 1)", child))
    print("Replace (2 1):")
    print(replaceNode(tree, "(2 1)", child))
    print("Replace 2:")
    print(replaceNode(tree, "2", child))
    print("Replace 0:")
    print(replaceNode(t, "0", child))
    print(getNodeID(tree, "(2 0)"))
    # print(insert_above(tree, "0", new_node))   
    print(insert_above(tree, "(2 1)", new_node))

    t = "(mkTree (mkNode AND) (Cons (mkTree (mkNode X) Nil) (Cons (mkTree (mkNode OR)(Cons (mkTree (mkNode Y) Nil)(Cons (mkTree (mkNode Z) Nil) Nil))) Nil)))"
   
    
    