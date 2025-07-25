//
//  QuotationManager.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import Foundation
import Combine

class QuotationManager: ObservableObject {
    @Published var quotations: [Quotation] = []
    @Published var currentQuotation: Quotation?
    
    private let userDefaults = UserDefaults.standard
    private let quotationsKey = "SavedQuotations"
    
    init() {
        loadQuotations()
    }
    
    // MARK: - Quotation Management
    func createNewQuotation() -> Quotation {
        let newQuotation = Quotation(
            clientName: "",
            clientPhone: "",
            clientEmail: "",
            eventType: .wedding,
            eventDate: Date(),
            venue: "",
            guestCount: 100,
            items: [],
            discountPercentage: 0,
            additionalFees: 0,
            taxPercentage: 18, // Standard GST rate in India
            notes: "",
            createdDate: Date(),
            isFinalized: false
        )
        return newQuotation
    }
    
    func saveQuotation(_ quotation: Quotation) {
        if let index = quotations.firstIndex(where: { $0.id == quotation.id }) {
            quotations[index] = quotation
        } else {
            quotations.append(quotation)
        }
        saveQuotations()
    }
    
    func deleteQuotation(_ quotation: Quotation) {
        quotations.removeAll { $0.id == quotation.id }
        if currentQuotation?.id == quotation.id {
            currentQuotation = nil
        }
        saveQuotations()
    }
    
    func duplicateQuotation(_ quotation: Quotation) -> Quotation {
        var newQuotation = quotation
        newQuotation = Quotation(
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
        quotations.append(newQuotation)
        saveQuotations()
        return newQuotation
    }
    
    // MARK: - Quote Items Management
    func addItemToQuotation(_ serviceItem: ServiceItem, quantity: Int = 1) {
        guard var quotation = currentQuotation else { return }
        
        let quoteItem = QuoteItem(
            serviceItem: serviceItem,
            quantity: quantity,
            customPrice: nil,
            notes: ""
        )
        
        quotation.items.append(quoteItem)
        currentQuotation = quotation
        saveQuotation(quotation)
    }
    
    func updateQuoteItem(_ quoteItem: QuoteItem) {
        guard var quotation = currentQuotation else { return }
        
        if let index = quotation.items.firstIndex(where: { $0.id == quoteItem.id }) {
            quotation.items[index] = quoteItem
            currentQuotation = quotation
            saveQuotation(quotation)
        }
    }
    
    func removeItemFromQuotation(_ quoteItem: QuoteItem) {
        guard var quotation = currentQuotation else { return }
        
        quotation.items.removeAll { $0.id == quoteItem.id }
        currentQuotation = quotation
        saveQuotation(quotation)
    }
    
    // MARK: - Pricing Calculations
    func calculateSubtotal(for quotation: Quotation) -> Double {
        return quotation.subtotal
    }
    
    func calculateDiscount(for quotation: Quotation) -> Double {
        return quotation.discountAmount
    }
    
    func calculateTax(for quotation: Quotation) -> Double {
        return quotation.taxAmount
    }
    
    func calculateGrandTotal(for quotation: Quotation) -> Double {
        return quotation.grandTotal
    }
    
    // MARK: - Regional Pricing Adjustments
    func getRegionalPriceMultiplier(for city: String) -> Double {
        let cityLower = city.lowercased()
        
        // Tier 1 cities (Higher pricing)
        if cityLower.contains("hyderabad") || cityLower.contains("secunderabad") ||
           cityLower.contains("visakhapatnam") || cityLower.contains("vijayawada") {
            return 1.2
        }
        
        // Tier 2 cities (Standard pricing)
        if cityLower.contains("guntur") || cityLower.contains("nellore") ||
           cityLower.contains("tirupati") || cityLower.contains("kakinada") ||
           cityLower.contains("rajahmundry") || cityLower.contains("warangal") ||
           cityLower.contains("nizamabad") || cityLower.contains("karimnagar") {
            return 1.0
        }
        
        // Tier 3 cities and rural areas (Lower pricing)
        return 0.8
    }
    
    func applyRegionalPricing(to quotation: Quotation, city: String) {
        guard var currentQuot = currentQuotation else { return }
        let multiplier = getRegionalPriceMultiplier(for: city)
        
        for i in 0..<currentQuot.items.count {
            let originalPrice = currentQuot.items[i].serviceItem.basePrice
            currentQuot.items[i].customPrice = originalPrice * multiplier
        }
        
        currentQuotation = currentQuot
        saveQuotation(currentQuot)
    }
    
    // MARK: - Data Persistence
    private func saveQuotations() {
        do {
            let data = try JSONEncoder().encode(quotations)
            userDefaults.set(data, forKey: quotationsKey)
        } catch {
            print("Failed to save quotations: \(error)")
        }
    }
    
    private func loadQuotations() {
        guard let data = userDefaults.data(forKey: quotationsKey) else { 
            quotations = []
            return 
        }
        
        do {
            quotations = try JSONDecoder().decode([Quotation].self, from: data)
        } catch {
            print("Failed to load quotations: \(error)")
            quotations = []
        }
    }
    
    // MARK: - Export Functionality
    func generateQuotationText(_ quotation: Quotation) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        
        let currencyFormatter = NumberFormatter()
        currencyFormatter.numberStyle = .currency
        currencyFormatter.currencyCode = "INR"
        currencyFormatter.locale = Locale(identifier: "en_IN")
        
        var text = """
        ═══════════════════════════════════════════════════════════════
                            S-QUOTE EVENT PLANNER
                         Telugu Wedding Specialists
        ═══════════════════════════════════════════════════════════════
        
        QUOTATION DETAILS
        ─────────────────────────────────────────────────────────────
        Quote ID: \(quotation.id.uuidString.prefix(8))
        Date: \(formatter.string(from: quotation.createdDate))
        
        CLIENT INFORMATION
        ─────────────────────────────────────────────────────────────
        Name: \(quotation.clientName)
        Phone: \(quotation.clientPhone)
        Email: \(quotation.clientEmail)
        
        EVENT DETAILS
        ─────────────────────────────────────────────────────────────
        Event Type: \(quotation.eventType.rawValue) (\(quotation.eventType.teluguName))
        Date: \(formatter.string(from: quotation.eventDate))
        Venue: \(quotation.venue)
        Expected Guests: \(quotation.guestCount)
        
        SERVICES & PRICING
        ═══════════════════════════════════════════════════════════════
        
        """
        
        // Group items by category
        let groupedItems = Dictionary(grouping: quotation.items) { $0.serviceItem.category }
        
        for category in ServiceCategory.allCases {
            if let items = groupedItems[category], !items.isEmpty {
                text += "\n\(category.rawValue.uppercased())\n"
                text += String(repeating: "─", count: 65) + "\n"
                
                for item in items {
                    let price = item.customPrice ?? item.serviceItem.basePrice
                    let total = price * Double(item.quantity)
                    
                    text += String(format: "%-40s %3d x %8s = %10s\n",
                                 item.serviceItem.name,
                                 item.quantity,
                                 currencyFormatter.string(from: NSNumber(value: price)) ?? "₹0",
                                 currencyFormatter.string(from: NSNumber(value: total)) ?? "₹0")
                    
                    if !item.notes.isEmpty {
                        text += "  Note: \(item.notes)\n"
                    }
                }
            }
        }
        
        text += """
        
        ═══════════════════════════════════════════════════════════════
        PRICING SUMMARY
        ─────────────────────────────────────────────────────────────
        Subtotal:                                    \(currencyFormatter.string(from: NSNumber(value: quotation.subtotal)) ?? "₹0")
        Discount (\(String(format: "%.1f", quotation.discountPercentage))%):                              -\(currencyFormatter.string(from: NSNumber(value: quotation.discountAmount)) ?? "₹0")
        After Discount:                              \(currencyFormatter.string(from: NSNumber(value: quotation.afterDiscount)) ?? "₹0")
        Additional Fees:                             \(currencyFormatter.string(from: NSNumber(value: quotation.additionalFees)) ?? "₹0")
        GST (\(String(format: "%.1f", quotation.taxPercentage))%):                                   \(currencyFormatter.string(from: NSNumber(value: quotation.taxAmount)) ?? "₹0")
        ─────────────────────────────────────────────────────────────
        GRAND TOTAL:                                 \(currencyFormatter.string(from: NSNumber(value: quotation.grandTotal)) ?? "₹0")
        ═══════════════════════════════════════════════════════════════
        
        """
        
        if !quotation.notes.isEmpty {
            text += """
            ADDITIONAL NOTES
            ─────────────────────────────────────────────────────────────
            \(quotation.notes)
            
            """
        }
        
        text += """
        TERMS & CONDITIONS
        ─────────────────────────────────────────────────────────────
        • 50% advance payment required to confirm booking
        • Final payment due 7 days before event date
        • Prices are subject to change based on final requirements
        • Cancellation charges apply as per company policy
        • All prices include GST as mentioned
        • Traditional Telugu customs and rituals included
        
        ═══════════════════════════════════════════════════════════════
        Contact: +91-XXXXX-XXXXX | Email: info@squote.com
        Specializing in Telugu Weddings | Andhra Pradesh & Telangana
        ═══════════════════════════════════════════════════════════════
        """
        
        return text
    }
    
    // MARK: - Search and Filter
    func searchQuotations(query: String) -> [Quotation] {
        if query.isEmpty {
            return quotations
        }
        
        return quotations.filter { quotation in
            quotation.clientName.localizedCaseInsensitiveContains(query) ||
            quotation.eventType.rawValue.localizedCaseInsensitiveContains(query) ||
            quotation.venue.localizedCaseInsensitiveContains(query)
        }
    }
    
    func getQuotationsByEventType(_ eventType: EventType) -> [Quotation] {
        return quotations.filter { $0.eventType == eventType }
    }
    
    func getQuotationsByDateRange(from startDate: Date, to endDate: Date) -> [Quotation] {
        return quotations.filter { quotation in
            quotation.eventDate >= startDate && quotation.eventDate <= endDate
        }
    }
    
    // MARK: - Statistics
    func getTotalRevenue() -> Double {
        return quotations.filter { $0.isFinalized }.reduce(0) { $0 + $1.grandTotal }
    }
    
    func getAverageQuotationValue() -> Double {
        let finalizedQuotations = quotations.filter { $0.isFinalized }
        guard !finalizedQuotations.isEmpty else { return 0 }
        return getTotalRevenue() / Double(finalizedQuotations.count)
    }
    
    func getMostPopularServices() -> [ServiceItem] {
        var serviceCount: [String: Int] = [:]
        
        for quotation in quotations {
            for item in quotation.items {
                serviceCount[item.serviceItem.name, default: 0] += item.quantity
            }
        }
        
        let sortedServices = serviceCount.sorted { $0.value > $1.value }
        let allServices = ServiceDataProvider.shared.getAllServices()
        
        return sortedServices.compactMap { serviceName, _ in
            allServices.first { $0.name == serviceName }
        }.prefix(10).map { $0 }
    }
}