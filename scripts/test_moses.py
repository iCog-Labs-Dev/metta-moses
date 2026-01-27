import subprocess
import os
import re
import shutil
import time
import json
import argparse
from typing import Dict, Any, List


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
        stopped_gen = int(gen_matches[-1]) if gen_matches else -1

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
        timeout_sec: int = 600,
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
                "wall_time": timeout_sec,
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
    parser = argparse.ArgumentParser(
        description="GP Harness - Run External Genetic Programming Engine"
    )

    # Required Arguments
    parser.add_argument(
        "--template", required=True, help="Path to the master template file"
    )
    parser.add_argument("--problem", required=True, help="Problem name (e.g. parity4)")
    parser.add_argument(
        "--fs", required=True, help="Feature Selector (e.g. smd, simple)"
    )
    parser.add_argument("--seed", type=int, required=True, help="Starting seed")

    # Optional Arguments
    parser.add_argument(
        "--count",
        type=int,
        default=1,
        help="Number of sequential runs (seeds incrementing)",
    )
    parser.add_argument("--max_gens", type=int, default=1000, help="Max generations")
    parser.add_argument("--demes", type=int, default=1, help="Number of demes")
    parser.add_argument("--engine", default="petta", help="Path to executable")
    parser.add_argument(
        "--args", type=List, default=["-s"], help="Args to the executable engine"
    )
    parser.add_argument(
        "--outdir", default="sandbox", help="Base directory for sandbox"
    )
    parser.add_argument(
        "--keep", action="store_true", help="Keep sandbox files after run"
    )
    parser.add_argument(
        "--log_json", action="store_true", help="Save result as JSON file in outdir"
    )

    args = parser.parse_args()

    # Initialize Runner
    try:
        runner = GPRunner(args.template, output_base_dir=args.outdir)
    except Exception as e:
        print(f"Error initializing runner: {e}")
        exit(1)

    results = []

    print(f"--- Starting Batch: {args.count} runs starting from seed {args.seed} ---")

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
        )

        results.append(res)

        # Terminal Output
        status = res.get("status", "UNKNOWN")
        score = res.get("best_score", "N/A")
        print(f"Seed {current_seed}: {status} (Score: {score})")

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

    # Summary
    success_count = sum(1 for r in results if r.get("status") == "SUCCESS")
    print("\n--- Batch Complete ---")
    print(f"Success Rate: {(success_count / args.count) * 100}%")
