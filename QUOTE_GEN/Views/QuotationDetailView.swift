//
//  QuotationDetailView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI
import AppKit

struct QuotationDetailView: View {
    @EnvironmentObject var quotationManager: QuotationManager
    @Environment(\.dismiss) private var dismiss
    
    @State var quotation: Quotation
    @State private var showingServiceSelector = false
    @State private var showingExportSheet = false

    @State private var exportText = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Client Information Section
                    clientInfoSection
                    
                    // Event Details Section
                    eventDetailsSection
                    
                    // Services Section
                    servicesSection
                    
                    // Pricing Section
                    pricingSection
                    
                    // Notes Section
                    notesSection
                }
                .padding()
            }
            .navigationTitle("Quotation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: saveQuotation) {
                            Label("Save", systemImage: "square.and.arrow.down")
                        }
                        
                        Button(action: exportQuotation) {
                            Label("Export", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: toggleFinalized) {
                            Label(quotation.isFinalized ? "Mark as Draft" : "Finalize", 
                                  systemImage: quotation.isFinalized ? "pencil" : "checkmark.seal")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showingServiceSelector) {
                ServiceSelectorView { serviceItem in
                    addService(serviceItem)
                }
            }

            .sheet(isPresented: $showingExportSheet) {
                ExportView(text: exportText)
            }
        }
    }
    
    private var clientInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Client Information", icon: "person.fill")
            
            VStack(spacing: 12) {
                CustomTextField(title: "Client Name", text: $quotation.clientName, placeholder: "Enter client name")
                CustomTextField(title: "Phone Number", text: $quotation.clientPhone, placeholder: "+91 XXXXX XXXXX")
                CustomTextField(title: "Email Address", text: $quotation.clientEmail, placeholder: "client@example.com")
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var eventDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Event Details", icon: "calendar")
            
            VStack(spacing: 12) {
                HStack {
                    Text("Event Type")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Picker("Event Type", selection: $quotation.eventType) {
                        ForEach(EventType.allCases) { eventType in
                            Text(eventType.rawValue).tag(eventType)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                
                DatePicker("Event Date", selection: $quotation.eventDate, displayedComponents: .date)
                    .datePickerStyle(CompactDatePickerStyle())
                
                CustomTextField(title: "Venue", text: $quotation.venue, placeholder: "Enter venue name")
                
                HStack {
                    Text("Guest Count")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Stepper(value: $quotation.guestCount, in: 1...10000, step: 10) {
                        Text("\(quotation.guestCount)")
                            .font(.headline)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var servicesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SectionHeader(title: "Services", icon: "list.bullet")
                Spacer()
                

                Button(action: { showingServiceSelector = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            if quotation.items.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No services added yet")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Button("Add Services") {
                        showingServiceSelector = true
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(quotation.items) { item in
                        ServiceItemRow(item: item) { updatedItem in
                            updateService(updatedItem)
                        } onDelete: {
                            removeService(item)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var pricingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Pricing", icon: "indianrupeesign.circle")
            
            VStack(spacing: 12) {
                PricingRow(title: "Subtotal", amount: quotation.subtotal, isTotal: false)
                
                HStack {
                    Text("Discount (%)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("0", value: $quotation.discountPercentage, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                if quotation.discountPercentage > 0 {
                    PricingRow(title: "Discount", amount: -quotation.discountAmount, isTotal: false)
                    PricingRow(title: "After Discount", amount: quotation.afterDiscount, isTotal: false)
                }
                
                HStack {
                    Text("Additional Fees")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("0", value: $quotation.additionalFees, format: .currency(code: "INR"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 120)
                }
                
                HStack {
                    Text("Tax (%)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    TextField("18", value: $quotation.taxPercentage, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                PricingRow(title: "Tax Amount", amount: quotation.taxAmount, isTotal: false)
                
                Divider()
                
                PricingRow(title: "Grand Total", amount: quotation.grandTotal, isTotal: true)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeader(title: "Additional Notes", icon: "note.text")
            
            TextEditor(text: $quotation.notes)
                .frame(minHeight: 100)
                .padding(8)
                .background(Color(NSColor.controlBackgroundColor))
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(NSColor.separatorColor), lineWidth: 1)
                )
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
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
    
    private func toggleFinalized() {
        quotation.isFinalized.toggle()
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.blue)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
        }
    }
}

struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct PricingRow: View {
    let title: String
    let amount: Double
    let isTotal: Bool
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .regular)
                .foregroundColor(isTotal ? .primary : .secondary)
            
            Spacer()
            
            Text(currencyFormatter.string(from: NSNumber(value: amount)) ?? "₹0")
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(isTotal ? .primary : (amount < 0 ? .red : .primary))
        }
    }
}

struct ServiceItemRow: View {
    let item: QuoteItem
    let onUpdate: (QuoteItem) -> Void
    let onDelete: () -> Void
    
    @State private var quantity: Int
    @State private var customPrice: String
    @State private var notes: String
    
    init(item: QuoteItem, onUpdate: @escaping (QuoteItem) -> Void, onDelete: @escaping () -> Void) {
        self.item = item
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self._quantity = State(initialValue: item.quantity)
        self._customPrice = State(initialValue: item.customPrice?.formatted() ?? "")
        self._notes = State(initialValue: item.notes)
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
                    Text(item.serviceItem.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(item.serviceItem.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if item.serviceItem.isTeluguSpecific {
                        Text("Telugu Traditional")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Quantity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Stepper(value: $quantity, in: 1...100) {
                        Text("\(quantity)")
                            .font(.subheadline)
                    }
                    .onChange(of: quantity) { _, newValue in
                        updateItem()
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Price per unit")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Custom price", text: $customPrice)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: customPrice) { _, _ in
                            updateItem()
                        }
                }
            }
            
            HStack {
                Text("Total: \(currencyFormatter.string(from: NSNumber(value: item.totalPrice)) ?? "₹0")")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
            }
            
            if !notes.isEmpty || item.notes.isEmpty {
                TextField("Add notes...", text: $notes)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.caption)
                    .onChange(of: notes) { _, _ in
                        updateItem()
                    }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
    
    private func updateItem() {
        let price = Double(customPrice) ?? item.serviceItem.basePrice
        let updatedItem = QuoteItem(
            serviceItem: item.serviceItem,
            quantity: quantity,
            customPrice: customPrice.isEmpty ? nil : price,
            notes: notes
        )
        onUpdate(updatedItem)
    }
}

struct ExportView: View {
    let text: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(text)
                    .font(.system(.body, design: .monospaced))
                    .padding()
            }
            .navigationTitle("Export Quotation")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    ShareLink(item: text) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
    }
}

#Preview {
    QuotationDetailView(quotation: Quotation(
        clientName: "Sample Client",
        clientPhone: "+91 98765 43210",
        clientEmail: "client@example.com",
        eventType: .wedding,
        eventDate: Date(),
        venue: "Sample Venue",
        guestCount: 200,
        items: [],
        discountPercentage: 10,
        additionalFees: 5000,
        taxPercentage: 18,
        notes: "Sample notes",
        createdDate: Date(),
        isFinalized: false
    ))
    .environmentObject(QuotationManager())
}