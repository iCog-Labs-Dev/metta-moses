from random import random
TREE_SIZE = 15
structure = [0]*TREE_SIZE
def generate_reduced_permutation(left, right,level=0,split_point = 0):
    if left == right:
        structure[left] = level
    else:
        split_point = pick_one(left,right)
        structure[split_point] = level
        middle = (left + right)//2
        if left < middle:
            generate_reduced_permutation(left,split_point - 1,level+1,split_point)
        else:
            generate_reduced_permutation(split_point + 1,right,level+1,split_point)


def pick_one(left,right):
    
    val = random()
    print(val)
    if val > 0.5:
        return right
    return left

generate_reduced_permutation(1,2)

print(structure)




    
    
