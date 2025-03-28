#!/bin/bash

# Script to safely add remote, commit, and push to GitHub from WSL
# For projects on Windows filesystem (/mnt/c)
# Author: Glen+Adam
# Date: March 28, 2025

# Repository variables
GITHUB_REPO="unity-child-transform-tool"
GITHUB_USERNAME="glen-martin-tvmsi"
REPO_URL="https://github.com/glen-martin-tvmsi/unity-child-transform-tool.git"

echo "Setting up Git repository in: $(pwd)"

# 1. Ensure Git knows this directory is safe to work with
git config --global --add safe.directory "$(pwd)"
echo "Directory marked as safe for Git operations"

# 2. Check if we have any commits yet
if ! git rev-parse --verify HEAD >/dev/null 2>&1; then
  echo "No commits found, creating initial commit..."
  git add .
  git config user.name "glen-martin-tvmsi"
  git config user.email "glen@tathvamasi.com"
  git commit -m "Initial commit: Child Transform Tool for Unity"
  
  # Rename current branch to main (in case it's called 'master')
  CURRENT_BRANCH=$(git branch --show-current)
  if [ "$CURRENT_BRANCH" != "main" ]; then
    git branch -m main
    echo "Renamed branch to 'main'"
  fi
else
  echo "Repository already has commits"
fi

# 3. Configure credential helper to store your token permanently
echo "Configuring credential helper..."
git config --global credential.helper store

# Ask for GitHub personal access token
read -p "Enter your GitHub personal access token: " GITHUB_TOKEN

# Save the token in the credential store
echo "https://${GITHUB_USERNAME}:${GITHUB_TOKEN}@github.com" > ~/.git-credentials
echo "GitHub token stored successfully!"

# 4. Set up the remote repository
git remote remove origin 2>/dev/null
git remote add origin "${REPO_URL}"
echo "Remote 'origin' configured"

# 5. Push to GitHub
echo "Pushing to GitHub..."
git push -u origin main

echo "Operation complete!"
