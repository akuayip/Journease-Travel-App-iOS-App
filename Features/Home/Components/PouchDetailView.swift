//
//  PouchDetailView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct PouchDetailView: View {
    let selectedColor: Color
    let selectedShape: String
    let columns: [GridItem]
    let trip: Trip?

    @Binding var searchText: String
    @Binding var isCameraActive: Bool
    @Binding var isPhotoPickerActive: Bool
    @Binding var isFilePickerActive: Bool
    @Binding var isAddDocumentFormActive: Bool
    @Binding var capturedImage: UIImage?
    @Binding var photosItem: PhotosPickerItem?
    @Binding var selectedFileURL: URL?  // ← binding langsung, bukan $vm

    @Binding var selectedCategory: DocumentCategory

    let onBack: () -> Void
    let onSelectDocument: (Document) -> Void
    let viewMode: HomeViewModel.PouchViewMode

    // MARK: - Filtered + Searched dari trip
    var documents: [Document] {
        trip?.documents ?? []
    }

    var searchedDocuments: [Document] {
        let filtered = selectedCategory == .all
            ? documents
            : documents.filter { $0.category == selectedCategory.rawValue }

        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return filtered
        }
        return filtered.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.category.lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {

            // MARK: - Shape + konten
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    // Background shape
                    Image(selectedShape)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .offset(y: -30)

                    // Konten grid
                    VStack(spacing: 0) {
                        Spacer()

                        ScrollView(showsIndicators: false) {
                            if searchedDocuments.isEmpty {
                                VStack(spacing: 12) {
                                    Image(systemName: "doc.text.magnifyingglass")
                                        .font(.system(size: 40))
                                        .foregroundColor(.black.opacity(0.3))
                                    Text("No documents found")
                                        .font(.headline)
                                        .foregroundColor(.black.opacity(0.6))
                                    Text("Try a different keyword or category")
                                        .font(.caption)
                                        .foregroundColor(.black.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)

                            } else if viewMode == .gallery {
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(searchedDocuments) { doc in
                                        Button {
                                            onSelectDocument(doc)
                                        } label: {
                                            VStack(spacing: 4) {
                                                GeometryReader { g in
                                                    documentThumbnail(doc: doc)
                                                        .frame(width: g.size.width, height: 85)
                                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                                }
                                                .frame(height: 85)
                                                Text(doc.name)
                                                    .font(.system(size: 12, weight: .semibold))
                                                    .foregroundColor(.black)
                                                    .lineLimit(1)
                                                HStack(spacing: 3) {
                                                    Image(systemName: "folder").font(.caption2)
                                                    Text(doc.category).font(.caption2)
                                                        .lineLimit(1)
                                                }
                                                .foregroundColor(.black.opacity(0.6))
                                            }
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                                .padding(.bottom, 100)

                            } else {
                                LazyVStack(spacing: 10) {
                                    ForEach(searchedDocuments) { doc in
                                        Button {
                                            onSelectDocument(doc)
                                        } label: {
                                            HStack(spacing: 14) {
                                                documentThumbnail(doc: doc)
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(doc.name)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.black)
                                                        .lineLimit(1)
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "folder").font(.caption2)
                                                        Text(doc.category).font(.caption2)
                                                            .lineLimit(1)
                                                    }
                                                    .foregroundColor(.black.opacity(0.6))
                                                }
                                                Spacer()
                                                Image(systemName: "chevron.right")
                                                    .font(.caption)
                                                    .foregroundColor(.black.opacity(0.4))
                                            }
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 10)
                                            .background(Color.white.opacity(0.4))
                                            .clipShape(RoundedRectangle(cornerRadius: 14))
                                            .padding(.horizontal, 16)
                                        }
                                    }
                                }
                                .padding(.top, 14)
                                .padding(.bottom, 100)
                            }
                        }
//                        .onTapGesture {
//                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .padding(.vertical, -40)
            .ignoresSafeArea(edges: .bottom)

            // MARK: - Search bar
            SearchBarView(
                searchText: $searchText,
                isCameraActive: $isCameraActive,
                isPhotoPickerActive: $isPhotoPickerActive,
                isFilePickerActive: $isFilePickerActive,
                isAddDocumentFormActive: $isAddDocumentFormActive,
                capturedImage: $capturedImage,
                photosItem: $photosItem,
                selectedFileURL: $selectedFileURL,  // ← binding langsung
                trip: trip
            )
            .padding(.bottom, 20)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        
        .fullScreenCover(isPresented: $isCameraActive) {
            CameraView(image: $capturedImage, isPresented: $isCameraActive)
                .ignoresSafeArea()
        }
        .onChange(of: capturedImage) { _, newImage in
            if newImage != nil { isAddDocumentFormActive = true }
        }
    }

    // MARK: - Thumbnail helper
    @ViewBuilder
    private func documentThumbnail(doc: Document) -> some View {
        if let filePath = doc.filePath,
           let image = FileManagerHelper.loadImage(from: filePath) {
            Image(uiImage: image)
                .resizable()
                .scaledToFill()
        } else if doc.fileType == "pdf",
                  let filePath = doc.filePath,
                  let pdfImage = FileManagerHelper.loadPDFThumbnail(from: filePath) {
            Image(uiImage: pdfImage)
                .resizable()
                .scaledToFill()
        } else {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.1))
                Image(systemName: "doc")
                    .font(.system(size: 30))
                    .foregroundColor(.gray.opacity(0.7))
            }
        }
    }
}
