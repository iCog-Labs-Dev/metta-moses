import os
import sys
import re
import json
import time
import argparse
import subprocess
import concurrent.futures
from pathlib import Path

REPO_DIR = "/home/nonplds/projects/metta-projects/metta-moses-representation"
PETTA_RUNNER = "/home/nonplds/projects/metta-projects/PeTTa/run.sh"

CONDITIONS = {
    "baseline": {
        "label": "Exp0-Baseline",
        "seedPool": "legacy",
        "permPolarityMode": "classic"
    },
    "exp1_tautology": {
        "label": "Exp1-Tautology",
        "seedPool": "tautology",
        "permPolarityMode": "classic"
    },
    "exp2_motifs": {
        "label": "Exp2-Motifs",
        "seedPool": "exp2_motifs",
        "permPolarityMode": "classic"
    },
    "exp2_motifs_symmetric": {
        "label": "Exp2-Motifs-Symmetric",
        "seedPool": "exp2_motifs",
        "permPolarityMode": "symmetric"
    },
    "exp2_1_arity": {
        "label": "Exp2.1-Arity",
        "seedPool": "exp2_1_arity",
        "permPolarityMode": "classic"
    },
    "exp2_1_arity_symmetric": {
        "label": "Exp2.1-Arity-Symmetric",
        "seedPool": "exp2_1_arity",
        "permPolarityMode": "symmetric"
    },
    "random_small": {
        "label": "Random-Small",
        "seedPool": "random_small",
        "permPolarityMode": "classic"
    },
    "guard_on": {
        "label": "Guard-On",
        "seedPool": "legacy",
        "permPolarityMode": "classic",
        "revisit": 0
    },
    "guard_off": {
        "label": "Guard-Off",
        "seedPool": "legacy",
        "permPolarityMode": "classic",
        "revisit": -1
    },
    "revisit_0": {
        "label": "Revisit-0",
        "seedPool": "legacy",
        "permPolarityMode": "classic",
        "revisit": 0
    },
    "revisit_1": {
        "label": "Revisit-1",
        "seedPool": "legacy",
        "permPolarityMode": "classic",
        "revisit": 1
    },
    "revisit_2": {
        "label": "Revisit-2",
        "seedPool": "legacy",
        "permPolarityMode": "classic",
        "revisit": 2
    },
    "revisit_neg1": {
        "label": "Revisit--1",
        "seedPool": "legacy",
        "permPolarityMode": "classic",
        "revisit": -1
    },
    "llm_best": {
        "label": "LLM-Best",
        "seedPool": "llm_best",
        "permPolarityMode": "classic",
        "revisit": 0
    },
    "llm_worst": {
        "label": "LLM-Worst",
        "seedPool": "llm_worst",
        "permPolarityMode": "classic",
        "revisit": 0
    }
}

def parse_run_output(output, returncode):
    error = (returncode != 0)
    
    # 1. Best raw score & best program from FinalResult
    best_raw = None
    best_program = None
    
    fr_idx = output.rfind('(FinalResult')
    if fr_idx != -1:
        fr_snippet = output[fr_idx:]
        raws = re.findall(r'\)\s+([-+]?\d*\.?\d+)\)', fr_snippet)
        if raws:
            best_raw = max(float(r) for r in raws)
        first_m = re.search(r'\(FinalResult\s*\(\s*\((\(.*?\)|[^\s\(\)]+)\s+([-+]?\d*\.?\d+)\)', fr_snippet, re.DOTALL)
        if first_m:
            best_program = first_m.group(1).strip()
            
    # Check Termination marker: (Termination: ...) or (Step2-Termination: ...)
    term_m = re.search(r"\((?:Step2-)?Termination:\s+(\w+)\)", output)
    termination_reason = term_m.group(1) if term_m else None
    if termination_reason == "EXHAUSTION":
        termination_reason = "EXHAUSTED"

    # Check Summary marker: (Summary ...) or (Step2-Summary ...)
    summary_m = re.search(
        r"\((?:Step2-)?Summary UniqueVisited:\s*(\d+)\s*TotalExpansions:\s*(\d+)\s*DuplicateRate:\s*([\d\.]+)(?:\s*FallbackCount:\s*(\d+))?\s*Exhaustions?:\s*(\d+)\s*BestRaw:\s*([-+]?\d*\.?\d+)",
        output
    )
    unique_visited = 0
    total_expansions = 0
    duplicate_rate = 0.0
    fallback_count = 0
    exhaustion_count = 0
    if summary_m:
        unique_visited = int(summary_m.group(1))
        total_expansions = int(summary_m.group(2))
        duplicate_rate = float(summary_m.group(3))
        # group(4) is optional FallbackCount
        if summary_m.group(4) is not None:
            fallback_count = int(summary_m.group(4))
        exhaustion_count = int(summary_m.group(5))
        if best_raw is None:
            best_raw = float(summary_m.group(6))
    else:
        old_sum_m = re.search(
            r"\((?:Step2-)?Summary UniqueVisited:\s*(\d+)\s*TotalExpansions:\s*(\d+)\s*FallbackCount:\s*(\d+)\s*BestRaw:\s*([-+]?\d*\.?\d+)",
            output
        )
        if old_sum_m:
            unique_visited = int(old_sum_m.group(1))
            total_expansions = int(old_sum_m.group(2))
            fallback_count = int(old_sum_m.group(3))
            if total_expansions > 0:
                duplicate_rate = max(0.0, 1.0 - (unique_visited / total_expansions))
            if best_raw is None:
                best_raw = float(old_sum_m.group(4))
        else:
            best_raw_matches = re.findall(r"\(Step2-BestRaw Gen: \d+ Exp: \d+ Ever: ([-+]?\d*\.?\d+)", output)
            if best_raw_matches and best_raw is None:
                best_raw = float(best_raw_matches[-1])
            
    # Count expansions and unique trees if not from summary
    if not total_expansions:
        selected_trees = re.findall(r'\(SelectedTree:\s+(.*?)\)\n', output)
        total_expansions = len(selected_trees)
        unique_visited = len(set(selected_trees))
        duplicate_rate = (1.0 - (unique_visited / total_expansions)) if total_expansions > 0 else 0.0
        
    if not fallback_count:
        fb_matches = re.findall(r'\(Step2-Fallback Count:\s+(\d+)\)', output)
        fallback_count = int(fb_matches[-1]) if fb_matches else 0

    # Best composite / penalized score
    best_pen = None
    score_matches = re.findall(r"\(New best score:\s+([-\d\.]+)\)", output)
    if score_matches:
        best_pen = float(score_matches[-1])
        
    final_best_score = best_pen if best_pen is not None else best_raw
    exact_solve = (best_raw == 0.0) if best_raw is not None else False
    
    if termination_reason is None:
        if exact_solve:
            termination_reason = "SOLVED"
        elif "No eligible exemplar" in output or exhaustion_count > 0:
            termination_reason = "EXHAUSTION"
        else:
            termination_reason = "MAX_GEN"
    
    return {
        "final_best_score": final_best_score,
        "best_raw": best_raw,
        "exact_solve": exact_solve,
        "termination_reason": termination_reason,
        "unique_visited": unique_visited,
        "distinct_exemplars": unique_visited,
        "total_expansions": total_expansions,
        "duplicate_rate": duplicate_rate,
        "revisits": max(0, total_expansions - unique_visited),
        "fallback_count": fallback_count,
        "exhaustion_count": exhaustion_count,
        "best_program": best_program,
        "error": error
    }

def run_single_seed(problem, cond_key, seed, max_gen, out_dir, timeout=900):
    cond_info = CONDITIONS[cond_key]
    seed_pool = cond_info["seedPool"]
    cond_label = cond_info["label"]
    perm_mode = cond_info.get("permPolarityMode", "classic")
    revisit = cond_info.get("revisit", 0)
    
    cmd = [
        "bash",
        PETTA_RUNNER,
        "moses.metta",
        "-s",
        f"--problem={problem}",
        f"--seedPool={seed_pool}",
        f"--seed={seed}",
        f"--maxGen={max_gen}",
        "--nDeme=1",
        "--optAlgo=hc",
        "--hcMaxDistBoolean=4",
        f"--permPolarityMode={perm_mode}",
        "--logicalPermRatio=1.0",
        "--complexityRatio=3.5",
        f"--revisit={revisit}"
    ]
    
    t0 = time.time()
    try:
        proc = subprocess.run(
            cmd,
            cwd=REPO_DIR,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            timeout=timeout
        )
        elapsed = time.time() - t0
        output = proc.stdout
        if proc.stderr:
            output += "\nSTDERR:\n" + proc.stderr
        returncode = proc.returncode
    except subprocess.TimeoutExpired as e:
        elapsed = time.time() - t0
        output = (e.stdout or "") + f"\nTIMEOUT after {timeout}s\n"
        returncode = -1
    except Exception as e:
        elapsed = time.time() - t0
        output = f"EXCEPTION: {str(e)}\n"
        returncode = -1
        
    log_path = os.path.join(out_dir, f"seed_{seed}.log")
    with open(log_path, "w", encoding="utf-8") as f:
        f.write(output)
        
    parsed = parse_run_output(output, returncode)
    
    result = {
        "seed": seed,
        "condition": cond_label,
        "problem": problem,
        "final_best_score": parsed["final_best_score"],
        "best_raw": parsed["best_raw"],
        "exact_solve": parsed["exact_solve"],
        "termination_reason": parsed["termination_reason"],
        "wall_seconds": elapsed,
        "generations": max_gen,
        "total_expansions": parsed["total_expansions"],
        "distinct_exemplars": parsed["distinct_exemplars"],
        "unique_visited": parsed["unique_visited"],
        "duplicate_rate": parsed["duplicate_rate"],
        "revisits": parsed.get("revisits", max(0, parsed["total_expansions"] - parsed["unique_visited"])),
        "fallback_count": parsed["fallback_count"],
        "exhaustion_count": parsed["exhaustion_count"],
        "best_program": parsed["best_program"],
        "error": parsed["error"]
    }
    
    json_path = os.path.join(out_dir, f"seed_{seed}.json")
    with open(json_path, "w", encoding="utf-8") as f:
        json.dump(result, f, indent=2)
        
    raw_str = f"{parsed['best_raw']:4.1f}" if parsed['best_raw'] is not None else " N/A"
    pen_str = f"{parsed['final_best_score']:6.2f}" if parsed['final_best_score'] is not None else "  N/A"
    solve_str = "SOLVED ✅" if parsed["exact_solve"] else "      "
    print(
        f"[{problem:9s} | {cond_label:14s} | Seed {seed:2d}/29] "
        f"Done in {elapsed:5.1f}s | Raw: {raw_str} | Score: {pen_str} | {solve_str}",
        flush=True
    )
    return result

def run_condition_benchmark(problem, cond_key, count=30, max_gen=50, max_workers=2, data_dir="experiments/data"):
    cond_info = CONDITIONS[cond_key]
    out_dir = os.path.join(REPO_DIR, data_dir, problem, cond_key)
    os.makedirs(out_dir, exist_ok=True)
    
    print("=" * 80)
    print(f"STARTING BENCHMARK: {problem.upper()} | Condition: {cond_info['label']} ({cond_key})")
    print(f"Total Seeds: {count} (0 to {count-1}) | MaxGen: {max_gen} | Workers: {max_workers}")
    print(f"Output Directory: {out_dir}")
    print("=" * 80, flush=True)
    
    start_total = time.time()
    results = []
    
    with concurrent.futures.ThreadPoolExecutor(max_workers=max_workers) as executor:
        futures = {
            executor.submit(run_single_seed, problem, cond_key, seed, max_gen, out_dir): seed
            for seed in range(count)
        }
        for future in concurrent.futures.as_completed(futures):
            seed = futures[future]
            try:
                res = future.result()
                results.append(res)
            except Exception as e:
                print(f"[ERROR in Seed {seed}]: {e}", flush=True)
                
    results.sort(key=lambda r: r["seed"])
    total_time = time.time() - start_total
    
    valid_scores = [r["final_best_score"] for r in results if r["final_best_score"] is not None]
    raw_scores = [r["best_raw"] for r in results if r["best_raw"] is not None]
    exact_solves = sum(1 for r in results if r["exact_solve"])
    solve_rate = (exact_solves / len(results) * 100.0) if results else 0.0
    mean_score = (sum(valid_scores) / len(valid_scores)) if valid_scores else 0.0
    mean_raw = (sum(raw_scores) / len(raw_scores)) if raw_scores else 0.0
    mean_time = (sum(r["wall_seconds"] for r in results) / len(results)) if results else 0.0
    
    import collections
    mean_dup = (sum(r.get("duplicate_rate", 0.0) for r in results) / len(results)) if results else 0.0
    mean_revisits = (sum(r.get("revisits", 0) for r in results) / len(results)) if results else 0.0
    mean_distinct = (sum(r.get("distinct_exemplars", 0) for r in results) / len(results)) if results else 0.0
    mean_expansions = (sum(r.get("total_expansions", 0) for r in results) / len(results)) if results else 0.0
    
    term_counts = collections.Counter(r.get("termination_reason", "UNKNOWN") for r in results)

    summary = {
        "problem": problem,
        "condition": cond_info["label"],
        "cond_key": cond_key,
        "total_seeds": len(results),
        "exact_solves": exact_solves,
        "exact_solve_rate": solve_rate,
        "mean_final_score": mean_score,
        "mean_best_raw": mean_raw,
        "mean_duplicate_rate": mean_dup,
        "mean_revisits": mean_revisits,
        "mean_distinct_exemplars": mean_distinct,
        "mean_total_expansions": mean_expansions,
        "termination_breakdown": dict(term_counts),
        "mean_wall_seconds": mean_time,
        "total_wall_seconds": total_time,
        "runs": results
    }
    
    summary_path = os.path.join(out_dir, "summary.json")
    with open(summary_path, "w", encoding="utf-8") as f:
        json.dump(summary, f, indent=2)
        
    print("-" * 80)
    print(f"SUMMARY ({problem} - {cond_info['label']}):")
    print(f"  Exact Solves:       {exact_solves}/{len(results)} ({solve_rate:.1f}%)")
    print(f"  Mean Raw Score:     {mean_raw:.3f}")
    print(f"  Mean Final Score:   {mean_score:.3f}")
    print(f"  Mean Expansions:    {mean_expansions:.1f}")
    print(f"  Distinct Exemplars: {mean_distinct:.1f}")
    print(f"  Mean Revisits:      {mean_revisits:.1f}")
    print(f"  Duplicate Rate:     {mean_dup*100.0:.1f}%")
    print(f"  Termination:        {dict(term_counts)}")
    print(f"  Avg Wall Time:      {mean_time:.1f}s")
    print(f"  Total Wall Time:    {total_time:.1f}s")
    print(f"  Summary File:       {summary_path}")
    print("-" * 80, flush=True)
    return summary

def main():
    parser = argparse.ArgumentParser(description="Overnight Metapopulation Initialization Experiments")
    parser.add_argument("--problem", nargs="+", choices=["parity3", "parity4", "majority5", "mux6", "majority6", "majority7", "all"], default=["all"])
    parser.add_argument("--condition", nargs="+", choices=list(CONDITIONS.keys()) + ["all"], default=["all"])
    parser.add_argument("--count", type=int, default=30)
    parser.add_argument("--max_gen", type=int, default=50)
    parser.add_argument("--workers", type=int, default=2)
    parser.add_argument("--data_dir", type=str, default="experiments/data")
    args = parser.parse_args()
    
    if "all" in args.problem:
        problems = ["majority5", "parity4", "parity3", "mux6"]
    else:
        problems = args.problem
    if "all" in args.condition:
        conditions = list(CONDITIONS.keys())
    else:
        conditions = args.condition
    
    print("=" * 80)
    print("OVERNIGHT EXPERIMENTS PLAN:")
    print(f"Problems:    {problems}")
    print(f"Conditions:  {conditions}")
    print(f"Seeds/Cond:  {args.count}")
    print(f"MaxGen:      {args.max_gen}")
    print(f"Workers:     {args.workers}")
    print(f"Data Dir:    {args.data_dir}")
    print("=" * 80, flush=True)
    
    overall_summaries = {}
    for prob in problems:
        for cond in conditions:
            sum_res = run_condition_benchmark(
                problem=prob,
                cond_key=cond,
                count=args.count,
                max_gen=args.max_gen,
                max_workers=args.workers,
                data_dir=args.data_dir
            )
            overall_summaries[f"{prob}_{cond}"] = {
                "exact_solves": sum_res["exact_solves"],
                "total_seeds": sum_res["total_seeds"],
                "exact_solve_rate": sum_res["exact_solve_rate"],
                "mean_best_raw": sum_res["mean_best_raw"],
                "mean_final_score": sum_res["mean_final_score"],
                "mean_revisits": sum_res.get("mean_revisits", 0.0),
                "mean_distinct_exemplars": sum_res.get("mean_distinct_exemplars", 0.0),
                "mean_total_expansions": sum_res.get("mean_total_expansions", 0.0),
                "mean_wall_seconds": sum_res["mean_wall_seconds"]
            }
            
    print("\n" + "=" * 80)
    print("ALL SCHEDULED EXPERIMENTS COMPLETED!")
    print(json.dumps(overall_summaries, indent=2))
    print("=" * 80)

if __name__ == "__main__":
    main()
