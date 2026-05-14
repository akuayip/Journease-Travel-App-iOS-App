//
//  DocumentPreviewView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI
import PDFKit

struct DocumentPreviewView: View {
    let document: Document
    let onBack: () -> Void
    let onDelete: (() -> Void)?

    @State private var isDocumentFormActive: Bool = false

    init(document: Document, onBack: @escaping () -> Void, onDelete: (() -> Void)? = nil) {
        self.document = document
        self.onBack = onBack
        self.onDelete = onDelete
    }

    // MARK: - Zoom state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var previewSize: CGSize = .zero

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button {
                    onBack()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 55, height: 55)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
                Spacer()
                Text(document.name).font(.title3).bold()
                Spacer()
                Button { isDocumentFormActive = true } label: {
                    Image(systemName: "square.and.pencil")
                        .font(.title2)
                        .foregroundColor(.primary)
                        .frame(width: 55, height: 55)
                        .background(Color(.systemBackground))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                }
            }
            .padding(20)

            // Tampilkan file dari FileManager
            if let filePath = document.filePath,
               let image = FileManagerHelper.loadImage(from: filePath) {
                zoomablePreviewImage(image)

            } else if document.fileType == "pdf",
                      let filePath = document.filePath,
                      let pdfImage = FileManagerHelper.loadPDFThumbnail(from: filePath) {
                zoomablePreviewImage(pdfImage)

            } else if document.fileType == "pdf" {
                // PDF fallback icon
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.red.opacity(0.1))
                    .frame(height: 400)
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "doc.richtext")
                                .font(.system(size: 60))
                                .foregroundColor(.red.opacity(0.7))
                            Text("PDF Document")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    )
                    .padding(20)

            } else {
                // Placeholder jika tidak ada file
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.gray.opacity(0.1))
                    .frame(height: 400)
                    .overlay(
                        VStack(spacing: 16) {
                            Image(systemName: "doc")
                                .font(.system(size: 60))
                                .foregroundColor(.gray.opacity(0.5))
                            Text("No file attached")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                    )
                    .padding(20)
            }
        }
        .sheet(isPresented: $isDocumentFormActive) {
            DocumentFormView(
                trip: document.trip,
                document: document,
                onDelete: {
                    isDocumentFormActive = false
                    onBack()
                    onDelete?()
                }
            )
        }
    }

    private func zoomablePreviewImage(_ image: UIImage) -> some View {
        GeometryReader { geo in
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .frame(width: geo.size.width, height: geo.size.height)
                .scaleEffect(scale)
                .offset(offset)
                .contentShape(Rectangle())
                .gesture(previewGesture)
                .onTapGesture(count: 2) {
                    resetZoom()
                }
                .onAppear {
                    previewSize = geo.size
                }
                .onChange(of: geo.size) { _, newSize in
                    previewSize = newSize
                    offset = clampedOffset(offset, for: scale)
                    lastOffset = offset
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var previewGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let delta = value / lastScale
                lastScale = value
                scale = min(max(scale * delta, 1.0), 5.0)
            }
            .onEnded { _ in
                lastScale = 1.0
                if scale < 1.0 {
                    withAnimation(.spring()) { scale = 1.0 }
                }

                offset = clampedOffset(offset, for: scale)
                lastOffset = offset
            }
            .simultaneously(with:
                DragGesture()
                    .onChanged { value in
                        if scale > 1.0 {
                            let proposedOffset = CGSize(
                                width: lastOffset.width + value.translation.width,
                                height: lastOffset.height + value.translation.height
                            )
                            offset = clampedOffset(proposedOffset, for: scale)
                        } else {
                            offset = .zero
                        }
                    }
                    .onEnded { _ in
                        if scale <= 1.0 {
                            resetZoom()
                        } else {
                            offset = clampedOffset(offset, for: scale)
                            lastOffset = offset
                        }
                    }
            )
    }

    private func resetZoom() {
        withAnimation(.spring()) {
            scale = 1.0
            offset = .zero
            lastOffset = .zero
        }
    }

    private func clampedOffset(_ proposedOffset: CGSize, for scale: CGFloat) -> CGSize {
        guard scale > 1.0 else { return .zero }

        let maxX = previewSize.width * (scale - 1.0) / 2
        let maxY = previewSize.height * (scale - 1.0) / 2

        return CGSize(
            width: min(max(proposedOffset.width, -maxX), maxX),
            height: min(max(proposedOffset.height, -maxY), maxY)
        )
    }
}
