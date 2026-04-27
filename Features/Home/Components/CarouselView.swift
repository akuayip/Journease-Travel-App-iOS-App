//
//  CarouselView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI
import SwiftData

struct CarouselView: View {
    let trips: [Trip]
    let isEditing: Bool
    let isDetailActive: Bool
    let isClosingDetail: Bool
    let onTap: (Trip) -> Void
    let onScroll: (Trip) -> Void
    @Binding var scrolledTripID: Trip.ID?  // ← binding agar HomeView bisa scroll

    var body: some View {
        GeometryReader { geo in
            let cardWidth: CGFloat = geo.size.width * 0.7
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(trips) { trip in
                        PouchCardView(
                            bodyAsset: trip.pouchColor.replacingOccurrences(of: "pouch_", with: "bs_"),
                            lidAsset: trip.pouchColor.replacingOccurrences(of: "pouch_", with: "hs_"),
                            cardWidth: cardWidth,
                            isEditing: isEditing,
                            isDetailActive: isDetailActive,
                            isClosingDetail: isClosingDetail,
                            onTap: { onTap(trip) }
                        )
                        .frame(width: cardWidth)
                        .frame(height: 300)
                    }
                }
                .scrollTargetLayout()
                .padding(.top, 30)
                .padding(.horizontal, (geo.size.width - cardWidth) / 2)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollDisabled(isEditing || isDetailActive)
            .scrollClipDisabled()
            .scrollPosition(id: $scrolledTripID, anchor: .center)
            .onChange(of: scrolledTripID) { _, newID in
                if let id = newID,
                   let trip = trips.first(where: { $0.id == id }) {
                    onScroll(trip)
                }
            }
        }
    }
}

// MARK: - PouchCardView
struct PouchCardView: View {
    let bodyAsset: String
    let lidAsset: String
    let cardWidth: CGFloat
    let isEditing: Bool
    let isDetailActive: Bool
    let isClosingDetail: Bool
    let onTap: () -> Void

    enum PouchState {
        case closed
        case opening
        case open
        case closing
    }

    @State private var pouchState: PouchState = .closed
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack(alignment: .top) {
            // Shadow card
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemGray4))
                .frame(width: cardWidth, height: 220)
                .offset(x: 20, y: 20)
                .opacity(pouchState == .open ? 0 : 1)
                .animation(.easeOut(duration: 0.15), value: pouchState)

            ZStack(alignment: .top) {
                // Body pouch
                Image(bodyAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .opacity(pouchState == .open ? 0 : 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: pouchState)

                // Tutup pouch
                Image(lidAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth)
                    .rotation3DEffect(
                        .degrees(pouchState == .opening || pouchState == .open ? -180 :
                                 pouchState == .closing ? -10 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top,
                        perspective: 0.3
                    )
                    .opacity(pouchState == .open ? 0 : 1)
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: pouchState)
                    .zIndex(1)
            }
            .scaleEffect(scale)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: scale)
        }
        .onTapGesture {
            guard !isEditing else { return }
            animateOpen()
        }
        .onChange(of: isClosingDetail) { _, newValue in
            if newValue {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    pouchState = .closing
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    pouchState = .closed
                    scale = 1.0
                }
            }
        }
        .onChange(of: isDetailActive) { _, newValue in
            if !newValue && !isClosingDetail {
                pouchState = .closed
                scale = 1.0
            }
        }
    }

    private func animateOpen() {
        withAnimation(.spring(response: 0.12, dampingFraction: 0.6)) {
            scale = 0.96
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                scale = 1.0
                pouchState = .opening
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            pouchState = .open
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                onTap()
            }
        }
    }
}
