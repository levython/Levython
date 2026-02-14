#!/bin/bash

# Package Levython VS Code Extension
cd "$(dirname "$0")"

echo "Installing vsce if needed..."
if ! command -v vsce &> /dev/null; then
    echo "Installing @vscode/vsce..."
    npm install -g @vscode/vsce
fi

echo ""
echo "Packaging extension..."
npx --yes @vscode/vsce package

echo ""
echo "Done! VSIX file created."
ls -lh *.vsix
