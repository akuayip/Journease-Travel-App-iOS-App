//
//  HomeViewModel.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI
import PhotosUI
import Combine

@MainActor
class HomeViewModel: ObservableObject {

    enum PouchViewMode {
        case gallery
        case list
    }

    // MARK: - Trip
    @Published var selectedTrip: Trip?
    @Published var pouchViewMode: PouchViewMode = .gallery
    @Published var selectedPouchCategory: DocumentCategory = .all
    @Published var isPouchOpening: Bool = false

    // MARK: - Navigation
    @Published var isEditing: Bool = false
    @Published var isDetailActive: Bool = false
    @Published var isClosingDetail: Bool = false
    @Published var isPreviewActive: Bool = false
    @Published var isSearchActive: Bool = false

    // MARK: - Document
    @Published var selectedDocument: String = ""
    @Published var selectedDocumentName: String = ""

    // MARK: - Add Document
    @Published var isAddDocumentFormActive: Bool = false
    @Published var isCameraActive: Bool = false
    @Published var isPhotoPickerActive: Bool = false
    @Published var isFilePickerActive: Bool = false
    @Published var capturedImage: UIImage? = nil
    @Published var photosItem: PhotosPickerItem? = nil

    // MARK: - Alert
    @Published var showDeleteTripAlert: Bool = false

    // MARK: - Search
    @Published var searchText: String = ""

    // MARK: - Deep Link
    @Published var selectedCategoryFromWidget: String = ""

    // MARK: - Computed Properties dari selectedTrip
    var selectedPouch: String {
        selectedTrip?.pouchColor ?? "pouch_blue"
    }

    var selectedColor: Color {
        selectedTrip?.color ?? Color(hex: "63BBF9")
    }

    var selectedShape: String {
        let pouchToShape: [String: String] = [
            "pouch_blue"   : "shape_blue",
            "pouch_gray"   : "shape_gray",
            "pouch_green"  : "shape_green",
            "pouch_pink"   : "shape_pink",
            "pouch_purple" : "shape_purple",
            "pouch_yellow" : "shape_yellow"
        ]
        return pouchToShape[selectedPouch] ?? "shape_blue"
    }

    // Sementara 0 — akan diupdate setelah relasi Trip ↔ Document dibuat
    var documentCount: Int {
        0
    }

    // MARK: - Constants
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    let pouchAssets = ["pouch_blue", "pouch_gray", "pouch_green", "pouch_pink", "pouch_purple", "pouch_yellow"]

    // MARK: - Init
    init() {
        NotificationCenter.default.addObserver(
            forName: .openCategory,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            guard let self else { return }
            let category = notification.userInfo?["category"] as? String ?? ""
            Task { @MainActor in
                self.isDetailActive = true
                self.selectedCategoryFromWidget = category
            }
        }
    }

    // MARK: - Actions
    func selectDocument(imageName: String, docName: String) {
        selectedDocument = imageName
        selectedDocumentName = docName
        isPreviewActive = true
    }

    func deleteTrip() {
        print("Delete trip: \(selectedTrip?.name ?? "")")
    }

    func resetWidgetCategory() {
        selectedCategoryFromWidget = ""
        selectedPouchCategory = .all
    }
}
