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
    @Environment(\.modelContext) private var modelContext

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

    @State private var isSelectionMode = false
    @State private var selectedDocumentIDs: Set<Document.ID> = []
    @State private var showDeleteDocumentsAlert = false

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
                                    Text("Tap + to add your documents essential")
                                        .font(.caption)
                                        .foregroundColor(.black.opacity(0.4))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.top, 60)

                            } else if viewMode == .gallery {
                                LazyVGrid(columns: columns, spacing: 14) {
                                    ForEach(searchedDocuments) { doc in
                                        VStack(spacing: 4) {
                                            GeometryReader { g in
                                                documentThumbnail(doc: doc)
                                                    .frame(width: g.size.width, height: 85)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                                    .overlay {
                                                        selectionBorder(for: doc, cornerRadius: 10)
                                                    }
                                                    .overlay(alignment: .topTrailing) {
                                                        selectionBadge(for: doc)
                                                            .padding(6)
                                                    }
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
                                        .opacity(isSelectionMode && !isSelected(doc) ? 0.65 : 1)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            handleDocumentTap(doc)
                                        }
                                        .onLongPressGesture {
                                            enterSelectionMode(with: doc)
                                        }
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 14)
                                .padding(.bottom, 100)

                            } else {
                                LazyVStack(spacing: 10) {
                                    ForEach(searchedDocuments) { doc in
                                        HStack(spacing: 14) {
                                            documentThumbnail(doc: doc)
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                                .overlay {
                                                    selectionBorder(for: doc, cornerRadius: 10)
                                                }
                                                .overlay(alignment: .topTrailing) {
                                                    selectionBadge(for: doc)
                                                        .padding(4)
                                                }
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
                                            Image(systemName: isSelectionMode ? (isSelected(doc) ? "checkmark.circle.fill" : "circle") : "chevron.right")
                                                .font(isSelectionMode ? .title3 : .caption)
                                                .foregroundColor(isSelected(doc) ? .black : .black.opacity(0.4))
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 10)
                                        .background(isSelected(doc) ? Color.white.opacity(0.7) : Color.white.opacity(0.4))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .padding(.horizontal, 16)
                                        .contentShape(Rectangle())
                                        .onTapGesture {
                                            handleDocumentTap(doc)
                                        }
                                        .onLongPressGesture {
                                            enterSelectionMode(with: doc)
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

            // MARK: - Search bar / selection actions
            if isSelectionMode {
                selectionActionBar
                    .padding(.bottom, 20)
            } else {
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

    private var selectionActionBar: some View {
        HStack(spacing: 12) {
            Button("Cancel") {
                exitSelectionMode()
            }
            .font(.headline)
            .foregroundColor(.primary)
            .frame(height: 55)
            .padding(.horizontal, 18)
            .background(Color(.systemBackground))
            .clipShape(Capsule())
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

            Text("\(selectedDocumentIDs.count) Selected")
                .font(.headline)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 55)
                .background(Color(.systemBackground))
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)

            Button {
                showDeleteDocumentsAlert = true
            } label: {
                Image(systemName: "trash")
                    .font(.title2)
                    .foregroundColor(.white)
                    .frame(width: 55, height: 55)
                    .background(selectedDocumentIDs.isEmpty ? Color.gray.opacity(0.45) : Color.red)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.12), radius: 10, x: 0, y: 5)
            }
            .disabled(selectedDocumentIDs.isEmpty)
            .alert(deleteAlertTitle, isPresented: $showDeleteDocumentsAlert) {
                Button("Delete", role: .destructive) {
                    deleteSelectedDocuments()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Selected documents will be removed from this pouch.")
            }
        }
        .padding(.horizontal, 15)
    }

    private var deleteAlertTitle: String {
        selectedDocumentIDs.count == 1
            ? "Delete selected document?"
            : "Delete \(selectedDocumentIDs.count) selected documents?"
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

    @ViewBuilder
    private func selectionBadge(for doc: Document) -> some View {
        if isSelectionMode {
            ZStack {
                Circle()
                    .fill(isSelected(doc) ? Color(hex: "E6B435") : Color.white.opacity(0.9))
                    .frame(width: 28, height: 28)
                Circle()
                    .stroke(isSelected(doc) ? Color.white : Color.gray.opacity(0.45), lineWidth: 2)
                    .frame(width: 28, height: 28)
                if isSelected(doc) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
        }
    }

    @ViewBuilder
    private func selectionBorder(for doc: Document, cornerRadius: CGFloat) -> some View {
        if isSelectionMode {
            RoundedRectangle(cornerRadius: cornerRadius)
                .strokeBorder(
                    isSelected(doc) ? Color(hex: "E6B435") : Color.white.opacity(0.8),
                    lineWidth: isSelected(doc) ? 4 : 2
                )
        }
    }

    private func handleDocumentTap(_ doc: Document) {
        if isSelectionMode {
            toggleSelection(for: doc)
        } else {
            onSelectDocument(doc)
        }
    }

    private func enterSelectionMode(with doc: Document) {
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.spring()) {
            isSelectionMode = true
            selectedDocumentIDs = [doc.id]
        }
    }

    private func toggleSelection(for doc: Document) {
        withAnimation(.spring()) {
            if selectedDocumentIDs.contains(doc.id) {
                selectedDocumentIDs.remove(doc.id)
            } else {
                selectedDocumentIDs.insert(doc.id)
            }

            if selectedDocumentIDs.isEmpty {
                isSelectionMode = false
            }
        }
    }

    private func isSelected(_ doc: Document) -> Bool {
        selectedDocumentIDs.contains(doc.id)
    }

    private func exitSelectionMode() {
        withAnimation(.spring()) {
            isSelectionMode = false
            selectedDocumentIDs.removeAll()
        }
    }

    private func deleteSelectedDocuments() {
        let documentsToDelete = documents.filter { selectedDocumentIDs.contains($0.id) }

        for document in documentsToDelete {
            if let filePath = document.filePath {
                FileManagerHelper.deleteFile(filename: filePath)
            }
            modelContext.delete(document)
        }

        exitSelectionMode()
    }
}
