#!/bin/bash

# Script to update local repository and refresh Xcode
echo "🔄 Updating S-Quote repository..."

# Navigate to your local repo directory
cd /Users/dirakhil/REPOS/QUOTE_GEN

# Stash any local changes
echo "📦 Stashing local changes..."
git stash

# Pull latest changes
echo "⬇️ Pulling latest changes from GitHub..."
git pull origin main

# Clean Xcode derived data
echo "🧹 Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/QUOTE_GEN-*

echo "✅ Update complete!"
echo ""
echo "Next steps:"
echo "1. Close Xcode completely"
echo "2. Reopen the QUOTE_GEN.xcodeproj file"
echo "3. Clean build folder (Product → Clean Build Folder)"
echo "4. Build the project (⌘+B)"
echo ""
echo "The compilation errors should now be resolved! 🎉"