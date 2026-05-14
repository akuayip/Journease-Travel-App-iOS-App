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
    @State private var pendingScrollTripID: Trip.ID? = nil
    @State private var pendingScrollOrder: Int? = nil

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
                                    documentCount: currentVisibleTrip?.documents.count ?? vm.selectedTrip?.documents.count ?? 0
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
                                onScroll: { trip in
                                    if pendingScrollTripID != nil || pendingScrollOrder != nil {
                                        guard trip.id == pendingScrollTripID || trip.order == pendingScrollOrder else { return }
                                    }

                                    currentVisibleTrip = trip
                                    vm.selectedTrip = trip
                                },
                                scrolledTripID: $scrolledTripID
                            )
                            .frame(height: 300)
                        }

                        if !vm.isDetailActive && !vm.isEditing {
                            ActionButtonsView(
                                onCustomize: {
                                    vm.selectedTrip = currentTripForAction()
                                    withAnimation(.spring()) { vm.isEditing = true }
                                },
                                onDeleteTap: handleDeleteTap,
                                onDelete: deleteCurrentTrip,
                                onAdd: addTripAfterCurrent,
                                tripName: currentTripForAction()?.name ?? "Trip",
                                hasTrips: !trips.isEmpty,
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
                                .background(Color(.systemBackground))
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
                            trip: vm.selectedTrip,  // ← pass trip
                            searchText: $vm.searchText,
                            isCameraActive: $vm.isCameraActive,
                            isPhotoPickerActive: $vm.isPhotoPickerActive,
                            isFilePickerActive: $vm.isFilePickerActive,
                            isAddDocumentFormActive: $vm.isAddDocumentFormActive,
                            capturedImage: $vm.capturedImage,
                            photosItem: $vm.photosItem,
                            selectedFileURL: $vm.selectedFileURL,
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
                            onSelectDocument: { document in
                                vm.selectedDocumentObject = document
                                vm.isPreviewActive = true
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
                                    .background(Color(.systemBackground))
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
                                    .font(.title2)
                                    .foregroundColor(.primary)
                                    .frame(width: 55, height: 55)
                                    .background(Color(.systemBackground))
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
                if vm.isPreviewActive, let document = vm.selectedDocumentObject {
                    DocumentPreviewView(
                        document: document,
                        onBack: {
                            vm.isPreviewActive = false
                        },
                        onDelete: {
                            vm.selectedDocumentObject = nil
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
        // Sheet untuk add document form
        .sheet(isPresented: $vm.isAddDocumentFormActive) {
            DocumentFormView(
                trip: vm.selectedTrip,
                selectedImage: vm.capturedImage,
                selectedFileURL: vm.selectedFileURL
            )
            .onDisappear {
                vm.capturedImage = nil
                vm.photosItem = nil
                vm.selectedFileURL = nil
            }
        }
        .onAppear {
            if vm.selectedTrip == nil {
                vm.selectedTrip = trips.first
                currentVisibleTrip = trips.first
            }
        }
        .onChange(of: trips) { _, newTrips in
            if let pendingTrip = pendingTrip(in: newTrips) {
                DispatchQueue.main.async {
                    vm.selectedTrip = pendingTrip
                    currentVisibleTrip = pendingTrip
                    withAnimation(.spring()) {
                        scrolledTripID = pendingTrip.id
                    }

                    let resolvedID = pendingTrip.id
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                        if pendingScrollTripID == resolvedID || pendingScrollOrder == pendingTrip.order {
                            pendingScrollTripID = nil
                            pendingScrollOrder = nil
                        }
                    }
                }
                return
            }

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

    private func pendingTrip(in trips: [Trip]) -> Trip? {
        if let pendingID = pendingScrollTripID,
           let trip = trips.first(where: { $0.id == pendingID }) {
            return trip
        }

        if let pendingOrder = pendingScrollOrder {
            return trips.first(where: { $0.order == pendingOrder })
        }

        return nil
    }

    private func addTripAfterCurrent() {
        let currentTrip = currentTripForInsertion()
        let currentIndex = currentTrip.flatMap { current in
            trips.firstIndex(where: { $0.id == current.id })
        } ?? trips.count - 1
        let insertionIndex = trips.isEmpty ? 0 : min(currentIndex + 1, trips.count)

        for (index, trip) in trips.enumerated() {
            trip.order = index >= insertionIndex ? index + 1 : index
        }

        let newTrip = Trip(
            name: "Trip",
            pouchColor: Trip.randomPouchColor(),
            order: insertionIndex
        )

        vm.selectedTrip = newTrip
        currentVisibleTrip = newTrip
        pendingScrollTripID = newTrip.id
        pendingScrollOrder = insertionIndex
        scrolledTripID = newTrip.id
        modelContext.insert(newTrip)
    }

    private func deleteCurrentTrip() {
        guard let tripToDelete = currentTripForAction(),
              let deleteIndex = trips.firstIndex(where: { $0.id == tripToDelete.id })
        else { return }

        let nextTrip = nextTripAfterDeleting(at: deleteIndex)
        modelContext.delete(tripToDelete)

        for (index, trip) in trips.filter({ $0.id != tripToDelete.id }).enumerated() {
            trip.order = index
        }

        vm.selectedTrip = nextTrip
        currentVisibleTrip = nextTrip
        scrolledTripID = nextTrip?.id
        pendingScrollTripID = nil
        pendingScrollOrder = nil
    }

    private func handleDeleteTap() {
        guard let trip = currentTripForAction() else { return }

        if trip.documents.isEmpty {
            deleteCurrentTrip()
        } else {
            vm.showDeleteTripAlert = true
        }
    }

    private func nextTripAfterDeleting(at index: Int) -> Trip? {
        let remainingTrips = trips.enumerated()
            .filter { $0.offset != index }
            .map(\.element)

        if index < remainingTrips.count {
            return remainingTrips[index]
        }

        return remainingTrips.last
    }

    private func currentTripForInsertion() -> Trip? {
        currentTripForAction() ?? trips.last
    }

    private func currentTripForAction() -> Trip? {
        if let scrolledID = scrolledTripID,
           let trip = trips.first(where: { $0.id == scrolledID }) {
            return trip
        }

        if let visibleTrip = currentVisibleTrip,
           let trip = trips.first(where: { $0.id == visibleTrip.id }) {
            return trip
        }

        if let selectedTrip = vm.selectedTrip,
           let trip = trips.first(where: { $0.id == selectedTrip.id }) {
            return trip
        }

        return nil
    }
}

#Preview {
    Home()
        .modelContainer(for: [Trip.self, Document.self], inMemory: true)
}
