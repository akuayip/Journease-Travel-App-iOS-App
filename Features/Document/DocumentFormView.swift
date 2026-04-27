//
//  DocumentFormView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 18/04/26.
//

import SwiftUI
import PhotosUI
import SwiftData

struct DocumentFormView: View {

    @Environment(\.dismiss) var dismiss
    @Environment(\.modelContext) var modelContext

    let trip: Trip?
    let editingDocument: Document? 

    @State private var docName: String
    @State private var description: String
    @State private var showActionSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    @State private var selectedImage: UIImage? = nil
    @State private var selectedFileURL: URL? = nil
    @State private var selectedFileType: String? = nil
    @State private var photosItem: PhotosPickerItem? = nil
    @State private var selectedCategory: DocumentCategory
    @State private var isCameraActive: Bool = false
    @State private var isPhotoPickerActive: Bool = false
    @State private var isFilePickerActive: Bool = false
    @State private var startDate: Date
    @State private var endDate: Date

    private var isFormValid: Bool {
        !docName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    init(trip: Trip? = nil, initialDocName: String = "", selectedImage: UIImage? = nil, selectedFileURL: URL? = nil, document: Document? = nil) {
        self.trip = trip
        self.editingDocument = document
        self._docName = State(initialValue: document?.name ?? initialDocName)
        self._selectedImage = State(initialValue: {
            if let filePath = document?.filePath {
                return FileManagerHelper.loadImage(from: filePath)
            }
            return selectedImage
        }())
        self._selectedFileURL = State(initialValue: selectedFileURL)
        self._description = State(initialValue: document?.desc ?? "")
        self._selectedCategory = State(initialValue: DocumentCategory(rawValue: document?.category ?? "") ?? .identity)
        self._selectedFileType = State(initialValue: document?.fileType)

        // startDate
        let defaultStart: Date = {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = 12
            components.minute = 0
            return calendar.date(from: components) ?? Date()
        }()
        self._startDate = State(initialValue: document?.startDate ?? defaultStart)

        // endDate
        let defaultEnd: Date = {
            let calendar = Calendar.current
            var components = calendar.dateComponents([.year, .month, .day], from: Date())
            components.hour = 13
            components.minute = 0
            return calendar.date(from: components) ?? Date()
        }()
        self._endDate = State(initialValue: document?.endDate ?? defaultEnd)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {

                        // Image / File preview
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                        } else if selectedFileType == "pdf" {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.red.opacity(0.1))
                                .frame(height: 250)
                                .overlay(
                                    VStack(spacing: 12) {
                                        Image(systemName: "doc.richtext")
                                            .font(.system(size: 50))
                                            .foregroundColor(.red.opacity(0.7))
                                        Text("PDF Document")
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                )
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 250)
                                .overlay(
                                    Image(systemName: "photo")
                                        .font(.largeTitle)
                                        .foregroundColor(.gray)
                                )
                        }

                        // Document Name
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 4) {
                                Text("Document Name").font(.title3)
                                Text("*").foregroundColor(.red)
                            }
                            .font(.subheadline)

                            TextField("KTP, Passport, Ticket, dll", text: $docName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(15)
                                .onChange(of: docName) { _, newValue in
                                    if newValue.count > 50 {
                                        docName = String(newValue.prefix(50))
                                    }
                                }
                        }

                        // Category & Date
                        VStack(spacing: 0) {
                            HStack {
                                Text("Category").font(.title3)
                                Text("*").foregroundColor(.red)
                                Spacer()
                                Menu {
                                    ForEach(DocumentCategory.allCases, id: \.self) { category in
                                        Button {
                                            selectedCategory = category
                                        } label: {
                                            HStack {
                                                Text(category.rawValue)
                                                if selectedCategory == category {
                                                    Image(systemName: "checkmark")
                                                }
                                            }
                                        }
                                    }
                                } label: {
                                    HStack(spacing: 4) {
                                        Text(selectedCategory.rawValue)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .lineLimit(1)
                                            .truncationMode(.tail)
                                            .frame(maxWidth: 130, alignment: .trailing)
                                        Image(systemName: "chevron.up.chevron.down")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                            .padding()

                            Divider().padding(.horizontal)

                            HStack {
                                Text("Starts").font(.title3)
                                Text("*").foregroundColor(.red)
                                Spacer()
                                DatePicker("", selection: $startDate)
                                    .labelsHidden()
                            }
                            .padding()

                            Divider().padding(.horizontal)

                            HStack {
                                Text("Ends").font(.title3)
                                Text("*").foregroundColor(.red)
                                Spacer()
                                DatePicker("", selection: $endDate)
                                    .labelsHidden()
                            }
                            .padding()
                        }
                        .background(Color(.systemGray6))
                        .cornerRadius(15)

                        // Description
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Description").font(.title3)

                            TextField("Notes...", text: $description, axis: .vertical)
                                .lineLimit(3...10)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(15)
                        }

                        // Save Button
                        Button {
                            saveDocument()
                        } label: {
                            Text("Save")
                                .font(.title3)
                                .foregroundColor(isFormValid ? .white : .white.opacity(0.5))
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(isFormValid ? Color.black : Color.black.opacity(0.3))
                                .clipShape(Capsule())
                        }
                        .disabled(!isFormValid)
                        .padding(.top, 10)
                    }
                    .padding(20)
                }

                // Popup overlay
                if showActionSheet {
                    Color.black.opacity(0.01)
                        .ignoresSafeArea()
                        .onTapGesture { showActionSheet = false }

                    VStack(alignment: .leading, spacing: 0) {
                        Menu {
                            Button {
                                showActionSheet = false
                                isCameraActive = true
                            } label: {
                                Label("Take a Photo", systemImage: "camera")
                            }
                            Button {
                                showActionSheet = false
                                isPhotoPickerActive = true
                            } label: {
                                Label("Choose Photo", systemImage: "photo")
                            }
                            Button {
                                showActionSheet = false
                                isFilePickerActive = true
                            } label: {
                                Label("Choose File", systemImage: "doc")
                            }
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "pencil").frame(width: 20)
                                Text("Edit Photo")
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }

                        Divider()

                        Button {
                            showActionSheet = false
                            showDeleteAlert = true
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "trash").frame(width: 20)
                                Text("Delete File")
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }

                        Divider()

                        Button {
                            showActionSheet = false
                            print("Get Info")
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "info.circle").frame(width: 20)
                                Text("Get Info")
                            }
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                        }
                    }
                    .background(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .shadow(color: .black.opacity(0.15), radius: 20, x: 0, y: 10)
                    .frame(width: 220)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    .padding(.trailing, 15)
                }
            }
            .navigationTitle(editingDocument != nil ? "Edit Document" : (trip?.name ?? "Document"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button { dismiss() } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.primary)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button { showActionSheet.toggle() } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.black)
                            .padding(8)
                            .clipShape(Circle())
                    }
                }
            }
            .alert("Are you sure you want to delete this document?", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    selectedImage = nil
                    selectedFileURL = nil
                    selectedFileType = nil
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("The document will be deleted on the trip")
            }
            .fullScreenCover(isPresented: $isCameraActive) {
                CameraView(image: $selectedImage, isPresented: $isCameraActive)
                    .ignoresSafeArea()
            }
            .photosPicker(isPresented: $isPhotoPickerActive, selection: $photosItem, matching: .images)
            .onChange(of: photosItem) { _, newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        selectedFileType = "image"
                    }
                }
            }
            .fileImporter(isPresented: $isFilePickerActive, allowedContentTypes: [.image, .pdf]) { result in
                if case .success(let url) = result {
                    _ = url.startAccessingSecurityScopedResource()
                    if url.pathExtension.lowercased() == "pdf" {
                        selectedFileURL = url
                        selectedFileType = "pdf"
                        selectedImage = nil
                    } else if let data = try? Data(contentsOf: url),
                              let uiImage = UIImage(data: data) {
                        selectedImage = uiImage
                        selectedFileType = "image"
                    }
                    url.stopAccessingSecurityScopedResource()
                }
            }
        }
        .onAppear {
                if let url = selectedFileURL,
                   url.pathExtension.lowercased() == "pdf",
                   selectedFileType == nil {
                    selectedFileType = "pdf"
                }
            }
    }

    // MARK: - Save / Update Document
    private func saveDocument() {
        var filePath: String? = editingDocument?.filePath
        var fileType: String? = editingDocument?.fileType

        if let image = selectedImage, editingDocument?.fileType != "image" || selectedImage != nil {
            if let newPath = FileManagerHelper.saveImage(image) {
                if let oldPath = editingDocument?.filePath {
                    FileManagerHelper.deleteFile(filename: oldPath)
                }
                filePath = newPath
                fileType = "image"
            }
        } else if let url = selectedFileURL,
                  let data = try? Data(contentsOf: url) {
            if let newPath = FileManagerHelper.savePDF(data) {
                if let oldPath = editingDocument?.filePath {
                    FileManagerHelper.deleteFile(filename: oldPath)
                }
                filePath = newPath
                fileType = "pdf"
            }
        }

        if let doc = editingDocument {
            // MODE EDIT — update dokumen yang ada
            doc.name = docName
            doc.category = selectedCategory.rawValue
            doc.desc = description
            doc.startDate = startDate
            doc.endDate = endDate
            doc.filePath = filePath
            doc.fileType = fileType
        } else {
            // MODE CREATE — buat dokumen baru
            let newDocument = Document(
                name: docName,
                category: selectedCategory.rawValue,
                filePath: filePath,
                fileType: fileType,
                startDate: startDate,
                endDate: endDate,
                desc: description,
                trip: trip
            )
            modelContext.insert(newDocument)
            trip?.documents.append(newDocument)
        }

        dismiss()
    }
}

#Preview {
    DocumentFormView()
        .modelContainer(for: [Trip.self, Document.self], inMemory: true)
}
