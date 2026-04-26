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

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray5).ignoresSafeArea()

                // MARK: - Home content — selalu ada di belakang
                ZStack {

                    // MARK: - Title — selalu di atas semua layer
                    VStack {
                        VStack(spacing: 4) {
                            if vm.isEditing {
                                TitleEditView(tripName: $vm.tripName, onClear: { vm.tripName = "" })
                            } else {
                                TitleNormalView(tripName: vm.tripName, documentCount: vm.documentCount)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        Spacer()
                    }
                    .zIndex(10)

                    // MARK: - Carousel + action buttons
                    VStack(spacing: 0) {
                        Spacer().frame(height: 140)

                        CarouselView(
                            totalCards: vm.totalCards,
                            selectedPouch: vm.selectedPouch,
                            isEditing: vm.isEditing,
                            isDetailActive: vm.isDetailActive,
                            isClosingDetail: vm.isClosingDetail,
                            onTap: {
                                vm.isDetailActive = true
                            }
                        )
                        .frame(height: 300)

                        if !vm.isDetailActive && !vm.isEditing {
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
                            .padding(.top, 10)
                            .padding(.bottom, 10)

                        } else if vm.isEditing {
                            Spacer()
                        }
                    }
                    .zIndex(1)

                    // MARK: - PouchDetailView
                    if vm.isDetailActive {
                        PouchDetailView(
                            selectedColor: vm.selectedColor,
                            selectedShape: vm.selectedShape,
                            columns: vm.columns,
                            searchText: $vm.searchText,
                            isCameraActive: $vm.isCameraActive,
                            isPhotoPickerActive: $vm.isPhotoPickerActive,
                            isFilePickerActive: $vm.isFilePickerActive,
                            isAddDocumentFormActive: $vm.isAddDocumentFormActive,
                            capturedImage: $vm.capturedImage,
                            photosItem: $vm.photosItem,
                            selectedCategory: $vm.selectedPouchCategory,
                            onBack: {
                                vm.isDetailActive = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    vm.isClosingDetail = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                                    vm.isClosingDetail = false
                                    vm.resetWidgetCategory()
                                }
                            },
                            onSelectDocument: { imageName, docName in
                                vm.selectDocument(imageName: imageName, docName: docName)
                            },
                            viewMode: vm.pouchViewMode
                        )
                        .padding(.top, 200)
                        .zIndex(5)
                    }

                    // MARK: - Buttons overlay saat detail aktif
                    if vm.isDetailActive {
                        HStack {
                            Button {
                                vm.isDetailActive = false
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                                    vm.isClosingDetail = true
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) {
                                    vm.isClosingDetail = false
                                    vm.resetWidgetCategory()
                                }
                            } label: {
                                Image(systemName: "chevron.left")
                                    .font(.title2).bold()
                                    .foregroundColor(.primary)
                                    .frame(width: 55, height: 55)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                            }

                            Spacer()

                            Menu {
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
                                    .font(.title2).bold()
                                    .foregroundColor(.primary)
                                    .frame(width: 55, height: 55)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal, 20)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                        .padding(.top, 20)
                        .zIndex(6)
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
                                        withAnimation(.spring()) { vm.isEditing = false }
                                }
                            )
                        }
                        .transition(.move(edge: .bottom))
                        .zIndex(20)
                    }
                }

                // MARK: - DocumentPreviewView sebagai overlay di atas semua
                if vm.isPreviewActive {
                    DocumentPreviewView(
                        selectedDocument: vm.selectedDocument,
                        selectedDocumentName: vm.selectedDocumentName,
                        onBack: {
                            // Langsung dismiss — home content sudah ada di belakang
                            vm.isPreviewActive = false
                        }
                    )
                    .background(Color(.systemGray5))
//                    .transition(.opacity)
                    .zIndex(100)
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
