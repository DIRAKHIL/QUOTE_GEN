//
//  QuotationDetailView_macOS.swift
//  QUOTE_GEN
//
//  macOS-native quotation detail view
//

import SwiftUI
import AppKit

struct QuotationDetailView_macOS: View {
    @EnvironmentObject var quotationManager: QuotationManager
    @Environment(\.dismiss) private var dismiss
    
    @State var quotation: Quotation
    @State private var showingServiceSelector = false
    @State private var showingExportSheet = false
    @State private var exportText = ""
    
    var body: some View {
        HSplitView {
            // Left Panel - Form
            formPanel
                .frame(minWidth: 400, idealWidth: 450, maxWidth: 500)
            
            // Right Panel - Services & Preview
            servicesPanel
                .frame(minWidth: 500)
        }
        .navigationTitle(quotation.clientName.isEmpty ? "New Quotation" : quotation.clientName)
        .toolbar {
            ToolbarItemGroup(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
                .keyboardShortcut(.escape)
            }
            
            ToolbarItemGroup(placement: .confirmationAction) {
                Button("Export") {
                    exportQuotation()
                }
                .disabled(quotation.clientName.isEmpty)
                
                Button("Save") {
                    saveQuotation()
                }
                .keyboardShortcut("s", modifiers: .command)
                .buttonStyle(.borderedProminent)
            }
        }
        .sheet(isPresented: $showingServiceSelector) {
            ServiceSelectorView { serviceItem in
                addService(serviceItem)
            }
            .frame(minWidth: 600, minHeight: 500)
        }
        .sheet(isPresented: $showingExportSheet) {
            ExportView(text: exportText)
                .frame(minWidth: 500, minHeight: 400)
        }
    }
    
    private var formPanel: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Client Information
                clientInfoSection
                
                // Event Details
                eventDetailsSection
                
                // Pricing Settings
                pricingSection
                
                // Notes
                notesSection
                
                Spacer()
            }
            .padding(24)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var clientInfoSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Client Information", icon: "person.fill")
            
            VStack(spacing: 12) {
                FormField(title: "Client Name", text: $quotation.clientName)
                FormField(title: "Phone Number", text: $quotation.clientPhone)
                FormField(title: "Email Address", text: $quotation.clientEmail)
            }
        }
    }
    
    private var eventDetailsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Event Details", icon: "heart.fill")
            
            VStack(spacing: 12) {
                HStack {
                    Text("Event Type")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .leading)
                    
                    Picker("Event Type", selection: $quotation.eventType) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            Text(type.rawValue.capitalized).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                HStack {
                    Text("Event Date")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .leading)
                    
                    DatePicker("", selection: $quotation.eventDate, displayedComponents: .date)
                        .datePickerStyle(.compact)
                }
                
                FormField(title: "Venue", text: $quotation.venue)
                
                HStack {
                    Text("Guest Count")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .leading)
                    
                    TextField("Number of guests", value: $quotation.guestCount, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
    
    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Pricing", icon: "indianrupeesign.circle.fill")
            
            VStack(spacing: 12) {
                HStack {
                    Text("Discount %")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .leading)
                    
                    TextField("0", value: $quotation.discountPercentage, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Additional Fees")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .leading)
                    
                    TextField("0", value: $quotation.additionalFees, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
                
                HStack {
                    Text("Tax %")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .frame(width: 120, alignment: .leading)
                    
                    TextField("18", value: $quotation.taxPercentage, format: .number)
                        .textFieldStyle(.roundedBorder)
                }
            }
        }
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            SectionHeader(title: "Notes", icon: "note.text")
            
            TextEditor(text: $quotation.notes)
                .font(.body)
                .frame(minHeight: 100)
                .background(Color(NSColor.textBackgroundColor))
                .cornerRadius(6)
        }
    }
    
    private var servicesPanel: some View {
        VStack(spacing: 0) {
            // Services Header
            HStack {
                Text("Services")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add Service") {
                    showingServiceSelector = true
                }
                .buttonStyle(.bordered)
            }
            .padding(20)
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Services List
            if quotation.items.isEmpty {
                emptyServicesView
            } else {
                servicesListView
            }
            
            Divider()
            
            // Pricing Summary
            pricingSummaryView
        }
        .background(Color(NSColor.textBackgroundColor))
    }
    
    private var emptyServicesView: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 48))
                .foregroundColor(.secondary)
            
            Text("No Services Added")
                .font(.headline)
                .fontWeight(.medium)
            
            Text("Add services to build your quotation")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            Button("Add First Service") {
                showingServiceSelector = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(40)
    }
    
    private var servicesListView: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(quotation.items) { item in
                    ServiceItemRow(
                        item: item,
                        onUpdate: { updatedItem in
                            updateService(updatedItem)
                        },
                        onRemove: {
                            removeService(item)
                        }
                    )
                }
            }
        }
    }
    
    private var pricingSummaryView: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Pricing Summary")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            VStack(spacing: 8) {
                PricingRow(label: "Subtotal", amount: quotation.subtotal)
                
                if quotation.discountPercentage > 0 {
                    PricingRow(
                        label: "Discount (\(String(format: "%.1f", quotation.discountPercentage))%)",
                        amount: -quotation.discountAmount,
                        color: .red
                    )
                }
                
                if quotation.additionalFees > 0 {
                    PricingRow(label: "Additional Fees", amount: quotation.additionalFees)
                }
                
                PricingRow(
                    label: "Tax (\(String(format: "%.1f", quotation.taxPercentage))%)",
                    amount: quotation.taxAmount
                )
                
                Divider()
                
                HStack {
                    Text("Total")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("₹\(String(format: "%.2f", quotation.total))")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
        }
        .padding(20)
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    // MARK: - Actions
    
    private func addService(_ serviceItem: ServiceItem) {
        quotationManager.currentQuotation = quotation
        quotationManager.addItemToQuotation(serviceItem)
        if let updated = quotationManager.currentQuotation {
            quotation = updated
        }
    }
    
    private func updateService(_ item: QuoteItem) {
        if let index = quotation.items.firstIndex(where: { $0.id == item.id }) {
            quotation.items[index] = item
        }
    }
    
    private func removeService(_ item: QuoteItem) {
        quotation.items.removeAll { $0.id == item.id }
    }
    
    private func saveQuotation() {
        quotationManager.saveQuotation(quotation)
        dismiss()
    }
    
    private func exportQuotation() {
        exportText = quotationManager.generateQuotationText(quotation)
        showingExportSheet = true
    }
}

struct FormField: View {
    let title: String
    @Binding var text: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .frame(width: 120, alignment: .leading)
            
            TextField(title, text: $text)
                .textFieldStyle(.roundedBorder)
        }
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
            
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct ServiceItemRow: View {
    let item: QuoteItem
    let onUpdate: (QuoteItem) -> Void
    let onRemove: () -> Void
    
    @State private var quantity: Int
    @State private var customPrice: Double
    
    init(item: QuoteItem, onUpdate: @escaping (QuoteItem) -> Void, onRemove: @escaping () -> Void) {
        self.item = item
        self.onUpdate = onUpdate
        self.onRemove = onRemove
        self._quantity = State(initialValue: item.quantity)
        self._customPrice = State(initialValue: item.customPrice ?? item.serviceItem.basePrice)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(item.serviceItem.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(item.serviceItem.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                Button(action: onRemove) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
                .help("Remove service")
            }
            
            HStack {
                HStack {
                    Text("Qty:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Qty", value: $quantity, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 60)
                        .onChange(of: quantity) { _, newValue in
                            updateItem()
                        }
                }
                
                Spacer()
                
                HStack {
                    Text("Price:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    TextField("Price", value: $customPrice, format: .number)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 80)
                        .onChange(of: customPrice) { _, newValue in
                            updateItem()
                        }
                }
                
                Spacer()
                
                Text("₹\(String(format: "%.0f", item.totalPrice))")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .overlay(
            Rectangle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
    
    private func updateItem() {
        var updatedItem = item
        updatedItem.quantity = quantity
        updatedItem.customPrice = customPrice
        onUpdate(updatedItem)
    }
}

struct PricingRow: View {
    let label: String
    let amount: Double
    let color: Color
    
    init(label: String, amount: Double, color: Color = .primary) {
        self.label = label
        self.amount = amount
        self.color = color
    }
    
    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
            
            Spacer()
            
            Text("₹\(String(format: "%.2f", amount))")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

#Preview {
    QuotationDetailView_macOS(quotation: Quotation(
        clientName: "Test Client",
        clientPhone: "1234567890",
        clientEmail: "test@example.com",
        eventType: .wedding,
        eventDate: Date(),
        venue: "Test Venue",
        guestCount: 200,
        items: [],
        discountPercentage: 0,
        additionalFees: 0,
        taxPercentage: 18,
        notes: "",
        createdDate: Date(),
        isFinalized: false
    ))
    .environmentObject(QuotationManager())
}