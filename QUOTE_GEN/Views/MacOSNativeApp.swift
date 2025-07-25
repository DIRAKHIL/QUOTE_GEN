//
//  MacOSNativeApp.swift
//  QUOTE_GEN
//
//  Native macOS app following Apple Human Interface Guidelines
//  Professional Telugu event planning quotation generator
//

import SwiftUI
import AppKit

struct MacOSNativeApp: View {
    @StateObject private var quotationManager = QuotationManager()
    @State private var selectedQuotation: Quotation?
    @State private var searchText = ""
    @State private var showingNewQuotationSheet = false
    @State private var showingSettingsSheet = false
    @State private var showingInspector = true
    @State private var selectedSidebarItem: SidebarItem = .allQuotations
    
    enum SidebarItem: String, CaseIterable, Identifiable {
        case allQuotations = "All Quotations"
        case drafts = "Drafts"
        case finalized = "Finalized"
        case clients = "Clients"
        case services = "Services"
        case templates = "Templates"
        
        var id: String { rawValue }
        
        var systemImage: String {
            switch self {
            case .allQuotations: return "doc.text"
            case .drafts: return "doc.badge.plus"
            case .finalized: return "checkmark.seal"
            case .clients: return "person.2"
            case .services: return "list.bullet.rectangle"
            case .templates: return "doc.on.doc"
            }
        }
    }
    
    var body: some View {
        NavigationSplitView {
            // Sidebar
            sidebarView
        } content: {
            // Main content
            mainContentView
        } detail: {
            // Detail/Inspector
            detailView
        }
        .navigationSplitViewStyle(.balanced)
        .toolbar {
            toolbarContent
        }
        .searchable(text: $searchText, placement: .toolbar)
        .sheet(isPresented: $showingNewQuotationSheet) {
            NewQuotationSheet(quotationManager: quotationManager)
        }
        .sheet(isPresented: $showingSettingsSheet) {
            SettingsSheet()
        }
        .environmentObject(quotationManager)
        .onAppear {
            configureWindow()
        }
    }
    
    // MARK: - Sidebar
    private var sidebarView: some View {
        List(selection: $selectedSidebarItem) {
            Section("Library") {
                ForEach(SidebarItem.allCases) { item in
                    NavigationLink(value: item) {
                        Label {
                            HStack {
                                Text(item.rawValue)
                                Spacer()
                                if let count = itemCount(for: item) {
                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(.quaternary, in: Capsule())
                                }
                            }
                        } icon: {
                            Image(systemName: item.systemImage)
                        }
                    }
                }
            }
        }
        .listStyle(.sidebar)
        .navigationTitle("S-Quote")
        .navigationSubtitle("Telugu Events")
    }
    
    // MARK: - Main Content
    private var mainContentView: some View {
        Group {
            switch selectedSidebarItem {
            case .allQuotations:
                QuotationListView(
                    quotations: filteredQuotations,
                    selectedQuotation: $selectedQuotation,
                    searchText: searchText
                )
            case .drafts:
                QuotationListView(
                    quotations: filteredQuotations.filter { !$0.isFinalized },
                    selectedQuotation: $selectedQuotation,
                    searchText: searchText
                )
            case .finalized:
                QuotationListView(
                    quotations: filteredQuotations.filter { $0.isFinalized },
                    selectedQuotation: $selectedQuotation,
                    searchText: searchText
                )
            case .clients:
                ClientManagementView()
            case .services:
                ServiceManagementView()
            case .templates:
                TemplateManagementView()
            }
        }
        .navigationTitle(selectedSidebarItem.rawValue)
    }
    
    // MARK: - Detail View
    private var detailView: some View {
        Group {
            if let quotation = selectedQuotation {
                QuotationDetailView(quotation: quotation)
                    .navigationTitle(quotation.clientName.isEmpty ? "New Quotation" : quotation.clientName)
                    .navigationSubtitle(quotation.eventType.rawValue)
            } else {
                ContentUnavailableView {
                    Label("No Quotation Selected", systemImage: "doc.text")
                } description: {
                    Text("Select a quotation from the list to view and edit its details.")
                } actions: {
                    Button("Create New Quotation") {
                        showingNewQuotationSheet = true
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingInspector.toggle()
                } label: {
                    Image(systemName: "sidebar.right")
                }
                .help("Toggle Inspector")
            }
        }
        .inspector(isPresented: $showingInspector) {
            if selectedQuotation != nil {
                QuotationInspectorView(quotation: $selectedQuotation)
            }
        }
    }
    
    // MARK: - Toolbar
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .navigation) {
            Button {
                toggleSidebar()
            } label: {
                Image(systemName: "sidebar.left")
            }
            .help("Toggle Sidebar")
        }
        
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                showingNewQuotationSheet = true
            } label: {
                Image(systemName: "plus")
            }
            .help("New Quotation (⌘N)")
            .keyboardShortcut("n", modifiers: .command)
            
            Button {
                showingSettingsSheet = true
            } label: {
                Image(systemName: "gearshape")
            }
            .help("Settings (⌘,)")
            .keyboardShortcut(",", modifiers: .command)
        }
    }
    
    // MARK: - Helper Methods
    private var filteredQuotations: [Quotation] {
        if searchText.isEmpty {
            return quotationManager.quotations
        } else {
            return quotationManager.quotations.filter { quotation in
                quotation.clientName.localizedCaseInsensitiveContains(searchText) ||
                quotation.eventType.rawValue.localizedCaseInsensitiveContains(searchText) ||
                quotation.services.contains { $0.name.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }
    
    private func itemCount(for item: SidebarItem) -> Int? {
        switch item {
        case .allQuotations:
            return quotationManager.quotations.count
        case .drafts:
            return quotationManager.quotations.filter { !$0.isFinalized }.count
        case .finalized:
            return quotationManager.quotations.filter { $0.isFinalized }.count
        default:
            return nil
        }
    }
    
    private func toggleSidebar() {
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
    
    private func configureWindow() {
        guard let window = NSApp.windows.first else { return }
        
        window.titlebarAppearsTransparent = false
        window.titleVisibility = .visible
        window.toolbarStyle = .unified
        window.setContentSize(NSSize(width: 1200, height: 800))
        window.minSize = NSSize(width: 900, height: 600)
        
        // Center window
        window.center()
    }
}

// MARK: - Quotation List View
struct QuotationListView: View {
    let quotations: [Quotation]
    @Binding var selectedQuotation: Quotation?
    let searchText: String
    
    var body: some View {
        Table(quotations, selection: $selectedQuotation) {
            TableColumn("Client") { quotation in
                VStack(alignment: .leading, spacing: 2) {
                    Text(quotation.clientName.isEmpty ? "Untitled" : quotation.clientName)
                        .font(.headline)
                    Text(quotation.eventType.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .width(min: 150, ideal: 200)
            
            TableColumn("Event Date") { quotation in
                Text(quotation.eventDate, style: .date)
                    .font(.body)
            }
            .width(min: 100, ideal: 120)
            
            TableColumn("Status") { quotation in
                StatusBadge(isFinalized: quotation.isFinalized)
            }
            .width(min: 80, ideal: 100)
            
            TableColumn("Total") { quotation in
                Text(quotation.grandTotal, format: .currency(code: "INR"))
                    .font(.body.monospacedDigit())
                    .fontWeight(.medium)
            }
            .width(min: 100, ideal: 120)
            
            TableColumn("Created") { quotation in
                Text(quotation.createdDate, style: .date)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .width(min: 80, ideal: 100)
        }
        .tableStyle(.inset(alternatesRowBackgrounds: true))
        .contextMenu(forSelectionType: Quotation.ID.self) { selection in
            if selection.count == 1 {
                Button("Duplicate") {
                    // Duplicate quotation
                }
                Button("Export PDF") {
                    // Export as PDF
                }
                Divider()
                Button("Delete", role: .destructive) {
                    // Delete quotation
                }
            }
        }
    }
}

// MARK: - Status Badge
struct StatusBadge: View {
    let isFinalized: Bool
    
    var body: some View {
        Text(isFinalized ? "Finalized" : "Draft")
            .font(.caption)
            .fontWeight(.medium)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(isFinalized ? .green.opacity(0.2) : .orange.opacity(0.2))
            .foregroundStyle(isFinalized ? .green : .orange)
            .clipShape(Capsule())
    }
}

// MARK: - New Quotation Sheet
struct NewQuotationSheet: View {
    @ObservedObject var quotationManager: QuotationManager
    @Environment(\.dismiss) private var dismiss
    @State private var clientName = ""
    @State private var eventType: EventType = .wedding
    @State private var eventDate = Date()
    @State private var venue = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Client Information") {
                    TextField("Client Name", text: $clientName)
                    TextField("Venue", text: $venue)
                }
                
                Section("Event Details") {
                    Picker("Event Type", selection: $eventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    DatePicker("Event Date", selection: $eventDate, displayedComponents: .date)
                }
            }
            .formStyle(.grouped)
            .navigationTitle("New Quotation")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createQuotation()
                    }
                    .disabled(clientName.isEmpty)
                }
            }
        }
        .frame(width: 500, height: 400)
    }
    
    private func createQuotation() {
        let newQuotation = Quotation(
            clientName: clientName,
            eventType: eventType,
            eventDate: eventDate,
            venue: venue,
            services: [],
            notes: "",
            isFinalized: false
        )
        quotationManager.addQuotation(newQuotation)
        dismiss()
    }
}

// MARK: - Settings Sheet
struct SettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            TabView {
                GeneralSettingsView()
                    .tabItem {
                        Label("General", systemImage: "gearshape")
                    }
                
                BusinessSettingsView()
                    .tabItem {
                        Label("Business", systemImage: "building.2")
                    }
                
                TemplateSettingsView()
                    .tabItem {
                        Label("Templates", systemImage: "doc.on.doc")
                    }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .frame(width: 600, height: 500)
    }
}

// MARK: - Settings Views
struct GeneralSettingsView: View {
    var body: some View {
        Form {
            Section("Appearance") {
                // Settings content
                Text("General settings will go here")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct BusinessSettingsView: View {
    var body: some View {
        Form {
            Section("Business Information") {
                // Settings content
                Text("Business settings will go here")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

struct TemplateSettingsView: View {
    var body: some View {
        Form {
            Section("Templates") {
                // Settings content
                Text("Template settings will go here")
            }
        }
        .formStyle(.grouped)
        .padding()
    }
}

// MARK: - Management Views
struct ClientManagementView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Client Management", systemImage: "person.2")
        } description: {
            Text("Manage your client database and contact information.")
        } actions: {
            Button("Add Client") {
                // Add client action
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct ServiceManagementView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Service Management", systemImage: "list.bullet.rectangle")
        } description: {
            Text("Manage your service catalog and pricing.")
        } actions: {
            Button("Add Service") {
                // Add service action
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

struct TemplateManagementView: View {
    var body: some View {
        ContentUnavailableView {
            Label("Template Management", systemImage: "doc.on.doc")
        } description: {
            Text("Create and manage quotation templates for different event types.")
        } actions: {
            Button("Create Template") {
                // Create template action
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// MARK: - Quotation Detail View
struct QuotationDetailView: View {
    let quotation: Quotation
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Client information
                clientInfoSection
                
                // Services
                servicesSection
                
                // Totals
                totalsSection
            }
            .padding()
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var clientInfoSection: some View {
        GroupBox("Client Information") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Client:")
                        .fontWeight(.medium)
                    Text(quotation.clientName)
                }
                
                HStack {
                    Text("Event:")
                        .fontWeight(.medium)
                    Text(quotation.eventType.rawValue)
                }
                
                HStack {
                    Text("Date:")
                        .fontWeight(.medium)
                    Text(quotation.eventDate, style: .date)
                }
                
                if !quotation.venue.isEmpty {
                    HStack {
                        Text("Venue:")
                            .fontWeight(.medium)
                        Text(quotation.venue)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    private var servicesSection: some View {
        GroupBox("Services") {
            if quotation.services.isEmpty {
                Text("No services added")
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
            } else {
                VStack(spacing: 8) {
                    ForEach(quotation.services) { service in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(service.name)
                                    .fontWeight(.medium)
                                if !service.description.isEmpty {
                                    Text(service.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            Spacer()
                            
                            Text(service.price, format: .currency(code: "INR"))
                                .font(.body.monospacedDigit())
                        }
                        .padding(.vertical, 4)
                        
                        if service != quotation.services.last {
                            Divider()
                        }
                    }
                }
            }
        }
    }
    
    private var totalsSection: some View {
        GroupBox("Summary") {
            VStack(spacing: 8) {
                HStack {
                    Text("Subtotal:")
                    Spacer()
                    Text(quotation.subtotal, format: .currency(code: "INR"))
                        .font(.body.monospacedDigit())
                }
                
                HStack {
                    Text("Tax:")
                    Spacer()
                    Text(quotation.tax, format: .currency(code: "INR"))
                        .font(.body.monospacedDigit())
                }
                
                Divider()
                
                HStack {
                    Text("Total:")
                        .fontWeight(.semibold)
                    Spacer()
                    Text(quotation.grandTotal, format: .currency(code: "INR"))
                        .font(.title3.monospacedDigit())
                        .fontWeight(.semibold)
                }
            }
        }
    }
}

// MARK: - Quotation Inspector
struct QuotationInspectorView: View {
    @Binding var quotation: Quotation?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if let quotation = quotation {
                Text("Inspector")
                    .font(.headline)
                
                GroupBox("Actions") {
                    VStack(spacing: 8) {
                        Button("Edit Quotation") {
                            // Edit action
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("Export PDF") {
                            // Export action
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                        
                        Button("Send Email") {
                            // Email action
                        }
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                    }
                    .frame(maxWidth: .infinity)
                }
                
                GroupBox("Status") {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Status:")
                            Spacer()
                            StatusBadge(isFinalized: quotation.isFinalized)
                        }
                        
                        HStack {
                            Text("Created:")
                            Spacer()
                            Text(quotation.createdDate, style: .date)
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
            }
        }
        .padding()
        .frame(width: 250)
    }
}