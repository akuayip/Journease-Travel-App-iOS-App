//
//  OnboardingView.swift
//  Travel
//
//  Created by M. Arief Rahman Hakim on 20/04/26.
//

import SwiftUI
 
struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @State private var currentPage: Int = 0
 
    let pages: [OnboardingPage] = [
        OnboardingPage(
            imageName: "ob_1",
            title: "ORGANIZE\nESSENTIALS.",
            subtitle: "A single digital vault for your most critical assets. No more scrambling at the gate."
        ),
        OnboardingPage(
            imageName: "ob_2",
            title: "Your\nPouch,\nYour Way.",
            subtitle: "Curate your essential documents into customizable sets. Organize by your trip and category - exactly how you think."
        ),
        OnboardingPage(
            imageName: "ob_3",
            title: "FAST &\nOFFLINE ACCESS",
            subtitle: "No signal? No problem. Your documents are always accessible, even without an internet connection. Rest easy.",
            centerAligned: true
        )
    ]
 
    var body: some View {
        VStack(spacing: 0) {
            // Slides
            TabView(selection: $currentPage) {
                ForEach(0..<pages.count, id: \.self) { index in
                    OnboardingSlide(page: pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(maxHeight: .infinity)

            // Bottom controls
            VStack(spacing: 20) {
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(0..<pages.count, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.black : Color.gray.opacity(0.4))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.4), value: currentPage)
                    }
                }

                // Buttons
                HStack {
                    if currentPage < pages.count - 1 {
                        Button("Skip") {
                            hasSeenOnboarding = true
                        }
                        .font(.body)
                        .foregroundColor(.gray)

                        Spacer()

                        Button {
                            withAnimation(.spring()) { currentPage += 1 }
                        } label: {
                            Text("Next")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 120, height: 52)
                                .background(Color.black)
                                .clipShape(Capsule())
                        }
                    } else {
                        Button {
                            hasSeenOnboarding = true
                        } label: {
                            Text("START")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 52)
                                .background(Color.black)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
            .padding(.horizontal, 30)
            .padding(.top, 20)
            .padding(.bottom, 50)
        }
        .ignoresSafeArea(edges: .top)
    }
}
