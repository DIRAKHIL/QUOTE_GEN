//
//  NewQuotationWizard.swift
//  QUOTE_GEN
//
//  Step-by-step quotation creation wizard
//

import SwiftUI

struct NewQuotationWizard: View {
    let quotationManager: QuotationManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 0
    @State private var clientName = ""
    @State private var clientPhone = ""
    @State private var clientEmail = ""
    @State private var eventType: EventType = .wedding
    @State private var eventDate = Date()
    @State private var venue = ""
    @State private var guestCount = 100
    @State private var selectedServices: [ServiceItem] = []
    @State private var notes = ""
    
    private let steps = [
        "Client Information",
        "Event Details",
        "Services Selection",
        "Review & Create"
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            Divider()
            
            // Content
            TabView(selection: $currentStep) {
                clientInformationStep.tag(0)
                eventDetailsStep.tag(1)
                servicesSelectionStep.tag(2)
                reviewStep.tag(3)
            }
            .tabViewStyle(.automatic)
            
            Divider()
            
            // Footer
            footerView
        }
        .frame(width: 700, height: 600)
    }
    
    // MARK: - Header
    private var headerView: some View {
        VStack(spacing: 16) {
            HStack {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.borderless)
                
                Spacer()
                
                Text("New Quotation")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Save Draft") {
                    saveDraft()
                }
                .buttonStyle(.borderless)
                .disabled(!canSaveDraft)
            }
            
            // Progress Indicator
            HStack(spacing: 8) {
                ForEach(0..<steps.count, id: \.self) { index in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(index <= currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(width: 12, height: 12)
                        
                        Text(steps[index])
                            .font(.caption)
                            .foregroundColor(index <= currentStep ? .primary : .secondary)
                    }
                    
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(index < currentStep ? Color.accentColor : Color.secondary.opacity(0.3))
                            .frame(height: 2)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding(20)
    }
    
    // MARK: - Steps
    private var clientInformationStep: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Client Information")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Enter the client's contact details")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Client Name *")
                        .font(.headline)
                    TextField("Enter client name", text: $clientName)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Phone Number *")
                            .font(.headline)
                        TextField("+91 9876543210", text: $clientPhone)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.large)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.headline)
                        TextField("client@example.com", text: $clientEmail)
                            .textFieldStyle(.roundedBorder)
                            .controlSize(.large)
                    }
                }
            }
            
            Spacer()
        }
        .padding(40)
    }
    
    private var eventDetailsStep: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Event Details")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Specify the event type, date, and venue")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Event Type *")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(EventType.allCases, id: \.self) { type in
                            EventTypeCard(
                                eventType: type,
                                isSelected: eventType == type
                            ) {
                                eventType = type
                            }
                        }
                    }
                }
                
                HStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Event Date *")
                            .font(.headline)
                        DatePicker("", selection: $eventDate, displayedComponents: .date)
                            .datePickerStyle(.compact)
                    }
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Guest Count *")
                            .font(.headline)
                        Stepper(value: $guestCount, in: 1...10000, step: 10) {
                            Text("\(guestCount) guests")
                                .font(.subheadline)
                        }
                    }
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Venue *")
                        .font(.headline)
                    TextField("Enter venue name and location", text: $venue)
                        .textFieldStyle(.roundedBorder)
                        .controlSize(.large)
                }
            }
            
            Spacer()
        }
        .padding(40)
    }
    
    private var servicesSelectionStep: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Services Selection")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Choose services for your event (you can add more later)")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(ServiceCategory.allCases, id: \.self) { category in
                        ServiceCategorySection(
                            category: category,
                            selectedServices: $selectedServices
                        )
                    }
                }
            }
            
            Spacer()
        }
        .padding(40)
    }
    
    private var reviewStep: some View {
        VStack(spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Review & Create")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Review your quotation details before creating")
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView {
                VStack(spacing: 20) {
                    // Client Summary
                    ReviewSection(title: "Client Information") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Name: \(clientName)")
                            Text("Phone: \(clientPhone)")
                            if !clientEmail.isEmpty {
                                Text("Email: \(clientEmail)")
                            }
                        }
                    }
                    
                    // Event Summary
                    ReviewSection(title: "Event Details") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Type: \(eventType.rawValue)")
                            Text("Date: \(eventDate.formatted(date: .abbreviated, time: .omitted))")
                            Text("Venue: \(venue)")
                            Text("Guests: \(guestCount)")
                        }
                    }
                    
                    // Services Summary
                    ReviewSection(title: "Selected Services (\(selectedServices.count))") {
                        if selectedServices.isEmpty {
                            Text("No services selected")
                                .foregroundColor(.secondary)
                        } else {
                            VStack(alignment: .leading, spacing: 4) {
                                ForEach(selectedServices, id: \.name) { service in
                                    HStack {
                                        Text(service.name)
                                        Spacer()
                                        Text("₹\(String(format: "%.0f", service.basePrice))")
                                            .foregroundColor(.green)
                                    }
                                }
                            }
                        }
                    }
                    
                    // Notes
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Additional Notes")
                            .font(.headline)
                        
                        TextEditor(text: $notes)
                            .frame(height: 80)
                            .padding(8)
                            .background(Color(NSColor.textBackgroundColor))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }
            }
            
            Spacer()
        }
        .padding(40)
    }
    
    // MARK: - Footer
    private var footerView: some View {
        HStack {
            if currentStep > 0 {
                Button("Previous") {
                    withAnimation {
                        currentStep -= 1
                    }
                }
                .buttonStyle(.bordered)
            }
            
            Spacer()
            
            if currentStep < steps.count - 1 {
                Button("Next") {
                    withAnimation {
                        currentStep += 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceedToNextStep)
            } else {
                Button("Create Quotation") {
                    createQuotation()
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canCreateQuotation)
            }
        }
        .padding(20)
    }
    
    // MARK: - Helper Methods
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case 0:
            return !clientName.isEmpty && !clientPhone.isEmpty
        case 1:
            return !venue.isEmpty
        case 2:
            return true // Services are optional
        default:
            return true
        }
    }
    
    private var canCreateQuotation: Bool {
        !clientName.isEmpty && !clientPhone.isEmpty && !venue.isEmpty
    }
    
    private var canSaveDraft: Bool {
        !clientName.isEmpty || !clientPhone.isEmpty || !venue.isEmpty
    }
    
    private func createQuotation() {
        let items = selectedServices.map { service in
            QuoteItem(
                serviceItem: service,
                quantity: 1,
                customPrice: nil,
                notes: ""
            )
        }
        
        let quotation = Quotation(
            clientName: clientName,
            clientPhone: clientPhone,
            clientEmail: clientEmail,
            eventType: eventType,
            eventDate: eventDate,
            venue: venue,
            guestCount: guestCount,
            items: items,
            discountPercentage: 0,
            additionalFees: 0,
            taxPercentage: 18,
            notes: notes,
            createdDate: Date(),
            isFinalized: false
        )
        
        quotationManager.saveQuotation(quotation)
        dismiss()
    }
    
    private func saveDraft() {
        createQuotation()
    }
}

// MARK: - Supporting Views
struct EventTypeCard: View {
    let eventType: EventType
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 8) {
                Text(eventType.teluguName)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(eventType.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color(NSColor.controlBackgroundColor))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}

struct ServiceCategorySection: View {
    let category: ServiceCategory
    @Binding var selectedServices: [ServiceItem]
    @State private var isExpanded = false
    
    private var categoryServices: [ServiceItem] {
        ServiceDataProvider.shared.getAllServices().filter { $0.category == category }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: category.icon)
                        .foregroundColor(.accentColor)
                    
                    Text(category.rawValue)
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Spacer()
                    
                    Text("\(selectedServicesCount)")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.accentColor.opacity(0.2))
                        .clipShape(Capsule())
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                LazyVStack(spacing: 8) {
                    ForEach(categoryServices.prefix(5), id: \.name) { service in
                        ServiceSelectionRow(
                            service: service,
                            isSelected: selectedServices.contains { $0.name == service.name }
                        ) { isSelected in
                            if isSelected {
                                selectedServices.append(service)
                            } else {
                                selectedServices.removeAll { $0.name == service.name }
                            }
                        }
                    }
                    
                    if categoryServices.count > 5 {
                        Text("+ \(categoryServices.count - 5) more services available")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                }
                .padding(.leading, 16)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
    
    private var selectedServicesCount: Int {
        selectedServices.filter { $0.category == category }.count
    }
}

struct ServiceSelectionRow: View {
    let service: ServiceItem
    let isSelected: Bool
    let onToggle: (Bool) -> Void
    
    var body: some View {
        HStack {
            Button(action: { onToggle(!isSelected) }) {
                Image(systemName: isSelected ? "checkmark.square.fill" : "square")
                    .foregroundColor(isSelected ? .accentColor : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(service.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(service.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
            
            Text("₹\(String(format: "%.0f", service.basePrice))")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            onToggle(!isSelected)
        }
    }
}

struct ReviewSection<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
            
            content
                .font(.subheadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Settings")
                .font(.title)
                .fontWeight(.bold)
            
            Text("App settings and preferences")
                .foregroundColor(.secondary)
            
            Spacer()
            
            Button("Close") {
                dismiss()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(40)
        .frame(width: 400, height: 300)
    }
}

#Preview {
    NewQuotationWizard(quotationManager: QuotationManager())
}