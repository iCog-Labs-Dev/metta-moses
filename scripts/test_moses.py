import subprocess
import os
import re
import shutil
import time
import json
import argparse
import math
from typing import Dict, Any, List, Optional


class GPRunner:
    """
    Manages the execution of an external Genetic Programming engine
    via template injection and subprocess execution.
    """

    def __init__(
        self,
        template_path: str,
        output_base_dir: str = "sandbox",
        comment_prefixes: List[str] = None,
    ):
        self.template_path = template_path
        self.output_base_dir = output_base_dir
        # Default to common comment markers.
        # Crucial: Put longer prefixes (like ";;") BEFORE shorter ones (like ";")
        # to ensure the full comment marker is matched and removed.
        self.comment_prefixes = (
            comment_prefixes if comment_prefixes else [";;", "//", ";", "#", "--"]
        )

        # Pre-load template to fail early if file missing
        if not os.path.exists(template_path):
            raise FileNotFoundError(f"Template not found: {template_path}")

        with open(template_path, "r") as f:
            self.template_content = f.read()

    def _prepare_sandbox(self) -> tuple[str, str]:
        """Creates a unique isolated directory for this specific run."""
        # Note: relying on global 'args' here is brittle if this class is imported elsewhere.
        # Assuming args is available in the global scope as per user modification.
        run_dir = os.path.join(self.output_base_dir, "logs", args.problem)
        log_dir = os.path.join(self.output_base_dir, "logs", args.problem, "stdout")
        os.makedirs(run_dir, exist_ok=True)
        os.makedirs(log_dir, exist_ok=True)
        return run_dir, log_dir

    def _inject_code(self, run_dir: str, params: Dict[str, Any]) -> str:
        """
        Injects parameters into the template and writes the executable script.

        Automatic Uncommenting:
        If a line contains a placeholder that gets replaced, and that line starts
        with a comment prefix (e.g., ';;' or '//'), the comment prefix is removed
        to 'activate' the code.
        """
        lines = self.template_content.splitlines()
        injected_lines = []

        for line in lines:
            modified_line = line
            replaced = False

            # Replace placeholders.
            # Note: params keys should include the delimiter (e.g. "$seed" or "{{SEED}}")
            for placeholder, value in params.items():
                if placeholder in modified_line:
                    modified_line = modified_line.replace(placeholder, str(value))
                    replaced = True

            # If replacement happened, check if we need to uncomment the line
            if replaced:
                stripped = modified_line.lstrip()
                for prefix in self.comment_prefixes:
                    if stripped.startswith(prefix):
                        # Use regex to robustly preserve indentation while removing the comment marker
                        # Pattern: ^(\s*)(prefix)(\s*)(rest)
                        pattern = f"^(\\s*){re.escape(prefix)}(\\s*)(.*)"
                        match = re.match(pattern, modified_line)
                        if match:
                            indent = match.group(1)
                            code_content = match.group(3)
                            modified_line = indent + code_content
                        break

            injected_lines.append(modified_line)

        script_content = "\n".join(injected_lines)

        # We name it generic 'script.code'. Change extension if your engine needs specific one (e.g., .scm, .cpp)
        script_path = os.path.join(run_dir, "script_to_run.metta")
        with open(script_path, "w") as f:
            f.write(script_content)

        return "script_to_run.metta"

    def _parse_lisp_results(self, text_block: str) -> List[Dict[str, Any]]:
        """
        Parses a Lisp-style result line: "((ExprA ScoreA) (ExprB ScoreB) (ExprC ScoreC))"
        Returns: [{'expression': '...', 'score': float}, ...]
        """
        text_block = text_block.strip()

        # Validations
        if not text_block.startswith("(") or not text_block.endswith(")"):
            return []

        # Strip outer parens: ((A 1) (B 2)) -> (A 1) (B 2)
        inner_content = text_block[1:-1].strip()

        candidates = []
        stack = 0
        buffer = ""

        # Stack-based character parsing to handle nested parens in expressions
        for char in inner_content:
            if char == "(":
                stack += 1
                buffer += char
            elif char == ")":
                stack -= 1
                buffer += char
                if stack == 0:
                    candidates.append(buffer.strip())
                    buffer = ""
            else:
                if stack > 0 or char.strip():
                    buffer += char

        parsed_results = []
        for cand in candidates:
            # cand is "(BooleanExpr Score)"
            # Find the last space to separate Expr from Score
            last_space_idx = cand.rfind(" ")
            if last_space_idx == -1:
                continue

            expr_raw = cand[1:last_space_idx].strip()
            score_raw = cand[last_space_idx + 1 : -1].strip()

            try:
                score_float = float(score_raw)
            except ValueError:
                score_float = float("inf")  # Treat parse error as bad score

            parsed_results.append({"expression": expr_raw, "score": score_float})

        return parsed_results

    def _extract_results_from_stdout(self, stdout_text: str) -> Dict[str, Any]:
        """
        Scans stdout for the result triplet and parses it.
        """
        lines = stdout_text.strip().split("\n")
        result_line = ""

        # Search for the last valid S-expression line
        for line in reversed(lines):
            line = line.strip()
            if line.startswith("(FinalResult ((") and line.endswith(")))"):
                result_line = line.removeprefix("(FinalResult ").removesuffix(")")
                break

        # 1. Recover Generation Logic
        # Finds all occurrences of "Generation X" and takes the last one as the stopped gen.
        gen_matches = re.findall(r"Generation\s+(\d+)", stdout_text)
        started_gen = int(gen_matches[0]) if gen_matches else -1
        end_gen = int(gen_matches[-1]) if gen_matches else -1

        # Generation in metta is logged from n to 0. This gets us the generation as if it run from 0 to n.
        stopped_gen = started_gen - (end_gen - 1) if gen_matches else -1

        if not result_line:
            return {
                "status": "PARSE_ERROR",
                "candidates": [],
                "message": "Result marker not found",
                "stopped_generation": stopped_gen,
            }

        candidates = self._parse_lisp_results(result_line)

        if not candidates:
            return {
                "status": "PARSE_ERROR",
                "candidates": [],
                "message": "Malformed S-Expression",
                "stopped_generation": stopped_gen,
            }

        # Sort by score (Assuming 0.0 is best/min error)
        candidates.sort(key=lambda x: x["score"], reverse=True)
        best_score = candidates[0]["score"]

        return {
            "status": "SUCCESS",
            "best_score": best_score,
            "candidates": candidates,
            "stopped_generation": stopped_gen,
        }

    def run(
        self,
        seed: int,
        problem: str,
        feature_selector: str,
        max_gens: int,
        n_deme: int = 1,
        engine_executable: str = "petta",
        engine_args: List[str] = ["-s"],
        timeout_sec: Optional[float] = 600,
        keep_sandbox: bool = False,
        log_json: bool = False,
    ) -> Dict[str, Any]:
        """
        Orchestrates a single GP run.
        """
        run_dir, log_dir = self._prepare_sandbox()
        start_time = time.time()

        try:
            # 1. Inject Template
            # Mapped specifically to the requested placeholders:
            # $seed, $maxGen, $nDeme, $fsAlgo, $problem
            params = {
                "$seed": seed,
                "$problem": problem,
                "$maxGen": max_gens,
                "$fsAlgo": feature_selector,
                "$nDeme": n_deme,
                "$outputDir": run_dir,
            }
            script_path = self._inject_code(run_dir, params)

            # 2. Execute Subprocess
            # Passing the script path as argument to the engine
            cmd = [engine_executable, script_path, *engine_args]

            print(
                f"[GPRunner] Seed {seed}: Running {problem} with {feature_selector} (Demes: {n_deme})..."
            )

            # If timeout_sec is None, subprocess waits indefinitely
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=timeout_sec,
                cwd=run_dir,  # Run inside the sandbox dir context
            )

            # 3. Handle Process Level Errors
            if result.returncode != 0:
                # Process crashed
                return {
                    "seed": seed,
                    "problem": problem,
                    "feature_selector": feature_selector,
                    "status": "CRASHED",
                    "return_code": result.returncode,
                    "error_log": result.stderr,
                    "candidates": [],
                    "wall_time": time.time() - start_time,
                }

            # 4. Parse Output
            parsed_data = self._extract_results_from_stdout(result.stdout)

            # Combine meta-data with parsed data
            output = {
                "seed": seed,
                "problem": problem,
                "feature_selector": feature_selector,
                "n_deme": n_deme,
                "wall_time": time.time() - start_time,
                **parsed_data,
            }

            # Save raw stdout for debugging (Senior practice)

            with open(
                os.path.join(
                    log_dir,
                    f"stdout_maxgen_{args.max_gens}_seed_{seed}.log",
                ),
                "w",
            ) as f:
                f.write(result.stdout)

            return output

        except subprocess.TimeoutExpired:
            return {
                "seed": seed,
                "problem": problem,
                "feature_selector": feature_selector,
                "status": "TIMEOUT",
                "candidates": [],
                "wall_time": timeout_sec if timeout_sec else -1,
            }

        except Exception as e:
            return {
                "seed": seed,
                "problem": problem,
                "feature_selector": feature_selector,
                "status": "SYSTEM_ERROR",
                "error_log": str(e),
                "candidates": [],
                "wall_time": time.time() - start_time,
            }

        finally:
            # 5. Cleanup
            if not keep_sandbox and os.path.exists(log_dir):
                shutil.rmtree(log_dir)

            if not log_json and os.path.exists(run_dir):
                shutil.rmtree(run_dir)


if __name__ == "__main__":
    # 1. First pass: Check for config file to load defaults
    conf_parser = argparse.ArgumentParser(add_help=False)
    conf_parser.add_argument(
        "--config", help="Path to JSON configuration file to load arguments from"
    )
    known_args, remaining_argv = conf_parser.parse_known_args()

    # Define Base Defaults (Code Level)
    defaults = {
        "count": 1,
        "max_gens": 1000,
        "demes": 1,
        "engine": "petta",
        "args": ["-s"],
        "outdir": "sandbox",
        "keep": False,
        "log_json": False,
        "timeout": 600,
    }

    # If Config File exists, load it and update defaults
    if known_args.config:
        if os.path.exists(known_args.config):
            try:
                with open(known_args.config, "r") as f:
                    file_defaults = json.load(f)
                    defaults.update(file_defaults)
                print(f"[GPRunner] Configuration loaded from {known_args.config}")
            except Exception as e:
                print(f"Error loading configuration file: {e}")
                exit(1)
        else:
            print(f"Error: Configuration file not found: {known_args.config}")
            exit(1)

    # 2. Main Parser setup
    parser = argparse.ArgumentParser(
        description="GP Harness - Run External Genetic Programming Engine",
        parents=[conf_parser],  # Inherit config arg for help display
    )

    # Set the defaults (combination of Code + Config)
    # CLI args will override these automatically if provided
    parser.set_defaults(**defaults)

    # Arguments
    # Note: required=False because they might be provided via config file
    parser.add_argument("--template", help="Path to the master template file")
    parser.add_argument("--problem", help="Problem name (e.g. parity4)")
    parser.add_argument("--fs", help="Feature Selector (e.g. smd, simple)")
    parser.add_argument("--seed", type=int, help="Starting seed")

    # Optional Arguments (Defaults are handled via set_defaults above)
    parser.add_argument(
        "--count",
        type=int,
        help="Number of sequential runs (seeds incrementing)",
    )
    parser.add_argument("--max_gens", type=int, help="Max generations")
    parser.add_argument("--demes", type=int, help="Number of demes")
    parser.add_argument("--engine", help="Path to executable")
    parser.add_argument(
        "--args", nargs="*", help="Args to the executable engine (space separated)"
    )
    parser.add_argument("--outdir", help="Base directory for sandbox")
    parser.add_argument(
        "--keep", action="store_true", help="Keep sandbox files after run"
    )
    parser.add_argument(
        "--log_json", action="store_true", help="Save result as JSON file in outdir"
    )
    parser.add_argument(
        "--timeout",
        type=float,
        help="Timeout in seconds. Set to 0 for infinite wait.",
    )

    args = parser.parse_args()

    # 3. Manual Validation for required fields (since we removed required=True)
    missing_args = []
    if not args.template:
        missing_args.append("--template")
    if not args.problem:
        missing_args.append("--problem")
    if not args.fs:
        missing_args.append("--fs")
    if args.seed is None:
        missing_args.append("--seed")

    if missing_args:
        parser.error(
            f"Missing required arguments: {', '.join(missing_args)}. "
            "Provide them via CLI or a --config JSON file."
        )

    # Initialize Runner
    try:
        runner = GPRunner(args.template, output_base_dir=args.outdir)
    except Exception as e:
        print(f"Error initializing runner: {e}")
        exit(1)

    # Handle timeout logic: 0 or None means infinite (passed as None to subprocess)
    effective_timeout = args.timeout if args.timeout and args.timeout > 0 else None

    results = []

    # Trackers for advanced metrics
    valid_scores = []
    success_gens = []

    print(f"--- Starting Batch: {args.count} runs starting from seed {args.seed} ---")
    if effective_timeout is None:
        print("⚠️  WARNING: Timeout disabled. Processes may hang indefinitely.")

    for i in range(args.count):
        current_seed = args.seed + i

        res = runner.run(
            seed=current_seed,
            problem=args.problem,
            feature_selector=args.fs,
            max_gens=args.max_gens,
            n_deme=args.demes,
            engine_executable=args.engine,
            engine_args=args.args,
            keep_sandbox=args.keep,
            log_json=args.log_json,
            timeout_sec=effective_timeout,
        )

        results.append(res)

        # Terminal Output
        status = res.get("status", "UNKNOWN")
        score = res.get("best_score", "N/A")
        gen = res.get("stopped_generation", -1)

        # Collect Stats
        if isinstance(score, (int, float)) and score != float("inf"):
            valid_scores.append(score)

        if status == "SUCCESS" and gen > -1:
            success_gens.append(gen)

        print(f"Seed {current_seed}: {status} (Score: {score}, Gen: {gen})")

        # Optional: Save individual JSON logs
        if args.log_json:
            log_dir = os.path.join(args.outdir, "logs", args.problem, "result")
            os.makedirs(log_dir, exist_ok=True)
            log_path = os.path.join(
                log_dir, f"maxgen_{args.max_gens}_seed_{current_seed}.json"
            )
            with open(log_path, "w") as f:
                json.dump(res, f, indent=4)
            print(f"  -> Log saved: {log_path}")

    # --- Devo's Senior Analysis ---
    success_count = sum(1 for r in results if r.get("status") == "SUCCESS")
    success_rate = (success_count / args.count) * 100

    # MBF (Mean Best Fitness) - The average final score of ALL runs
    mean_best_fitness = (
        sum(valid_scores) / len(valid_scores) if valid_scores else float("inf")
    )

    # AES (Average Evaluations to Solution) approximation using Generations
    avg_gen_success = sum(success_gens) / len(success_gens) if success_gens else 0

    # Standard Deviation of Scores (Stability Metric)
    std_dev_score = 0
    if len(valid_scores) > 1:
        variance = sum((x - mean_best_fitness) ** 2 for x in valid_scores) / (
            len(valid_scores) - 1
        )
        std_dev_score = math.sqrt(variance)

    print(f"\n--- Batch Analysis ({args.problem}) ---")
    print(f"Total Runs:      {args.count}")
    print(f"Success Rate:    {success_rate:.1f}%")
    print(f"Mean Best Score: {mean_best_fitness:.4f} (Lower is better)")
    print(f"Std Dev Score:   {std_dev_score:.4f} (Stability)")
    print(f"Avg Gens to Win: {avg_gen_success:.1f} (Speed)")

    # Save Batch Summary Log
    if args.log_json:
        summary_dir = os.path.join(args.outdir, "logs", args.problem, "summary")
        os.makedirs(summary_dir, exist_ok=True)

        batch_summary = {
            "run_configuration": vars(args),
            "aggregate_metrics": {
                "total_runs": args.count,
                "start_seed": args.seed,
                "success_rate": success_rate,
                "mean_best_fitness": mean_best_fitness,
                "std_dev_fitness": std_dev_score,
                "avg_gens_to_solution": avg_gen_success,
            },
            "timestamp": time.time(),
        }

        summary_filename = f"aggregate_startseed_{args.seed}_count_{args.count}.json"
        summary_path = os.path.join(summary_dir, summary_filename)

        with open(summary_path, "w") as f:
            json.dump(batch_summary, f, indent=4)
        print(f"  -> Batch Summary saved: {summary_path}")
