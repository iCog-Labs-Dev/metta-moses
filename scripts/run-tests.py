import subprocess
import pathlib
import sys
import re
import os
from concurrent.futures import ThreadPoolExecutor, as_completed
import shutil

print("🚀 Starting test script")

# Define ANSI escape codes for colors
RESET = "\033[0m"
BOLD = "\033[1m"
UNDERLINE = "\033[4m"
CYAN = "\033[96m"
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
MAGENTA = "\033[95m"


def extract_and_print(result, path, idx) -> bool:
    """
    Extracts the output from the test execution result and prints the status.
    """
    # Always use stdout for petta output
    output = result.stdout if result.stdout else result.stderr
    extracted = output.strip()  # Remove any leading/trailing whitespace

    with open(path, "r") as test_file:
        content = test_file.read()
        total_asserts = sum(
            1
            for line in content.splitlines()
            if "!(assertEqual" in line and not line.lstrip().startswith(";")
        )

    raw_passed = extracted.count("✅")
    passed_asserts = min(
        raw_passed, total_asserts
    )  # Cap passed asserts to total asserts to avoid redundancy

    # Check for actual failures in the Petta Report
    has_failure = False  # Assume failure by default

    # Treat exit code 0 as success, anything else as failure
    if result.returncode == 0:
        if "❌" in extracted or passed_asserts != total_asserts:
            has_failure = True
            extracted = f"test failed (output: {extracted})"
        else:
            extracted = "test passed"
    else:
        has_failure = True
        extracted = f"test failed (output: {extracted})"

    # Print the test result
    status_color = RED if has_failure else GREEN
    print(YELLOW + f"Test {idx + 1}: {path}" + RESET)
    print(status_color + extracted + RESET)
    print(YELLOW + f"Exit-code: {result.returncode}" + RESET)
    print("-" * 40)

    return has_failure


def run_test_file(test_file):
    try:
        # Create a clean environment with bash as default shell
        env = os.environ.copy()
        env["SHELL"] = "/bin/bash"

        # Full path to the run.sh script
        run_sh_path = shutil.which("run.sh")
        if not os.path.isfile(run_sh_path):
            raise FileNotFoundError(f"{run_sh_path} not found")

        # Command to execute the test file
        command = [run_sh_path, str(test_file), "-s"]

        # Run the command
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,
            shell=False,
            env=env,
        )

        return result, test_file, False

    except Exception as e:
        print(RED + f"\n--- EXCEPTION in {test_file} ---" + RESET)
        print(RED + f"Exception: {e}" + RESET)
        print("-" * 40)

        # Create a mock result for the exception case
        class MockResult:
            def __init__(self):
                self.returncode = -1
                self.stdout = ""
                self.stderr = str(e)

        return MockResult(), test_file, True


# Function to print ASCII art
def print_ascii_art(text):
    art = f"""
                {text}
           """
    print(CYAN + art + RESET)


# Define the command to run with the test files
root = pathlib.Path(".")
testPettaFiles = list(root.rglob("*test.metta"))
total_files = len(testPettaFiles)
results = []
fails = 0
failed_tests = []

if total_files == 0:
    print("⚠️  No test files found matching pattern '*test.metta'")
    sys.exit(0)

# Print ASCII art title
print_ascii_art("Parallel Test Runner")

# Execute tests in parallel
with ThreadPoolExecutor(max_workers=1) as executor:
    future_to_test = {
        executor.submit(run_test_file, test_file): idx
        for idx, test_file in enumerate(testPettaFiles)
    }

    for future in as_completed(future_to_test):
        idx = future_to_test[future]
        try:
            result, path, has_failure = future.result()

            # Since we're no longer using check=True, we won't get CalledProcessError
            # Just check if the result is valid
            if result is None:
                print(RED + f"Error with {path}: No result returned" + RESET)
                fails += 1
                continue

            # Extract and print results
            has_failure = extract_and_print(result, path, idx)
            if has_failure:
                fails += 1
                failed_tests.append(str(path))

        except Exception as exc:
            print(RED + f"Test {idx + 1}: generated an exception: {exc}" + RESET)
            fails += 1

# Summary
print(CYAN + "\nTest Summary" + RESET)
print(f"{total_files} files tested.")
print(RED + f"{fails} failed." + RESET)
print(GREEN + f"{total_files - fails} succeeded." + RESET)
if fails > 0:
    print(RED + "Failed test files:" + RESET)
    for failed in failed_tests:
        print(RED + f" - {failed}" + RESET)

if fails > 0:
    print(RED + "Tests failed. Process Exiting with exit code 1" + RESET)
    sys.exit(1)

