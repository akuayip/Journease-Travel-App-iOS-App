//
//  PouchDetailView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI
import PhotosUI

struct PouchDetailView: View {
    let selectedColor: Color
    let selectedShape: String
    let columns: [GridItem]
    let namespace: Namespace.ID
    let isDetailActive: Bool

    @Binding var searchText: String
    @Binding var isCameraActive: Bool
    @Binding var isPhotoPickerActive: Bool
    @Binding var isFilePickerActive: Bool
    @Binding var isAddDocumentFormActive: Bool
    @Binding var capturedImage: UIImage?
    @Binding var photosItem: PhotosPickerItem?

    @Binding var selectedCategory: DocumentCategory

    let onBack: () -> Void
    let onSelectDocument: (String, String) -> Void
    let viewMode: HomeViewModel.PouchViewMode

    // MARK: - Dummy Data
    struct DocumentItem: Identifiable {
        let id = UUID()
        let name: String
        let category: DocumentCategory
        let imageName: String
    }

    let dummyDocuments: [DocumentItem] = [
        DocumentItem(name: "KTP", category: .identity, imageName: "ktp"),
        DocumentItem(name: "Passport", category: .identity, imageName: "ktp"),
        DocumentItem(name: "Visa", category: .identity, imageName: "ktp"),
        DocumentItem(name: "SIM", category: .identity, imageName: "ktp"),
        DocumentItem(name: "Tiket Pesawat", category: .transportation, imageName: "ktp"),
        DocumentItem(name: "Boarding Pass", category: .transportation, imageName: "ktp"),
        DocumentItem(name: "Tiket Kereta", category: .transportation, imageName: "ktp"),
        DocumentItem(name: "Booking Hotel", category: .accommodation, imageName: "ktp"),
        DocumentItem(name: "Voucher Airbnb", category: .accommodation, imageName: "ktp"),
        DocumentItem(name: "Tiket Wahana", category: .activity, imageName: "ktp"),
        DocumentItem(name: "Itinerary", category: .activity, imageName: "ktp"),
        DocumentItem(name: "Travel Insurance", category: .others, imageName: "ktp"),
    ]

    // MARK: - Filtered + Searched
    var searchedDocuments: [DocumentItem] {
        let filtered = selectedCategory == .all
            ? dummyDocuments
            : dummyDocuments.filter { $0.category == selectedCategory }

        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return filtered
        }
        return filtered.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.category.rawValue.lowercased().contains(searchText.lowercased())
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
                        .offset(y: isDetailActive ? 90 : geo.size.height) // ← mulai dari bawah
                        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: isDetailActive)
                        .matchedGeometryEffect(id: "hero_card", in: namespace, isSource: isDetailActive)

                    // Konten grid
                    VStack(spacing: 0) {
                        Spacer().frame(height: 180) // lewati bagian segitiga

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
                                            onSelectDocument(doc.imageName, doc.name)
                                        } label: {
                                            VStack(spacing: 4) {
                                                GeometryReader { g in
                                                    Image(doc.imageName)
                                                        .resizable()
                                                        .scaledToFit()
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
                                                    Text(doc.category.rawValue).font(.caption2)
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
                                            onSelectDocument(doc.imageName, doc.name)
                                        } label: {
                                            HStack(spacing: 14) {
                                                Image(doc.imageName)
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 60, height: 60)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(doc.name)
                                                        .font(.system(size: 14, weight: .semibold))
                                                        .foregroundColor(.black)
                                                        .lineLimit(1)
                                                    HStack(spacing: 4) {
                                                        Image(systemName: "folder").font(.caption2)
                                                        Text(doc.category.rawValue).font(.caption2)
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
                photosItem: $photosItem
            )
            .padding(.bottom, 20)
        }
        .fullScreenCover(isPresented: $isCameraActive) {
            CameraView(image: $capturedImage, isPresented: $isCameraActive)
                .ignoresSafeArea()
                .onChange(of: capturedImage) { _, newImage in
                    if newImage != nil { isAddDocumentFormActive = true }
                }
        }
    }
}
