//
//  ServiceSelectorView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI
import AppKit

struct ServiceSelectorView: View {
    @Environment(\.dismiss) private var dismiss
    let onServiceSelected: (ServiceItem) -> Void
    
    @State private var searchText = ""
    @State private var selectedCategory: ServiceCategory? = nil
    @State private var showTeluguOnly = false
    
    private let serviceProvider = ServiceDataProvider.shared
    
    var filteredServices: [ServiceItem] {
        var services = serviceProvider.getAllServices()
        
        // Filter by category
        if let category = selectedCategory {
            services = services.filter { $0.category == category }
        }
        
        // Filter by Telugu specific
        if showTeluguOnly {
            services = services.filter { $0.isTeluguSpecific }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            services = services.filter { service in
                service.name.localizedCaseInsensitiveContains(searchText) ||
                service.description.localizedCaseInsensitiveContains(searchText) ||
                service.category.rawValue.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return services.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search and filters
                searchAndFiltersSection
                
                // Services list
                servicesList
            }
            .navigationTitle("Add Services")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var searchAndFiltersSection: some View {
        VStack(spacing: 12) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search services...", text: $searchText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Category filter
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    CategoryFilterChip(
                        title: "All",
                        isSelected: selectedCategory == nil,
                        action: { selectedCategory = nil }
                    )
                    
                    ForEach(ServiceCategory.allCases) { category in
                        CategoryFilterChip(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category,
                            action: { selectedCategory = category }
                        )
                    }
                }
                .padding(.horizontal)
            }
            
            // Telugu filter toggle
            HStack {
                Toggle("Telugu Traditional Only", isOn: $showTeluguOnly)
                    .font(.subheadline)
                Spacer()
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var servicesList: some View {
        List {
            if filteredServices.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No services found")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Try adjusting your search or filters")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .listRowBackground(Color.clear)
            } else {
                ForEach(groupedServices.keys.sorted { $0.rawValue < $1.rawValue }, id: \.self) { category in
                    Section(header: CategorySectionHeader(category: category)) {
                        ForEach(groupedServices[category] ?? []) { service in
                            ServiceRow(service: service) {
                                onServiceSelected(service)
                                dismiss()
                            }
                        }
                    }
                }
            }
        }
        .listStyle(PlainListStyle())
    }
    
    private var groupedServices: [ServiceCategory: [ServiceItem]] {
        Dictionary(grouping: filteredServices) { $0.category }
    }
}

struct CategoryFilterChip: View {
    let title: String
    var icon: String? = nil
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.caption)
                }
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isSelected ? Color.blue : Color(NSColor.controlColor))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CategorySectionHeader: View {
    let category: ServiceCategory
    
    var body: some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(.blue)
            Text(category.rawValue)
                .font(.headline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

struct ServiceRow: View {
    let service: ServiceItem
    let onSelect: () -> Void
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }
    
    var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(service.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                        
                        Text(service.description)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 4) {
                        Text(currencyFormatter.string(from: NSNumber(value: service.basePrice)) ?? "₹0")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        
                        Text("per \(service.unit)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack {
                    if service.isTeluguSpecific {
                        Text("Telugu Traditional")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - AI-Powered Service Suggestions
extension ServiceSelectorView {
    func getAIServiceSuggestions(for eventType: EventType, guestCount: Int) -> [ServiceItem] {
        let allServices = serviceProvider.getAllServices()
        var suggestions: [ServiceItem] = []
        
        switch eventType {
        case .wedding:
            // Essential Telugu wedding services
            suggestions.append(contentsOf: allServices.filter { service in
                service.name.contains("Traditional Telugu Mandap") ||
                service.name.contains("Nadaswaram") ||
                service.name.contains("Telugu Traditional Meals") ||
                service.name.contains("Bridal Flower Jewelry") ||
                service.name.contains("Purohit/Priest") ||
                service.name.contains("Traditional Wedding Photography")
            })
            
        case .engagement:
            suggestions.append(contentsOf: allServices.filter { service in
                service.name.contains("Stage Decoration") ||
                service.name.contains("Photography") ||
                service.name.contains("Cocktail Snacks") ||
                service.name.contains("DJ with Sound System")
            })
            
        case .haldi:
            suggestions.append(contentsOf: allServices.filter { service in
                service.name.contains("Haldi Ceremony Setup") ||
                service.name.contains("Marigold Decoration") ||
                service.name.contains("Traditional") ||
                service.name.contains("Flower")
            })
            
        case .reception:
            suggestions.append(contentsOf: allServices.filter { service in
                service.name.contains("Stage Decoration") ||
                service.name.contains("LED") ||
                service.name.contains("DJ") ||
                service.name.contains("Live Band") ||
                service.name.contains("Photography")
            })
            
        default:
            // General suggestions based on guest count
            if guestCount > 500 {
                suggestions.append(contentsOf: allServices.filter { service in
                    service.category == .venue ||
                    service.category == .catering ||
                    service.category == .equipment
                })
            }
        }
        
        // Add guest count based suggestions
        if guestCount > 200 {
            suggestions.append(contentsOf: allServices.filter { service in
                service.name.contains("Generator") ||
                service.name.contains("AC & Cooling") ||
                service.name.contains("Security") ||
                service.name.contains("Parking")
            })
        }
        
        return Array(Set(suggestions)).prefix(10).map { $0 }
    }
}

#Preview {
    ServiceSelectorView { service in
        print("Selected: \(service.name)")
    }
}