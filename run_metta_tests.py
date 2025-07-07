#!/usr/bin/env python3

import subprocess
import pathlib
import sys
import shutil
import re

# Force output to appear immediately
sys.stdout.reconfigure(line_buffering=True)
sys.stderr.reconfigure(line_buffering=True)

print('🚀 Starting Metta test runner', flush=True)

# Define ANSI escape codes for colors
RESET = "\033[0m"
BOLD = "\033[1m"
CYAN = "\033[96m"
GREEN = "\033[92m"
RED = "\033[91m"
YELLOW = "\033[93m"
MAGENTA = "\033[95m"

def parse_test_results(output, test_file=None):
    """Parse mettalog output to determine if tests passed or failed"""
    if not output:
        return True  # No output usually means failure

    # Look for LoonIt Report section
    if "[LoonIt Report" in output:
        # Extract the report section
        report_start = output.find("[LoonIt Report")
        report_section = output[report_start:]

        # Look for failure count
        failure_match = re.search(r"Failures:\s*(\d+)", report_section)
        if failure_match:
            failures = int(failure_match.group(1))
            return failures > 0

        # If no failures line found, check for success indicators
        if "Successes:" in report_section:
            success_match = re.search(r"Successes:\s*(\d+)", report_section)
            if success_match:
                successes = int(success_match.group(1))
                return successes == 0  # Failed if no successes

    # Look for error indicators in the output
    error_indicators = [
        "error",
        "Error",
        "ERROR",
        "Exception",
        "type_error",
        "EOF: exit (status",
        "zsh:1: no matches found"
    ]

    for indicator in error_indicators:
        if indicator in output:
            return True  # Has failure

    # If we can't determine, assume failure for safety
    return True

def run_test_file(test_file):
    """Run a single test file with mettalog command"""
    try:
        # Check if mettalog is available
        mettalog_path = shutil.which("mettalog")
        if not mettalog_path:
            print(RED + f"❌ mettalog command not found in PATH" + RESET)
            return None, test_file, True

        # Create command
        command = [mettalog_path, str(test_file)]

        print(f"🔄 Running: {' '.join(command)}", flush=True)

        # Run the command with timeout
        result = subprocess.run(
            command,
            capture_output=True,
            text=True,
            check=False,  # Don't raise exception on non-zero exit
            timeout=300   # 5 minute timeout
        )

        print(GREEN + f"\n--- COMPLETED {test_file} ---" + RESET)

        # Parse the output to determine if tests passed or failed
        output = result.stdout if result.stdout else result.stderr
        has_failure = parse_test_results(output, test_file)

        # Show condensed output
        if has_failure:
            print(RED + "❌ TEST FAILED" + RESET)
            # Show only the LoonIt Report section if available
            if "[LoonIt Report" in output:
                report_start = output.find("[LoonIt Report")
                report_section = output[report_start:]
                print(YELLOW + "Test Report:\n" + report_section + RESET)
            else:
                # Show last few lines of output
                lines = output.strip().split('\n')
                print(YELLOW + "Last few lines of output:\n" + '\n'.join(lines[-10:]) + RESET)
        else:
            print(GREEN + "✅ TEST PASSED" + RESET)

        print(YELLOW + f"Exit code: {result.returncode}" + RESET)
        print("-" * 50)

        return result, test_file, has_failure
        
    except subprocess.TimeoutExpired:
        print(RED + f"\n--- TIMEOUT in {test_file} ---" + RESET, flush=True)
        print(RED + f"Test timed out after 5 minutes" + RESET, flush=True)
        print("-" * 50)
        
        # Create a mock result for timeout
        class MockTimeoutResult:
            def __init__(self):
                self.returncode = -1
                self.stdout = ""
                self.stderr = "Test timed out after 5 minutes"
        
        return MockTimeoutResult(), test_file, True
        
    except Exception as e:
        print(RED + f"\n--- ERROR in {test_file} ---" + RESET, flush=True)
        print(RED + f"Error: {str(e)}" + RESET, flush=True)
        print("-" * 50)
        
        # Create a mock result for errors
        class MockErrorResult:
            def __init__(self, error):
                self.returncode = -2
                self.stdout = ""
                self.stderr = f"Error running test: {str(error)}"
        
        return MockErrorResult(e), test_file, True

def main():
    """Main function to find and run all *test.metta files"""
    
    print("🔍 Searching for *test.metta files...", flush=True)
    
    # Find all files matching *test.metta pattern
    root = pathlib.Path(".")
    test_files = list(root.rglob("*test.metta"))
    
    print(f"📁 Found test files: {[str(f) for f in test_files]}", flush=True)
    total_files = len(test_files)
    
    if total_files == 0:
        print("⚠️  No test files found matching pattern '*test.metta'", flush=True)
        print("✅ Exiting with success (no tests to run)", flush=True)
        return 0
    
    print(f"🎯 Will run {total_files} test file(s)", flush=True)
    print("=" * 60)
    
    # Track results
    failed_tests = 0
    passed_tests = 0
    
    # Run tests sequentially for clearer output
    for idx, test_file in enumerate(test_files):
        print(f"\n📝 Test {idx + 1}/{total_files}: {test_file}")
        print("-" * 50)
        
        result, path, has_failure = run_test_file(test_file)
        
        if result is None:
            print(RED + f"❌ Failed to run {path}" + RESET)
            failed_tests += 1
            continue
            
        if has_failure:
            print(RED + f"❌ Test failed: {path}" + RESET)
            failed_tests += 1
        else:
            print(GREEN + f"✅ Test passed: {path}" + RESET)
            passed_tests += 1
    
    # Print summary
    print("\n" + "=" * 60)
    print(CYAN + BOLD + "TEST SUMMARY" + RESET)
    print(f"📊 Total files tested: {total_files}")
    print(GREEN + f"✅ Passed: {passed_tests}" + RESET)
    print(RED + f"❌ Failed: {failed_tests}" + RESET)
    
    if failed_tests > 0:
        print(RED + "\n💥 Some tests failed!" + RESET)
        return 1
    else:
        print(GREEN + "\n🎉 All tests passed!" + RESET)
        return 0

if __name__ == "__main__":
    exit_code = main()
    sys.exit(exit_code)
