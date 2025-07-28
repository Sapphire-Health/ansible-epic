#!/bin/bash

# Define the root directory to start searching for repositories
# Change this to the desired parent directory of your Git repositories
ROOT_DIR="roles" 

# Find all .git directories and process their parent directories
find "$ROOT_DIR" -type d -name ".git" | while read git_dir; do
  # Get the parent directory of the .git directory
  repo_dir=$(dirname "$git_dir")

  echo "Synchronizing Git repository in: $repo_dir"

  # Change to the repository directory
  if cd "$repo_dir"; then
    # Perform a git pull to fetch and merge changes
    git pull
    
    # Optional: Add other Git commands here, e.g., git fetch, git status, etc.
    # git fetch
    # git status

    # Return to the original working directory
    cd - > /dev/null
  else
    echo "Error: Could not change to directory $repo_dir"
  fi
  echo "-----------------------------------------"
done