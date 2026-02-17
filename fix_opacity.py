import os

def replace_with_opacity(directory):
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".dart"):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()
                
                if ".withOpacity(" in content:
                    print(f"Updating {filepath}")
                    new_content = content.replace(".withOpacity(", ".withValues(alpha: ")
                    with open(filepath, 'w') as f:
                        f.write(new_content)

replace_with_opacity("lib")
