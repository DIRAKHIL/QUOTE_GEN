//
//  AIRecommendationEngine.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import Foundation

class AIRecommendationEngine {
    static let shared = AIRecommendationEngine()
    
    private init() {}
    
    // MARK: - Service Recommendations
    func getRecommendedServices(for eventType: EventType, guestCount: Int, budget: Double? = nil, venue: String = "") -> [ServiceRecommendation] {
        let allServices = ServiceDataProvider.shared.getAllServices()
        var recommendations: [ServiceRecommendation] = []
        
        switch eventType {
        case .wedding:
            recommendations = getTeluguWeddingRecommendations(allServices, guestCount: guestCount, budget: budget)
        case .engagement:
            recommendations = getEngagementRecommendations(allServices, guestCount: guestCount, budget: budget)
        case .haldi:
            recommendations = getHaldiRecommendations(allServices, guestCount: guestCount)
        case .mehendi:
            recommendations = getMehendiRecommendations(allServices, guestCount: guestCount)
        case .sangeet:
            recommendations = getSangeetRecommendations(allServices, guestCount: guestCount)
        case .reception:
            recommendations = getReceptionRecommendations(allServices, guestCount: guestCount, budget: budget)
        case .naming:
            recommendations = getNamingCeremonyRecommendations(allServices, guestCount: guestCount)
        default:
            recommendations = getGeneralEventRecommendations(allServices, guestCount: guestCount, budget: budget)
        }
        
        // Apply venue-specific recommendations
        if !venue.isEmpty {
            recommendations = applyVenueSpecificRecommendations(recommendations, venue: venue)
        }
        
        return recommendations.sorted { $0.priority > $1.priority }
    }
    
    // MARK: - Telugu Wedding Specific Recommendations
    private func getTeluguWeddingRecommendations(_ services: [ServiceItem], guestCount: Int, budget: Double?) -> [ServiceRecommendation] {
        var recommendations: [ServiceRecommendation] = []
        
        // Essential Telugu wedding services (High Priority)
        let essentialServices = [
            "Traditional Telugu Mandap",
            "Nadaswaram & Thavil",
            "Telugu Traditional Meals",
            "Purohit/Priest",
            "Traditional Wedding Photography",
            "Bridal Flower Jewelry",
            "Sacred Fire Setup",
            "Garland Exchange"
        ]
        
        for serviceName in essentialServices {
            if let service = services.first(where: { $0.name.contains(serviceName) }) {
                recommendations.append(ServiceRecommendation(
                    service: service,
                    priority: .high,
                    reason: "Essential for Telugu wedding traditions",
                    suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                    estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                ))
            }
        }
        
        // Recommended services based on guest count
        if guestCount > 200 {
            let largeWeddingServices = [
                "Kalyanam Mandap with Pillars",
                "4K Cinematic Videography",
                "Live Streaming Setup",
                "Generator Backup",
                "Security Personnel",
                "Guest Transportation"
            ]
            
            for serviceName in largeWeddingServices {
                if let service = services.first(where: { $0.name.contains(serviceName) }) {
                    recommendations.append(ServiceRecommendation(
                        service: service,
                        priority: .medium,
                        reason: "Recommended for large weddings (\(guestCount) guests)",
                        suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                        estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                    ))
                }
            }
        }
        
        // Budget-based recommendations
        if let budget = budget, budget > 500000 {
            let premiumServices = [
                "Elephant for Procession",
                "Horse for Groom Entry",
                "Drone Photography",
                "Live Band Performance",
                "Classical Dance Performance"
            ]
            
            for serviceName in premiumServices {
                if let service = services.first(where: { $0.name.contains(serviceName) }) {
                    recommendations.append(ServiceRecommendation(
                        service: service,
                        priority: .low,
                        reason: "Premium addition for grand celebrations",
                        suggestedQuantity: 1,
                        estimatedCost: service.basePrice
                    ))
                }
            }
        }
        
        return recommendations
    }
    
    // MARK: - Other Event Type Recommendations
    private func getEngagementRecommendations(_ services: [ServiceItem], guestCount: Int, budget: Double?) -> [ServiceRecommendation] {
        var recommendations: [ServiceRecommendation] = []
        
        let engagementServices = [
            "Stage Decoration",
            "Candid Photography",
            "DJ with Sound System",
            "Cocktail Snacks",
            "Return Gifts",
            "Anchor/MC Services"
        ]
        
        for serviceName in engagementServices {
            if let service = services.first(where: { $0.name.contains(serviceName) }) {
                recommendations.append(ServiceRecommendation(
                    service: service,
                    priority: .high,
                    reason: "Essential for engagement ceremony",
                    suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                    estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                ))
            }
        }
        
        return recommendations
    }
    
    private func getHaldiRecommendations(_ services: [ServiceItem], guestCount: Int) -> [ServiceRecommendation] {
        var recommendations: [ServiceRecommendation] = []
        
        let haldiServices = [
            "Haldi Ceremony Setup",
            "Marigold Decoration",
            "Traditional Wedding Photography",
            "Jasmine Strings",
            "Rangoli Design"
        ]
        
        for serviceName in haldiServices {
            if let service = services.first(where: { $0.name.contains(serviceName) }) {
                recommendations.append(ServiceRecommendation(
                    service: service,
                    priority: .high,
                    reason: "Traditional haldi ceremony essential",
                    suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                    estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                ))
            }
        }
        
        return recommendations
    }
    
    private func getMehendiRecommendations(_ services: [ServiceItem], guestCount: Int) -> [ServiceRecommendation] {
        var recommendations: [ServiceRecommendation] = []
        
        let mehendiServices = [
            "Mehendi Artist",
            "Stage Decoration",
            "DJ with Sound System",
            "Cocktail Snacks",
            "Candid Photography"
        ]
        
        for serviceName in mehendiServices {
            if let service = services.first(where: { $0.name.contains(serviceName) }) {
                recommendations.append(ServiceRecommendation(
                    service: service,
                    priority: .high,
                    reason: "Essential for mehendi ceremony",
                    suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                    estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                ))
            }
        }
        
        return recommendations
    }
    
    private func getSangeetRecommendations(_ services: [ServiceItem], guestCount: Int) -> [ServiceRecommendation] {
        var recommendations: [ServiceRecommendation] = []
        
        let sangeetServices = [
            "DJ with Sound System",
            "Professional Lighting",
            "Stage Decoration",
            "Live Band Performance",
            "Anchor/MC Services",
            "4K Cinematic Videography"
        ]
        
        for serviceName in sangeetServices {
            if let service = services.first(where: { $0.name.contains(serviceName) }) {
                recommendations.append(ServiceRecommendation(
                    service: service,
                    priority: .high,
                    reason: "Essential for sangeet night entertainment",
                    suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                    estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                ))
            }
        }
        
        return recommendations
    }
    
    private func getReceptionRecommendations(_ services: [ServiceItem], guestCount: Int, budget: Double?) -> [ServiceRecommendation] {
        var recommendations: [ServiceRecommendation] = []
        
        let receptionServices = [
            "Stage Decoration",
            "LED Screen Rental",
            "Professional Lighting",
            "DJ with Sound System",
            "Candid Photography",
            "4K Cinematic Videography"
        ]
        
        for serviceName in receptionServices {
            if let service = services.first(where: { $0.name.contains(serviceName) }) {
                recommendations.append(ServiceRecommendation(
                    service: service,
                    priority: .high,
                    reason: "Essential for reception ceremony",
                    suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                    estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                ))
            }
        }
        
        return recommendations
    }
    
    private func getNamingCeremonyRecommendations(_ services: [ServiceItem], guestCount: Int) -> [ServiceRecommendation] {
        var recommendations: [ServiceRecommendation] = []
        
        let namingServices = [
            "Purohit/Priest",
            "Traditional Wedding Photography",
            "Sweet Counter",
            "Kalash Decoration",
            "Ashtamangala Items"
        ]
        
        for serviceName in namingServices {
            if let service = services.first(where: { $0.name.contains(serviceName) }) {
                recommendations.append(ServiceRecommendation(
                    service: service,
                    priority: .high,
                    reason: "Traditional naming ceremony essential",
                    suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                    estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                ))
            }
        }
        
        return recommendations
    }
    
    private func getGeneralEventRecommendations(_ services: [ServiceItem], guestCount: Int, budget: Double?) -> [ServiceRecommendation] {
        var recommendations: [ServiceRecommendation] = []
        
        let generalServices = [
            "Event Coordinator",
            "Photography",
            "Sound System",
            "Catering"
        ]
        
        for serviceName in generalServices {
            if let service = services.first(where: { $0.name.contains(serviceName) }) {
                recommendations.append(ServiceRecommendation(
                    service: service,
                    priority: .medium,
                    reason: "General event requirement",
                    suggestedQuantity: getSuggestedQuantity(for: service, guestCount: guestCount),
                    estimatedCost: service.basePrice * Double(getSuggestedQuantity(for: service, guestCount: guestCount))
                ))
            }
        }
        
        return recommendations
    }
    
    // MARK: - Venue-Specific Recommendations
    private func applyVenueSpecificRecommendations(_ recommendations: [ServiceRecommendation], venue: String) -> [ServiceRecommendation] {
        var updatedRecommendations = recommendations
        let allServices = ServiceDataProvider.shared.getAllServices()
        
        let venueLower = venue.lowercased()
        
        // Outdoor venue recommendations
        if venueLower.contains("garden") || venueLower.contains("outdoor") || venueLower.contains("lawn") {
            let outdoorServices = ["Generator Backup", "AC & Cooling", "Professional Lighting"]
            
            for serviceName in outdoorServices {
                if let service = allServices.first(where: { $0.name.contains(serviceName) }),
                   !updatedRecommendations.contains(where: { $0.service.id == service.id }) {
                    updatedRecommendations.append(ServiceRecommendation(
                        service: service,
                        priority: .high,
                        reason: "Essential for outdoor venue",
                        suggestedQuantity: 1,
                        estimatedCost: service.basePrice
                    ))
                }
            }
        }
        
        // Hotel/Banquet hall recommendations
        if venueLower.contains("hotel") || venueLower.contains("banquet") || venueLower.contains("hall") {
            let indoorServices = ["LED Screen Rental", "Professional Lighting"]
            
            for serviceName in indoorServices {
                if let service = allServices.first(where: { $0.name.contains(serviceName) }),
                   !updatedRecommendations.contains(where: { $0.service.id == service.id }) {
                    updatedRecommendations.append(ServiceRecommendation(
                        service: service,
                        priority: .medium,
                        reason: "Enhances indoor venue experience",
                        suggestedQuantity: 1,
                        estimatedCost: service.basePrice
                    ))
                }
            }
        }
        
        return updatedRecommendations
    }
    
    // MARK: - Quantity Suggestions
    private func getSuggestedQuantity(for service: ServiceItem, guestCount: Int) -> Int {
        switch service.category {
        case .catering:
            return guestCount
        case .staffing:
            if service.name.contains("Waitstaff") {
                return max(1, guestCount / 20) // 1 waiter per 20 guests
            } else if service.name.contains("Security") {
                return max(1, guestCount / 100) // 1 security per 100 guests
            }
            return 1
        case .transportation:
            if service.name.contains("Bus") {
                return max(1, guestCount / 50) // 1 bus per 50 guests
            }
            return 1
        case .flowers:
            if service.name.contains("Rose Petals") {
                return max(1, guestCount / 100) // 1 kg per 100 guests
            }
            return 1
        default:
            return 1
        }
    }
    
    // MARK: - Seasonal Recommendations
    func getSeasonalRecommendations(for date: Date) -> [String] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        
        switch month {
        case 3...5: // Summer (March-May)
            return [
                "AC & Cooling arrangements are essential",
                "Consider indoor venues or covered areas",
                "Increase water and cooling arrangements",
                "Schedule events during cooler hours"
            ]
        case 6...9: // Monsoon (June-September)
            return [
                "Covered venue is mandatory",
                "Generator backup recommended",
                "Waterproof decorations needed",
                "Indoor photography backup plan"
            ]
        case 10...2: // Winter (October-February)
            return [
                "Perfect weather for outdoor events",
                "Garden venues highly recommended",
                "Extended event hours possible",
                "Ideal for traditional ceremonies"
            ]
        default:
            return []
        }
    }
    
    // MARK: - Budget Optimization
    func optimizeBudget(_ recommendations: [ServiceRecommendation], targetBudget: Double) -> [ServiceRecommendation] {
        let totalCost = recommendations.reduce(0) { $0 + $1.estimatedCost }
        
        if totalCost <= targetBudget {
            return recommendations
        }
        
        // Prioritize high-priority items first
        let highPriority = recommendations.filter { $0.priority == .high }
        let mediumPriority = recommendations.filter { $0.priority == .medium }
        let lowPriority = recommendations.filter { $0.priority == .low }
        
        var optimizedRecommendations: [ServiceRecommendation] = []
        var currentBudget = targetBudget
        
        // Add high priority items first
        for recommendation in highPriority {
            if currentBudget >= recommendation.estimatedCost {
                optimizedRecommendations.append(recommendation)
                currentBudget -= recommendation.estimatedCost
            }
        }
        
        // Add medium priority items if budget allows
        for recommendation in mediumPriority {
            if currentBudget >= recommendation.estimatedCost {
                optimizedRecommendations.append(recommendation)
                currentBudget -= recommendation.estimatedCost
            }
        }
        
        // Add low priority items if budget allows
        for recommendation in lowPriority {
            if currentBudget >= recommendation.estimatedCost {
                optimizedRecommendations.append(recommendation)
                currentBudget -= recommendation.estimatedCost
            }
        }
        
        return optimizedRecommendations
    }
}

// MARK: - Supporting Models
struct ServiceRecommendation: Identifiable {
    let id = UUID()
    let service: ServiceItem
    let priority: RecommendationPriority
    let reason: String
    let suggestedQuantity: Int
    let estimatedCost: Double
}

enum RecommendationPriority: Int, CaseIterable {
    case high = 3
    case medium = 2
    case low = 1
    
    var displayName: String {
        switch self {
        case .high: return "Essential"
        case .medium: return "Recommended"
        case .low: return "Optional"
        }
    }
    
    var color: String {
        switch self {
        case .high: return "red"
        case .medium: return "orange"
        case .low: return "green"
        }
    }
}