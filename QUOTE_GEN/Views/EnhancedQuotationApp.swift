//
//  EnhancedQuotationApp.swift
//  QUOTE_GEN
//
//  Enhanced macOS app following Apple Human Interface Guidelines
//  Modern, professional UI/UX for Telugu event planners
//

import SwiftUI
import AppKit

struct EnhancedQuotationApp: View {
    @StateObject private var quotationManager = QuotationManager()
    @State private var selectedSidebarItem: SidebarItem = .dashboard
    @State private var selectedQuotation: Quotation?
    @State private var searchText = ""
    @State private var showingNewQuotationSheet = false
    @State private var showingSettingsSheet = false
    
    enum SidebarItem: String, CaseIterable, Identifiable {
        case dashboard = "Dashboard"
        case allQuotations = "All Quotations"
        case drafts = "Drafts"
        case finalized = "Finalized"
        case thisMonth = "This Month"
        case clients = "Clients"
        case services = "Services"
        case reports = "Reports"
        
        var id: String { rawValue }
        
        var icon: String {
            switch self {
            case .dashboard: return "chart.bar.fill"
            case .allQuotations: return "doc.text.fill"
            case .drafts: return "doc.badge.plus"
            case .finalized: return "checkmark.seal.fill"
            case .thisMonth: return "calendar"
            case .clients: return "person.2.fill"
            case .services: return "list.bullet.rectangle"
            case .reports: return "chart.line.uptrend.xyaxis"
            }
        }
        
        var color: Color {
            switch self {
            case .dashboard: return .blue
            case .allQuotations: return .primary
            case .drafts: return .orange
            case .finalized: return .green
            case .thisMonth: return .purple
            case .clients: return .pink
            case .services: return .indigo
            case .reports: return .teal
            }
        }
    }
    
    var body: some View {
        NavigationSplitView(sidebar: {
            sidebarView
        }, content: {
            contentView
        }, detail: {
            detailView
        })
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            ToolbarItemGroup(placement: .navigation) {
                Button(action: toggleSidebar) {
                    Image(systemName: "sidebar.left")
                }
                .help("Toggle Sidebar")
            }
            
            ToolbarItemGroup(placement: .primaryAction) {
                HStack {
                    Button(action: { showingNewQuotationSheet = true }) {
                        Label("New Quotation", systemImage: "plus")
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .help("Create New Quotation (⌘N)")
                    
                    Button(action: { showingSettingsSheet = true }) {
                        Image(systemName: "gearshape.fill")
                    }
                    .help("Settings")
                }
            }
        }
        .searchable(text: $searchText, placement: .toolbar, prompt: "Search quotations, clients, or services...")
        .sheet(isPresented: $showingNewQuotationSheet) {
            NewQuotationWizard(quotationManager: quotationManager)
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsView()
        }
        .environmentObject(quotationManager)
        .onAppear {
            setupWindow()
        }
    }
    
    // MARK: - Sidebar
    private var sidebarView: some View {
        List(selection: $selectedSidebarItem) {
            Section {
                ForEach(SidebarItem.allCases) { item in
                    NavigationLink(value: item) {
                        HStack {
                            Image(systemName: item.icon)
                                .foregroundColor(item.color)
                                .frame(width: 20)
                            
                            Text(item.rawValue)
                                .font(.system(.body, design: .rounded))
                            
                            Spacer()
                            
                            if let count = getItemCount(for: item) {
                                Text("\(count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .tag(item)
                }
            } header: {
                HStack {
                    Text("S-Quote")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Spacer()
                    
                    Text("Telugu Events")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("S-Quote")
    }
    
    // MARK: - Content View
    private var contentView: some View {
        Group {
            switch selectedSidebarItem {
            case .dashboard:
                DashboardView()
            case .allQuotations:
                EnhancedQuotationListView(quotations: quotationManager.quotations, selectedQuotation: $selectedQuotation)
            case .drafts:
                EnhancedQuotationListView(quotations: quotationManager.quotations.filter { !$0.isFinalized }, selectedQuotation: $selectedQuotation)
            case .finalized:
                EnhancedQuotationListView(quotations: quotationManager.quotations.filter { $0.isFinalized }, selectedQuotation: $selectedQuotation)
            case .thisMonth:
                EnhancedQuotationListView(quotations: quotationsThisMonth, selectedQuotation: $selectedQuotation)
            case .clients:
                ClientsView()
            case .services:
                ServicesView()
            case .reports:
                ReportsView()
            }
        }
        .navigationTitle(selectedSidebarItem.rawValue)
        .searchable(text: $searchText, placement: .automatic)
    }
    
    // MARK: - Detail View
    private var detailView: some View {
        Group {
            if let quotation = selectedQuotation {
                EnhancedQuotationDetailView(quotation: quotation)
            } else {
                ContentUnavailableView(
                    "Select a Quotation",
                    systemImage: "doc.text",
                    description: Text("Choose a quotation from the list to view and edit details")
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    private func setupWindow() {
        if let window = NSApp.windows.first {
            window.titlebarAppearsTransparent = true
            window.titleVisibility = .hidden
            window.toolbarStyle = .unified
        }
    }
    
    private func getItemCount(for item: SidebarItem) -> Int? {
        switch item {
        case .allQuotations:
            return quotationManager.quotations.count
        case .drafts:
            return quotationManager.quotations.filter { !$0.isFinalized }.count
        case .finalized:
            return quotationManager.quotations.filter { $0.isFinalized }.count
        case .thisMonth:
            return quotationsThisMonth.count
        default:
            return nil
        }
    }
    
    private var quotationsThisMonth: [Quotation] {
        let calendar = Calendar.current
        let now = Date()
        return quotationManager.quotations.filter { quotation in
            calendar.isDate(quotation.createdDate, equalTo: now, toGranularity: .month)
        }
    }
}

// MARK: - Dashboard View
struct DashboardView: View {
    @EnvironmentObject var quotationManager: QuotationManager
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 24) {
                // Welcome Section
                welcomeSection
                
                // Quick Stats
                quickStatsSection
                
                // Recent Activity
                recentActivitySection
                
                // Quick Actions
                quickActionsSection
            }
            .padding(24)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var welcomeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Welcome back!")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Manage your Telugu event quotations with ease")
                        .font(.title3)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Image(systemName: "heart.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.pink.gradient)
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var quickStatsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
            EnhancedStatCard(
                title: "Total Quotations",
                value: "\(quotationManager.quotations.count)",
                icon: "doc.text.fill",
                color: .blue,
                trend: .up,
                trendValue: "12%"
            )
            
            EnhancedStatCard(
                title: "This Month",
                value: "\(quotationsThisMonth.count)",
                icon: "calendar",
                color: .green,
                trend: .up,
                trendValue: "8%"
            )
            
            EnhancedStatCard(
                title: "Finalized",
                value: "\(finalizedQuotations.count)",
                icon: "checkmark.seal.fill",
                color: .orange,
                trend: .up,
                trendValue: "15%"
            )
            
            EnhancedStatCard(
                title: "Total Value",
                value: "₹\(String(format: "%.0f", totalValue))",
                icon: "indianrupeesign.circle.fill",
                color: .purple,
                trend: .up,
                trendValue: "23%"
            )
        }
    }
    
    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 12) {
                ForEach(quotationManager.quotations.prefix(5)) { quotation in
                    RecentActivityRow(quotation: quotation)
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                QuickActionCard(
                    title: "New Wedding Quote",
                    icon: "heart.fill",
                    color: .pink
                ) {
                    // Action
                }
                
                QuickActionCard(
                    title: "Import Services",
                    icon: "square.and.arrow.down",
                    color: .blue
                ) {
                    // Action
                }
                
                QuickActionCard(
                    title: "Export Report",
                    icon: "square.and.arrow.up",
                    color: .green
                ) {
                    // Action
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // Helper computed properties
    private var quotationsThisMonth: [Quotation] {
        let calendar = Calendar.current
        let now = Date()
        return quotationManager.quotations.filter { quotation in
            calendar.isDate(quotation.createdDate, equalTo: now, toGranularity: .month)
        }
    }
    
    private var finalizedQuotations: [Quotation] {
        quotationManager.quotations.filter { $0.isFinalized }
    }
    
    private var totalValue: Double {
        quotationManager.quotations.reduce(0.0) { $0 + $1.grandTotal }
    }
}

// MARK: - Supporting Views
struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let trend: TrendDirection
    let trendValue: String
    
    enum TrendDirection {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .secondary
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: trend.icon)
                        .font(.caption)
                    Text(trendValue)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                .foregroundColor(trend.color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct RecentActivityRow: View {
    let quotation: Quotation
    
    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(quotation.isFinalized ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(quotation.clientName.isEmpty ? "Untitled Quotation" : quotation.clientName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(quotation.eventType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("₹\(String(format: "%.0f", quotation.grandTotal))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Text(quotation.createdDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

struct QuickActionCard: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .padding(16)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    EnhancedQuotationApp()
        .frame(width: 1200, height: 800)
}