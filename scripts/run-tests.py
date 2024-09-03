import subprocess
import pathlib
from typing import Tuple
import sys

# Define ANSI escape codes for colors
RESET = "\033[0m"
BOLD = "\033[1m"
UNDERLINE = "\033[4m"
CYAN = "\033[96m"
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
MAGENTA = "\033[95m"


def extract_and_print(result, path) -> bool:
    output = result.stdout if result.returncode == 0 else result.stderr
    # Remove the specified substring
    extracted = output.replace("[()]\n", "")

    # Check if the string contains the word "Error"
    has_failure = "Error" in extracted

    if not has_failure:
        extracted = "test passed"

    status_color = RED if has_failure else GREEN
    print(YELLOW + f"Test {idx + 1}: {path}" + RESET)
    print(status_color + extracted + RESET)
    print(YELLOW + f"Exit-code: {result.returncode}" + RESET)
    print("-" * 40)

    return has_failure


# Function to print ASCII art
def print_ascii_art(text):
    art = f"""
                {text}
           """
    print(CYAN + art + RESET)


# Define the command to run with the test files
metta_run_command = "metta-run"

root = pathlib.Path("../")
testMettaFiles = root.rglob("*test.metta")
total_files = 0
results = []
fails = 0

# Print ASCII art title
print_ascii_art("Test Runner")

for testFile in testMettaFiles:
    total_files += 1
    try:
        result = subprocess.run(
            [metta_run_command, str(testFile)],  # Convert testFile to string
            capture_output=True,
            text=True,
            check=True,
        )
        fails += result.returncode
        results.append((result, testFile))  # Collect only stdout in the results list
    except subprocess.CalledProcessError as e:
        results.append(f"Error with {testFile}: {e.stderr}")
        fails += 1

# Output the results
for idx, (result, path) in enumerate(results):
    if isinstance(result, str):
        print(RED + f"Error found: {result}" + RESET)
        continue

    has_failure = extract_and_print(result, path)
    if has_failure:
        fails += 1


# Summary
print(CYAN + "\nTest Summary" + RESET)
print(f"{total_files} files tested.")
print(RED + f"{fails} failed." + RESET)
print(GREEN + f"{total_files - fails} succeeded." + RESET)


if fails > 0:
    print(RED + "Tests failed . Process Exiting with exit code 1" + RESET)
    sys.exit(1)
