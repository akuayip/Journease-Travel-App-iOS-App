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

    private var bodyAsset: String {
        selectedPouch.replacingOccurrences(of: "pouch_", with: "bs_")
    }

    private var lidAsset: String {
        selectedPouch.replacingOccurrences(of: "pouch_", with: "hs_")
    }

    var body: some View {
        GeometryReader { geo in
            let cardWidth: CGFloat = geo.size.width * 0.7
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 20) {
                    ForEach(0..<totalCards, id: \.self) { _ in
                        PouchCardView(
                            bodyAsset: bodyAsset,
                            lidAsset: lidAsset,
                            cardWidth: cardWidth,
                            isEditing: isEditing,
                            isDetailActive: isDetailActive,
                            namespace: namespace,
                            onTap: onTap
                        )
                        .frame(width: cardWidth)
                        .frame(height: 300)
                    }
                }
                .scrollTargetLayout()
                .padding(.top, 50)
                .padding(.horizontal, (geo.size.width - cardWidth) / 2)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollDisabled(isEditing || isDetailActive)
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
    let namespace: Namespace.ID
    let onTap: () -> Void

    enum PouchState {
        case closed
        case opening
        case open
    }

    @State private var pouchState: PouchState = .closed
    @State private var scale: CGFloat = 1.0

    var body: some View {
        ZStack(alignment: .top) {
            // Shadow card — tidak ikut animasi
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(.systemGray4))
                .frame(width: cardWidth, height: 220)
                .offset(x: 20, y: 20)

            // Body + Lid dalam satu ZStack
            // matchedGeometryEffect di sini agar tidak clip animasi lid
            ZStack(alignment: .top) {

                // Body pouch — hanya body yang di-clip
                Image(bodyAsset)
                    .resizable()
                    .scaledToFill()
                    .frame(width: cardWidth, height: 220)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))

                // Tutup pouch — BEBAS tanpa clip
                // overflow ke luar card saat animasi berlangsung
                Image(lidAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: cardWidth)
                    .rotation3DEffect(
                        .degrees(pouchState == .opening || pouchState == .open ? -180 : 0),
                        axis: (x: 1, y: 0, z: 0),
                        anchor: .top,
                        perspective: 0.3
                    )
                    .opacity(pouchState == .open ? 0 : 1)
                    .animation(
                        .spring(response: 0.35, dampingFraction: 0.75),
                        value: pouchState
                    )
                    .zIndex(1)
            }
            .scaleEffect(scale)
            .animation(.spring(response: 0.2, dampingFraction: 0.8), value: scale)
            .matchedGeometryEffect(id: "hero_card", in: namespace, isSource: !isDetailActive)
            // Tidak ada .clipped() di sini agar lid bebas bergerak
        }
        .onTapGesture {
            guard !isEditing else { return }
            animateOpen()
        }
        .onChange(of: isDetailActive) { _, newValue in
            if !newValue {
                // Reset dengan animasi ketika kembali ke home
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    pouchState = .closed
                    scale = 1.0
                }
            }
        }
    }

    private func animateOpen() {
        // Step 1: feedback sentuhan — scale mengecil sedikit
        withAnimation(.spring(response: 0.12, dampingFraction: 0.6)) {
            scale = 0.96
        }

        // Step 2: scale kembali + tutup mulai terangkat
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                scale = 1.0
                pouchState = .opening
            }
        }

        // Step 3: tunggu animasi tutup selesai, baru pindah ke detail
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            pouchState = .open
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                onTap()
            }
        }
    }
}
