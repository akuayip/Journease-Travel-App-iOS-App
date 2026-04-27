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
    @Binding var isCameraActive: Bool
    @Binding var isPhotoPickerActive: Bool
    @Binding var isFilePickerActive: Bool
    @Binding var isAddDocumentFormActive: Bool
    @Binding var capturedImage: UIImage?
    @Binding var photosItem: PhotosPickerItem?
    @Binding var selectedFileURL: URL?
    let trip: Trip?

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

            Menu {
                Button {
                    isFilePickerActive = true
                } label: {
                    Label("Choose File", systemImage: "doc")
                }

                Button {
                    isPhotoPickerActive = true
                } label: {
                    Label("Choose Photo", systemImage: "photo")
                }
                Button {
                    isCameraActive = true
                } label: {
                    Label("Take a Photo", systemImage: "camera")
                }
            } label: {
                Image(systemName: "plus").font(.title2).foregroundColor(.black)
                    .frame(width: 55, height: 55)
                    .background(Color.white).clipShape(Circle())
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
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
                if case .success(let url) = result {
                    _ = url.startAccessingSecurityScopedResource()
                    if url.pathExtension.lowercased() == "pdf" {
                        _ = url.startAccessingSecurityScopedResource()
                        
                        let tempURL = FileManager.default.temporaryDirectory
                            .appendingPathComponent(UUID().uuidString + ".pdf")
                        try? FileManager.default.copyItem(at: url, to: tempURL)
                        
                        url.stopAccessingSecurityScopedResource()
                        
                        selectedFileURL = tempURL
                        DispatchQueue.main.async {
                            isAddDocumentFormActive = true
                        }
                    } else if let data = try? Data(contentsOf: url),
                              let uiImage = UIImage(data: data) {
                        capturedImage = uiImage
                        DispatchQueue.main.async {
                            isAddDocumentFormActive = true
                        }
                    }
                    url.stopAccessingSecurityScopedResource()
                }
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
