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
                    ZStack(alignment: .bottom) {
                        VStack(spacing: 0) {
                            VStack(spacing: 4) {
                                if vm.isEditing {
                                    TitleEditView(tripName: $vm.tripName, onClear: { vm.tripName = "" })
                                } else {
                                    TitleNormalView(tripName: vm.tripName, documentCount: vm.documentCount)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.top, 80)
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
                                        .padding(.top, 20)
                                        Spacer()
 
                                        // Search bar sebagai button trigger sheet
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
 
                            } else {
                                PouchDetailView(
                                    selectedColor: vm.selectedColor,
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
                                    onBack: {
                                        withAnimation(.spring()) { vm.isDetailActive = false }
                                    },
                                    onSelectDocument: { imageName, docName in
                                        vm.selectDocument(imageName: imageName, docName: docName)
                                    }
                                )
                                .padding(.top, 40)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
 
                        if vm.isEditing {
                            CustomizePanelView(
                                selectedPouch: $vm.selectedPouch,
                                pouchAssets: vm.pouchAssets,
                                onDone: {
                                    vm.validateTripName()
                                    withAnimation { vm.isEditing = false }
                                }
                            )
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
