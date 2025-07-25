//
//  EnhancedQuotationListView.swift
//  QUOTE_GEN
//
//  Modern quotation list with enhanced UX
//

import SwiftUI

struct EnhancedQuotationListView: View {
    let quotations: [Quotation]
    @Binding var selectedQuotation: Quotation?
    @State private var sortOrder: SortOrder = .dateDescending
    @State private var viewMode: ViewMode = .list
    @State private var searchText = ""
    
    enum SortOrder: String, CaseIterable {
        case dateDescending = "Date (Newest)"
        case dateAscending = "Date (Oldest)"
        case clientName = "Client Name"
        case eventType = "Event Type"
        case value = "Value (High to Low)"
        case valueAscending = "Value (Low to High)"
        
        var systemImage: String {
            switch self {
            case .dateDescending, .dateAscending: return "calendar"
            case .clientName: return "person.fill"
            case .eventType: return "heart.fill"
            case .value, .valueAscending: return "indianrupeesign.circle"
            }
        }
    }
    
    enum ViewMode: String, CaseIterable {
        case list = "List"
        case grid = "Grid"
        
        var systemImage: String {
            switch self {
            case .list: return "list.bullet"
            case .grid: return "square.grid.2x2"
            }
        }
    }
    
    var filteredAndSortedQuotations: [Quotation] {
        let filtered = quotations.filter { quotation in
            searchText.isEmpty ||
            quotation.clientName.localizedCaseInsensitiveContains(searchText) ||
            quotation.eventType.rawValue.localizedCaseInsensitiveContains(searchText) ||
            quotation.venue.localizedCaseInsensitiveContains(searchText)
        }
        
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
            return filtered.sorted { $0.grandTotal > $1.grandTotal }
        case .valueAscending:
            return filtered.sorted { $0.grandTotal < $1.grandTotal }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Toolbar
            toolbarView
            
            Divider()
            
            // Content
            if filteredAndSortedQuotations.isEmpty {
                emptyStateView
            } else {
                contentView
            }
        }
        .searchable(text: $searchText, placement: .automatic, prompt: "Search quotations...")
    }
    
    private var toolbarView: some View {
        HStack {
            // Sort Menu
            Menu {
                ForEach(SortOrder.allCases, id: \.self) { order in
                    Button(action: { sortOrder = order }) {
                        Label(order.rawValue, systemImage: order.systemImage)
                        if sortOrder == order {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
            }
            .menuStyle(.borderlessButton)
            
            Spacer()
            
            // View Mode Toggle
            Picker("View Mode", selection: $viewMode) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Label(mode.rawValue, systemImage: mode.systemImage)
                        .tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .frame(width: 120)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.regularMaterial)
    }
    
    private var contentView: some View {
        Group {
            switch viewMode {
            case .list:
                listView
            case .grid:
                gridView
            }
        }
    }
    
    private var listView: some View {
        List(filteredAndSortedQuotations, selection: $selectedQuotation) { quotation in
            EnhancedQuotationRow(quotation: quotation)
                .tag(quotation)
        }
        .listStyle(.inset)
    }
    
    private var gridView: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                ForEach(filteredAndSortedQuotations) { quotation in
                    EnhancedQuotationCard(quotation: quotation, isSelected: selectedQuotation?.id == quotation.id) {
                        selectedQuotation = quotation
                    }
                }
            }
            .padding(16)
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Quotations Found",
            systemImage: "doc.text.magnifyingglass",
            description: Text(searchText.isEmpty ? "Create your first quotation to get started" : "No quotations match your search")
        )
    }
}

struct EnhancedQuotationRow: View {
    let quotation: Quotation
    
    var body: some View {
        HStack(spacing: 16) {
            // Status Indicator
            statusIndicator
            
            // Main Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(quotation.clientName.isEmpty ? "Untitled Quotation" : quotation.clientName)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Text("₹\(String(format: "%.0f", quotation.grandTotal))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
                
                HStack {
                    Label(quotation.eventType.rawValue, systemImage: "heart.fill")
                        .font(.subheadline)
                        .foregroundColor(.pink)
                    
                    Spacer()
                    
                    Label(quotation.eventDate.formatted(date: .abbreviated, time: .omitted), systemImage: "calendar")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Label(quotation.venue, systemImage: "location.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                    
                    Spacer()
                    
                    Label("\(quotation.guestCount) guests", systemImage: "person.3.fill")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Action Buttons
            actionButtons
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private var statusIndicator: some View {
        VStack(spacing: 8) {
            Circle()
                .fill(quotation.isFinalized ? Color.green : Color.orange)
                .frame(width: 12, height: 12)
            
            Rectangle()
                .fill(quotation.isFinalized ? Color.green.opacity(0.3) : Color.orange.opacity(0.3))
                .frame(width: 3)
        }
        .frame(height: 60)
    }
    
    private var actionButtons: some View {
        VStack(spacing: 8) {
            Button(action: {}) {
                Image(systemName: "square.and.arrow.up")
            }
            .buttonStyle(.borderless)
            .help("Export Quotation")
            
            Button(action: {}) {
                Image(systemName: "doc.on.doc")
            }
            .buttonStyle(.borderless)
            .help("Duplicate Quotation")
        }
        .opacity(0.7)
    }
}

struct EnhancedQuotationCard: View {
    let quotation: Quotation
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(quotation.clientName.isEmpty ? "Untitled" : quotation.clientName)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        Text(quotation.eventType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.pink)
                    }
                    
                    Spacer()
                    
                    statusBadge
                }
                
                Divider()
                
                // Details
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.secondary)
                        Text(quotation.eventDate.formatted(date: .abbreviated, time: .omitted))
                            .font(.caption)
                    }
                    
                    HStack {
                        Image(systemName: "location")
                            .foregroundColor(.secondary)
                        Text(quotation.venue)
                            .font(.caption)
                            .lineLimit(1)
                    }
                    
                    HStack {
                        Image(systemName: "person.3")
                            .foregroundColor(.secondary)
                        Text("\(quotation.guestCount) guests")
                            .font(.caption)
                    }
                }
                
                Spacer()
                
                // Footer
                HStack {
                    Text("₹\(String(format: "%.0f", quotation.grandTotal))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    Text(quotation.createdDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var statusBadge: some View {
        Text(quotation.isFinalized ? "Finalized" : "Draft")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(quotation.isFinalized ? Color.green.opacity(0.2) : Color.orange.opacity(0.2))
            .foregroundColor(quotation.isFinalized ? .green : .orange)
            .clipShape(Capsule())
    }
}

// MARK: - Supporting Views for other sections
// Note: ClientsView, ServicesView, and ReportsView are now implemented in separate files

#Preview {
    EnhancedQuotationListView(quotations: [], selectedQuotation: .constant(nil))
        .frame(width: 800, height: 600)
}