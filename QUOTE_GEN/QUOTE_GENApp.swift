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
            ContentView()
        }
        .windowStyle(.hiddenTitleBar)
        .windowToolbarStyle(.unified)
        .commands {
            CommandGroup(replacing: .newItem) {
                Button("New Quotation") {
                    // Handle new quotation
                }
                .keyboardShortcut("n", modifiers: .command)
            }
        }
    }
}
