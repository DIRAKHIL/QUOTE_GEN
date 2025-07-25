#!/bin/bash

# Script to verify all compilation fixes are in place
echo "🔍 Verifying S-Quote compilation fixes..."
echo ""

# Check if we're in the right directory
if [ ! -f "QUOTE_GEN.xcodeproj/project.pbxproj" ]; then
    echo "❌ Error: Not in QUOTE_GEN project directory"
    echo "Please run this script from /Users/dirakhil/REPOS/QUOTE_GEN"
    exit 1
fi

echo "📁 Project directory: $(pwd)"
echo ""

# Check 1: QuotationManager methods
echo "1️⃣ Checking QuotationManager methods..."
if grep -q "func updateQuotation" QUOTE_GEN/QuotationManager.swift && grep -q "func addQuotation" QUOTE_GEN/QuotationManager.swift; then
    echo "   ✅ updateQuotation and addQuotation methods found"
else
    echo "   ❌ Missing methods in QuotationManager"
fi

# Check 2: onChange syntax
echo ""
echo "2️⃣ Checking onChange syntax..."
deprecated_count=$(grep "onChange.*{ _ in" QUOTE_GEN/Views/EnhancedQuotationDetailView.swift 2>/dev/null | wc -l)
deprecated_count=$(echo $deprecated_count | tr -d ' ')
if [ "$deprecated_count" = "0" ]; then
    echo "   ✅ No deprecated onChange syntax found"
else
    echo "   ❌ Found $deprecated_count deprecated onChange calls"
fi

# Check 3: Missing view files
echo ""
echo "3️⃣ Checking for required view files..."
missing_files=0

if [ ! -f "QUOTE_GEN/Views/ClientsView.swift" ]; then
    echo "   ❌ Missing ClientsView.swift"
    missing_files=$((missing_files + 1))
else
    echo "   ✅ ClientsView.swift exists"
fi

if [ ! -f "QUOTE_GEN/Views/ServicesView.swift" ]; then
    echo "   ❌ Missing ServicesView.swift"
    missing_files=$((missing_files + 1))
else
    echo "   ✅ ServicesView.swift exists"
fi

if [ ! -f "QUOTE_GEN/Views/ReportsView.swift" ]; then
    echo "   ❌ Missing ReportsView.swift"
    missing_files=$((missing_files + 1))
else
    echo "   ✅ ReportsView.swift exists"
fi

if [ ! -f "QUOTE_GEN/Views/SettingsView.swift" ]; then
    echo "   ❌ Missing SettingsView.swift"
    missing_files=$((missing_files + 1))
else
    echo "   ✅ SettingsView.swift exists"
fi

# Check 4: Git status
echo ""
echo "4️⃣ Checking Git status..."
git_status=$(git status --porcelain)
if [ -z "$git_status" ]; then
    echo "   ✅ Repository is clean and up to date"
else
    echo "   ⚠️  Repository has uncommitted changes:"
    git status --short
fi

# Summary
echo ""
echo "📊 SUMMARY"
echo "=========="
if [ "$deprecated_count" = "0" ] && [ "$missing_files" -eq 0 ]; then
    echo "🎉 All fixes are in place! The project should compile successfully."
    echo ""
    echo "If you're still seeing compilation errors:"
    echo "1. Close Xcode completely"
    echo "2. Clean derived data: rm -rf ~/Library/Developer/Xcode/DerivedData/QUOTE_GEN-*"
    echo "3. Reopen QUOTE_GEN.xcodeproj"
    echo "4. Clean build folder (Product → Clean Build Folder)"
    echo "5. Build project (⌘+B)"
else
    echo "❌ Some issues remain:"
    [ "$deprecated_count" != "0" ] && echo "   - $deprecated_count deprecated onChange calls"
    [ "$missing_files" -gt 0 ] && echo "   - $missing_files missing view files"
    echo ""
    echo "Please run the update script: ./update_local_repo.sh"
fi

echo ""
echo "🔗 Latest changes are available at: https://github.com/DIRAKHIL/QUOTE_GEN"