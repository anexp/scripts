#!/usr/bin/env python

import os
import sys

def substitute_word_in_file(file_path, target_word, replacement_word):
    try:
        with open(file_path, 'r') as file:
            content = file.read()

        modified_content = content.replace(target_word, replacement_word)

        with open(file_path, 'w') as file:
            file.write(modified_content)

    except Exception as e:
        print(f"Error processing file {file_path}: {e}")

def substitute_word_in_directory(directory_path, target_word, replacement_word):
    for root, dirs, files in os.walk(directory_path):
        # Check if '.git' is in the list of directories
        # print(root,dirs,files)
        if '.git' in dirs:
            # Remove '.git' from the list of directories to prevent traversal
            dirs.remove('.git')

        for file_name in files:
            file_path = os.path.join(root, file_name)
            print(f"Processing file : {file_path}")
            substitute_word_in_file(file_path, target_word, replacement_word)

# Replace 'old_word' with 'new_word' in all files in the specified directory
directory_path = '/path/to/your/directory'
target_word = 'old_word'
replacement_word = 'new_word'

directory_path = sys.argv[1]
directory_path = os.path.expanduser(directory_path)
target_word= sys.argv[2]
replacement_word = sys.argv[3]
print(f"Directory path : {directory_path}")
print(f"Target word : {target_word}")
print(f"Replacement word : {replacement_word}")

if __name__ == "__main__":

    substitute_word_in_directory(directory_path, target_word, replacement_word)



