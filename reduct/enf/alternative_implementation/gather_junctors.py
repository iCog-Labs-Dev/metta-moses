from alternative_implementation.Node import Node

def gather_junctors(current_node:Node, parent_node:Node):
    match current_node.node_type:
        case 'ROOT':
            current_node.node_type = 'AND'
            current_node.guard_set = []
            gather_junctors(current_node.right, current_node)
            return current_node
        case 'AND'|'OR':
            if current_node.node_type == parent_node.node_type:
                gather_junctors(current_node.right, current_node)
                gather_junctors(current_node.left,current_node)
            else:
                parent_node.children_list.append(current_node)
            if current_node.node_type == 'AND':
                current_node.guard_set = []
            return None
        case 'LITERAL':
            if(parent_node.node_type == 'AND'):
                parent_node.guard_set.append(current_node.val)
            else:
                current_node.node_type = 'AND'
                parent_node.guard_set.append(current_node.val)
                parent_node.children_list.append(current_node)
            return None
                
            