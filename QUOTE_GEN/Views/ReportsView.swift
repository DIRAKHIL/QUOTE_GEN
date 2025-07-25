//
//  ReportsView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI
import Charts

struct ReportsView: View {
    @EnvironmentObject var quotationManager: QuotationManager
    @State private var selectedTimeRange: TimeRange = .thisMonth
    @State private var selectedReportType: ReportType = .revenue
    
    enum TimeRange: String, CaseIterable {
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case thisQuarter = "This Quarter"
        case thisYear = "This Year"
        case allTime = "All Time"
    }
    
    enum ReportType: String, CaseIterable {
        case revenue = "Revenue"
        case quotations = "Quotations"
        case services = "Services"
        case clients = "Clients"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Reports & Analytics")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Business insights and performance metrics")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack {
                    Picker("Time Range", selection: $selectedTimeRange) {
                        ForEach(TimeRange.allCases, id: \.self) { range in
                            Text(range.rawValue).tag(range)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(width: 150)
                    
                    Picker("Report Type", selection: $selectedReportType) {
                        ForEach(ReportType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 300)
                    
                    Button("Export Report") {
                        // Export functionality
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    // Key Metrics
                    keyMetricsSection
                    
                    // Charts Section
                    chartsSection
                    
                    // Detailed Analytics
                    detailedAnalyticsSection
                }
                .padding()
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
    
    private var keyMetricsSection: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
            MetricCard(
                title: "Total Revenue",
                value: "₹\(String(format: "%.0f", totalRevenue))",
                icon: "indianrupeesign.circle.fill",
                color: .green,
                change: "+12.5%"
            )
            
            MetricCard(
                title: "Total Quotations",
                value: "\(filteredQuotations.count)",
                icon: "doc.text.fill",
                color: .blue,
                change: "+8.3%"
            )
            
            MetricCard(
                title: "Conversion Rate",
                value: "\(String(format: "%.1f", conversionRate))%",
                icon: "chart.line.uptrend.xyaxis",
                color: .orange,
                change: "+2.1%"
            )
            
            MetricCard(
                title: "Avg. Quote Value",
                value: "₹\(String(format: "%.0f", averageQuoteValue))",
                icon: "chart.bar.fill",
                color: .purple,
                change: "+5.7%"
            )
        }
    }
    
    private var chartsSection: some View {
        VStack(spacing: 20) {
            // Revenue Chart
            VStack(alignment: .leading, spacing: 12) {
                Text("Revenue Trend")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(NSColor.controlBackgroundColor))
                    .frame(height: 300)
                    .overlay {
                        // Placeholder for chart
                        VStack {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .font(.system(size: 50))
                                .foregroundColor(.secondary)
                            
                            Text("Revenue Chart")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text("Chart implementation requires Charts framework")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
            }
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            
            // Service Distribution
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Popular Services")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(popularServices.prefix(5), id: \.name) { service in
                            HStack {
                                Text(service.name)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(serviceUsageCount[service.name] ?? 0)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Event Types")
                        .font(.title3)
                        .fontWeight(.semibold)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(eventTypeDistribution.prefix(5), id: \.key) { eventType, count in
                            HStack {
                                Text(eventType.rawValue)
                                    .font(.subheadline)
                                
                                Spacer()
                                
                                Text("\(count)")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(20)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    private var detailedAnalyticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Detailed Analytics")
                .font(.title2)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                AnalyticsCard(
                    title: "Monthly Growth",
                    value: "+15.2%",
                    subtitle: "Compared to last month",
                    icon: "arrow.up.right",
                    color: .green
                )
                
                AnalyticsCard(
                    title: "Client Retention",
                    value: "78.5%",
                    subtitle: "Repeat customers",
                    icon: "person.2.fill",
                    color: .blue
                )
                
                AnalyticsCard(
                    title: "Avg. Response Time",
                    value: "2.3 hrs",
                    subtitle: "Quote delivery time",
                    icon: "clock.fill",
                    color: .orange
                )
                
                AnalyticsCard(
                    title: "Peak Season",
                    value: "Nov-Feb",
                    subtitle: "Wedding season",
                    icon: "calendar",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
    
    // MARK: - Computed Properties
    private var filteredQuotations: [Quotation] {
        let calendar = Calendar.current
        let now = Date()
        
        return quotationManager.quotations.filter { quotation in
            switch selectedTimeRange {
            case .thisWeek:
                return calendar.isDate(quotation.createdDate, equalTo: now, toGranularity: .weekOfYear)
            case .thisMonth:
                return calendar.isDate(quotation.createdDate, equalTo: now, toGranularity: .month)
            case .thisQuarter:
                return calendar.isDate(quotation.createdDate, equalTo: now, toGranularity: .quarter)
            case .thisYear:
                return calendar.isDate(quotation.createdDate, equalTo: now, toGranularity: .year)
            case .allTime:
                return true
            }
        }
    }
    
    private var totalRevenue: Double {
        filteredQuotations.filter { $0.isFinalized }.reduce(0) { $0 + $1.grandTotal }
    }
    
    private var conversionRate: Double {
        let finalized = filteredQuotations.filter { $0.isFinalized }.count
        let total = filteredQuotations.count
        return total > 0 ? (Double(finalized) / Double(total)) * 100 : 0
    }
    
    private var averageQuoteValue: Double {
        let finalizedQuotes = filteredQuotations.filter { $0.isFinalized }
        return finalizedQuotes.isEmpty ? 0 : totalRevenue / Double(finalizedQuotes.count)
    }
    
    private var popularServices: [ServiceItem] {
        quotationManager.getMostPopularServices()
    }
    
    private var serviceUsageCount: [String: Int] {
        var count: [String: Int] = [:]
        for quotation in filteredQuotations {
            for item in quotation.items {
                count[item.serviceItem.name, default: 0] += item.quantity
            }
        }
        return count
    }
    
    private var eventTypeDistribution: [(key: EventType, value: Int)] {
        let distribution = Dictionary(grouping: filteredQuotations) { $0.eventType }
            .mapValues { $0.count }
        return distribution.sorted { $0.value > $1.value }
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    let change: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Spacer()
                
                Text(change)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title)
                    .fontWeight(.bold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct AnalyticsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    ReportsView()
        .environmentObject(QuotationManager())
}