//
//  TitleView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI

struct TitleNormalView: View {
    let tripName: String
    let documentCount: Int

    var body: some View {
        VStack(spacing: 4) {
            Text(tripName.isEmpty ? "Trip" : tripName)
                .font(.largeTitle).bold().lineLimit(1).padding(.horizontal, 30)
            Text("\(documentCount) Documents")
                .font(.headline).foregroundColor(.secondary)
        }
    }
}

struct TitleEditView: View {
    @Binding var tripName: String
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            TextField("Trip", text: $tripName)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(1)
            Button { onClear() } label: {
                Image(systemName: "xmark")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(.horizontal, 20).padding(.vertical, 12)
        .background(Color.gray).cornerRadius(16)
        .fixedSize(horizontal: true, vertical: false)
    }
}
