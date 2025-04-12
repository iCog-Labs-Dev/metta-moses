import re

## accepts Metta boolean expression and returns equivalent binary enf expression
## e.g 
##      (OR A B C D) -->  "|(a,|(b,|(c,d)))
def parse_metta_expression(expr: str) -> str:
    def parse_tokens(tokens: list[str]) -> str:
        token = tokens.pop(0)

        if token != '(':
            return token.lower()

        op = tokens.pop(0).upper()

        if op == 'NOT':
            sub_expr = parse_tokens(tokens)
            assert tokens.pop(0) == ')'
            return f"!({sub_expr})"

        elif op in ('AND', 'OR'):
            symbol = '&' if op == 'AND' else '|'
            args = []
            while tokens[0] != ')':
                args.append(parse_tokens(tokens))
            tokens.pop(0)  # remove ')'

            # Convert to binary expression by right-associating
            def to_binary(args):
                if len(args) == 1:
                    return args[0]
                return f"{symbol}({args[0]},{to_binary(args[1:])})"
            
            return to_binary(args)

        else:
            raise ValueError(f"Unknown operator: {op}")

    tokens = re.findall(r'\(|\)|[A-Za-z]+', expr)
    return parse_tokens(tokens)

## accepts constraint tree and returns metta boolean expression
def parse_constraint_tree(text):
    lines = text.strip().split('\n')

    def parse_literal(lit):
        sign = lit[0]
        name = lit[1:].upper()
        return name if sign == '+' else f"(NOT {name})"

    def get_indent_level(line):
        return len(line) - len(line.lstrip())

    def parse_node(index):
        line = lines[index]
        indent = get_indent_level(line)

        # Match operator and optional literals (only if AND)
        match = re.search(r'\]\s+(\w+)(?:\[(.*?)\])?', line)
        if not match:
            raise ValueError(f"Invalid format: {line}")
        
        op = match.group(1).upper()
        raw_literals = match.group(2) or ""
        literals = [parse_literal(lit) for lit in raw_literals.strip().split()] if op == "AND" and raw_literals else []

        # Recursively collect children
        children = []
        i = index + 1
        while i < len(lines) and get_indent_level(lines[i]) > indent:
            child_expr, i = parse_node(i)
            children.append(child_expr)

        args = literals + children
        expr = f"({op} {' '.join(args)})"
        return expr, i

    expression, _ = parse_node(0)
    return expression
