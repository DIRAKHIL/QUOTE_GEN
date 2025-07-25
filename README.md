# S-Quote: Telugu Event Planner Quotation Generator

A professional macOS application for creating detailed event planning quotations, specifically designed for Telugu wedding planners, photographers, and event management companies in Andhra Pradesh and Telangana.

## 🎯 Features

### Core Functionality
- **Event Management**: Create and manage multiple event quotations
- **Service Catalog**: Comprehensive library of Telugu-specific event services
- **Dynamic Pricing**: Real-time calculation with taxes, discounts, and regional pricing
- **Professional Export**: Generate formatted quotations for clients
- **Data Persistence**: Local storage with UserDefaults integration
- **Search & Filter**: Advanced filtering by category, Telugu-specific services

### 📸 Photography & Videography Services
Based on real-world Telugu wedding requirements:
- Traditional Telugu wedding photography with ritual coverage
- Candid photography with professional equipment
- 4K cinematic video recording
- Drone photography and videography
- Wedding albums and promotional videos
- Live streaming for remote family members

### 🎉 Telugu-Specific Event Categories

#### Traditional Wedding Services
- **Mandap & Decoration**: Traditional Telugu mandap, Kalyanam mandap with pillars
- **Religious Services**: Purohit/Priest, Sacred fire setup, Ashtamangala items
- **Traditional Music**: Nadaswaram & Thavil, Classical dance performances
- **Ceremonial Items**: Mangalsutra making, Kalash decoration, Coconut breaking ceremony

#### Regional Catering
- **Telugu Traditional Meals**: Authentic Telugu cuisine with traditional items
- **Andhra Spicy Menu**: Spicy Andhra style dishes and curries
- **Hyderabadi Biryani**: Authentic Hyderabadi biryani with raita and shorba
- **South Indian Breakfast**: Traditional breakfast with idli, dosa, vada
- **Sweet Counter**: Traditional sweets including laddu, mysore pak
- **Live Counters**: Dosa counter, Paan counter

#### Transportation & Procession
- **Traditional Entries**: Horse for groom entry, Elephant for procession
- **Decorated Vehicles**: Luxury car decoration for bride and groom
- **Guest Transportation**: Bus transportation for guests

#### Flowers & Traditional Items
- **Bridal Flower Jewelry**: Traditional flower jewelry sets
- **Groom's Sehra**: Traditional flower sehra
- **Garland Exchange**: Special garlands for ceremony
- **Jasmine Strings**: Traditional jasmine flower strings
- **Marigold Decoration**: Extensive marigold decorations

### 💰 Advanced Pricing Features
- **Regional Pricing**: Automatic price adjustments for different cities
  - Tier 1 cities (Hyderabad, Visakhapatnam, Vijayawada): +20%
  - Tier 2 cities (Guntur, Nellore, Tirupati, etc.): Standard pricing
  - Tier 3 cities and rural areas: -20%
- **Percentage-based discounts**
- **Additional fees and charges**
- **GST calculations (18% standard)**
- **Currency formatting in INR**
- **Real-time total updates**

### 🏛️ Venue Categories
- **Traditional Venues**: Kalyana Mandapam, Wedding halls
- **Modern Facilities**: Garden venues, AC & cooling, Generator backup
- **Support Services**: Parking arrangements, Security personnel

### 🎭 Entertainment & Cultural Services
- **Traditional Music**: Nadaswaram & Thavil ensembles
- **Modern Entertainment**: DJ with sound system, Live bands
- **Cultural Performances**: Bharatanatyam, Kuchipudi dance
- **Ceremonial Music**: Dhol players for baraat
- **Event Coordination**: Professional anchors and MCs

### 👥 Staffing & Coordination
- **Wedding Coordination**: Professional wedding planners
- **Beauty Services**: Makeup artists, Mehendi artists, Hair styling
- **Service Staff**: Waitstaff, Security personnel
- **Traditional Services**: Saree draping, Traditional grooming

## 🛠️ Technical Features

### Data Models
- **ServiceItem**: Comprehensive service catalog with Telugu-specific flags
- **Quotation**: Complete quotation management with client details
- **QuoteItem**: Individual service items with custom pricing
- **EventType**: Telugu event types with native names

### User Interface
- **SwiftUI**: Modern, responsive interface
- **Search & Filter**: Advanced filtering capabilities
- **Export Functionality**: Professional quotation formatting
- **Statistics Dashboard**: Revenue tracking and analytics

### Regional Intelligence
- **City-based Pricing**: Automatic price adjustments
- **Telugu Language Support**: Event names in Telugu script
- **Cultural Awareness**: Traditional service recommendations

## 📱 System Requirements

- **macOS**: 14.0 or later
- **Xcode**: 15.0 or later
- **Swift**: 5.9 or later
- **Architecture**: Apple Silicon (M1/M2) or Intel

## 🚀 Installation & Setup

1. **Clone the Repository**
   ```bash
   git clone https://github.com/DIRAKHIL/QUOTE_GEN.git
   cd QUOTE_GEN
   ```

2. **Open in Xcode**
   ```bash
   open QUOTE_GEN.xcodeproj
   ```

3. **Build and Run**
   - Select your target device/simulator
   - Press `Cmd + R` to build and run

## 📊 Usage Guide

### Creating a New Quotation
1. Tap the "+" button in the top-right corner
2. Fill in client information and event details
3. Select event type (automatically suggests Telugu-specific services)
4. Add services from the comprehensive catalog
5. Adjust pricing, discounts, and taxes
6. Add notes and finalize the quotation

### Service Management
- **Browse by Category**: Filter services by type
- **Telugu Filter**: Show only traditional Telugu services
- **Search**: Find services by name or description
- **Custom Pricing**: Override default prices for specific clients

### Export & Sharing
- Generate professional PDF quotations
- Share via email or messaging apps
- Print-ready formatting with company branding

## 🎨 Customization

### Adding New Services
1. Open `Models.swift`
2. Add new `ServiceItem` to the `getAllServices()` method
3. Set appropriate category and Telugu-specific flag
4. Include regional pricing considerations

### Regional Pricing
Modify the `getRegionalPriceMultiplier` function in `QuotationManager.swift` to add new cities or adjust pricing tiers.

### Event Types
Add new event types in the `EventType` enum with corresponding Telugu names.

## 📈 Analytics & Reporting

- **Total Revenue**: Track finalized quotations
- **Average Quotation Value**: Business performance metrics
- **Popular Services**: Most requested services analysis
- **Regional Performance**: City-wise business insights

## 🔒 Data Privacy

- All data stored locally using UserDefaults
- No cloud synchronization (privacy-first approach)
- Client information encrypted at rest
- GDPR compliant data handling

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Telugu wedding traditions and customs
- Event planning professionals in Andhra Pradesh and Telangana
- Photography and videography specialists
- Traditional music and cultural performers

## 📞 Support

For support, email support@squote.com or create an issue in this repository.

## 🗺️ Roadmap

### Version 2.0 (Planned)
- [ ] Cloud synchronization
- [ ] Multi-language support (Telugu, Hindi, English)
- [ ] Vendor management system
- [ ] Calendar integration
- [ ] Payment tracking
- [ ] Client portal
- [ ] Mobile app (iOS/Android)
- [ ] Advanced analytics dashboard
- [ ] Template management
- [ ] Bulk operations

### Version 2.1 (Future)
- [ ] AI-powered service recommendations
- [ ] Automated pricing optimization
- [ ] Integration with popular accounting software
- [ ] Multi-currency support
- [ ] Advanced reporting and insights
- [ ] CRM integration
- [ ] Social media integration
- [ ] Review and rating system

---

**Made with ❤️ for Telugu Event Planners**

*Specializing in Telugu Weddings | Andhra Pradesh & Telangana*