//
//  DocumentPreviewView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI

struct DocumentPreviewView: View {
    let selectedDocument: String
    let selectedDocumentName: String
    let onBack: () -> Void

    @State private var isDocumentFormActive: Bool = false

    var body: some View {
        VStack {
            HStack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 55, height: 55)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                Spacer()
                Text(selectedDocumentName).font(.title3).bold()
                Spacer()
                Button { isDocumentFormActive = true } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 55, height: 55)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
            .padding(20)

            Image(selectedDocument)
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(20)

            Spacer()
        }
        .sheet(isPresented: $isDocumentFormActive) {
            DocumentFormView(initialDocName: selectedDocumentName)
        }
    }
}
