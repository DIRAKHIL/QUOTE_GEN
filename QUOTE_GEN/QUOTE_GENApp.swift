//
//  QUOTE_GENApp.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI

@main
struct QUOTE_GENApp: App {
    var body: some Scene {
        WindowGroup {
            MacOSNativeApp()
        }
        .defaultSize(width: 1200, height: 800)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Quotation") {
                    // Handle new quotation
                }
                .keyboardShortcut("n", modifiers: .command)
            }
            
            CommandGroup(after: .newItem) {
                Button("New Wedding Quote") {
                    // Handle new wedding quotation
                }
                .keyboardShortcut("w", modifiers: [.command, .shift])
                
                Divider()
                
                Button("Import Services") {
                    // Handle import
                }
                .keyboardShortcut("i", modifiers: .command)
                
                Button("Export Report") {
                    // Handle export
                }
                .keyboardShortcut("e", modifiers: .command)
            }
            
            CommandGroup(replacing: .help) {
                Button("S-Quote Help") {
                    // Show help
                }
                
                Button("Telugu Event Planning Guide") {
                    // Show guide
                }
                
                Divider()
                
                Button("About S-Quote") {
                    // Show about
                }
            }
        }
    }
}
