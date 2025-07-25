//
//  AIRecommendationsView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI
import AppKit

struct AIRecommendationsView: View {
    let quotation: Quotation
    let onServiceSelected: (ServiceItem, Int) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var recommendations: [ServiceRecommendation] = []
    @State private var seasonalTips: [String] = []
    @State private var selectedPriority: RecommendationPriority? = nil
    @State private var showingBudgetOptimization = false
    @State private var targetBudget: Double = 0
    
    private let aiEngine = AIRecommendationEngine.shared
    
    var filteredRecommendations: [ServiceRecommendation] {
        if let priority = selectedPriority {
            return recommendations.filter { $0.priority == priority }
        }
        return recommendations
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header with AI insights
                    aiInsightsHeader
                    
                    // Seasonal recommendations
                    if !seasonalTips.isEmpty {
                        seasonalRecommendationsSection
                    }
                    
                    // Priority filter
                    priorityFilterSection
                    
                    // Service recommendations
                    serviceRecommendationsSection
                    
                    // Budget optimization
                    budgetOptimizationSection
                }
                .padding()
            }
            .navigationTitle("AI Recommendations")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .primaryAction) {
                    Button("Optimize Budget") {
                        showingBudgetOptimization = true
                    }
                    .disabled(recommendations.isEmpty)
                }
            }
            .onAppear {
                loadRecommendations()
            }
            .sheet(isPresented: $showingBudgetOptimization) {
                BudgetOptimizationView(
                    recommendations: recommendations,
                    currentBudget: quotation.grandTotal,
                    onOptimize: { optimizedRecommendations in
                        recommendations = optimizedRecommendations
                    }
                )
            }
        }
    }
    
    private var aiInsightsHeader: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "brain.head.profile")
                    .font(.title2)
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI-Powered Recommendations")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Based on \(quotation.eventType.rawValue) for \(quotation.guestCount) guests")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
            
            HStack(spacing: 16) {
                InsightCard(
                    title: "Total Suggestions",
                    value: "\(recommendations.count)",
                    icon: "lightbulb.fill",
                    color: .blue
                )
                
                InsightCard(
                    title: "Essential Items",
                    value: "\(recommendations.filter { $0.priority == .high }.count)",
                    icon: "exclamationmark.triangle.fill",
                    color: .red
                )
                
                InsightCard(
                    title: "Est. Cost",
                    value: "₹\(String(format: "%.0f", recommendations.reduce(0) { $0 + $1.estimatedCost }))",
                    icon: "indianrupeesign.circle.fill",
                    color: .green
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var seasonalRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .foregroundColor(.orange)
                Text("Seasonal Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                ForEach(seasonalTips, id: \.self) { tip in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.orange)
                            .font(.caption)
                        
                        Text(tip)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var priorityFilterSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                PriorityFilterChip(
                    title: "All",
                    count: recommendations.count,
                    isSelected: selectedPriority == nil,
                    color: .blue
                ) {
                    selectedPriority = nil
                }
                
                ForEach(RecommendationPriority.allCases, id: \.self) { priority in
                    let count = recommendations.filter { $0.priority == priority }.count
                    if count > 0 {
                        PriorityFilterChip(
                            title: priority.displayName,
                            count: count,
                            isSelected: selectedPriority == priority,
                            color: Color(priority.color)
                        ) {
                            selectedPriority = priority
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var serviceRecommendationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "list.bullet.rectangle")
                    .foregroundColor(.blue)
                Text("Service Recommendations")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            if filteredRecommendations.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "tray")
                        .font(.system(size: 40))
                        .foregroundColor(.secondary)
                    Text("No recommendations for selected filter")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(filteredRecommendations) { recommendation in
                        RecommendationCard(recommendation: recommendation) { service, quantity in
                            onServiceSelected(service, quantity)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private var budgetOptimizationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.green)
                Text("Budget Insights")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            let totalRecommendedCost = recommendations.reduce(0) { $0 + $1.estimatedCost }
            let currentQuotationTotal = quotation.grandTotal
            
            VStack(spacing: 8) {
                BudgetInsightRow(
                    title: "Current Quotation",
                    amount: currentQuotationTotal,
                    color: .primary
                )
                
                BudgetInsightRow(
                    title: "Recommended Additions",
                    amount: totalRecommendedCost,
                    color: .blue
                )
                
                Divider()
                
                BudgetInsightRow(
                    title: "Projected Total",
                    amount: currentQuotationTotal + totalRecommendedCost,
                    color: .green,
                    isTotal: true
                )
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(12)
    }
    
    private func loadRecommendations() {
        recommendations = aiEngine.getRecommendedServices(
            for: quotation.eventType,
            guestCount: quotation.guestCount,
            budget: quotation.grandTotal,
            venue: quotation.venue
        )
        
        seasonalTips = aiEngine.getSeasonalRecommendations(for: quotation.eventDate)
    }
}

struct InsightCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
    }
}

struct PriorityFilterChip: View {
    let title: String
    let count: Int
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("(\(count))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? color : Color(NSColor.controlColor))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct RecommendationCard: View {
    let recommendation: ServiceRecommendation
    let onAdd: (ServiceItem, Int) -> Void
    
    @State private var quantity: Int
    
    init(recommendation: ServiceRecommendation, onAdd: @escaping (ServiceItem, Int) -> Void) {
        self.recommendation = recommendation
        self.onAdd = onAdd
        self._quantity = State(initialValue: recommendation.suggestedQuantity)
    }
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(recommendation.service.name)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        Spacer()
                        
                        Text(recommendation.priority.displayName)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(recommendation.priority.color).opacity(0.2))
                            .foregroundColor(Color(recommendation.priority.color))
                            .cornerRadius(4)
                    }
                    
                    Text(recommendation.reason)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
                    if recommendation.service.isTeluguSpecific {
                        Text("Telugu Traditional")
                            .font(.caption)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.orange.opacity(0.2))
                            .foregroundColor(.orange)
                            .cornerRadius(4)
                    }
                }
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Suggested Quantity")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Stepper(value: $quantity, in: 1...100) {
                        Text("\(quantity)")
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Estimated Cost")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(currencyFormatter.string(from: NSNumber(value: recommendation.service.basePrice * Double(quantity))) ?? "₹0")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                }
            }
            
            Button(action: {
                onAdd(recommendation.service, quantity)
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add to Quotation")
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(Color.blue)
                .cornerRadius(8)
            }
        }
        .padding()
        .background(Color(NSColor.controlBackgroundColor))
        .cornerRadius(8)
        .shadow(radius: 1)
    }
}

struct BudgetInsightRow: View {
    let title: String
    let amount: Double
    let color: Color
    var isTotal: Bool = false
    
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
                .fontWeight(isTotal ? .bold : .medium)
                .foregroundColor(color)
            
            Spacer()
            
            Text(currencyFormatter.string(from: NSNumber(value: amount)) ?? "₹0")
                .font(isTotal ? .headline : .subheadline)
                .fontWeight(isTotal ? .bold : .semibold)
                .foregroundColor(color)
        }
    }
}

struct BudgetOptimizationView: View {
    let recommendations: [ServiceRecommendation]
    let currentBudget: Double
    let onOptimize: ([ServiceRecommendation]) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var targetBudget: Double
    @State private var optimizedRecommendations: [ServiceRecommendation] = []
    
    init(recommendations: [ServiceRecommendation], currentBudget: Double, onOptimize: @escaping ([ServiceRecommendation]) -> Void) {
        self.recommendations = recommendations
        self.currentBudget = currentBudget
        self.onOptimize = onOptimize
        self._targetBudget = State(initialValue: currentBudget + recommendations.reduce(0) { $0 + $1.estimatedCost })
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Budget Optimization")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Set your target budget and we'll optimize the recommendations to fit within your budget while prioritizing essential services.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Target Budget")
                        .font(.headline)
                    
                    TextField("Enter target budget", value: $targetBudget, format: .currency(code: "INR"))
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onChange(of: targetBudget) { _, _ in
                            optimizeRecommendations()
                        }
                }
                
                if !optimizedRecommendations.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Optimized Recommendations")
                            .font(.headline)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(optimizedRecommendations) { recommendation in
                                    OptimizedRecommendationRow(recommendation: recommendation)
                                }
                            }
                        }
                        .frame(maxHeight: 300)
                    }
                }
                
                Spacer()
                
                Button("Apply Optimization") {
                    onOptimize(optimizedRecommendations)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(optimizedRecommendations.isEmpty)
            }
            .padding()
            .navigationTitle("Budget Optimization")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                optimizeRecommendations()
            }
        }
    }
    
    private func optimizeRecommendations() {
        optimizedRecommendations = AIRecommendationEngine.shared.optimizeBudget(recommendations, targetBudget: targetBudget)
    }
}

struct OptimizedRecommendationRow: View {
    let recommendation: ServiceRecommendation
    
    private var currencyFormatter: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        formatter.locale = Locale(identifier: "en_IN")
        return formatter
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(recommendation.service.name)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(recommendation.priority.displayName)
                    .font(.caption)
                    .foregroundColor(Color(recommendation.priority.color))
            }
            
            Spacer()
            
            Text(currencyFormatter.string(from: NSNumber(value: recommendation.estimatedCost)) ?? "₹0")
                .font(.subheadline)
                .fontWeight(.semibold)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    AIRecommendationsView(
        quotation: Quotation(
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
        )
    ) { service, quantity in
        print("Selected: \(service.name) x \(quantity)")
    }
}