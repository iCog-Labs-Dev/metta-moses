# run_tests.py
import unittest
import os

def discover_and_run_tests(start_dir='.'):
    loader = unittest.TestLoader()
    suite = unittest.TestSuite()

    for root, _, files in os.walk(start_dir):
        for file in files:
            if file.startswith('test') and file.endswith('.py'):
                path = os.path.join(root, file)
                # Convert path to module-like format (relative to start_dir)
                rel_path = os.path.relpath(path, start_dir)
                module_name = rel_path[:-3].replace(os.path.sep, '.')
                
                # Import and add the tests
                try:
                    module = __import__(module_name, fromlist=[''])
                    suite.addTests(loader.loadTestsFromModule(module))
                except Exception as e:
                    print(f"Could not import {module_name}: {e}")

    runner = unittest.TextTestRunner(verbosity=2)
    runner.run(suite)

if __name__ == '__main__':
    discover_and_run_tests()
