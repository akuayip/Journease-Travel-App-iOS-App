//
//  HomeView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct Home: View {
    @Query(sort: \Trip.order) var trips: [Trip]
    @Environment(\.modelContext) var modelContext
    @StateObject private var vm = HomeViewModel()
    @State private var currentVisibleTrip: Trip? = nil
    @State private var scrolledTripID: Trip.ID? = nil

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemGray5).ignoresSafeArea()

                ZStack {

                    // MARK: - Title
                    VStack {
                        VStack(spacing: 4) {
                            if vm.isEditing {
                                TitleEditView(
                                    tripName: Binding(
                                        get: { vm.selectedTrip?.name ?? "" },
                                        set: { vm.selectedTrip?.name = $0 }
                                    ),
                                    onClear: { vm.selectedTrip?.name = "" }
                                )
                            } else {
                                TitleNormalView(
                                    tripName: currentVisibleTrip?.name ?? vm.selectedTrip?.name ?? "Journease",
                                    documentCount: vm.documentCount
                                )
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 60)
                        Spacer()
                    }
                    .zIndex(vm.isDetailActive ? 0 : 10)

                    // MARK: - Carousel
                    VStack(spacing: 0) {
                        Spacer().frame(height: 140)

                        if trips.isEmpty {
                            VStack(spacing: 16) {
                                Image(systemName: "bag.badge.plus")
                                    .font(.system(size: 50))
                                    .foregroundColor(.secondary)
                                Text("No trips yet")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Tap + to add your first trip")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .frame(height: 300)
                        } else {
                            CarouselView(
                                trips: trips,
                                isEditing: vm.isEditing,
                                isDetailActive: vm.isDetailActive,
                                isClosingDetail: vm.isClosingDetail,
                                onTap: { trip in
                                    vm.selectedTrip = trip
                                    vm.isPouchOpening = true
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                            vm.isDetailActive = true
                                            vm.isPouchOpening = false
                                        }
                                    }
                                },
                                onScroll: { trip in currentVisibleTrip = trip},
                                scrolledTripID: $scrolledTripID
                            )
                            .frame(height: 300)
                        }

                        if !vm.isDetailActive && !vm.isEditing {
                            ActionButtonsView(
                                onCustomize: {
                                    vm.selectedTrip = currentVisibleTrip ?? trips.first
                                    withAnimation(.spring()) { vm.isEditing = true }
                                },
                                onDelete: {
                                    // Hapus trip yang sedang terlihat di carousel
                                    if let tripToDelete = currentVisibleTrip ?? trips.first {
                                        modelContext.delete(tripToDelete)
                                        // Set ke trip pertama yang tersisa
                                        vm.selectedTrip = trips.first(where: { $0.id != tripToDelete.id })
                                        currentVisibleTrip = vm.selectedTrip
                                    }
                                },
                                onAdd: {
                                    let currentIndex = trips.firstIndex(where: { $0.id == currentVisibleTrip?.id }) ?? trips.count - 1
                                    
                                    for (i, trip) in trips.enumerated() {
                                        if i > currentIndex {
                                            trip.order += 1
                                        }
                                    }
                                    
                                    let newTrip = Trip(
                                        name: "Trip",  // ← selalu "Trip" tanpa nomor
                                        pouchColor: Trip.randomPouchColor(),
                                        order: currentIndex + 1
                                    )
                                    modelContext.insert(newTrip)
                                    vm.selectedTrip = newTrip
                                    currentVisibleTrip = newTrip
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                        withAnimation(.spring()) {
                                            scrolledTripID = newTrip.id
                                        }
                                    }
                                },
                                tripName: currentVisibleTrip?.name ?? "Trip",
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
                    .zIndex(vm.isDetailActive ? 20 : 1)
                    .opacity(vm.isPouchOpening || vm.isDetailActive ? 0 : 1)
                    .animation(.easeOut(duration: 0.15), value: vm.isPouchOpening)

                    // MARK: - PouchDetailView
                    if vm.isDetailActive {
                        PouchDetailView(
                            selectedColor: vm.selectedTrip?.color ?? Color(hex: "63BBF9"),
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
                        .padding(.top, 300)
                        .transition(.move(edge: .bottom))
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
                                selectedPouch: Binding(
                                    get: { vm.selectedTrip?.pouchColor ?? "pouch_blue" },
                                    set: { vm.selectedTrip?.pouchColor = $0 }
                                ),
                                pouchAssets: vm.pouchAssets,
                                onDone: {
                                    withAnimation(.spring()) { vm.isEditing = false }
                                }
                            )
                        }
                        .transition(.move(edge: .bottom))
                        .zIndex(20)
                    }
                }

                // MARK: - DocumentPreviewView
                if vm.isPreviewActive {
                    DocumentPreviewView(
                        selectedDocument: vm.selectedDocument,
                        selectedDocumentName: vm.selectedDocumentName,
                        onBack: {
                            vm.isPreviewActive = false
                        }
                    )
                    .background(Color(.systemGray5))
                    .zIndex(100)
                }
            }
        }
        .sheet(isPresented: $vm.isSearchActive) {
            DocumentSearchView()
        }
        .onAppear {
            if vm.selectedTrip == nil {
                vm.selectedTrip = trips.first
                currentVisibleTrip = trips.first
            }
        }
        .onChange(of: trips) { _, newTrips in
            if let selected = vm.selectedTrip, !newTrips.contains(where: { $0.id == selected.id }) {
                vm.selectedTrip = newTrips.first
                currentVisibleTrip = newTrips.first
            }
        }
        .onChange(of: vm.isEditing) { _, newValue in
            if !newValue {
                if let current = currentVisibleTrip {
                    scrolledTripID = current.id
                }
            }
        }
    }
}

#Preview {
    Home()
        .modelContainer(for: Trip.self, inMemory: true)
}
