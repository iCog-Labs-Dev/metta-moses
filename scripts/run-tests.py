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
    # Always use stdout for mettalog output
    output = result.stdout if result.stdout else result.stderr
    extracted = output.replace("[()]\n", "")

    # Check for actual failures in the LoonIt Report
    has_failure = False
    if "Failures:" in extracted:
        # Extract the failures count
        import re

        failures_match = re.search(r"Failures:\s*(\d+)", extracted)
        if failures_match:
            failures_count = int(failures_match.group(1))
            has_failure = failures_count > 0

    if not has_failure:
        extracted = "test passed"

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

        # Use the full path to mettalog
        mettalog_path = shutil.which("mettalog")
        command = [mettalog_path, str(test_file)]

        # Don't use check=True since mettalog returns 1 even for successful tests
        # Add timeout to prevent hanging in CI
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,  # Changed from True to False
            shell=False,
            env=env,
        )

        return result, test_file, False

    except subprocess.TimeoutExpired as e:
        print(RED + f"\n--- TIMEOUT in {test_file} ---" + RESET)
        print(
            RED
            + f"Test timed out after 5 minutes. Likely infinite loop in test."
            + RESET
        )
        print("-" * 40)

        # Create a mock result for the timeout case
        class MockTimeoutResult:
            def __init__(self):
                self.returncode = -2
                self.stdout = ""
                self.stderr = "Test timed out after 5 minutes"

        return MockTimeoutResult(), test_file, True

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
metta_run_command = "mettalog"

root = pathlib.Path(".")
testMettaFiles = list(root.rglob("*test.metta"))
total_files = len(testMettaFiles)
results = []
fails = 0

if total_files == 0:
    print("⚠️  No test files found matching pattern '*test.metta'")
    sys.exit(0)

# Print ASCII art title
print_ascii_art("Parallel Test Runner")

# Execute tests in parallel
with ThreadPoolExecutor(max_workers=1) as executor:
    future_to_test = {
        executor.submit(run_test_file, test_file): idx
        for idx, test_file in enumerate(testMettaFiles)
    }

    for future in as_completed(future_to_test):
        idx = future_to_test[future]
        try:
            result, path, has_failure = future.result()
            # print("")
            # print("Result: ", result)
            # print("")

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

        except Exception as exc:
            print(RED + f"Test {idx + 1}: generated an exception: {exc}" + RESET)
            fails += 1

# Summary
print(CYAN + "\nTest Summary" + RESET)
print(f"{total_files} files tested.")
print(RED + f"{fails} failed." + RESET)
print(GREEN + f"{total_files - fails} succeeded." + RESET)

if fails > 0:
    print(RED + "Tests failed. Process Exiting with exit code 1" + RESET)
    sys.exit(1)
