//
//  ContentView.swift
//  QUOTE_GEN
//
//  Created by Akhil Maddali on 25/07/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        QuotationListView_macOS()
            .frame(minWidth: 1000, minHeight: 700)
    }
}

#Preview {
    ContentView()
}
