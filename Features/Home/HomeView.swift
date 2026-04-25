//
//  HomeView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI
import PhotosUI

struct Home: View {

    @StateObject private var vm = HomeViewModel()
    @Namespace private var cardTransition

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray5).ignoresSafeArea()

                if vm.isPreviewActive {
                    DocumentPreviewView(
                        selectedDocument: vm.selectedDocument,
                        selectedDocumentName: vm.selectedDocumentName,
                        onBack: {
                            withAnimation(.spring()) { vm.isPreviewActive = false }
                        }
                    )
                    .transition(.asymmetric(insertion: .move(edge: .bottom), removal: .move(edge: .bottom)))

                } else {
                    ZStack {
                        // MARK: - Title + Carousel
                        VStack(spacing: 0) {
                            VStack(spacing: 4) {
                                if vm.isEditing {
                                    TitleEditView(tripName: $vm.tripName, onClear: { vm.tripName = "" })
                                } else {
                                    TitleNormalView(tripName: vm.tripName, documentCount: vm.documentCount)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, vm.isDetailActive ? 50 : 80)
                            .padding(.bottom, 20)

                            if !vm.isDetailActive {
                                VStack(spacing: 0) {
                                    CarouselView(
                                        totalCards: vm.totalCards,
                                        selectedPouch: vm.selectedPouch,
                                        isEditing: vm.isEditing,
                                        isDetailActive: vm.isDetailActive,
                                        namespace: cardTransition,
                                        onTap: {
                                            withAnimation(.spring()) { vm.isDetailActive = true }
                                        }
                                    )
                                    .frame(height: 300)

                                    if !vm.isEditing {
                                        ActionButtonsView(
                                            onCustomize: { withAnimation(.spring()) { vm.isEditing = true } },
                                            onDelete: { vm.deleteTrip() },
                                            onAdd: { print("Add trip") },
                                            showDeleteAlert: $vm.showDeleteTripAlert
                                        )
                                        Spacer()

                                        Button {
                                            vm.isSearchActive = true
                                        } label: {
                                            HStack {
                                                Image(systemName: "magnifyingglass")
                                                    .font(.title2)
                                                    .foregroundColor(.secondary)
                                                Text("Search")
                                                    .font(.title3)
                                                    .foregroundColor(.secondary)
                                                Spacer()
                                                Image(systemName: "mic.fill")
                                                    .font(.title2)
                                                    .foregroundColor(.secondary)
                                            }
                                            .padding(.horizontal, 20)
                                            .frame(height: 55)
                                            .background(Color.white)
                                            .clipShape(Capsule())
                                            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
                                            .padding(.horizontal, 30)
                                        }
                                        .padding(.bottom, 10)

                                    } else {
                                        Spacer()
                                    }
                                }
                                .transition(.asymmetric(insertion: .opacity, removal: .opacity))
                            }

                            Spacer()
                        }

                        // MARK: - PouchDetailView
                        if vm.isDetailActive {
                            PouchDetailView(
                                selectedColor: vm.selectedColor,
                                selectedShape: vm.selectedShape,
                                columns: vm.columns,
                                namespace: cardTransition,
                                isDetailActive: vm.isDetailActive,
                                searchText: $vm.searchText,
                                isCameraActive: $vm.isCameraActive,
                                isPhotoPickerActive: $vm.isPhotoPickerActive,
                                isFilePickerActive: $vm.isFilePickerActive,
                                isAddDocumentFormActive: $vm.isAddDocumentFormActive,
                                capturedImage: $vm.capturedImage,
                                photosItem: $vm.photosItem,
                                selectedCategory: $vm.selectedPouchCategory,
                                onBack: {
                                    withAnimation(.spring()) {
                                        vm.isDetailActive = false
                                        vm.resetWidgetCategory()
                                    }
                                },
                                onSelectDocument: { imageName, docName in
                                    vm.selectDocument(imageName: imageName, docName: docName)
                                },
                                viewMode: vm.pouchViewMode
                            )
                            .padding(.top, 120)
                            .transition(.move(edge: .bottom).combined(with: .opacity))
                            .zIndex(1)

                            // MARK: - Buttons overlay sejajar title
                            HStack {
                                // Back button
                                Button {
                                    withAnimation(.spring()) {
                                        vm.isDetailActive = false
                                        vm.resetWidgetCategory()
                                    }
                                } label: {
                                    Image(systemName: "chevron.left")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.primary)
                                        .frame(width: 50, height: 50)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                                }

                                Spacer()

                                // Sort + View mode menu
                                Menu {
                                    // View mode toggle
                                    if vm.pouchViewMode == .gallery {
                                        Button { vm.pouchViewMode = .list } label: {
                                            Label("View as List", systemImage: "list.bullet")
                                        }
                                    } else {
                                        Button { vm.pouchViewMode = .gallery } label: {
                                            Label("View as Gallery", systemImage: "square.grid.2x2")
                                        }
                                    }

                                    Divider()

                                    // Sort by category
                                    ForEach(DocumentCategory.allCases, id: \.self) { category in
                                        Button { vm.selectedPouchCategory = category } label: {
                                            HStack {
                                                Text(category.rawValue)
                                                if vm.selectedPouchCategory == category {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    Image(systemName: "ellipsis")
                                        .font(.title2)
                                        .bold()
                                        .foregroundColor(.primary)
                                        .frame(width: 50, height: 50)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                                }
                            }
                            .padding(.horizontal, 20)
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                            .padding(.top, 55)
                            .zIndex(2)
                        }

                        // MARK: - Customize panel
                        if vm.isEditing {
                            VStack {
                                Spacer()
                                CustomizePanelView(
                                    selectedPouch: $vm.selectedPouch,
                                    pouchAssets: vm.pouchAssets,
                                    onDone: {
                                        vm.validateTripName()
                                        withAnimation { vm.isEditing = false }
                                    }
                                )
                            }
                            .zIndex(3)
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $vm.isSearchActive) {
            DocumentSearchView()
        }
    }
}

#Preview {
    Home()
}
