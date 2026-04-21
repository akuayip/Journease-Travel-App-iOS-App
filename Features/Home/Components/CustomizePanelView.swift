//
//  CustomizePanelView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI

struct CustomizePanelView: View {
    @Binding var selectedPouch: String
    let pouchAssets: [String]
    let onDone: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Customize your pouch").font(.title3).bold()
                Spacer()
                Button {
                    onDone()
                } label: {
                    Image(systemName: "checkmark")
                        .font(.title3).bold()
                        .padding(8)
                        .foregroundColor(.black)
                }
            }
            .padding([.horizontal, .top], 25)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    ForEach(pouchAssets, id: \.self) { pouchName in
                        Button {
                            withAnimation(.spring()) { selectedPouch = pouchName }
                        } label: {
                            Image(pouchName)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 140, height: 100)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .strokeBorder(
                                            selectedPouch == pouchName ? Color.primary : Color.clear,
                                            lineWidth: 3
                                        )
                                )
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 3)
                        }
                    }
                }
                .padding(.horizontal, 25)
            }
            .padding(.bottom, 50)
        }
        .background(Color.white)
        .clipShape(UnevenRoundedRectangle(topLeadingRadius: 50, topTrailingRadius: 50))
        .transition(.move(edge: .bottom))
        .ignoresSafeArea(edges: .bottom)
        .padding(.vertical, -40)
    }
}
