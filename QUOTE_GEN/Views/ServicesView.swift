//
//  ServicesView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI

struct ServicesView: View {
    @State private var searchText = ""
    @State private var selectedCategory: ServiceCategory? = nil
    @State private var showingTeluguOnly = false
    
    private let allServices = ServiceDataProvider.shared.getAllServices()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Services Catalog")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(filteredServices.count) services available")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Toggle("Telugu Specific Only", isOn: $showingTeluguOnly)
                        .toggleStyle(.switch)
                    
                    Button("Add Custom Service") {
                        // Add custom service functionality
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            
            // Search and Filter
            HStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    
                    TextField("Search services...", text: $searchText)
                        .textFieldStyle(.plain)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(NSColor.controlBackgroundColor))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                // Category Filter
                Picker("Category", selection: $selectedCategory) {
                    Text("All Categories").tag(nil as ServiceCategory?)
                    ForEach(ServiceCategory.allCases) { category in
                        Text(category.rawValue).tag(category as ServiceCategory?)
                    }
                }
                .pickerStyle(.menu)
                .frame(width: 200)
            }
            .padding(.horizontal)
            
            // Services List
            List {
                ForEach(ServiceCategory.allCases, id: \.self) { category in
                    let categoryServices = filteredServices.filter { $0.category == category }
                    if !categoryServices.isEmpty {
                        Section {
                            ForEach(categoryServices) { service in
                                ServiceRow(service: service)
                            }
                        } header: {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(.blue)
                                Text(category.rawValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Spacer()
                                Text("\(categoryServices.count)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color.secondary.opacity(0.2))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
            }
            .listStyle(.sidebar)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var filteredServices: [ServiceItem] {
        var services = allServices
        
        // Filter by Telugu specific if enabled
        if showingTeluguOnly {
            services = services.filter { $0.isTeluguSpecific }
        }
        
        // Filter by category if selected
        if let selectedCategory = selectedCategory {
            services = services.filter { $0.category == selectedCategory }
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
}

struct ServiceRow: View {
    let service: ServiceItem
    
    var body: some View {
        HStack(spacing: 16) {
            // Service Icon
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue.opacity(0.1))
                .frame(width: 40, height: 40)
                .overlay {
                    Image(systemName: service.category.icon)
                        .font(.title3)
                        .foregroundColor(.blue)
                }
            
            // Service Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(service.name)
                        .font(.headline)
                        .fontWeight(.medium)
                    
                    if service.isTeluguSpecific {
                        Text("Telugu")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .clipShape(Capsule())
                    }
                }
                
                Text(service.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                Text("Unit: \(service.unit)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            // Price
            VStack(alignment: .trailing, spacing: 2) {
                Text("₹\(String(format: "%.0f", service.basePrice))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("per \(service.unit)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
        .contextMenu {
            Button("Add to Current Quote") {
                // Add to current quotation
            }
            
            Button("Edit Service") {
                // Edit service
            }
            
            Divider()
            
            Button("Duplicate Service") {
                // Duplicate service
            }
            
            Button("Delete Service", role: .destructive) {
                // Delete service
            }
        }
    }
}

#Preview {
    ServicesView()
}