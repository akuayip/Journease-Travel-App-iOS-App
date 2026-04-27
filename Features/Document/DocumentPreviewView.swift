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

    @State private var isDocumentFormActive: Bool = false

    // MARK: - Zoom state
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        VStack {
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
                // Gambar biasa — dengan zoom
                GeometryReader { geo in
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: 400)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
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
                                }
                                .simultaneously(with:
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                            if scale <= 1.0 {
                                                withAnimation(.spring()) { offset = .zero }
                                                lastOffset = .zero
                                            }
                                        }
                                )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                scale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                }
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(20)

            } else if document.fileType == "pdf",
                      let filePath = document.filePath,
                      let pdfImage = FileManagerHelper.loadPDFThumbnail(from: filePath) {
                // PDF — dengan zoom
                GeometryReader { geo in
                    Image(uiImage: pdfImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width, height: 400)
                        .scaleEffect(scale)
                        .offset(offset)
                        .gesture(
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
                                }
                                .simultaneously(with:
                                    DragGesture()
                                        .onChanged { value in
                                            if scale > 1.0 {
                                                offset = CGSize(
                                                    width: lastOffset.width + value.translation.width,
                                                    height: lastOffset.height + value.translation.height
                                                )
                                            }
                                        }
                                        .onEnded { _ in
                                            lastOffset = offset
                                            if scale <= 1.0 {
                                                withAnimation(.spring()) { offset = .zero }
                                                lastOffset = .zero
                                            }
                                        }
                                )
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring()) {
                                scale = 1.0
                                offset = .zero
                                lastOffset = .zero
                            }
                        }
                }
                .frame(height: 400)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding(20)

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

            Spacer()
        }
        .sheet(isPresented: $isDocumentFormActive) {
            DocumentFormView(
                trip: document.trip,
                document: document
            )
        }
    }
}
