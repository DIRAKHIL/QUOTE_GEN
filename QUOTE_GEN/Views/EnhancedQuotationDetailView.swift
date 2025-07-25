//
//  EnhancedQuotationDetailView.swift
//  QUOTE_GEN
//
//  Modern quotation detail view with enhanced UX
//

import SwiftUI

struct EnhancedQuotationDetailView: View {
    @State var quotation: Quotation
    @EnvironmentObject var quotationManager: QuotationManager
    @State private var isEditing = false
    @State private var showingServiceSelector = false
    @State private var showingExportSheet = false
    @State private var showingDeleteAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                headerSection
                
                // Client Information
                clientInformationSection
                
                // Event Details
                eventDetailsSection
                
                // Services & Items
                servicesSection
                
                // Pricing Summary
                pricingSummarySection
                
                // Notes
                notesSection
            }
            .padding(24)
        }
        .background(Color(NSColor.controlBackgroundColor))
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                HStack {
                    Button(action: { isEditing.toggle() }) {
                        Label(isEditing ? "Done" : "Edit", systemImage: isEditing ? "checkmark" : "pencil")
                    }
                    .buttonStyle(.bordered)
                    
                    Menu {
                        Button(action: { showingExportSheet = true }) {
                            Label("Export PDF", systemImage: "doc.fill")
                        }
                        
                        Button(action: duplicateQuotation) {
                            Label("Duplicate", systemImage: "doc.on.doc")
                        }
                        
                        Divider()
                        
                        Button(action: { showingDeleteAlert = true }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .foregroundColor(.red)
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .menuStyle(.borderlessButton)
                }
            }
        }
        .sheet(isPresented: $showingServiceSelector) {
            ServiceSelectorView { serviceItem in
                addService(serviceItem)
            }
        }
        .sheet(isPresented: $showingExportSheet) {
            EnhancedExportView(quotation: quotation)
        }
        .alert("Delete Quotation", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteQuotation()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("Are you sure you want to delete this quotation? This action cannot be undone.")
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(quotation.clientName.isEmpty ? "Untitled Quotation" : quotation.clientName)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    HStack {
                        statusBadge
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text("Created \(quotation.createdDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("₹\(String(format: "%.2f", quotation.grandTotal))")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    
                    Text("Total Amount")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(24)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var statusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(quotation.isFinalized ? Color.green : Color.orange)
                .frame(width: 8, height: 8)
            
            Text(quotation.isFinalized ? "Finalized" : "Draft")
                .font(.subheadline)
                .fontWeight(.medium)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(quotation.isFinalized ? Color.green.opacity(0.1) : Color.orange.opacity(0.1))
        .clipShape(Capsule())
    }
    
    // MARK: - Client Information Section
    private var clientInformationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            EnhancedSectionHeader(title: "Client Information", icon: "person.fill")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                InfoCard(title: "Name", value: quotation.clientName, icon: "person.fill", isEditing: isEditing) { newValue in
                    quotation.clientName = newValue
                    updateQuotation()
                }
                
                InfoCard(title: "Phone", value: quotation.clientPhone, icon: "phone.fill", isEditing: isEditing) { newValue in
                    quotation.clientPhone = newValue
                    updateQuotation()
                }
                
                InfoCard(title: "Email", value: quotation.clientEmail, icon: "envelope.fill", isEditing: isEditing) { newValue in
                    quotation.clientEmail = newValue
                    updateQuotation()
                }
                
                InfoCard(title: "Guest Count", value: "\(quotation.guestCount)", icon: "person.3.fill", isEditing: isEditing) { newValue in
                    quotation.guestCount = Int(newValue) ?? 0
                    updateQuotation()
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Event Details Section
    private var eventDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            EnhancedSectionHeader(title: "Event Details", icon: "heart.fill")
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                InfoCard(title: "Event Type", value: quotation.eventType.rawValue, icon: "heart.fill", isEditing: false) { _ in }
                
                InfoCard(title: "Date", value: quotation.eventDate.formatted(date: .abbreviated, time: .omitted), icon: "calendar", isEditing: false) { _ in }
                
                InfoCard(title: "Venue", value: quotation.venue, icon: "location.fill", isEditing: isEditing) { newValue in
                    quotation.venue = newValue
                    updateQuotation()
                }
                
                InfoCard(title: "Telugu Name", value: quotation.eventType.teluguName, icon: "textformat", isEditing: false) { _ in }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Services Section
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                EnhancedSectionHeader(title: "Services & Items", icon: "list.bullet.rectangle")
                
                Spacer()
                
                Button(action: { showingServiceSelector = true }) {
                    Label("Add Service", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.small)
            }
            
            if quotation.items.isEmpty {
                ContentUnavailableView(
                    "No Services Added",
                    systemImage: "list.bullet.rectangle",
                    description: Text("Add services to build your quotation")
                )
                .frame(height: 200)
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(quotation.items) { item in
                        EnhancedServiceItemRow(item: item, isEditing: isEditing) { updatedItem in
                            updateService(updatedItem)
                        } onDelete: {
                            removeService(item)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Pricing Summary Section
    private var pricingSummarySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            EnhancedSectionHeader(title: "Pricing Summary", icon: "indianrupeesign.circle.fill")
            
            VStack(spacing: 12) {
                EnhancedPricingRow(label: "Subtotal", amount: quotation.subtotal, isTotal: false)
                
                if quotation.discountPercentage > 0 {
                    EnhancedPricingRow(
                        label: "Discount (\(String(format: "%.1f", quotation.discountPercentage))%)",
                        amount: -quotation.discountAmount,
                        isTotal: false,
                        color: .red
                    )
                }
                
                if quotation.additionalFees > 0 {
                    EnhancedPricingRow(label: "Additional Fees", amount: quotation.additionalFees, isTotal: false)
                }
                
                EnhancedPricingRow(
                    label: "Tax (\(String(format: "%.1f", quotation.taxPercentage))%)",
                    amount: quotation.taxAmount,
                    isTotal: false
                )
                
                Divider()
                
                EnhancedPricingRow(label: "Grand Total", amount: quotation.grandTotal, isTotal: true)
            }
            
            if isEditing {
                editingControls
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    private var editingControls: some View {
        VStack(spacing: 12) {
            Divider()
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Discount %")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("0", value: $quotation.discountPercentage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Additional Fees")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("0", value: $quotation.additionalFees, format: .currency(code: "INR"))
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 120)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("Tax %")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("18", value: $quotation.taxPercentage, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                }
            }
        }
        .onChange(of: quotation.discountPercentage) { _ in updateQuotation() }
        .onChange(of: quotation.additionalFees) { _ in updateQuotation() }
        .onChange(of: quotation.taxPercentage) { _ in updateQuotation() }
    }
    
    // MARK: - Notes Section
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            EnhancedSectionHeader(title: "Notes", icon: "note.text")
            
            if isEditing {
                TextEditor(text: $quotation.notes)
                    .font(.body)
                    .frame(minHeight: 100)
                    .padding(8)
                    .background(Color(NSColor.textBackgroundColor))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                    .onChange(of: quotation.notes) { _ in updateQuotation() }
            } else {
                Text(quotation.notes.isEmpty ? "No notes added" : quotation.notes)
                    .font(.body)
                    .foregroundColor(quotation.notes.isEmpty ? .secondary : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, 8)
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Helper Methods
    private func updateQuotation() {
        quotationManager.updateQuotation(quotation)
    }
    
    private func addService(_ serviceItem: ServiceItem) {
        let quoteItem = QuoteItem(
            serviceItem: serviceItem,
            quantity: 1,
            customPrice: nil,
            notes: ""
        )
        quotation.items.append(quoteItem)
        updateQuotation()
    }
    
    private func updateService(_ updatedItem: QuoteItem) {
        if let index = quotation.items.firstIndex(where: { $0.id == updatedItem.id }) {
            quotation.items[index] = updatedItem
            updateQuotation()
        }
    }
    
    private func removeService(_ item: QuoteItem) {
        quotation.items.removeAll { $0.id == item.id }
        updateQuotation()
    }
    
    private func duplicateQuotation() {
        let newQuotation = Quotation(
            clientName: quotation.clientName + " (Copy)",
            clientPhone: quotation.clientPhone,
            clientEmail: quotation.clientEmail,
            eventType: quotation.eventType,
            eventDate: quotation.eventDate,
            venue: quotation.venue,
            guestCount: quotation.guestCount,
            items: quotation.items,
            discountPercentage: quotation.discountPercentage,
            additionalFees: quotation.additionalFees,
            taxPercentage: quotation.taxPercentage,
            notes: quotation.notes,
            createdDate: Date(),
            isFinalized: false
        )
        quotationManager.addQuotation(newQuotation)
    }
    
    private func deleteQuotation() {
        quotationManager.deleteQuotation(quotation)
    }
}

// MARK: - Supporting Views
struct EnhancedSectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
        }
    }
}

struct InfoCard: View {
    let title: String
    let value: String
    let icon: String
    let isEditing: Bool
    let onUpdate: (String) -> Void
    
    @State private var editingValue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            if isEditing {
                TextField(title, text: $editingValue)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit {
                        onUpdate(editingValue)
                    }
            } else {
                Text(value.isEmpty ? "Not specified" : value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(value.isEmpty ? .secondary : .primary)
            }
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onAppear {
            editingValue = value
        }
    }
}

struct EnhancedServiceItemRow: View {
    let item: QuoteItem
    let isEditing: Bool
    let onUpdate: (QuoteItem) -> Void
    let onDelete: () -> Void
    
    @State private var quantity: Int
    @State private var customPrice: String = ""
    @State private var notes: String = ""
    
    init(item: QuoteItem, isEditing: Bool, onUpdate: @escaping (QuoteItem) -> Void, onDelete: @escaping () -> Void) {
        self.item = item
        self.isEditing = isEditing
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self._quantity = State(initialValue: item.quantity)
        self._customPrice = State(initialValue: item.customPrice?.formatted() ?? "")
        self._notes = State(initialValue: item.notes)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.serviceItem.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    Text(item.serviceItem.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.secondary.opacity(0.1))
                        .clipShape(Capsule())
                }
                
                Spacer()
                
                if isEditing {
                    Button(action: onDelete) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                    .buttonStyle(.borderless)
                }
            }
            
            HStack {
                if isEditing {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Quantity")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Stepper(value: $quantity, in: 1...999) {
                            Text("\(quantity)")
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }
                        .frame(width: 100)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Custom Price")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        TextField("Base: ₹\(String(format: "%.0f", item.serviceItem.basePrice))", text: $customPrice)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 120)
                    }
                } else {
                    Text("Qty: \(item.quantity)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text("₹\(String(format: "%.0f", item.customPrice ?? item.serviceItem.basePrice)) per \(item.serviceItem.unit)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Text("₹\(String(format: "%.2f", item.totalPrice))")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.green)
            }
            
            if !item.notes.isEmpty || isEditing {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if isEditing {
                        TextField("Add notes...", text: $notes)
                            .textFieldStyle(.roundedBorder)
                    } else {
                        Text(item.notes.isEmpty ? "No notes" : item.notes)
                            .font(.caption)
                            .foregroundColor(item.notes.isEmpty ? .secondary : .primary)
                    }
                }
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor).opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onChange(of: quantity) { _ in updateItem() }
        .onChange(of: customPrice) { _ in updateItem() }
        .onChange(of: notes) { _ in updateItem() }
    }
    
    private func updateItem() {
        let price = Double(customPrice.replacingOccurrences(of: ",", with: ""))
        let updatedItem = QuoteItem(
            serviceItem: item.serviceItem,
            quantity: quantity,
            customPrice: price,
            notes: notes
        )
        onUpdate(updatedItem)
    }
}

struct EnhancedPricingRow: View {
    let label: String
    let amount: Double
    let isTotal: Bool
    let color: Color
    
    init(label: String, amount: Double, isTotal: Bool, color: Color = .primary) {
        self.label = label
        self.amount = amount
        self.isTotal = isTotal
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .medium)
            
            Spacer()
            
            Text("₹\(String(format: "%.2f", amount))")
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .medium)
                .foregroundColor(isTotal ? .green : color)
        }
        .padding(.vertical, isTotal ? 8 : 4)
    }
}

struct EnhancedExportView: View {
    let quotation: Quotation
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Export Quotation")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Choose export format for \(quotation.clientName)")
                .foregroundColor(.secondary)
            
            VStack(spacing: 12) {
                Button("Export as PDF") {
                    // TODO: Implement PDF export
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Button("Copy to Clipboard") {
                    // TODO: Implement clipboard copy
                    dismiss()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            
            Button("Cancel") {
                dismiss()
            }
            .buttonStyle(.borderless)
        }
        .padding(40)
        .frame(width: 400)
    }
}

#Preview {
    EnhancedQuotationDetailView(quotation: Quotation(
        clientName: "Rajesh & Priya",
        clientPhone: "+91 9876543210",
        clientEmail: "rajesh@example.com",
        eventType: .wedding,
        eventDate: Date(),
        venue: "Grand Palace, Hyderabad",
        guestCount: 500,
        items: [],
        discountPercentage: 10,
        additionalFees: 5000,
        taxPercentage: 18,
        notes: "Traditional Telugu wedding with all customs",
        createdDate: Date(),
        isFinalized: false
    ))
    .environmentObject(QuotationManager())
    .frame(width: 800, height: 1000)
}