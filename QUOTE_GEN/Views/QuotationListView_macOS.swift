//
//  QuotationListView_macOS.swift
//  QUOTE_GEN
//
//  macOS-native design following Apple Human Interface Guidelines
//

import SwiftUI
import AppKit

struct QuotationListView_macOS: View {
    @StateObject private var quotationManager = QuotationManager()
    @State private var searchText = ""
    @State private var selectedQuotation: Quotation?
    @State private var newQuotation: Quotation?
    @State private var sortOrder: SortOrder = .dateDescending
    
    enum SortOrder: String, CaseIterable {
        case dateDescending = "Date (Newest)"
        case dateAscending = "Date (Oldest)"
        case clientName = "Client Name"
        case eventType = "Event Type"
        case value = "Value"
    }
    
    var filteredAndSortedQuotations: [Quotation] {
        let filtered = quotationManager.searchQuotations(query: searchText)
        
        switch sortOrder {
        case .dateDescending:
            return filtered.sorted { $0.createdDate > $1.createdDate }
        case .dateAscending:
            return filtered.sorted { $0.createdDate < $1.createdDate }
        case .clientName:
            return filtered.sorted { $0.clientName < $1.clientName }
        case .eventType:
            return filtered.sorted { $0.eventType.rawValue < $1.eventType.rawValue }
        case .value:
            return filtered.sorted { $0.subtotal > $1.subtotal }
        }
    }
    
    var body: some View {
        HSplitView {
            // Sidebar
            sidebarView
                .frame(minWidth: 280, idealWidth: 320, maxWidth: 400)
            
            // Main Content
            mainContentView
                .frame(minWidth: 600)
        }
        .navigationTitle("S-Quote - Telugu Event Planner")
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                Button("New Quotation") {
                    createNewQuotation()
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            ToolbarItemGroup(placement: .navigation) {
                Button(action: {}) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar")
            }
        }
        .sheet(item: $newQuotation) { quotation in
            QuotationDetailView_macOS(quotation: quotation)
                .environmentObject(quotationManager)
                .frame(minWidth: 900, minHeight: 700)
        }
        .sheet(item: $selectedQuotation) { quotation in
            QuotationDetailView_macOS(quotation: quotation)
                .environmentObject(quotationManager)
                .frame(minWidth: 900, minHeight: 700)
        }
    }
    
    private var sidebarView: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 16) {
                HStack {
                    Image(systemName: "doc.text.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Telugu Event Planner")
                            .font(.headline)
                            .fontWeight(.semibold)
                        
                        Text("Professional Quotations")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Statistics Cards
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    MacOSStatCard(
                        title: "Total Quotes",
                        value: "\(quotationManager.quotations.count)",
                        icon: "doc.text",
                        color: .blue
                    )
                    
                    MacOSStatCard(
                        title: "This Month",
                        value: "\(quotationsThisMonth)",
                        icon: "calendar",
                        color: .green
                    )
                    
                    MacOSStatCard(
                        title: "Finalized",
                        value: "\(finalizedQuotations)",
                        icon: "checkmark.seal",
                        color: .orange
                    )
                    
                    MacOSStatCard(
                        title: "Total Value",
                        value: "₹\(String(format: "%.0f", totalValue))",
                        icon: "indianrupeesign.circle",
                        color: .purple
                    )
                }
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Search and Controls
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search quotations...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(8)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
                
                HStack {
                    Text("Sort by:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Sort", selection: $sortOrder) {
                        ForEach(SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }
                    .pickerStyle(.menu)
                    .font(.caption)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            
            Divider()
            
            // Quotations List
            quotationsList
        }
        .background(Color(NSColor.windowBackgroundColor))
    }
    
    private var quotationsList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(filteredAndSortedQuotations) { quotation in
                    MacOSQuotationRowView(
                        quotation: quotation,
                        isSelected: selectedQuotation?.id == quotation.id
                    ) {
                        selectedQuotation = quotation
                    }
                }
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var mainContentView: some View {
        Group {
            if let selected = selectedQuotation {
                QuotationPreviewView(quotation: selected)
                    .environmentObject(quotationManager)
            } else {
                emptyStateView
            }
        }
        .background(Color(NSColor.textBackgroundColor))
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "doc.text.below.ecg")
                .font(.system(size: 64))
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                Text("Welcome to S-Quote")
                    .font(.title)
                    .fontWeight(.semibold)
                
                Text("Create professional quotations for Telugu weddings and events")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Button("Create New Quotation") {
                    createNewQuotation()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Text("or select a quotation from the sidebar")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    // MARK: - Computed Properties
    
    private var quotationsThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return quotationManager.quotations.filter { quotation in
            calendar.isDate(quotation.createdDate, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var finalizedQuotations: Int {
        quotationManager.quotations.filter { $0.isFinalized }.count
    }
    
    private var totalValue: Double {
        quotationManager.quotations.reduce(0.0) { $0 + $1.grandTotal }
    }
    
    // MARK: - Actions
    
    private func createNewQuotation() {
        newQuotation = quotationManager.createNewQuotation()
    }
}

struct MacOSQuotationRowView: View {
    let quotation: Quotation
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                // Status indicator
                Circle()
                    .fill(quotation.isFinalized ? Color.green : Color.orange)
                    .frame(width: 8, height: 8)
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(quotation.clientName.isEmpty ? "Untitled Quotation" : quotation.clientName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .lineLimit(1)
                        
                        Spacer()
                        
                        Text("₹\(String(format: "%.0f", quotation.grandTotal))")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    
                    HStack {
                        Text(quotation.eventType.rawValue.capitalized)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(quotation.createdDate, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color.clear)
            .overlay(
                Rectangle()
                    .fill(isSelected ? Color.accentColor : Color.clear)
                    .frame(width: 3)
                    .animation(.easeInOut(duration: 0.2), value: isSelected),
                alignment: .leading
            )
        }
        .buttonStyle(.plain)
    }
}

struct QuotationPreviewView: View {
    let quotation: Quotation
    @EnvironmentObject var quotationManager: QuotationManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(quotation.clientName.isEmpty ? "Untitled Quotation" : quotation.clientName)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        Button("Edit") {
                            // Edit action
                        }
                        .buttonStyle(.bordered)
                    }
                    
                    HStack {
                        Label(quotation.eventType.rawValue.capitalized, systemImage: "heart.fill")
                        
                        Spacer()
                        
                        Label("\(quotation.guestCount) guests", systemImage: "person.3.fill")
                        
                        Spacer()
                        
                        Label(quotation.eventDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                    }
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                }
                
                Divider()
                
                // Services
                if !quotation.items.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Services")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ForEach(quotation.items) { item in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.serviceItem.name)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                    
                                    Text(item.serviceItem.description)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("₹\(String(format: "%.0f", item.totalPrice))")
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                    
                                    Text("Qty: \(item.quantity)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 8)
                            
                            if item.id != quotation.items.last?.id {
                                Divider()
                            }
                        }
                    }
                }
                
                Divider()
                
                // Pricing Summary
                VStack(alignment: .leading, spacing: 12) {
                    Text("Pricing Summary")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Subtotal")
                            Spacer()
                            Text("₹\(String(format: "%.2f", quotation.subtotal))")
                        }
                        
                        if quotation.discountPercentage > 0 {
                            HStack {
                                Text("Discount (\(String(format: "%.1f", quotation.discountPercentage))%)")
                                Spacer()
                                Text("-₹\(String(format: "%.2f", quotation.discountAmount))")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if quotation.additionalFees > 0 {
                            HStack {
                                Text("Additional Fees")
                                Spacer()
                                Text("₹\(String(format: "%.2f", quotation.additionalFees))")
                            }
                        }
                        
                        HStack {
                            Text("Tax (\(String(format: "%.1f", quotation.taxPercentage))%)")
                            Spacer()
                            Text("₹\(String(format: "%.2f", quotation.taxAmount))")
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Total")
                                .font(.headline)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("₹\(String(format: "%.2f", quotation.total))")
                                .font(.headline)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                    .font(.subheadline)
                }
                
                Spacer()
            }
            .padding(32)
        }
    }
}

struct MacOSStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color(NSColor.textBackgroundColor))
        .cornerRadius(8)
    }
}

#Preview {
    QuotationListView_macOS()
}