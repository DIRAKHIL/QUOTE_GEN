//
//  Models.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import Foundation

// MARK: - Service Category Enum
enum ServiceCategory: String, CaseIterable, Identifiable, Codable {
    case photography = "Photography & Videography"
    case decoration = "Decoration & Mandap"
    case catering = "Catering & Food"
    case entertainment = "Entertainment & Music"
    case venue = "Venue & Facilities"
    case transportation = "Transportation"
    case flowers = "Flowers & Garlands"
    case staffing = "Staffing & Coordination"
    case traditional = "Traditional Services"
    case equipment = "Equipment & Technology"
    case gifts = "Gifts & Favors"
    case beauty = "Beauty & Grooming"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .photography: return "camera.fill"
        case .decoration: return "sparkles"
        case .catering: return "fork.knife"
        case .entertainment: return "music.note"
        case .venue: return "building.2.fill"
        case .transportation: return "car.fill"
        case .flowers: return "leaf.fill"
        case .staffing: return "person.3.fill"
        case .traditional: return "star.fill"
        case .equipment: return "speaker.wave.3.fill"
        case .gifts: return "gift.fill"
        case .beauty: return "paintbrush.fill"
        }
    }
}

// MARK: - Service Item Model
struct ServiceItem: Identifiable, Codable, Hashable {
    let id = UUID()
    let name: String
    let category: ServiceCategory
    let basePrice: Double
    let unit: String
    let description: String
    let isTeluguSpecific: Bool
    
    enum CodingKeys: String, CodingKey {
        case name, category, basePrice, unit, description, isTeluguSpecific
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
        hasher.combine(category)
        hasher.combine(basePrice)
    }
    
    static func == (lhs: ServiceItem, rhs: ServiceItem) -> Bool {
        return lhs.name == rhs.name && lhs.category == rhs.category && lhs.basePrice == rhs.basePrice
    }
}

// MARK: - Quote Item Model
struct QuoteItem: Identifiable, Codable {
    let id = UUID()
    let serviceItem: ServiceItem
    var quantity: Int
    var customPrice: Double?
    var notes: String
    
    var totalPrice: Double {
        let price = customPrice ?? serviceItem.basePrice
        return price * Double(quantity)
    }
    
    enum CodingKeys: String, CodingKey {
        case serviceItem, quantity, customPrice, notes
    }
}

// MARK: - Event Type Enum
enum EventType: String, CaseIterable, Identifiable, Codable {
    case wedding = "Telugu Wedding"
    case engagement = "Engagement (Nischitartham)"
    case haldi = "Haldi Ceremony"
    case mehendi = "Mehendi Ceremony"
    case sangeet = "Sangeet Night"
    case reception = "Reception"
    case housewarming = "Griha Pravesh"
    case birthday = "Birthday Celebration"
    case anniversary = "Anniversary"
    case corporate = "Corporate Event"
    case festival = "Festival Celebration"
    case naming = "Naming Ceremony (Namakaranam)"
    
    var id: String { self.rawValue }
    
    var teluguName: String {
        switch self {
        case .wedding: return "వివాహం"
        case .engagement: return "నిశ్చితార్థం"
        case .haldi: return "హల్దీ"
        case .mehendi: return "మెహెందీ"
        case .sangeet: return "సంగీత్"
        case .reception: return "రిసెప్షన్"
        case .housewarming: return "గృహప్రవేశం"
        case .birthday: return "పుట్టినరోజు"
        case .anniversary: return "వార్షికోత్సవం"
        case .corporate: return "కార్పొరేట్ ఈవెంట్"
        case .festival: return "పండుగ"
        case .naming: return "నామకరణం"
        }
    }
}

// MARK: - Quotation Model
struct Quotation: Identifiable, Codable {
    let id = UUID()
    var clientName: String
    var clientPhone: String
    var clientEmail: String
    var eventType: EventType
    var eventDate: Date
    var venue: String
    var guestCount: Int
    var items: [QuoteItem]
    var discountPercentage: Double
    var additionalFees: Double
    var taxPercentage: Double
    var notes: String
    var createdDate: Date
    var isFinalized: Bool
    
    var subtotal: Double {
        items.reduce(0) { $0 + $1.totalPrice }
    }
    
    var discountAmount: Double {
        subtotal * (discountPercentage / 100)
    }
    
    var afterDiscount: Double {
        subtotal - discountAmount
    }
    
    var taxAmount: Double {
        (afterDiscount + additionalFees) * (taxPercentage / 100)
    }
    
    var grandTotal: Double {
        afterDiscount + additionalFees + taxAmount
    }
    
    enum CodingKeys: String, CodingKey {
        case clientName, clientPhone, clientEmail, eventType, eventDate, venue, guestCount
        case items, discountPercentage, additionalFees, taxPercentage, notes, createdDate, isFinalized
    }
}

// MARK: - Service Data Provider
class ServiceDataProvider {
    static let shared = ServiceDataProvider()
    
    private init() {}
    
    func getAllServices() -> [ServiceItem] {
        var allServices = getBasicServices()
        allServices.append(contentsOf: getEnhancedTeluguServices())
        return allServices
    }
    
    private func getBasicServices() -> [ServiceItem] {
        return [
            // Photography & Videography
            ServiceItem(name: "Traditional Wedding Photography", category: .photography, basePrice: 25000, unit: "per day", description: "Complete traditional Telugu wedding photography with all rituals", isTeluguSpecific: true),
            ServiceItem(name: "Candid Photography", category: .photography, basePrice: 35000, unit: "per day", description: "Candid moments capture throughout the event", isTeluguSpecific: false),
            ServiceItem(name: "4K Cinematic Videography", category: .photography, basePrice: 45000, unit: "per day", description: "Professional 4K video recording with cinematic editing", isTeluguSpecific: false),
            ServiceItem(name: "Drone Photography", category: .photography, basePrice: 15000, unit: "per day", description: "Aerial shots and drone videography", isTeluguSpecific: false),
            ServiceItem(name: "Wedding Album (Premium)", category: .photography, basePrice: 12000, unit: "per album", description: "Premium quality wedding album with 50 pages", isTeluguSpecific: false),
            ServiceItem(name: "Live Streaming Setup", category: .photography, basePrice: 8000, unit: "per event", description: "Live streaming for remote family members", isTeluguSpecific: false),
            
            // Decoration & Mandap
            ServiceItem(name: "Traditional Telugu Mandap", category: .decoration, basePrice: 75000, unit: "per setup", description: "Authentic Telugu style mandap with traditional decorations", isTeluguSpecific: true),
            ServiceItem(name: "Kalyanam Mandap with Pillars", category: .decoration, basePrice: 95000, unit: "per setup", description: "Grand mandap with carved pillars and traditional motifs", isTeluguSpecific: true),
            ServiceItem(name: "Stage Decoration", category: .decoration, basePrice: 35000, unit: "per stage", description: "Reception stage decoration with flowers and lights", isTeluguSpecific: false),
            ServiceItem(name: "Entrance Gate Decoration", category: .decoration, basePrice: 25000, unit: "per gate", description: "Grand entrance decoration with welcome arch", isTeluguSpecific: false),
            ServiceItem(name: "LED Backdrop", category: .decoration, basePrice: 18000, unit: "per setup", description: "LED screen backdrop for stage", isTeluguSpecific: false),
            ServiceItem(name: "Ceiling Draping", category: .decoration, basePrice: 22000, unit: "per hall", description: "Elegant ceiling decoration with fabric draping", isTeluguSpecific: false),
            ServiceItem(name: "Rangoli Design", category: .decoration, basePrice: 3000, unit: "per design", description: "Traditional rangoli patterns for entrance", isTeluguSpecific: true),
            
            // Catering & Food
            ServiceItem(name: "Telugu Traditional Meals", category: .catering, basePrice: 450, unit: "per person", description: "Authentic Telugu cuisine with traditional items", isTeluguSpecific: true),
            ServiceItem(name: "Andhra Spicy Menu", category: .catering, basePrice: 500, unit: "per person", description: "Spicy Andhra style dishes and curries", isTeluguSpecific: true),
            ServiceItem(name: "Hyderabadi Biryani", category: .catering, basePrice: 350, unit: "per person", description: "Authentic Hyderabadi biryani with raita and shorba", isTeluguSpecific: true),
            ServiceItem(name: "South Indian Breakfast", category: .catering, basePrice: 180, unit: "per person", description: "Traditional breakfast with idli, dosa, vada", isTeluguSpecific: true),
            ServiceItem(name: "Cocktail Snacks", category: .catering, basePrice: 250, unit: "per person", description: "Variety of cocktail snacks and appetizers", isTeluguSpecific: false),
            ServiceItem(name: "Sweet Counter", category: .catering, basePrice: 150, unit: "per person", description: "Traditional sweets including laddu, mysore pak", isTeluguSpecific: true),
            ServiceItem(name: "Live Dosa Counter", category: .catering, basePrice: 8000, unit: "per counter", description: "Live dosa making station", isTeluguSpecific: true),
            ServiceItem(name: "Paan Counter", category: .catering, basePrice: 5000, unit: "per counter", description: "Traditional paan serving counter", isTeluguSpecific: true),
            
            // Entertainment & Music
            ServiceItem(name: "Nadaswaram & Thavil", category: .entertainment, basePrice: 12000, unit: "per day", description: "Traditional Telugu wedding music ensemble", isTeluguSpecific: true),
            ServiceItem(name: "DJ with Sound System", category: .entertainment, basePrice: 25000, unit: "per day", description: "Professional DJ with high-quality sound system", isTeluguSpecific: false),
            ServiceItem(name: "Live Band Performance", category: .entertainment, basePrice: 35000, unit: "per performance", description: "Live music band for entertainment", isTeluguSpecific: false),
            ServiceItem(name: "Dhol Players", category: .entertainment, basePrice: 8000, unit: "per group", description: "Traditional dhol players for baraat", isTeluguSpecific: true),
            ServiceItem(name: "Classical Dance Performance", category: .entertainment, basePrice: 15000, unit: "per performance", description: "Bharatanatyam or Kuchipudi dance performance", isTeluguSpecific: true),
            ServiceItem(name: "Anchor/MC Services", category: .entertainment, basePrice: 10000, unit: "per day", description: "Professional event hosting and coordination", isTeluguSpecific: false),
            
            // Venue & Facilities
            ServiceItem(name: "Wedding Hall Rental", category: .venue, basePrice: 50000, unit: "per day", description: "Traditional wedding hall with basic facilities", isTeluguSpecific: false),
            ServiceItem(name: "Kalyana Mandapam", category: .venue, basePrice: 75000, unit: "per day", description: "Traditional Telugu wedding venue", isTeluguSpecific: true),
            ServiceItem(name: "Garden Venue", category: .venue, basePrice: 40000, unit: "per day", description: "Outdoor garden venue for ceremonies", isTeluguSpecific: false),
            ServiceItem(name: "AC & Cooling", category: .venue, basePrice: 15000, unit: "per day", description: "Air conditioning and cooling arrangements", isTeluguSpecific: false),
            ServiceItem(name: "Generator Backup", category: .venue, basePrice: 8000, unit: "per day", description: "Power backup generator", isTeluguSpecific: false),
            ServiceItem(name: "Parking Arrangements", category: .venue, basePrice: 5000, unit: "per day", description: "Valet parking and security", isTeluguSpecific: false),
            
            // Transportation
            ServiceItem(name: "Decorated Car for Couple", category: .transportation, basePrice: 8000, unit: "per day", description: "Luxury car decoration for bride and groom", isTeluguSpecific: false),
            ServiceItem(name: "Horse for Groom Entry", category: .transportation, basePrice: 12000, unit: "per event", description: "Traditional horse for groom's grand entry", isTeluguSpecific: true),
            ServiceItem(name: "Elephant for Procession", category: .transportation, basePrice: 25000, unit: "per event", description: "Decorated elephant for traditional procession", isTeluguSpecific: true),
            ServiceItem(name: "Guest Transportation", category: .transportation, basePrice: 15000, unit: "per bus", description: "Bus transportation for guests", isTeluguSpecific: false),
            ServiceItem(name: "Vintage Car Rental", category: .transportation, basePrice: 20000, unit: "per day", description: "Classic vintage car for special occasions", isTeluguSpecific: false),
            
            // Flowers & Garlands
            ServiceItem(name: "Bridal Flower Jewelry", category: .flowers, basePrice: 8000, unit: "per set", description: "Traditional flower jewelry for bride", isTeluguSpecific: true),
            ServiceItem(name: "Groom's Sehra", category: .flowers, basePrice: 3000, unit: "per piece", description: "Traditional flower sehra for groom", isTeluguSpecific: true),
            ServiceItem(name: "Garland Exchange", category: .flowers, basePrice: 2500, unit: "per pair", description: "Special garlands for exchange ceremony", isTeluguSpecific: true),
            ServiceItem(name: "Rose Petals", category: .flowers, basePrice: 5000, unit: "per kg", description: "Fresh rose petals for ceremonies", isTeluguSpecific: false),
            ServiceItem(name: "Marigold Decoration", category: .flowers, basePrice: 12000, unit: "per setup", description: "Marigold flower decorations", isTeluguSpecific: true),
            ServiceItem(name: "Jasmine Strings", category: .flowers, basePrice: 1500, unit: "per string", description: "Traditional jasmine flower strings", isTeluguSpecific: true),
            
            // Staffing & Coordination
            ServiceItem(name: "Wedding Coordinator", category: .staffing, basePrice: 15000, unit: "per day", description: "Professional wedding planning and coordination", isTeluguSpecific: false),
            ServiceItem(name: "Waitstaff", category: .staffing, basePrice: 1500, unit: "per person/day", description: "Professional serving staff", isTeluguSpecific: false),
            ServiceItem(name: "Security Personnel", category: .staffing, basePrice: 2000, unit: "per person/day", description: "Event security and crowd management", isTeluguSpecific: false),
            ServiceItem(name: "Makeup Artist", category: .staffing, basePrice: 12000, unit: "per session", description: "Professional bridal makeup", isTeluguSpecific: false),
            ServiceItem(name: "Mehendi Artist", category: .staffing, basePrice: 8000, unit: "per session", description: "Traditional mehendi application", isTeluguSpecific: true),
            ServiceItem(name: "Purohit/Priest", category: .staffing, basePrice: 5000, unit: "per ceremony", description: "Traditional Telugu wedding priest", isTeluguSpecific: true),
            
            // Traditional Services
            ServiceItem(name: "Mangalsutra Making", category: .traditional, basePrice: 15000, unit: "per piece", description: "Custom mangalsutra creation", isTeluguSpecific: true),
            ServiceItem(name: "Haldi Ceremony Setup", category: .traditional, basePrice: 8000, unit: "per setup", description: "Traditional haldi ceremony arrangements", isTeluguSpecific: true),
            ServiceItem(name: "Kalash Decoration", category: .traditional, basePrice: 3000, unit: "per kalash", description: "Decorated kalash for ceremonies", isTeluguSpecific: true),
            ServiceItem(name: "Coconut Breaking Ceremony", category: .traditional, basePrice: 2000, unit: "per ceremony", description: "Traditional coconut breaking ritual", isTeluguSpecific: true),
            ServiceItem(name: "Sacred Fire Setup", category: .traditional, basePrice: 5000, unit: "per setup", description: "Agni kund setup for wedding rituals", isTeluguSpecific: true),
            ServiceItem(name: "Ashtamangala Items", category: .traditional, basePrice: 4000, unit: "per set", description: "Complete set of auspicious items", isTeluguSpecific: true),
            
            // Equipment & Technology
            ServiceItem(name: "LED Screen Rental", category: .equipment, basePrice: 12000, unit: "per screen/day", description: "Large LED screen for live streaming", isTeluguSpecific: false),
            ServiceItem(name: "Professional Lighting", category: .equipment, basePrice: 18000, unit: "per setup", description: "Stage and venue lighting setup", isTeluguSpecific: false),
            ServiceItem(name: "Sound System", category: .equipment, basePrice: 15000, unit: "per day", description: "Professional audio system", isTeluguSpecific: false),
            ServiceItem(name: "Projector Setup", category: .equipment, basePrice: 8000, unit: "per day", description: "Projector for presentations", isTeluguSpecific: false),
            ServiceItem(name: "Fog Machine", category: .equipment, basePrice: 5000, unit: "per day", description: "Special effects fog machine", isTeluguSpecific: false),
            
            // Gifts & Favors
            ServiceItem(name: "Return Gifts", category: .gifts, basePrice: 200, unit: "per piece", description: "Traditional return gifts for guests", isTeluguSpecific: false),
            ServiceItem(name: "Wedding Invitations", category: .gifts, basePrice: 50, unit: "per piece", description: "Custom designed wedding invitations", isTeluguSpecific: false),
            ServiceItem(name: "Tamboolam Bags", category: .gifts, basePrice: 150, unit: "per bag", description: "Traditional gift bags with betel leaves", isTeluguSpecific: true),
            ServiceItem(name: "Silver Coins", category: .gifts, basePrice: 500, unit: "per coin", description: "Silver coins as return gifts", isTeluguSpecific: true),
            
            // Beauty & Grooming
            ServiceItem(name: "Bridal Makeup Package", category: .beauty, basePrice: 25000, unit: "per package", description: "Complete bridal makeup and styling", isTeluguSpecific: false),
            ServiceItem(name: "Groom Grooming", category: .beauty, basePrice: 8000, unit: "per session", description: "Groom's grooming and styling", isTeluguSpecific: false),
            ServiceItem(name: "Hair Styling", category: .beauty, basePrice: 5000, unit: "per session", description: "Professional hair styling", isTeluguSpecific: false),
            ServiceItem(name: "Saree Draping", category: .beauty, basePrice: 3000, unit: "per session", description: "Traditional saree draping service", isTeluguSpecific: true),
            ServiceItem(name: "Nail Art", category: .beauty, basePrice: 2000, unit: "per session", description: "Bridal nail art and decoration", isTeluguSpecific: false)
        ]
    }
    
    func getServicesByCategory(_ category: ServiceCategory) -> [ServiceItem] {
        return getAllServices().filter { $0.category == category }
    }
    
    func getTeluguSpecificServices() -> [ServiceItem] {
        return getAllServices().filter { $0.isTeluguSpecific }
    }
    
    func getServicesForCity(_ city: String) -> [ServiceItem] {
        var services = getAllServices()
        services.append(contentsOf: getCitySpecificServices(for: city))
        return services
    }
    
    func getServicesForSeason(_ date: Date) -> [ServiceItem] {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: date)
        var services = getAllServices()
        services.append(contentsOf: getSeasonalTeluguServices(for: month))
        return services
    }
    
    func getPopularServices() -> [ServiceItem] {
        // Return most commonly used services for Telugu weddings
        let popularServiceNames = [
            "Traditional Telugu Mandap",
            "Telugu Traditional Meals",
            "Traditional Wedding Photography",
            "Nadaswaram & Thavil",
            "Bridal Flower Jewelry",
            "Purohit/Priest",
            "Hyderabadi Biryani",
            "Candid Photography",
            "DJ with Sound System",
            "Stage Decoration"
        ]
        
        return getAllServices().filter { service in
            popularServiceNames.contains { service.name.contains($0) }
        }
    }
}