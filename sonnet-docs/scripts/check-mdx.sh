#!/bin/bash

# Script to check MDX files for syntax errors
# This helps identify issues with Docusaurus MDX files

echo "Checking MDX files for syntax errors..."
echo "---------------------------------------------"

# Install docusaurus-mdx-checker if needed
if ! npm list -g docusaurus-mdx-checker &> /dev/null; then
    echo "Installing docusaurus-mdx-checker..."
    npm install -g docusaurus-mdx-checker
fi

# Run the MDX checker
echo "Running MDX checker..."
npx docusaurus-mdx-checker

echo "---------------------------------------------"
echo "If you see errors above, here are common fixes:"
echo "1. For curly braces {} in text: Use backticks or escape them with \\"
echo "2. For angle brackets <> in text: Use backticks or escape them with \\"
echo "3. For code blocks with React: Add 'jsx' after the opening backticks"
echo "4. For missing image errors: Make sure the image exists or comment out the reference"
echo "---------------------------------------------"
echo "For more details, see: https://docusaurus.io/docs/markdown-features/react" 