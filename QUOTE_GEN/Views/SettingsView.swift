//
//  SettingsView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var businessName = "S-Quote Telugu Events"
    @State private var businessAddress = ""
    @State private var businessPhone = ""
    @State private var businessEmail = ""
    @State private var defaultTaxRate = 18.0
    @State private var defaultDiscountRate = 0.0
    @State private var preferredCurrency = "INR"
    @State private var enableNotifications = true
    @State private var autoSave = true
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Business Information") {
                    TextField("Business Name", text: $businessName)
                    TextField("Address", text: $businessAddress, axis: .vertical)
                        .lineLimit(3)
                    TextField("Phone Number", text: $businessPhone)
                    TextField("Email", text: $businessEmail)
                }
                
                Section("Default Settings") {
                    HStack {
                        Text("Default Tax Rate (%)")
                        Spacer()
                        TextField("Tax Rate", value: $defaultTaxRate, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    
                    HStack {
                        Text("Default Discount Rate (%)")
                        Spacer()
                        TextField("Discount Rate", value: $defaultDiscountRate, format: .number)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                    }
                    
                    Picker("Currency", selection: $preferredCurrency) {
                        Text("Indian Rupee (₹)").tag("INR")
                        Text("US Dollar ($)").tag("USD")
                    }
                }
                
                Section("Preferences") {
                    Toggle("Enable Notifications", isOn: $enableNotifications)
                    Toggle("Auto-save Changes", isOn: $autoSave)
                }
                
                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("Build")
                        Spacer()
                        Text("2025.07.25")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveSettings()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .frame(width: 500, height: 600)
    }
    
    private func saveSettings() {
        // Save settings to UserDefaults or other persistence layer
        UserDefaults.standard.set(businessName, forKey: "businessName")
        UserDefaults.standard.set(businessAddress, forKey: "businessAddress")
        UserDefaults.standard.set(businessPhone, forKey: "businessPhone")
        UserDefaults.standard.set(businessEmail, forKey: "businessEmail")
        UserDefaults.standard.set(defaultTaxRate, forKey: "defaultTaxRate")
        UserDefaults.standard.set(defaultDiscountRate, forKey: "defaultDiscountRate")
        UserDefaults.standard.set(preferredCurrency, forKey: "preferredCurrency")
        UserDefaults.standard.set(enableNotifications, forKey: "enableNotifications")
        UserDefaults.standard.set(autoSave, forKey: "autoSave")
    }
}

#Preview {
    SettingsView()
}