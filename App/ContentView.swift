//
//  ContentView.swift
//  Travel
//
//  Created by M. Arief Rahman Hakim on 17/04/26.
//

import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    
    var body: some View {
            if hasSeenOnboarding {
                Home()
            } else {
                OnboardingView()
            }
        }
}

#Preview {
    ContentView()
}
