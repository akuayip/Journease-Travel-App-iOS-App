//
//  ActionButtonView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI

struct ActionButtonsView: View {
    let onCustomize: () -> Void
    let onDelete: () -> Void
    let onAdd: () -> Void
    @Binding var showDeleteAlert: Bool

    var body: some View {
        HStack(spacing: 20) {
            Button { onCustomize() } label: {
                Image(systemName: "slider.horizontal.3").font(.title2).foregroundStyle(.white)
                    .frame(width: 58, height: 58).background(.gray).clipShape(Circle())
            }
            Button { showDeleteAlert = true } label: {
                Image(systemName: "trash").font(.title2).foregroundStyle(.white)
                    .frame(width: 58, height: 58).background(.gray).clipShape(Circle())
            }
            .alert("Are you sure you want to delete this trip?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) { onDelete() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("All documents will be deleted.")
            }
            Button { onAdd() } label: {
                Image(systemName: "plus").font(.title2).bold().foregroundStyle(.white)
                    .frame(width: 58, height: 58).background(.gray).clipShape(Circle())
            }
            
        }
        .padding(.top, 70)
    }
}
