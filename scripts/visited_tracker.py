# Visit tracking state:
# _visit_counts is a plain dict mapping canonical_key -> int (count >= 1).
# We deliberately avoid defaultdict so that read operations (get_visit_count, is_eligible)
# NEVER insert 0-count entries when querying unvisited exemplars.
_visit_counts = {}
_exhaustion_count = 0
# Memoization cache: raw string -> canonical key string.
# Avoids re-parsing the same tree expression on every eligibility check.
_key_cache = {}

def parse_sexpr(s):
    if not isinstance(s, str):
        return s
    s = s.strip()
    if not (s.startswith('(') and s.endswith(')')):
        return s
    tokens = s.replace('(', ' ( ').replace(')', ' ) ').split()
    def _parse(toks):
        if not toks:
            return None
        t = toks.pop(0)
        if t == '(':
            sub = []
            while toks and toks[0] != ')':
                sub.append(_parse(toks))
            if toks and toks[0] == ')':
                toks.pop(0)
            return sub
        elif t == ')':
            return None
        return t
    return _parse(tokens)

def canonicalize_tree(expr):
    """
    Recursively canonicalizes a boolean tree expression into a deterministic form.
    AND and OR children are flattened, recursively canonicalized, deduplicated, 
    and lexicographically sorted.
    """
    # Check bool first before int since bool is subclass of int in Python
    if isinstance(expr, bool):
        return 'TRUE' if expr else 'FALSE'

    if isinstance(expr, str):
        s = expr.strip()
        if s.startswith('(') and s.endswith(')'):
            parsed = parse_sexpr(s)
            if isinstance(parsed, (list, tuple)):
                return canonicalize_tree(parsed)
        if s in ('True', 'TRUE', 'true'):
            return 'TRUE'
        if s in ('False', 'FALSE', 'false'):
            return 'FALSE'
        return s

    if isinstance(expr, (int, float)):
        return str(expr)
        
    # Check for Janus compound term if present
    if hasattr(expr, 'name') and hasattr(expr, 'args'):
        expr = (expr.name, *expr.args)

    if not isinstance(expr, (list, tuple)):
        s = str(expr).strip()
        if s.startswith('(') and s.endswith(')'):
            parsed = parse_sexpr(s)
            if isinstance(parsed, (list, tuple)):
                return canonicalize_tree(parsed)
        return s
        
    if len(expr) == 0:
        return '()'
        
    op = str(expr[0]).strip().upper()
    
    if op in ('AND', 'OR'):
        canon_children = []
        for child in expr[1:]:
            canon_child = canonicalize_tree(child)
            # Flatten associative operators
            if isinstance(canon_child, tuple) and canon_child[0] == op:
                canon_children.extend(canon_child[1:])
            else:
                canon_children.append(canon_child)
                
        # Deduplicate identical subtrees under same junctor
        unique_children = []
        seen = set()
        for c in canon_children:
            s_c = tree_to_str(c) if isinstance(c, tuple) else str(c)
            if s_c not in seen:
                seen.add(s_c)
                unique_children.append(c)
                
        # Lexicographically sort children
        unique_children.sort(key=lambda x: tree_to_str(x) if isinstance(x, tuple) else str(x))
        
        if len(unique_children) == 1:
            return unique_children[0]
        return (op, *unique_children)
        
    elif op == 'NOT':
        if len(expr) > 1:
            child = canonicalize_tree(expr[1])
            if isinstance(child, tuple) and child[0] == 'NOT' and len(child) > 1:
                return child[1]
            return ('NOT', child)
        return ('NOT',)
    else:
        return (str(expr[0]), *(canonicalize_tree(c) for c in expr[1:]))

def tree_to_str(node):
    if isinstance(node, tuple):
        return "(" + " ".join(tree_to_str(c) for c in node) + ")"
    return str(node)

def get_canonical_key(tree_expr):
    """Return the canonical string key for *tree_expr*.

    Strings are memoized so that repeated eligibility checks on the same raw
    s-expression string do not re-invoke the full parse + canonicalize pipeline.
    List/tuple inputs are not memoized (they are transient call-site objects).
    """
    if isinstance(tree_expr, str):
        cached = _key_cache.get(tree_expr)
        if cached is not None:
            return cached
        key = tree_to_str(canonicalize_tree(tree_expr))
        _key_cache[tree_expr] = key
        return key
    return tree_to_str(canonicalize_tree(tree_expr))

def reset():
    """Clear all visit counts, exhaustion counter, and the key cache.
    Call this at the start of each run/seed to prevent state leaking across runs.
    """
    global _visit_counts, _exhaustion_count, _key_cache
    _visit_counts.clear()
    _exhaustion_count = 0
    _key_cache.clear()
    return True

def get_visit_count(tree_expr):
    """Return visit count without mutating the underlying dict."""
    key = get_canonical_key(tree_expr)
    return _visit_counts.get(key, 0)

def is_eligible(tree_expr, revisit=0):
    """Return 1 if the exemplar is eligible for selection, 0 otherwise.

    Mirrors C++ MOSES ``metapop_parameters::revisit`` semantics exactly:
      * revisit < 0  — unbounded revisits; always eligible.
      * revisit == 0 — allow exactly 1 visit (default, same as C++ default).
      * revisit == N — allow N+1 visits total (N additional revisits).

    Eligibility condition: ``revisit < 0  or  count <= revisit``
    Uses dict.get() so unvisited exemplars NEVER insert a zero-entry into _visit_counts.
    """
    if revisit < 0:
        return 1  # unbounded — always eligible
    key = get_canonical_key(tree_expr)
    count = _visit_counts.get(key, 0)
    return 1 if count <= revisit else 0

def record_visit(tree_expr):
    """Record an actual deme expansion for tree_expr."""
    key = get_canonical_key(tree_expr)
    _visit_counts[key] = _visit_counts.get(key, 0) + 1
    return _visit_counts[key]

def record_exhaustion():
    """Track instances where no eligible exemplar was found (metapop exhausted)."""
    global _exhaustion_count
    _exhaustion_count += 1
    return _exhaustion_count

def get_exhaustion_count():
    return _exhaustion_count

def distinct_exemplars():
    """Count unique exemplars that have been expanded at least once."""
    return sum(1 for c in _visit_counts.values() if c > 0)

def total_expansions():
    """Total number of deme expansions executed."""
    return sum(_visit_counts.values())

def duplicate_rate():
    """Fraction of expansions that revisited an already-expanded exemplar."""
    tot = total_expansions()
    dist = distinct_exemplars()
    return (1.0 - (dist / tot)) if tot > 0 else 0.0

def log_summary(best_raw):
    """Print the standardized summary telemetry string at run termination."""
    tot = total_expansions()
    dist = distinct_exemplars()
    dup = duplicate_rate()
    try:
        r = float(best_raw)
    except Exception:
        r = 0.0
    print(f"(Summary UniqueVisited: {dist} TotalExpansions: {tot} DuplicateRate: {dup:.4f} Exhaustions: {_exhaustion_count} BestRaw: {r})", flush=True)
    return True

def stats():
    tot = total_expansions()
    dist = distinct_exemplars()
    dup = duplicate_rate()
    return {
        "total_expansions": tot,
        "distinct_exemplars": dist,
        "duplicate_rate": dup,
        "unique_keys": dist,
        "total_visits": tot,
        "exhaustion_count": _exhaustion_count,
        "counts": dict(_visit_counts)
    }
