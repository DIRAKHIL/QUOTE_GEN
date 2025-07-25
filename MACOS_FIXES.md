# macOS Compilation Fixes for S-Quote

## Quick Fix Instructions

The compilation errors you're seeing are due to iOS-specific code that needs to be replaced with macOS-compatible alternatives. Here are the exact fixes needed:

## 🚨 LATEST FIX (AIRecommendationsView.swift)

### Error: String formatting with specifier (Line 121)
**Replace:**
```swift
value: "₹\(recommendations.reduce(0) { $0 + $1.estimatedCost }, specifier: "%.0f")",
```
**With:**
```swift
value: "₹\(String(format: "%.0f", recommendations.reduce(0) { $0 + $1.estimatedCost }))",
```

## 1. Fix QuotationListView.swift

Replace the problematic lines in your `QuotationListView.swift` file:

### Error 1: navigationBarTitleDisplayMode (Line 38)
**Remove this line completely:**
```swift
.navigationBarTitleDisplayMode(.large)
```

### Error 2: navigationBarTrailing (Line 40)
**Replace:**
```swift
ToolbarItem(placement: .navigationBarTrailing) {
```
**With:**
```swift
ToolbarItem(placement: .primaryAction) {
```

### Error 3: String formatting with specifier (Line 100)
**Replace:**
```swift
value: "₹\(quotationManager.getAverageQuotationValue(), specifier: "%.0f")",
```
**With:**
```swift
value: "₹\(String(format: "%.0f", quotationManager.getAverageQuotationValue()))",
```

### Error 4: systemGray6 color (Line 107)
**Replace:**
```swift
.background(Color(.systemGray6))
```
**With:**
```swift
.background(Color(NSColor.controlBackgroundColor))
```

### Error 5: systemBackground color (Line 202)
**Replace:**
```swift
.background(Color(.systemBackground))
```
**With:**
```swift
.background(Color(NSColor.controlBackgroundColor))
```

## 2. Complete Fixed QuotationListView.swift

Here's the complete corrected file content. Replace your entire QuotationListView.swift with this:

```swift
//
//  QuotationListView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI
import AppKit

struct QuotationListView: View {
    @StateObject private var quotationManager = QuotationManager()
    @State private var searchText = ""
    @State private var showingNewQuotation = false
    
    var filteredQuotations: [Quotation] {
        if searchText.isEmpty {
            return quotationManager.quotations
        } else {
            return quotationManager.quotations.filter { quotation in
                quotation.clientName.localizedCaseInsensitiveContains(searchText) ||
                quotation.eventType.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                searchBar
                
                // Statistics header
                statisticsHeader
                
                // Quotations list
                if filteredQuotations.isEmpty {
                    emptyStateView
                } else {
                    quotationsList
                }
            }
            .navigationTitle("S-Quote")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: createNewQuotation) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingNewQuotation) {
                QuotationDetailView(quotation: quotationManager.createNewQuotation())
                    .environmentObject(quotationManager)
            }
        }
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search quotations...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding()
    }
    
    private var statisticsHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text("\(quotationManager.quotations.count)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
                Text("Total Quotations")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(String(format: "%.0f", quotationManager.getTotalRevenue()))")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
                Text("Total Revenue")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        )
        .padding(.horizontal)
    }
    
    private var quotationsList: some View {
        List {
            ForEach(filteredQuotations) { quotation in
                NavigationLink(destination: QuotationDetailView(quotation: quotation).environmentObject(quotationManager)) {
                    QuotationRowView(quotation: quotation)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }
            .onDelete(perform: deleteQuotations)
        }
        .listStyle(PlainListStyle())
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "doc.text.below.ecg")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Quotations Yet")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first quotation to get started with S-Quote")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Button(action: createNewQuotation) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Create New Quotation")
                }
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .background(Color.blue)
                .cornerRadius(10)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private func createNewQuotation() {
        showingNewQuotation = true
    }
    
    private func deleteQuotations(offsets: IndexSet) {
        for index in offsets {
            let quotation = filteredQuotations[index]
            quotationManager.deleteQuotation(quotation)
        }
    }
}

struct QuotationRowView: View {
    let quotation: Quotation
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quotation.clientName)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(quotation.eventType.rawValue)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(String(format: "%.0f", quotation.total))")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Text(quotation.eventDate, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !quotation.items.isEmpty {
                Text("\(quotation.items.count) services • \(quotation.items.reduce(0) { $0 + $1.quantity }) items")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(NSColor.controlBackgroundColor))
                .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 1)
        )
    }
}

#Preview {
    QuotationListView()
}
```

## 3. Additional Files to Check

Make sure these imports are present in all view files:

```swift
import SwiftUI
import AppKit
```

## 4. Quick Terminal Commands

If you want to apply these fixes quickly, run these commands in your project directory:

```bash
# Fix ALL string formatting issues (including the latest AIRecommendationsView fix)
sed -i '' 's/, specifier: "%.0f"/))/g' QUOTE_GEN/Views/*.swift
sed -i '' 's/\\(.*\\(quotationManager\\.get.*Value()\\)/\\(String(format: "%.0f", \\1)/g' QUOTE_GEN/Views/*.swift
sed -i '' 's/\\(.*reduce(0) { $0 + $1\\.estimatedCost }, specifier: "%.0f"\\)/String(format: "%.0f", \\1)/g' QUOTE_GEN/Views/*.swift

# Fix color references
sed -i '' 's/Color(\\.systemGray6)/Color(NSColor.controlBackgroundColor)/g' QUOTE_GEN/Views/*.swift
sed -i '' 's/Color(\\.systemBackground)/Color(NSColor.controlBackgroundColor)/g' QUOTE_GEN/Views/*.swift

# Remove iOS-specific modifiers
sed -i '' '/\\.navigationBarTitleDisplayMode/d' QUOTE_GEN/Views/*.swift

# Fix toolbar placements
sed -i '' 's/\\.navigationBarTrailing/.primaryAction/g' QUOTE_GEN/Views/*.swift
sed -i '' 's/\\.navigationBarLeading/.cancellationAction/g' QUOTE_GEN/Views/*.swift
```

## 5. Verification

After applying these fixes:

1. Clean your build folder (⌘+Shift+K)
2. Build the project (⌘+B)
3. All compilation errors should be resolved

## 6. Common macOS vs iOS Differences

For future reference:

| iOS | macOS Alternative |
|-----|------------------|
| `.navigationBarTitleDisplayMode()` | Remove (not needed) |
| `.navigationBarLeading` | `.cancellationAction` |
| `.navigationBarTrailing` | `.primaryAction` |
| `.keyboardType()` | Remove (not available) |
| `Color(.systemGray6)` | `Color(NSColor.controlBackgroundColor)` |
| `Color(.systemBackground)` | `Color(NSColor.controlBackgroundColor)` |
| `specifier:` in Text | `String(format:)` |

These fixes will make your S-Quote app fully compatible with macOS!