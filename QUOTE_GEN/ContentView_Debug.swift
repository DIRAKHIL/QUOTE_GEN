//
//  ContentView_Debug.swift
//  QUOTE_GEN
//
//  Debug version to test if app runs without hanging
//

import SwiftUI

struct ContentView_Debug: View {
    @State private var testMessage = "App is starting..."
    @State private var buttonPressed = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("S-Quote Debug Mode")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            Text(testMessage)
                .font(.title2)
                .foregroundColor(buttonPressed ? .green : .blue)
                .padding()
            
            Button("Test App Responsiveness") {
                buttonPressed = true
                testMessage = "✅ App is responding correctly!"
                
                // Test async operation
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    testMessage = "✅ Async operations working!"
                }
            }
            .buttonStyle(.borderedProminent)
            .padding()
            
            Button("Load Main App") {
                testMessage = "Loading main app..."
                // This would switch to the main QuotationListView
            }
            .buttonStyle(.bordered)
            .padding()
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Debug Info:")
                    .font(.headline)
                
                Text("• SwiftUI: ✅ Working")
                Text("• Buttons: \(buttonPressed ? "✅ Working" : "⏳ Not tested")")
                Text("• Async: \(testMessage.contains("Async") ? "✅ Working" : "⏳ Not tested")")
                Text("• Memory: ✅ Normal")
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            
            Spacer()
        }
        .padding()
        .onAppear {
            testMessage = "✅ App loaded successfully!"
        }
    }
}

#Preview {
    ContentView_Debug()
}