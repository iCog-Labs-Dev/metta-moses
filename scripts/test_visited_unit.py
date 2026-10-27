import visited_tracker

def test_canonicalization():
    cases = [
        # Associativity & flattening
        ('(AND (AND A B) C)', '(AND A B C)'),
        ('(OR A (OR B C))', '(OR A B C)'),
        # Commutativity & sorting
        ('(AND C B A)', '(AND A B C)'),
        ('(OR C A B)', '(OR A B C)'),
        # Deduplication
        ('(AND A B A)', '(AND A B)'),
        ('(OR A B B A)', '(OR A B)'),
        # Single child unwrapping
        ('(AND A)', 'A'),
        ('(OR B)', 'B'),
        # Double negation
        ('(NOT (NOT X))', 'X'),
        # Nested permutations
        ('(OR (AND B A) (AND A B))', '(AND A B)'),
        ('(AND (OR Y X) (OR X Y))', '(OR X Y)'),
        # Exact boolean constants
        ('true', 'TRUE'),
        ('True', 'TRUE'),
        ('TRUE', 'TRUE'),
        ('false', 'FALSE'),
        ('False', 'FALSE'),
        ('FALSE', 'FALSE'),
        # Feature names T / t must NOT become TRUE
        ('T', 'T'),
        ('t', 't'),
        ('(AND T X)', '(AND T X)'),
        ('(AND TRUE X)', '(AND TRUE X)'),
        # Numeric labels 0 / 1 must NOT become FALSE / TRUE
        ('0', '0'),
        ('1', '1'),
        ('(AND 1 X)', '(AND 1 X)'),
        # Python list/tuple input
        (['AND', 'C', ['OR', 'B', 'A']], '(AND (OR A B) C)'),
        (('AND', ('NOT', ('NOT', 'X')), 'A'), '(AND A X)'),
    ]

    for inp, expected in cases:
        actual = visited_tracker.get_canonical_key(inp)
        assert actual == expected, f"Failed for {inp}: expected {expected}, got {actual}"
        print(f"PASS: {inp} -> {actual}")

    # Explicit check that (AND T X) and (AND TRUE X) do NOT collide
    assert visited_tracker.get_canonical_key('(AND T X)') != visited_tracker.get_canonical_key('(AND TRUE X)')
    print("PASS: (AND T X) != (AND TRUE X) (no collision on feature T)")

    print("\nAll canonicalization unit tests passed!")


def test_visit_tracking():
    """Tests for C++ MOSES revisit semantics.

    C++ metapop_parameters::revisit:
      revisit < 0  => always eligible (unbounded)
      revisit == 0 => allow exactly 1 visit total  (C++ default)
      revisit == N => allow N+1 visits total
    Eligibility condition: revisit < 0 OR count <= revisit
    """
    visited_tracker.reset()

    # revisit=0: eligible before first visit, ineligible after
    assert visited_tracker.is_eligible('(AND A B)', revisit=0) == 1, "Should be eligible before any visit"
    visited_tracker.record_visit('(AND B A)')  # sibling permutation => same canonical key
    assert visited_tracker.get_visit_count('(AND A B)') == 1
    assert visited_tracker.is_eligible('(AND A B)', revisit=0) == 0, "Should be ineligible after 1 visit (revisit=0)"
    assert visited_tracker.is_eligible('(AND B A)', revisit=0) == 0, "Permutation should also be ineligible"

    # revisit=1: allows 2 visits total
    assert visited_tracker.is_eligible('(AND A B)', revisit=1) == 1, "revisit=1 allows 2nd visit (count=1 <= revisit=1)"
    visited_tracker.record_visit('(AND A B)')  # 2nd visit
    assert visited_tracker.get_visit_count('(AND A B)') == 2
    assert visited_tracker.is_eligible('(AND A B)', revisit=1) == 0, "Should be ineligible after 2 visits (revisit=1)"

    # revisit=-1: always eligible (unbounded)
    assert visited_tracker.is_eligible('(AND A B)', revisit=-1) == 1, "revisit<0 means unbounded, always eligible"
    visited_tracker.record_visit('(AND A B)')  # 3rd visit
    assert visited_tracker.is_eligible('(AND A B)', revisit=-1) == 1, "Still eligible after 3rd visit (unbounded)"

    # Reset test: clears counts AND the key cache
    visited_tracker.reset()
    assert visited_tracker.get_visit_count('(AND A B)') == 0
    assert visited_tracker.get_exhaustion_count() == 0
    assert visited_tracker.is_eligible('(AND A B)', revisit=0) == 1, "Should be eligible after reset"
    # Cache test: memoized key should survive reset correctly
    key1 = visited_tracker.get_canonical_key('(AND B A)')
    key2 = visited_tracker.get_canonical_key('(AND A B)')
    assert key1 == key2, "Memoized canonical keys must be equal for permutations"

    print("All visit tracking tests passed!")


def test_is_eligible_does_not_mutate_stats():
    """Ensure read queries (is_eligible, get_visit_count) NEVER mutate stats()."""
    visited_tracker.reset()
    init_stats = visited_tracker.stats()
    assert init_stats["total_expansions"] == 0
    assert init_stats["distinct_exemplars"] == 0
    assert init_stats["duplicate_rate"] == 0.0
    assert len(init_stats["counts"]) == 0

    # Query eligibility for 50 completely unseen tree expressions
    for i in range(50):
        dummy_tree = f"(AND X{i} (OR Y{i} Z{i}))"
        assert visited_tracker.is_eligible(dummy_tree, revisit=0) == 1
        assert visited_tracker.get_visit_count(dummy_tree) == 0

    after_query_stats = visited_tracker.stats()
    assert after_query_stats["total_expansions"] == 0, "Querying eligibility must NOT record expansions"
    assert after_query_stats["distinct_exemplars"] == 0, "Querying eligibility must NOT increment distinct exemplars"
    assert len(after_query_stats["counts"]) == 0, "_visit_counts must NOT contain zero-count entries"
    assert after_query_stats == init_stats, "stats() before and after queries must be identical"

    # Now record 1 visit for 1 tree
    visited_tracker.record_visit('(AND A B)')
    mid_stats = visited_tracker.stats()
    assert mid_stats["total_expansions"] == 1
    assert mid_stats["distinct_exemplars"] == 1
    assert mid_stats["duplicate_rate"] == 0.0

    # Record duplicate visit
    visited_tracker.record_visit('(AND B A)')  # canonical alias
    dup_stats = visited_tracker.stats()
    assert dup_stats["total_expansions"] == 2
    assert dup_stats["distinct_exemplars"] == 1
    assert dup_stats["duplicate_rate"] == 0.5  # 1 - (1/2) = 0.5

    # Check that querying another unseen tree still leaves stats intact
    assert visited_tracker.is_eligible('(OR W1 W2)', revisit=0) == 1
    after_mid_stats = visited_tracker.stats()
    assert after_mid_stats == dup_stats, "Querying unseen tree must not alter existing visit stats"

    print("PASS: test_is_eligible_does_not_mutate_stats passed!")


if __name__ == '__main__':
    test_canonicalization()
    test_visit_tracking()
    test_is_eligible_does_not_mutate_stats()


