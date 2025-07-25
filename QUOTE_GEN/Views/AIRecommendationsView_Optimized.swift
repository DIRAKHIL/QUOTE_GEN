//
//  AIRecommendationsView_Optimized.swift
//  QUOTE_GEN
//
//  Performance optimized version
//

import SwiftUI
import AppKit

struct AIRecommendationsView_Optimized: View {
    let quotation: Quotation
    @EnvironmentObject var quotationManager: QuotationManager
    @State private var recommendations: [ServiceRecommendation] = []
    @State private var isLoading = false
    @State private var showingServiceSelector = false
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Generating recommendations...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if recommendations.isEmpty {
                emptyStateView
            } else {
                recommendationsContent
            }
        }
        .navigationTitle("AI Recommendations")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Refresh") {
                    loadRecommendations()
                }
            }
        }
        .onAppear {
            loadRecommendations()
        }
        .sheet(isPresented: $showingServiceSelector) {
            ServiceSelectorView()
                .environmentObject(quotationManager)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lightbulb.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("AI Recommendations")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Get intelligent suggestions for your event")
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Generate Recommendations") {
                loadRecommendations()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var recommendationsContent: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                // Insights Section
                insightsSection
                
                // Recommendations List
                recommendationsSection
            }
            .padding()
        }
    }
    
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Event Insights")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                InsightCard(
                    title: "Recommendations",
                    value: "\(recommendations.count)",
                    icon: "star.fill",
                    color: .blue
                )
                
                InsightCard(
                    title: "Est. Cost",
                    value: "₹\(String(format: "%.0f", recommendations.reduce(0) { $0 + $1.estimatedCost }))",
                    icon: "indianrupeesign.circle.fill",
                    color: .green
                )
            }
        }
    }
    
    private var recommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Recommended Services")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button("Add Services") {
                    showingServiceSelector = true
                }
                .buttonStyle(.bordered)
            }
            
            LazyVStack(spacing: 8) {
                ForEach(recommendations.prefix(10), id: \.serviceItem.id) { recommendation in
                    RecommendationCard(recommendation: recommendation) {
                        addRecommendation(recommendation)
                    }
                }
            }
        }
    }
    
    private func loadRecommendations() {
        isLoading = true
        
        // Load recommendations asynchronously to prevent hanging
        DispatchQueue.global(qos: .userInitiated).async {
            let newRecommendations = AIRecommendationEngine.shared.getRecommendedServices(
                for: quotation.eventType,
                guestCount: quotation.guestCount,
                budget: quotation.total,
                venue: quotation.venue
            )
            
            DispatchQueue.main.async {
                self.recommendations = Array(newRecommendations.prefix(20)) // Limit to prevent performance issues
                self.isLoading = false
            }
        }
    }
    
    private func addRecommendation(_ recommendation: ServiceRecommendation) {
        quotationManager.addItemToQuotation(recommendation.serviceItem)
    }
}

struct RecommendationCard: View {
    let recommendation: ServiceRecommendation
    let onAdd: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(recommendation.serviceItem.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(recommendation.reason)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                
                HStack {
                    Text("₹\(String(format: "%.0f", recommendation.estimatedCost))")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    PriorityBadge(priority: recommendation.priority)
                }
            }
            
            Spacer()
            
            Button(action: onAdd) {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
            }
            .buttonStyle(.plain)
        }
        .padding(12)
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct PriorityBadge: View {
    let priority: RecommendationPriority
    
    var body: some View {
        Text(priority.rawValue.capitalized)
            .font(.caption2)
            .fontWeight(.medium)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(priorityColor.opacity(0.2))
            .foregroundColor(priorityColor)
            .cornerRadius(4)
    }
    
    private var priorityColor: Color {
        switch priority {
        case .high: return .red
        case .medium: return .orange
        case .low: return .blue
        }
    }
}

struct InsightCard: View {
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
                .font(.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
}

#Preview {
    AIRecommendationsView_Optimized(quotation: Quotation(
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