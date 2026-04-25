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
    @Published var tripName: String = "Japan Trip"
    @Published var documentCount: Int = 23
    @Published var pouchViewMode: PouchViewMode = .gallery
    @Published var selectedPouchCategory: DocumentCategory = .all

    // MARK: - Navigation
    @Published var isEditing: Bool = false
    @Published var isDetailActive: Bool = false
    @Published var isPreviewActive: Bool = false
    @Published var isSearchActive: Bool = false

    // MARK: - Document
    @Published var selectedDocument: String = ""
    @Published var selectedDocumentName: String = ""
    @Published var isDocumentFormActive: Bool = false

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

    // MARK: - Pouch
    @Published var selectedPouch: String = "pouch_blue"

    // MARK: - Deep Link
    @Published var selectedCategoryFromWidget: String = ""

    // MARK: - Constants
    let totalCards = 3
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    let pouchAssets = ["pouch_blue", "pouch_gray", "pouch_green", "pouch_pink", "pouch_purple", "pouch_yellow"]

    private let pouchToColor: [String: Color] = [
        "pouch_blue"   : Color(hex: "63BBF9"),
        "pouch_gray"   : Color(hex: "D4D6D9"),
        "pouch_green"  : Color(hex: "9CDDD0"),
        "pouch_pink"   : Color(hex: "F7B6C5"),
        "pouch_purple" : Color(hex: "BAABEB"),
        "pouch_yellow" : Color(hex: "FCDC7E")
    ]

    private let pouchToShape: [String: String] = [
        "pouch_blue"   : "shape_blue",
        "pouch_gray"   : "shape_gray",
        "pouch_green"  : "shape_green",
        "pouch_pink"   : "shape_pink",
        "pouch_purple" : "shape_purple",
        "pouch_yellow" : "shape_yellow"
    ]

    // MARK: - Computed Properties
    var selectedColor: Color {
        pouchToColor[selectedPouch] ?? Color(hex: "63BBF9")
    }

    var selectedShape: String {
        pouchToShape[selectedPouch] ?? "shape_blue"
    }

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
        print("Trip \(tripName) deleted")
    }

    func validateTripName() {
        if tripName.trimmingCharacters(in: .whitespaces).isEmpty {
            tripName = "Trip"
        }
    }

    func resetWidgetCategory() {
        selectedCategoryFromWidget = ""
    }
}
