//
//  TeluguCulturalServices.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import Foundation

// MARK: - Enhanced Telugu Cultural Services
extension ServiceDataProvider {
    
    func getEnhancedTeluguServices() -> [ServiceItem] {
        return [
            // Traditional Ceremony Services
            ServiceItem(name: "Pellikuthuru & Pellikoduku Ceremony", category: .traditional, basePrice: 15000, unit: "per ceremony", description: "Traditional pre-wedding ceremony for bride and groom", isTeluguSpecific: true),
            ServiceItem(name: "Mangala Snaanam", category: .traditional, basePrice: 8000, unit: "per ceremony", description: "Sacred bath ceremony with turmeric and oils", isTeluguSpecific: true),
            ServiceItem(name: "Kashi Yatra Setup", category: .traditional, basePrice: 12000, unit: "per setup", description: "Mock pilgrimage ceremony with traditional props", isTeluguSpecific: true),
            ServiceItem(name: "Madhuparkam Ceremony", category: .traditional, basePrice: 5000, unit: "per ceremony", description: "Traditional welcome ceremony for groom", isTeluguSpecific: true),
            ServiceItem(name: "Kanyadaanam Setup", category: .traditional, basePrice: 10000, unit: "per setup", description: "Sacred giving away of bride ceremony", isTeluguSpecific: true),
            ServiceItem(name: "Saptapadi Arrangement", category: .traditional, basePrice: 8000, unit: "per setup", description: "Seven steps ceremony with sacred fire", isTeluguSpecific: true),
            ServiceItem(name: "Talambralu Ceremony", category: .traditional, basePrice: 3000, unit: "per ceremony", description: "Rice and turmeric throwing ceremony", isTeluguSpecific: true),
            ServiceItem(name: "Mangalsutra Dharana", category: .traditional, basePrice: 5000, unit: "per ceremony", description: "Sacred thread tying ceremony", isTeluguSpecific: true),
            
            // Regional Cuisine Specialties
            ServiceItem(name: "Rayalaseema Spicy Thali", category: .catering, basePrice: 520, unit: "per person", description: "Authentic Rayalaseema cuisine with extra spicy dishes", isTeluguSpecific: true),
            ServiceItem(name: "Coastal Andhra Seafood Menu", category: .catering, basePrice: 580, unit: "per person", description: "Fresh seafood dishes from coastal Andhra", isTeluguSpecific: true),
            ServiceItem(name: "Telangana Traditional Meals", category: .catering, basePrice: 480, unit: "per person", description: "Authentic Telangana cuisine with jowar and bajra", isTeluguSpecific: true),
            ServiceItem(name: "Godavari Delta Special Menu", category: .catering, basePrice: 450, unit: "per person", description: "Traditional dishes from Godavari region", isTeluguSpecific: true),
            ServiceItem(name: "Nizami Cuisine", category: .catering, basePrice: 650, unit: "per person", description: "Royal Hyderabadi Nizami dishes and delicacies", isTeluguSpecific: true),
            ServiceItem(name: "Bobbatlu & Ariselu Counter", category: .catering, basePrice: 8000, unit: "per counter", description: "Traditional sweet making station", isTeluguSpecific: true),
            ServiceItem(name: "Pesarattu & Upma Counter", category: .catering, basePrice: 6000, unit: "per counter", description: "Traditional Andhra breakfast items", isTeluguSpecific: true),
            ServiceItem(name: "Gongura Pickle Station", category: .catering, basePrice: 4000, unit: "per station", description: "Fresh gongura pickle preparation", isTeluguSpecific: true),
            
            // Traditional Music & Entertainment
            ServiceItem(name: "Burrakatha Performance", category: .entertainment, basePrice: 18000, unit: "per performance", description: "Traditional Telugu storytelling with music", isTeluguSpecific: true),
            ServiceItem(name: "Harikatha Artist", category: .entertainment, basePrice: 15000, unit: "per performance", description: "Religious storytelling with devotional songs", isTeluguSpecific: true),
            ServiceItem(name: "Kolatam Dance Group", category: .entertainment, basePrice: 20000, unit: "per group", description: "Traditional stick dance performance", isTeluguSpecific: true),
            ServiceItem(name: "Dappu Drummers", category: .entertainment, basePrice: 12000, unit: "per group", description: "Traditional Telangana drum ensemble", isTeluguSpecific: true),
            ServiceItem(name: "Lambadi Folk Dance", category: .entertainment, basePrice: 25000, unit: "per group", description: "Colorful Lambadi tribal dance performance", isTeluguSpecific: true),
            ServiceItem(name: "Perini Shivatandavam", category: .entertainment, basePrice: 30000, unit: "per performance", description: "Traditional warrior dance of Telangana", isTeluguSpecific: true),
            ServiceItem(name: "Veeranatyam Performance", category: .entertainment, basePrice: 22000, unit: "per performance", description: "Traditional heroic dance form", isTeluguSpecific: true),
            
            // Specialized Decorations
            ServiceItem(name: "Kalyanam Mandapam Traditional Style", category: .decoration, basePrice: 125000, unit: "per setup", description: "Authentic temple-style mandap with traditional carvings", isTeluguSpecific: true),
            ServiceItem(name: "Banana Leaf Decoration", category: .decoration, basePrice: 8000, unit: "per setup", description: "Traditional banana leaf and plantain decorations", isTeluguSpecific: true),
            ServiceItem(name: "Mango Leaf Torans", category: .decoration, basePrice: 5000, unit: "per setup", description: "Sacred mango leaf garlands for entrances", isTeluguSpecific: true),
            ServiceItem(name: "Coconut & Betel Leaf Arrangements", category: .decoration, basePrice: 6000, unit: "per setup", description: "Traditional auspicious decorations", isTeluguSpecific: true),
            ServiceItem(name: "Kalash & Purna Kumbha Setup", category: .decoration, basePrice: 8000, unit: "per setup", description: "Sacred water vessels with decorations", isTeluguSpecific: true),
            ServiceItem(name: "Swastik & Rangoli Designs", category: .decoration, basePrice: 4000, unit: "per design", description: "Traditional floor art and auspicious symbols", isTeluguSpecific: true),
            ServiceItem(name: "Pasupu Kumkuma Decoration", category: .decoration, basePrice: 3000, unit: "per setup", description: "Turmeric and vermillion decorative arrangements", isTeluguSpecific: true),
            
            // Traditional Attire & Accessories
            ServiceItem(name: "Pattu Saree Draping Service", category: .beauty, basePrice: 5000, unit: "per session", description: "Traditional silk saree draping in Telugu style", isTeluguSpecific: true),
            ServiceItem(name: "Groom's Traditional Attire Setup", category: .beauty, basePrice: 8000, unit: "per session", description: "Complete traditional Telugu groom styling", isTeluguSpecific: true),
            ServiceItem(name: "Bride's Jewelry Arrangement", category: .beauty, basePrice: 6000, unit: "per session", description: "Traditional Telugu bridal jewelry styling", isTeluguSpecific: true),
            ServiceItem(name: "Maang Tikka & Nath Setup", category: .beauty, basePrice: 3000, unit: "per session", description: "Traditional forehead and nose jewelry", isTeluguSpecific: true),
            ServiceItem(name: "Gajra & Hair Decoration", category: .beauty, basePrice: 2500, unit: "per session", description: "Traditional flower hair decorations", isTeluguSpecific: true),
            
            // Regional Transportation
            ServiceItem(name: "Decorated Bullock Cart", category: .transportation, basePrice: 15000, unit: "per event", description: "Traditional bullock cart for ceremonial entry", isTeluguSpecific: true),
            ServiceItem(name: "Palanquin (Pallaki) Service", category: .transportation, basePrice: 20000, unit: "per event", description: "Traditional palanquin for bride's entry", isTeluguSpecific: true),
            ServiceItem(name: "Decorated Tractor Entry", category: .transportation, basePrice: 12000, unit: "per event", description: "Rural-style decorated tractor for groom", isTeluguSpecific: true),
            
            // Specialized Catering Equipment
            ServiceItem(name: "Traditional Banana Leaf Service", category: .catering, basePrice: 50, unit: "per person", description: "Authentic banana leaf plate service", isTeluguSpecific: true),
            ServiceItem(name: "Clay Pot Cooking Setup", category: .catering, basePrice: 15000, unit: "per setup", description: "Traditional clay pot cooking demonstration", isTeluguSpecific: true),
            ServiceItem(name: "Wood Fire Cooking Station", category: .catering, basePrice: 12000, unit: "per station", description: "Traditional wood fire cooking setup", isTeluguSpecific: true),
            
            // Religious & Spiritual Services
            ServiceItem(name: "Vedic Pandit for Ceremonies", category: .traditional, basePrice: 8000, unit: "per ceremony", description: "Learned Vedic scholar for complex rituals", isTeluguSpecific: true),
            ServiceItem(name: "Astrologer Consultation", category: .traditional, basePrice: 5000, unit: "per consultation", description: "Traditional astrology consultation for muhurtham", isTeluguSpecific: true),
            ServiceItem(name: "Homam & Havan Setup", category: .traditional, basePrice: 12000, unit: "per setup", description: "Sacred fire ceremony arrangements", isTeluguSpecific: true),
            ServiceItem(name: "Ganapathi Puja Setup", category: .traditional, basePrice: 6000, unit: "per setup", description: "Lord Ganesha worship arrangements", isTeluguSpecific: true),
            ServiceItem(name: "Kalasha Sthapana", category: .traditional, basePrice: 4000, unit: "per setup", description: "Sacred water vessel installation ceremony", isTeluguSpecific: true),
            
            // Modern Telugu Fusion Services
            ServiceItem(name: "Telugu DJ with Traditional Mix", category: .entertainment, basePrice: 35000, unit: "per day", description: "DJ specializing in Telugu folk and modern fusion", isTeluguSpecific: true),
            ServiceItem(name: "Live Telugu Folk Band", category: .entertainment, basePrice: 45000, unit: "per performance", description: "Contemporary Telugu folk music band", isTeluguSpecific: true),
            ServiceItem(name: "Telugu Anchor (Bilingual)", category: .entertainment, basePrice: 15000, unit: "per day", description: "Professional anchor fluent in Telugu and English", isTeluguSpecific: true),
            
            // Specialty Photography
            ServiceItem(name: "Traditional Ritual Photography", category: .photography, basePrice: 30000, unit: "per day", description: "Specialized photography for Telugu wedding rituals", isTeluguSpecific: true),
            ServiceItem(name: "Candid Telugu Wedding Album", category: .photography, basePrice: 18000, unit: "per album", description: "Album with Telugu captions and traditional layouts", isTeluguSpecific: true),
            ServiceItem(name: "Drone Footage of Procession", category: .photography, basePrice: 20000, unit: "per event", description: "Aerial coverage of baraat and procession", isTeluguSpecific: true),
            
            // Gift & Favor Specialties
            ServiceItem(name: "Traditional Brass Items", category: .gifts, basePrice: 800, unit: "per piece", description: "Authentic brass items as return gifts", isTeluguSpecific: true),
            ServiceItem(name: "Handloom Fabric Gifts", category: .gifts, basePrice: 1200, unit: "per piece", description: "Traditional Telugu handloom products", isTeluguSpecific: true),
            ServiceItem(name: "Kalamkari Art Pieces", category: .gifts, basePrice: 1500, unit: "per piece", description: "Traditional Kalamkari art as gifts", isTeluguSpecific: true),
            ServiceItem(name: "Nirmal Toys & Crafts", category: .gifts, basePrice: 600, unit: "per piece", description: "Traditional Nirmal wooden toys and crafts", isTeluguSpecific: true),
            ServiceItem(name: "Pochampally Silk Items", category: .gifts, basePrice: 2000, unit: "per piece", description: "Authentic Pochampally silk products", isTeluguSpecific: true),
            
            // Venue Enhancements
            ServiceItem(name: "Traditional Courtyard Setup", category: .venue, basePrice: 25000, unit: "per setup", description: "Recreate traditional Telugu home courtyard", isTeluguSpecific: true),
            ServiceItem(name: "Heritage Theme Decoration", category: .venue, basePrice: 35000, unit: "per venue", description: "Transform venue into heritage Telugu palace", isTeluguSpecific: true),
            ServiceItem(name: "Village Theme Setup", category: .venue, basePrice: 30000, unit: "per setup", description: "Rural Telugu village theme decoration", isTeluguSpecific: true)
        ]
    }
    
    // MARK: - Regional City-Specific Services
    func getCitySpecificServices(for city: String) -> [ServiceItem] {
        let cityLower = city.lowercased()
        var cityServices: [ServiceItem] = []
        
        if cityLower.contains("hyderabad") || cityLower.contains("secunderabad") {
            cityServices.append(contentsOf: [
                ServiceItem(name: "Charminar Backdrop Setup", category: .decoration, basePrice: 15000, unit: "per setup", description: "Iconic Charminar themed backdrop", isTeluguSpecific: true),
                ServiceItem(name: "Nizami Royal Theme", category: .decoration, basePrice: 45000, unit: "per setup", description: "Royal Nizami palace theme decoration", isTeluguSpecific: true),
                ServiceItem(name: "Hyderabadi Biryani Master Chef", category: .catering, basePrice: 25000, unit: "per day", description: "Expert Hyderabadi biryani chef", isTeluguSpecific: true)
            ])
        }
        
        if cityLower.contains("visakhapatnam") || cityLower.contains("vizag") {
            cityServices.append(contentsOf: [
                ServiceItem(name: "Beach Wedding Setup", category: .venue, basePrice: 35000, unit: "per setup", description: "Coastal beach wedding arrangements", isTeluguSpecific: false),
                ServiceItem(name: "Seafood Specialty Chef", category: .catering, basePrice: 20000, unit: "per day", description: "Expert in coastal Andhra seafood", isTeluguSpecific: true),
                ServiceItem(name: "Naval Theme Decoration", category: .decoration, basePrice: 25000, unit: "per setup", description: "Naval port city themed decorations", isTeluguSpecific: false)
            ])
        }
        
        if cityLower.contains("vijayawada") {
            cityServices.append(contentsOf: [
                ServiceItem(name: "Krishna River Theme", category: .decoration, basePrice: 20000, unit: "per setup", description: "Krishna river and delta themed decoration", isTeluguSpecific: true),
                ServiceItem(name: "Kanaka Durga Temple Style Mandap", category: .decoration, basePrice: 55000, unit: "per setup", description: "Temple architecture inspired mandap", isTeluguSpecific: true)
            ])
        }
        
        if cityLower.contains("tirupati") {
            cityServices.append(contentsOf: [
                ServiceItem(name: "Tirumala Temple Style Decoration", category: .decoration, basePrice: 60000, unit: "per setup", description: "Sacred Tirumala temple inspired decor", isTeluguSpecific: true),
                ServiceItem(name: "Laddu Prasadam Distribution", category: .catering, basePrice: 8000, unit: "per event", description: "Traditional Tirupati laddu distribution", isTeluguSpecific: true)
            ])
        }
        
        if cityLower.contains("warangal") {
            cityServices.append(contentsOf: [
                ServiceItem(name: "Kakatiya Dynasty Theme", category: .decoration, basePrice: 40000, unit: "per setup", description: "Historical Kakatiya kingdom themed decor", isTeluguSpecific: true),
                ServiceItem(name: "Thousand Pillar Temple Style", category: .decoration, basePrice: 50000, unit: "per setup", description: "Inspired by famous Warangal temple", isTeluguSpecific: true)
            ])
        }
        
        return cityServices
    }
    
    // MARK: - Seasonal Telugu Services
    func getSeasonalTeluguServices(for month: Int) -> [ServiceItem] {
        var seasonalServices: [ServiceItem] = []
        
        switch month {
        case 3...5: // Summer
            seasonalServices.append(contentsOf: [
                ServiceItem(name: "Mango Leaf Special Decoration", category: .decoration, basePrice: 8000, unit: "per setup", description: "Fresh mango leaves for summer weddings", isTeluguSpecific: true),
                ServiceItem(name: "Tender Coconut Water Station", category: .catering, basePrice: 6000, unit: "per station", description: "Fresh coconut water for guests", isTeluguSpecific: true),
                ServiceItem(name: "Cooling Tent Setup", category: .venue, basePrice: 15000, unit: "per setup", description: "Special cooling arrangements for summer", isTeluguSpecific: false)
            ])
            
        case 6...9: // Monsoon
            seasonalServices.append(contentsOf: [
                ServiceItem(name: "Monsoon Wedding Canopy", category: .venue, basePrice: 25000, unit: "per setup", description: "Waterproof decorative canopy", isTeluguSpecific: false),
                ServiceItem(name: "Traditional Umbrella Decoration", category: .decoration, basePrice: 12000, unit: "per setup", description: "Colorful traditional umbrellas as decor", isTeluguSpecific: true)
            ])
            
        case 10...2: // Winter/Festival Season
            seasonalServices.append(contentsOf: [
                ServiceItem(name: "Diwali Theme Integration", category: .decoration, basePrice: 18000, unit: "per setup", description: "Festival of lights themed decoration", isTeluguSpecific: true),
                ServiceItem(name: "Makar Sankranti Special Setup", category: .decoration, basePrice: 15000, unit: "per setup", description: "Kite festival themed decorations", isTeluguSpecific: true),
                ServiceItem(name: "Bonfire Ceremony Setup", category: .traditional, basePrice: 10000, unit: "per setup", description: "Traditional winter bonfire ceremony", isTeluguSpecific: true)
            ])
        default:
            break
        }
        
        return seasonalServices
    }
}