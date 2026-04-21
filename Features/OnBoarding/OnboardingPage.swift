//
//  OnboardingPage.swift
//  Travel
//
//  Created by M. Arief Rahman Hakim on 20/04/26.
//

import SwiftUI
 
// MARK: - Model
struct OnboardingPage {
    let imageName: String
    let title: String
    let subtitle: String
    var centerAligned: Bool = false
}
 
// MARK: - Slide View
struct OnboardingSlide: View {
    let page: OnboardingPage

    var body: some View {
        VStack(alignment: page.centerAligned ? .center : .leading, spacing: 0) {
            Text(page.title)
                .font(.system(size: 36, weight: .bold))
                .multilineTextAlignment(page.centerAligned ? .center : .leading)
                .lineSpacing(2)
                .padding(.top, 80)
                .padding(.horizontal, 30)

            Text(page.subtitle)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(page.centerAligned ? .center : .leading)
                .padding(.top, 16)
                .padding(.horizontal, 30)

            Image(page.imageName)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                .padding(.horizontal, 20)

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}



