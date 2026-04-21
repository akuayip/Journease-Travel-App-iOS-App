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
    let columns: [GridItem]
    let namespace: Namespace.ID
    let isDetailActive: Bool

    @Binding var searchText: String
    @Binding var showAddOptions: Bool
    @Binding var isCameraActive: Bool
    @Binding var isPhotoPickerActive: Bool
    @Binding var isFilePickerActive: Bool
    @Binding var isAddDocumentFormActive: Bool
    @Binding var capturedImage: UIImage?
    @Binding var photosItem: PhotosPickerItem?
    @State private var selectedCategory: DocumentCategory = .all
    @State private var showSortingOptions: Bool = false

    let onBack: () -> Void
    let onSelectDocument: (String, String) -> Void
    
    enum DocumentCategory: String, CaseIterable {
        case all = "All"
        case identity = "Identity"
        case transportation = "Transportation"
        case accommodation = "Accommodation"
        case activity = "Activity & Attraction"
        case others = "Others"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            GeometryReader { geo in
                ZStack(alignment: .top) {
                    RoundedRectangle(cornerRadius: 50)
                        .fill(selectedColor)
                        .frame(width: geo.size.width, height: geo.size.height)
                        .matchedGeometryEffect(id: "hero_card", in: namespace, isSource: isDetailActive)

                    VStack(spacing: 0) {
                        // Header buttons
                        HStack(spacing: 12) {
                            Button { onBack() } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title3).bold()
                                    .foregroundStyle(.black)
                                    .frame(width: 50, height: 50)
                                    .background(Color.black.opacity(0.12))
                                    .clipShape(Circle())
                            }
                            Spacer()
                            Button { print("Folder") } label: {
                                Image(systemName: "folder.badge.plus")
                                    .font(.title3)
                                    .foregroundStyle(.black)
                                    .frame(width: 50, height: 50)
                                    .background(Color.black.opacity(0.12))
                                    .clipShape(Circle())
                            }
                            Button { print("Edit") } label: {
                                Text("Edit")
                                    .font(.headline)
                                    .foregroundStyle(.black)
                                    .frame(width: 75, height: 50)
                                    .background(Color.black.opacity(0.12))
                                    .clipShape(Capsule())
                            }
                        }
                        .padding(.top, 20)
                        .padding(.horizontal, 20)

                        // Sorting bar
                        HStack {
                            Text("Sort Dcocument by")
                                .font(.body)
                                .foregroundColor(.black.opacity(0.8))
                            Spacer()
                            Picker("", selection: $selectedCategory) {
                                ForEach(DocumentCategory.allCases, id: \.self) { category in
                                    Text(category.rawValue).tag(category)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.black.opacity(0.6))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.white.opacity(0.4))
                        .clipShape(Capsule())
                        .padding(.horizontal, 20)
                        .padding(.top, 12)

                        // Document Grid
                        ScrollView(showsIndicators: false) {
                            LazyVGrid(columns: columns, spacing: 14) {
                                ForEach(0..<9) { _ in
                                    Button {
                                        onSelectDocument("ktp", "KTP")
                                    } label: {
                                        VStack(spacing: 4) {
                                            GeometryReader { g in
                                                Image("ktp")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width, height: 85)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                            .frame(height: 85)

                                            Text("KTP")
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.black)
                                            HStack(spacing: 3) {
                                                Image(systemName: "folder").font(.caption2)
                                                Text("Identity").font(.caption2)
                                            }
                                            .foregroundColor(.black.opacity(0.6))
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.top, 14)
                            .padding(.bottom, 80)
                        }
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height)
            }
            .padding(.vertical, -40)
            .ignoresSafeArea(edges: .bottom)

            // Search bar di luar GeometryReader — tidak ikut turun
            SearchBarView(
                searchText: $searchText,
                showAddOptions: $showAddOptions,
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
