from DataStructures.Trees import NodeType, TreeNode

a = TreeNode("a")
b = TreeNode("b")
c = TreeNode("c")
d = TreeNode("d")
e = TreeNode("e")
f = TreeNode("f")

aprime = TreeNode("a")
bprime = TreeNode("b")
cprime = TreeNode("c")
dprime = TreeNode("d")
eprime = TreeNode("e")
fprime = TreeNode("f")

a.constraint = True
b.constraint = True
c.constraint = True
d.constraint = True
e.constraint = True
f.constraint = True

or11 = TreeNode("OR")
or12 = TreeNode("OR")
or21 = TreeNode("OR")
or22 = TreeNode("OR")
or11.type = NodeType.OR
or12.type = NodeType.OR
or21.type = NodeType.OR
or22.type = NodeType.OR

or112 = TreeNode("OR")
or122 = TreeNode("OR")
or212 = TreeNode("OR")
or222 = TreeNode("OR")
or112.type = NodeType.OR
or122.type = NodeType.OR
or212.type = NodeType.OR
or222.type = NodeType.OR

and11 = TreeNode("AND")
and12 = TreeNode("AND")
and13 = TreeNode("AND")
and14 = TreeNode("AND")
and21 = TreeNode("AND")
and22 = TreeNode("AND")
and23 = TreeNode("AND")
and24 = TreeNode("AND")
and11.type = NodeType.AND
and12.type = NodeType.AND
and13.type = NodeType.AND
and14.type = NodeType.AND
and21.type = NodeType.AND
and22.type = NodeType.AND
and23.type = NodeType.AND
and24.type = NodeType.AND

and112 = TreeNode("AND")
and122 = TreeNode("AND")
and132 = TreeNode("AND")
and142 = TreeNode("AND")
and212 = TreeNode("AND")
and222 = TreeNode("AND")
and232 = TreeNode("AND")
and242 = TreeNode("AND")
and112.type = NodeType.AND
and122.type = NodeType.AND
and132.type = NodeType.AND
and142.type = NodeType.AND
and212.type = NodeType.AND
and222.type = NodeType.AND
and232.type = NodeType.AND
and242.type = NodeType.AND

constraint = TreeNode("AND")
constraint.type = NodeType.AND

constraint2 = TreeNode("AND")
constraint2.type = NodeType.AND


def deleteInconsistentHandleTestCase():
    """
    Builds and returns test case for Inconsistent Handle (InConHandle) transformation.

    Args: None

    Returns:
        A dictionary containing like the following:
            {
                "current": current,
                "parentOfCurrent": parentOfCurrent,
                "dominantSet": dominantSet,
                "commandSet": commandSet,
                "constraint2": constraint2
            }
        - "current": the current node before transformation.
        - "parentOfCurrent": the parent of the current before transformation.
        - "dominantSet": dominant set of current node.
        - "commandSet": the command set of current node.
        - "constraint2": the root of the constraint tree after transformation.

    """

    and11.guardSet = [b]
    and12.guardSet = [c]
    and21.guardSet = [aprime]
    and22.guardSet = [b]
    constraint.guardSet = [a]

    and21.children = [or11]
    constraint.children = [or21]
    or11.children = [and11, and12]
    or21.children = [and21, and22]

    or112 = TreeNode("OR")
    or112.type = NodeType.OR

    and112.guardSet = [b]
    constraint2.guardSet = [a]

    or112.children = [and112]
    constraint2.children = [or112]

    current = and21
    parentOfCurrent = or21
    dominantSet = [a]
    commandSet = [b]

    return {
        "current": current,
        "parentOfCurrent": parentOfCurrent,
        "dominantSet": dominantSet,
        "commandSet": commandSet,
        "constraint": constraint,
        "constraint2": constraint2,
    }


def promoteCommonConstraintsTestCase():
    """
    Builds and returns test case for promote common constraint (Promote) transformation.

    Args: None

    Returns:
        A dictionary containing like the following:
            {
                "current": current,
                "parentOfCurrent": parentOfCurrent,
                "dominantSet": dominantSet,
                "commandSet": commandSet,
                "constraint2": constraint2
            }
        - "current": the current node before transformation.
        - "parentOfCurrent": the parent of the current before transformation.
        - "dominantSet": dominant set of current node.
        - "commandSet": the command set of current node.
        - "constraint2": the root of the constraint tree after transformation.

    """

    and11.guardSet = [bprime, c]
    and12.guardSet = [bprime]
    and13.guardSet = [cprime]
    and14.guardSet = [bprime, dprime]

    or11.children = [and11, and12]
    or12.children = [and13, and14]

    constraint.guardSet = [a]
    constraint.children = [or11, or12]

    and112.guardSet = [c]
    and122.guardSet = []
    and132.guardSet = [cprime]
    and142.guardSet = [bprime, dprime]

    or112.children = [and112, and122]
    or122.children = [and132, and142]

    constraint2.guardSet = [a, bprime]
    constraint2.children = [or112, or122]

    current = or11
    parentOfCurrent = constraint
    dominantSet = [a]
    commandSet = []

    return {
        "current": current,
        "parentOfCurrent": parentOfCurrent,
        "dominantSet": dominantSet,
        "commandSet": commandSet,
        "constraint": constraint,
        "constraint2": constraint2,
    }


def subtractRedundantConstraintTestCase():
    """
    Builds and returns test case for subtract redundant constraint (Redundant) transformation.

    Args: None

    Returns:
        A dictionary containing like the following:
            {
                "current": current,
                "parentOfCurrent": parentOfCurrent,
                "dominantSet": dominantSet,
                "commandSet": commandSet,
                "constraint2": constraint2
            }
        - "current": the current node before transformation.
        - "parentOfCurrent": the parent of the current before transformation.
        - "dominantSet": dominant set of current node.
        - "commandSet": the command set of current node.
        - "constraint2": the root of the constraint tree after transformation.

    """

    and11.guardSet = [a, c, dprime]
    and12.guardSet = [a]
    and21.guardSet = [bprime, c]
    and22.guardSet = [eprime]
    constraint.guardSet = [a]

    or11.children = [and11, and12]
    or21.children = [and21, and22]
    and21.children = [or11]
    constraint.children = [or21]

    and112.guardSet = [dprime]
    and122.guardSet = [a]
    and212.guardSet = [bprime, c]
    and222.guardSet = [eprime]
    constraint2.guardSet = [a]

    or112.children = [and112, and122]
    or212.children = [and212, and222]
    and212.children = [or112]
    constraint2.children = [or212]

    current = and11
    parentOfCurrent = or11
    dominantSet = [bprime, c, a]
    commandSet = [a, eprime]

    return {
        "current": current,
        "parentOfCurrent": parentOfCurrent,
        "dominantSet": dominantSet,
        "commandSet": commandSet,
        "constraint": constraint,
        "constraint2": constraint2,
    }


def cutUnnecessaryOrTestCase():
    """
    Builds and returns test case for cut unnecessary OR (OrCut) transformation.

    Args: None

    Returns:
        A dictionary containing like the following:
            {
                "current": current,
                "parentOfCurrent": parentOfCurrent,
                "dominantSet": dominantSet,
                "commandSet": commandSet,
                "constraint2": constraint2
            }
        - "current": the current node before transformation.
        - "parentOfCurrent": the parent of the current before transformation.
        - "dominantSet": dominant set of current node.
        - "commandSet": the command set of current node.
        - "constraint2": the root of the constraint tree after transformation.

    """

    and11.guardSet = [dprime]
    and21.guardSet = [b]
    and22.guardSet = [cprime]
    constraint.guardSet = [a]

    or11.children = [and11]
    or21.children = [and21, and22]
    and21.children = [or11]
    constraint.children = [or21]

    and212.guardSet = [b, dprime]
    and222.guardSet = [cprime]
    and112.guardSet = []

    constraint2.guardSet = [a]

    or212.children = [and212, and222]
    or112.children = [and112]
    and212.children = [or112]
    constraint2.children = [or212]

    current = or11
    parentOfCurrent = and21
    dominantSet = [a, b]
    commandSet = []

    return {
        "current": current,
        "parentOfCurrent": parentOfCurrent,
        "dominantSet": dominantSet,
        "commandSet": commandSet,
        "constraint": constraint,
        "constraint2": constraint2,
    }


def cutUnnecessaryAndTestCase():
    """
    Builds and returns test case for cut unnecessary AND (AndCut) transformation.

    Args: None

    Returns:
        A dictionary containing like the following:
            {
                "current": current,
                "parentOfCurrent": parentOfCurrent,
                "dominantSet": dominantSet,
                "commandSet": commandSet,
                "constraint2": constraint2
            }
        - "current": the current node before transformation.
        - "parentOfCurrent": the parent of the current before transformation.
        - "dominantSet": dominant set of current node.
        - "commandSet": the command set of current node.
        - "constraint2": the root of the constraint tree after transformation.

    """

    and11.guardSet = [b, d]
    and12.guardSet = [eprime]
    and21.guardSet = []
    and22.guardSet = [c]
    constraint.guardSet = [a]

    or11.children = [and11, and12]
    or21.children = [and21, and22]
    and21.children = [or11]
    constraint.children = [or21]

    and112.guardSet = [b, d]
    and122.guardSet = [eprime]
    and132.guardSet = [c]
    constraint2.guardSet = [a]

    or112.children = [
        and132,
        and112,
        and122,
    ]
    constraint2.children = [or112]

    current = and21
    parentOfCurrent = or21
    dominantSet = [a]
    commandSet = [c]

    return {
        "current": current,
        "parentOfCurrent": parentOfCurrent,
        "dominantSet": dominantSet,
        "commandSet": commandSet,
        "constraint": constraint,
        "constraint2": constraint2,
    }


def zeroConstraintSubsumptionTestCase():
    """
    Builds and returns test case for the 0-Constraint-Subsumption (0-Subsume).

    Args: None

    Returns:
        A dictionary containing like the following:
            {
                "current": current,
                "parentOfCurrent": parentOfCurrent,
                "dominantSet": dominantSet,
                "commandSet": commandSet,
                "constraint2": constraint2
            }
        - "current": the current node before transformation.
        - "parentOfCurrent": the parent of the current before transformation.
        - "dominantSet": dominant set of current node.
        - "commandSet": the command set of current node.
        - "constraint2": the root of the constraint tree after transformation.

    """

    and11.guardSet = [e]
    and12.guardSet = [f]
    and21.guardSet = [a]
    and22.guardSet = [bprime]
    and23.guardSet = [c]
    and24.guardSet = []
    and22.children = [or11]

    or11.children = [and11, and12]
    or21.children = [and21, and22]
    or22.children = [and23, and24]

    constraint.guardSet = [a]
    constraint.children = [or21, or22]

    and112.guardSet = [e]
    and122.guardSet = [f]
    and212.guardSet = [a]
    and222.guardSet = [bprime]
    and222.children = [or112]

    or112.children = [and112, and122]
    or212.children = [and212, and222]

    constraint2.guardSet = [a]
    constraint2.children = [or212]

    current = or22
    parentOfCurrent = constraint
    dominantSet = [a]
    commandSet = []

    return {
        "current": current,
        "parentOfCurrent": parentOfCurrent,
        "dominantSet": dominantSet,
        "commandSet": commandSet,
        "constraint": constraint,
        "constraint2": constraint2,
    }


def oneConstraintSubsumptionTestCase():
    """
    Builds and returns test case for the 1-Constraint-Subsumption (1-Subsume).

    Args: None

    Returns:
        A dictionary containing like the following:
            {
                "current": current,
                "parentOfCurrent": parentOfCurrent,
                "dominantSet": dominantSet,
                "commandSet": commandSet,
                "constraint2": constraint2
            }
        - "current": the current node before transformation.
        - "parentOfCurrent": the parent of the current before transformation.
        - "dominantSet": dominant set of current node.
        - "commandSet": the command set of current node.
        - "constraint2": the root of the constraint tree after transformation.

    """

    and11.guardSet = [e, d]
    and12.guardSet = [c]
    and21.guardSet = [b]
    and22.guardSet = [d]
    constraint.guardSet = [a]

    or11.children = [and11, and12]
    or21.children = [and21, and22]
    and21.children = [or11]
    constraint.children = [or21]

    and112.guardSet = [c]
    and212.guardSet = [b]
    and222.guardSet = [d]
    constraint2.guardSet = [a]

    or112.children = [and112]
    or212.children = [and212, and222]
    and212.children = [or112]
    constraint2.children = [or212]

    current = and11
    parentOfCurrent = or11
    dominantSet = [a, b]
    commandSet = [c, d]

    return {
        "current": current,
        "parentOfCurrent": parentOfCurrent,
        "dominantSet": dominantSet,
        "commandSet": commandSet,
        "constraint": constraint,
        "constraint2": constraint2,
    }


def oneConstraintComplementSubtractionTestCase():
    """
    Builds and returns test case for the 1-Constraint-Complement-Subtraction (1-CCSubtract).

    Args: None

    Returns:
        A dictionary containing like the following:
            {
                "current": current,
                "parentOfCurrent": parentOfCurrent,
                "dominantSet": dominantSet,
                "commandSet": commandSet,
                "constraint2": constraint2
            }
        - "current": the current node before transformation.
        - "parentOfCurrent": the parent of the current before transformation.
        - "dominantSet": dominant set of current node.
        - "commandSet": the command set of current node.
        - "constraint2": the root of the constraint tree after transformation.

    """

    and11.guardSet = [b, c]
    and12.guardSet = [d]
    and21.guardSet = [b]
    and22.guardSet = [bprime]
    constraint.guardSet = [a]

    or11.children = [and11, and12]
    or21.children = [and21, and22]
    and21.children = [or11]
    constraint.children = [or21]

    and112.guardSet = [c]
    and122.guardSet = [d]
    and212.guardSet = [b]
    and222.guardSet = [bprime]
    constraint2.guardSet = [a]

    or112.children = [and112, and122]
    or212.children = [and212, and222]
    and212.children = [or112]
    constraint2.children = [or212]

    current = and11
    parentOfCurrent = or11
    dominantSet = [a, b]
    commandSet = [d]

    return {
        "current": current,
        "parentOfCurrent": parentOfCurrent,
        "dominantSet": dominantSet,
        "commandSet": commandSet,
        "constraint": constraint,
        "constraint2": constraint2,
    }
