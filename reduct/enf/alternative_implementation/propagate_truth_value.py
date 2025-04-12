from .Node import Node
# from typing import Boolean
def propagate_truth_value(curr_node:Node,parent_node:Node) -> Node:
    match curr_node.node_type:
        case "ROOT":
            parent_node = curr_node
            curr_node.right = propagate_truth_value(curr_node.right,parent_node)
            
            return curr_node
        case "NOT":
            parent_node = curr_node
            curr_node.val = not(curr_node.val)
            return propagate_truth_value(curr_node.right,parent_node)
        case "OR" | "AND":
            if(parent_node.node_type == "NOT"):
                curr_node.val = not(curr_node.val)
            if curr_node.val == False:
                if curr_node.node_type == "OR":
                    curr_node.node_type = "AND"
                else:
                    curr_node.node_type = "OR"
                parent_node = curr_node
                curr_node.left = propagate_truth_value(curr_node.left,parent_node)
                curr_node.right = propagate_truth_value(curr_node.right,parent_node)
            return curr_node
        case "LITERAL":
            return curr_node

            