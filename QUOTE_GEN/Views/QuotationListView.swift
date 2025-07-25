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
    @State private var selectedQuotation: Quotation?
    @State private var showingQuotationDetail = false
    
    var filteredQuotations: [Quotation] {
        quotationManager.searchQuotations(query: searchText)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Header with statistics
                headerView
                
                // Search bar
                searchBar
                
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
            .sheet(item: $selectedQuotation) { quotation in
                QuotationDetailView(quotation: quotation)
                    .environmentObject(quotationManager)
            }
        }
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Telugu Event Planner")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Text("Professional Quotation Generator")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(quotationManager.getTotalRevenue(), specifier: "%.0f")")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("Total Revenue")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack(spacing: 20) {
                StatCard(
                    title: "Total Quotes",
                    value: "\(quotationManager.quotations.count)",
                    icon: "doc.text.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Finalized",
                    value: "\(quotationManager.quotations.filter { $0.isFinalized }.count)",
                    icon: "checkmark.seal.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Avg. Value",
                    value: String(format: "₹%.0f", quotationManager.getAverageQuotationValue()),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .orange
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search quotations...", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
    
    private var quotationsList: some View {
        List {
            ForEach(filteredQuotations.sorted { $0.createdDate > $1.createdDate }) { quotation in
                QuotationRowView(quotation: quotation)
                    .onTapGesture {
                        selectedQuotation = quotation
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button("Delete") {
                            quotationManager.deleteQuotation(quotation)
                        }
                        .tint(.red)
                        
                        Button("Duplicate") {
                            let duplicated = quotationManager.duplicateQuotation(quotation)
                            selectedQuotation = duplicated
                        }
                        .tint(.blue)
                    }
            }
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
            
            Text("Create your first Telugu wedding quotation to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: createNewQuotation) {
                Label("Create New Quotation", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func createNewQuotation() {
        showingNewQuotation = true
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct QuotationRowView: View {
    let quotation: Quotation
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(quotation.clientName.isEmpty ? "Unnamed Client" : quotation.clientName)
                        .font(.headline)
                        .lineLimit(1)
                    
                    HStack {
                        Text(quotation.eventType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if quotation.eventType.isTeluguSpecific {
                            Text("తెలుగు")
                                .font(.caption)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .foregroundColor(.orange)
                                .cornerRadius(4)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text(currencyFormatter.string(from: NSNumber(value: quotation.grandTotal)) ?? "₹0")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if quotation.isFinalized {
                        Text("Finalized")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.green.opacity(0.2))
                            .foregroundColor(.green)
                            .cornerRadius(4)
                    } else {
                        Text("Draft")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.gray.opacity(0.2))
                            .foregroundColor(.gray)
                            .cornerRadius(4)
                    }
                }
            }
            
            HStack {
                Label(dateFormatter.string(from: quotation.eventDate), systemImage: "calendar")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !quotation.venue.isEmpty {
                    Label(quotation.venue, systemImage: "location")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
            }
            
            if quotation.items.count > 0 {
                Text("\(quotation.items.count) services • \(quotation.guestCount) guests")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

extension EventType {
    var isTeluguSpecific: Bool {
        switch self {
        case .wedding, .engagement, .haldi, .naming:
            return true
        default:
            return false
        }
    }
}

#Preview {
    QuotationListView()
}