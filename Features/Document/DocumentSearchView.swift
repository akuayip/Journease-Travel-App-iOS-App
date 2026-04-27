//
//  DocumentSearchView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 22/04/26.
//

import SwiftUI
import SwiftData

struct DocumentSearchView: View {
    @State private var searchText: String = ""
    @State private var selectedDocument: Document? = nil
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool

    @Query var allDocuments: [Document]

    var searchResults: [Document] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return []
        }
        return allDocuments.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.category.lowercased().contains(searchText.lowercased()) ||
            ($0.trip?.name ?? "").lowercased().contains(searchText.lowercased())
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground).ignoresSafeArea()

            VStack(spacing: 0) {
                if searchText.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("Search your documents")
                            .font(.headline)
                        Text("Try typing KTP, Passport, Tiket, etc.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else if searchResults.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "doc.text.magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        Text("No results for \"\(searchText)\"")
                            .font(.headline)
                        Text("Check the spelling or try a different keyword.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 30)

                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack {
                                Text("Top Hits")
                                    .font(.title3).bold()
                                Spacer()
                                Text("\(searchResults.count) Found")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            .padding(.bottom, 12)

                            VStack(spacing: 10) {
                                ForEach(searchResults) { doc in
                                    Button {
                                        selectedDocument = doc  // ← buka preview
                                    } label: {
                                        HStack(spacing: 14) {
                                            documentThumbnail(doc: doc)
                                                .frame(width: 60, height: 60)
                                                .clipShape(RoundedRectangle(cornerRadius: 10))

                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(doc.name)
                                                    .font(.system(size: 16, weight: .semibold))
                                                    .foregroundColor(.primary)
                                                    .lineLimit(1)
                                                HStack(spacing: 4) {
                                                    Image(systemName: "folder")
                                                        .font(.caption2)
                                                    Text(doc.trip?.name ?? "Unknown Trip")
                                                        .font(.subheadline)
                                                        .lineLimit(1)
                                                }
                                                .foregroundColor(.secondary)
                                            }

                                            Spacer()

                                            Image(systemName: "chevron.right")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 12)
                                        .background(Color(.systemGray6))
                                        .clipShape(RoundedRectangle(cornerRadius: 14))
                                        .padding(.horizontal, 16)
                                    }
                                }
                            }
                            .padding(.bottom, 100)
                        }
                    }
                }
            }

            // Search bar fixed at bottom
            VStack(spacing: 0) {
                Divider()
                HStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                        TextField("Search", text: $searchText)
                            .focused($isFocused)
                            .autocorrectionDisabled()
                        if !searchText.isEmpty {
                            Button {
                                searchText = ""
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding(.horizontal, 14)
                    .frame(height: 44)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())

                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color(.systemBackground))
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
        // Sheet preview document
        .sheet(item: $selectedDocument) { doc in
            DocumentPreviewView(
                document: doc,
                onBack: {
                    selectedDocument = nil
                }
            )
        }
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
                Color(.systemGray5)
                Image(systemName: doc.fileType == "pdf" ? "doc.richtext" : "doc")
                    .font(.system(size: 24))
                    .foregroundColor(.secondary)
            }
        }
    }
}
