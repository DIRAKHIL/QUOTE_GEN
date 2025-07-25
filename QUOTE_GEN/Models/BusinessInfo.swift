//
//  BusinessInfo.swift
//  QUOTE_GEN
//
//  Business information model for Telugu event planning
//

import Foundation

struct BusinessInfo: Codable, Identifiable {
    let id = UUID()
    var businessName: String
    var ownerName: String
    var address: Address
    var contactInfo: ContactInfo
    var bankDetails: BankDetails
    var taxInfo: TaxInfo
    var branding: BrandingInfo
    
    struct Address: Codable {
        var street: String
        var city: String
        var state: String
        var pincode: String
        var country: String = "India"
        
        var formatted: String {
            [street, city, "\(state) \(pincode)", country]
                .filter { !$0.isEmpty }
                .joined(separator: "\n")
        }
    }
    
    struct ContactInfo: Codable {
        var primaryPhone: String
        var secondaryPhone: String
        var email: String
        var website: String
        var whatsapp: String
        var instagram: String
    }
    
    struct BankDetails: Codable {
        var bankName: String
        var accountNumber: String
        var ifscCode: String
        var accountHolderName: String
        var upiId: String
    }
    
    struct TaxInfo: Codable {
        var gstNumber: String
        var panNumber: String
        var taxRate: Double = 18.0 // Default GST rate
    }
    
    struct BrandingInfo: Codable {
        var logoPath: String
        var primaryColor: String
        var secondaryColor: String
        var tagline: String
        var specialization: [String] // e.g., ["Telugu Weddings", "Corporate Events"]
    }
    
    static let `default` = BusinessInfo(
        businessName: "S-Quote Events",
        ownerName: "Event Planner",
        address: Address(
            street: "123 Event Street",
            city: "Hyderabad",
            state: "Telangana",
            pincode: "500001"
        ),
        contactInfo: ContactInfo(
            primaryPhone: "+91 9876543210",
            secondaryPhone: "",
            email: "info@squoteevents.com",
            website: "www.squoteevents.com",
            whatsapp: "+91 9876543210",
            instagram: "@squoteevents"
        ),
        bankDetails: BankDetails(
            bankName: "State Bank of India",
            accountNumber: "1234567890",
            ifscCode: "SBIN0001234",
            accountHolderName: "S-Quote Events",
            upiId: "squoteevents@paytm"
        ),
        taxInfo: TaxInfo(
            gstNumber: "36XXXXX1234X1ZX",
            panNumber: "XXXXX1234X"
        ),
        branding: BrandingInfo(
            logoPath: "",
            primaryColor: "#FF6B6B",
            secondaryColor: "#4ECDC4",
            tagline: "Creating Memorable Telugu Celebrations",
            specialization: ["Telugu Weddings", "Engagement Ceremonies", "Corporate Events", "Cultural Programs"]
        )
    )
}

// MARK: - Business Manager
class BusinessManager: ObservableObject {
    @Published var businessInfo: BusinessInfo
    
    private let userDefaults = UserDefaults.standard
    private let businessInfoKey = "BusinessInfo"
    
    init() {
        if let data = userDefaults.data(forKey: businessInfoKey),
           let businessInfo = try? JSONDecoder().decode(BusinessInfo.self, from: data) {
            self.businessInfo = businessInfo
        } else {
            self.businessInfo = BusinessInfo.default
        }
    }
    
    func save() {
        if let data = try? JSONEncoder().encode(businessInfo) {
            userDefaults.set(data, forKey: businessInfoKey)
        }
    }
    
    func reset() {
        businessInfo = BusinessInfo.default
        save()
    }
}