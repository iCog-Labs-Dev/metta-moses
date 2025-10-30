import os

# Start from the current directory
start_dir = "."

# Walk through all directories and subdirectories
for root, dirs, files in os.walk(start_dir):
    for file in files:
        if file.endswith("test.metta"):
            old_path = os.path.join(root, file)
            new_file = file.replace("test.metta", "testold.metta")
            new_path = os.path.join(root, new_file)

            os.rename(old_path, new_path)
            print(f"Renamed: {old_path} -> {new_path}")
