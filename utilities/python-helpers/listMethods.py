import unittest
import re
from typing import List, Tuple, Union


def tokenizeExpr(expr: str):
    expr = expr.strip()
    stack = []
    matches = []

    begin = None

    for i, char in enumerate(expr):
        if char == "(":
            if begin is None:
                begin = i
            stack.append(char)
        elif char == ")":
            if stack:
                stack.pop()
                if not stack:
                    matches.append(expr[begin : i + 1])
                    begin = None

    return matches


def exprToList(expr: str):
    def tokenize(expr: str):
        expr = expr.strip()
        expr = expr[1:-1]

        matches = tokenizeExpr(expr)

        for substr in matches:
            expr = expr.replace(substr, "")

        return matches + expr.split()

    tokens = tokenize(expr)
    list = "Nil"

    for token in reversed(tokens):
        list = f"(Cons {token} {list})"

    return list



# Helper funcitons for listToExpr fucntion 
ParsedStructure = Union[str, Tuple, List]

def format_to_string(structure: ParsedStructure) -> str:
    """
    Recursively formats a nested Python object (lists/tuples/strings)
    into a single Lisp-style string.
    """
    if isinstance(structure, (list, tuple)):
        elements_as_strings = [format_to_string(elem) for elem in structure]
        return f"({' '.join(elements_as_strings)})"
    else:
        return str(structure)

def parse_from_tokens(tokens: list) -> ParsedStructure:
    """
    Recursively parses a list of tokens into a nested Python structure.
    """
    if not tokens:
        raise ValueError("Unexpected end of input, missing ')'")

    token = tokens.pop(0)

    if token == '(':
        if tokens and tokens[0] == 'Cons':
            tokens.pop(0)
            car = parse_from_tokens(tokens)
            cdr = parse_from_tokens(tokens)
            if not tokens or tokens.pop(0) != ')':
                raise ValueError("Expected ')' to close cons expression")
            return [car] + cdr
        else:
            sub_list = []
            while tokens and tokens[0] != ')':
                sub_list.append(parse_raw(tokens))
            if not tokens:
                raise ValueError("Unexpected end of input, missing ')' for sub-list")
            tokens.pop(0)
            return tuple(sub_list)
    elif token == 'Nil':
        return []
    elif token == ')':
        raise ValueError("Unexpected ')'")
    else:
        return token

def parse_raw(tokens: list) -> ParsedStructure:
    """
    Parses the structure without interpreting Cons as a list.
    Used to preserve structure inside non-top-level Cons expressions.
    """
    if not tokens:
        raise ValueError("Unexpected end of input")

    token = tokens.pop(0)

    if token == '(':
        sub_list = []
        while tokens and tokens[0] != ')':
            sub_list.append(parse_raw(tokens))
        if not tokens or tokens.pop(0) != ')':
            raise ValueError("Expected ')'")
        return tuple(sub_list)
    elif token == ')':
        raise ValueError("Unexpected ')'")
    else:
        return token


def listToExpr(list_str: str) -> str:
    """
    Main function to convert a Lisp-style cons list into a
    formatted single-line string.
    """
    if not list_str.strip():
        return "()"
        
    tokens = re.findall(r'\(|\)|[^\s()]+', list_str)
    
    parsed_structure = parse_from_tokens(tokens)
    
    return format_to_string(parsed_structure)



# class TestListMethods(unittest.TestCase):
#     def test_expr_to_list(self):
#         self.assertEqual(exprToList("(A B C)"), "(Cons A (Cons B (Cons C Nil)))")
#         self.assertEqual(
#             exprToList("((A) (B) (C))"), "(Cons (A) (Cons (B) (Cons (C) Nil)))"
#         )
#         self.assertEqual(
#             exprToList("((mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (B) (C) D E)"),
#             "(Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (B) (Cons (C) (Cons D (Cons E Nil)))))",
#         )
#         self.assertEqual(
#             exprToList("(A (B C E) D E)"),
#             "(Cons (B C E) (Cons A (Cons D (Cons E Nil))))",
#         )


if __name__ == "__main__":
    print(listToExpr("(Cons (mkInst (Cons 0 (Cons 1 (Cons 2 Nil)))) (Cons (B) (Cons (C) (Cons D (Cons E Nil)))))"))
    # unittest.main()