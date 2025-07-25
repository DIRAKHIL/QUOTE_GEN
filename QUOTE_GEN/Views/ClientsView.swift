//
//  ClientsView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI

struct ClientsView: View {
    @EnvironmentObject var quotationManager: QuotationManager
    @State private var searchText = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Clients")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("\(uniqueClients.count) unique clients")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Export Client List") {
                    // Export functionality
                }
                .buttonStyle(.borderedProminent)
            }
            .padding()
            
            // Search Bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search clients...", text: $searchText)
                    .textFieldStyle(.plain)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(NSColor.controlBackgroundColor))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal)
            
            // Client List
            List {
                ForEach(filteredClients, id: \.name) { client in
                    ClientRow(client: client)
                }
            }
            .listStyle(.plain)
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var uniqueClients: [ClientInfo] {
        var clientDict: [String: ClientInfo] = [:]
        
        for quotation in quotationManager.quotations {
            if !quotation.clientName.isEmpty {
                let key = quotation.clientName.lowercased()
                if clientDict[key] == nil {
                    clientDict[key] = ClientInfo(
                        name: quotation.clientName,
                        phone: quotation.clientPhone,
                        email: quotation.clientEmail,
                        quotationCount: 1,
                        totalValue: quotation.grandTotal,
                        lastEventDate: quotation.eventDate,
                        eventTypes: [quotation.eventType]
                    )
                } else {
                    clientDict[key]!.quotationCount += 1
                    clientDict[key]!.totalValue += quotation.grandTotal
                    if quotation.eventDate > clientDict[key]!.lastEventDate {
                        clientDict[key]!.lastEventDate = quotation.eventDate
                    }
                    if !clientDict[key]!.eventTypes.contains(quotation.eventType) {
                        clientDict[key]!.eventTypes.append(quotation.eventType)
                    }
                }
            }
        }
        
        return Array(clientDict.values).sorted { $0.name < $1.name }
    }
    
    private var filteredClients: [ClientInfo] {
        if searchText.isEmpty {
            return uniqueClients
        } else {
            return uniqueClients.filter { client in
                client.name.localizedCaseInsensitiveContains(searchText) ||
                client.phone.localizedCaseInsensitiveContains(searchText) ||
                client.email.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
}

struct ClientInfo {
    let name: String
    let phone: String
    let email: String
    var quotationCount: Int
    var totalValue: Double
    var lastEventDate: Date
    var eventTypes: [EventType]
}

struct ClientRow: View {
    let client: ClientInfo
    
    var body: some View {
        HStack(spacing: 16) {
            // Avatar
            Circle()
                .fill(Color.blue.gradient)
                .frame(width: 50, height: 50)
                .overlay {
                    Text(client.name.prefix(1).uppercased())
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }
            
            // Client Info
            VStack(alignment: .leading, spacing: 4) {
                Text(client.name)
                    .font(.headline)
                    .fontWeight(.medium)
                
                if !client.phone.isEmpty {
                    Text(client.phone)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                if !client.email.isEmpty {
                    Text(client.email)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // Event types
                HStack {
                    ForEach(client.eventTypes.prefix(3), id: \.self) { eventType in
                        Text(eventType.rawValue)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .clipShape(Capsule())
                    }
                    
                    if client.eventTypes.count > 3 {
                        Text("+\(client.eventTypes.count - 3)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Stats
            VStack(alignment: .trailing, spacing: 4) {
                Text("₹\(String(format: "%.0f", client.totalValue))")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
                
                Text("\(client.quotationCount) quotation\(client.quotationCount == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(client.lastEventDate, style: .date)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ClientsView()
        .environmentObject(QuotationManager())
}