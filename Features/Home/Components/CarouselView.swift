//
//  CarouselView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI

struct CarouselView: View {
    let totalCards: Int
    let selectedPouch: String
    let isEditing: Bool
    let isDetailActive: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void

    var body: some View {
        GeometryReader { geo in
            let cardWidth: CGFloat = geo.size.width * 0.7
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<totalCards, id: \.self) { _ in
                        ZStack {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .fill(Color(.systemGray4))
                                .frame(width: cardWidth, height: 220)
                                .offset(x: 20, y: 20)

                            Image(selectedPouch)
                                .resizable()
                                .scaledToFill()
                                .frame(width: cardWidth, height: 220)
                                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                                .matchedGeometryEffect(id: "hero_card", in: namespace, isSource: !isDetailActive)
                        }
                        .onTapGesture {
                            if !isEditing { onTap() }
                        }
                        .frame(width: cardWidth)
                        .frame(height: 300)
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, (geo.size.width - cardWidth) / 2)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollDisabled(isEditing || isDetailActive)
        }
    }
}
