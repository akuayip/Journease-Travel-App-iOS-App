//
//  SearchBarView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI
import PhotosUI

struct SearchBarView: View {
    @Binding var searchText: String
    @Binding var showAddOptions: Bool
    @Binding var isCameraActive: Bool
    @Binding var isPhotoPickerActive: Bool
    @Binding var isFilePickerActive: Bool
    @Binding var isAddDocumentFormActive: Bool
    @Binding var capturedImage: UIImage?
    @Binding var photosItem: PhotosPickerItem?

    var body: some View {
        HStack(spacing: 15) {
            HStack {
                Image(systemName: "magnifyingglass").font(.title2)
                TextField("Search", text: $searchText).font(.title3)
                Image(systemName: "mic.fill").font(.title2)
            }
            .padding(.horizontal, 20).frame(height: 55)
            .background(Color.white).clipShape(Capsule())
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

            Button { showAddOptions = true } label: {
                Image(systemName: "plus").font(.title2).bold().foregroundColor(.white)
                    .frame(width: 55, height: 55)
                    .background(Color.black).clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
            }
            .confirmationDialog("Add Document", isPresented: $showAddOptions, titleVisibility: .visible) {
                Button("Take a Photo") { isCameraActive = true }
                Button("Choose Photo") { isPhotoPickerActive = true }
                Button("Choose File") { isFilePickerActive = true }
                Button("Cancel", role: .cancel) { }
            }
            .photosPicker(isPresented: $isPhotoPickerActive, selection: $photosItem, matching: .images)
            .onChange(of: photosItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        capturedImage = uiImage
                        isAddDocumentFormActive = true
                    }
                }
            }
            .fileImporter(isPresented: $isFilePickerActive, allowedContentTypes: [.image, .pdf]) { result in
                if case .success(let url) = result,
                   let data = try? Data(contentsOf: url),
                   let uiImage = UIImage(data: data) {
                    capturedImage = uiImage
                    isAddDocumentFormActive = true
                }
            }
            .sheet(isPresented: $isAddDocumentFormActive) {
                DocumentFormView(selectedImage: capturedImage)
            }
        }
        .padding(.horizontal, 15)
    }
}


struct SearchBarHomeView: View {
    @Binding var searchText: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass").font(.title2)
            TextField("Search", text: $searchText).font(.title3)
            Image(systemName: "mic.fill").font(.title2)
        }
        .padding(.horizontal, 20).frame(height: 55)
        .background(Color.white).clipShape(Capsule())
        .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
        .padding(.horizontal, 30)
    }
}
