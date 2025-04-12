
class Node:
    def __init__(self, node_type,val):
        self.node_type = node_type
        self.val = val
        self.left = None
        self.right = None
        self.guard_set = []
        self.children_list = []
        
class Tree:
   def __init__(self,root):
       self.root = Node("ROOT", root)
    

        
    