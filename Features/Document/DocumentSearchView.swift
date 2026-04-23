//
//  DocumentSearchView.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 22/04/26.
//


import SwiftUI

struct DocumentSearchView: View {
    @State private var searchText: String = ""
    @Environment(\.dismiss) var dismiss
    @FocusState private var isFocused: Bool

    let allDocuments: [DocumentItem] = [
        DocumentItem(name: "KTP", category: .identity, imageName: "ktp"),
        DocumentItem(name: "Passport", category: .identity, imageName: "ktp"),
        DocumentItem(name: "Visa", category: .identity, imageName: "ktp"),
        DocumentItem(name: "SIM", category: .identity, imageName: "ktp"),
        DocumentItem(name: "Tiket Pesawat", category: .transportation, imageName: "ktp"),
        DocumentItem(name: "Boarding Pass", category: .transportation, imageName: "ktp"),
        DocumentItem(name: "Tiket Kereta", category: .transportation, imageName: "ktp"),
        DocumentItem(name: "Booking Hotel", category: .accommodation, imageName: "ktp"),
        DocumentItem(name: "Voucher Airbnb", category: .accommodation, imageName: "ktp"),
        DocumentItem(name: "Tiket Wahana", category: .activity, imageName: "ktp"),
        DocumentItem(name: "Itinerary", category: .activity, imageName: "ktp"),
        DocumentItem(name: "Travel Insurance", category: .others, imageName: "ktp"),
    ]

    struct DocumentItem: Identifiable {
        let id = UUID()
        let name: String
        let category: DocumentCategory
        let imageName: String
    }

    var searchResults: [DocumentItem] {
        if searchText.trimmingCharacters(in: .whitespaces).isEmpty {
            return []
        }
        return allDocuments.filter {
            $0.name.lowercased().contains(searchText.lowercased()) ||
            $0.category.rawValue.lowercased().contains(searchText.lowercased())
        }
    }

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(.systemBackground).ignoresSafeArea()

            // Content area
            VStack(spacing: 0) {
                if searchText.isEmpty {
                    // Idle state
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
                    // Empty state
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
                    // Results
                    ScrollView(showsIndicators: false) {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack{
                                Text("Top Hits")
                                    .font(.body)
                                    .bold()
                                    .padding(20)
                                
                            Spacer()
                                
                                Text("\(searchResults.count) Found")
                                    .font(.callout)
                                    .foregroundColor(.secondary)
                                    .padding(.horizontal, 16)
                                    .padding(.top, 16)
                                    .padding(.bottom, 8)
                                    .padding(20)
                            }
                            

                            LazyVGrid(columns: columns, spacing: 16) {
                                ForEach(searchResults) { doc in
                                    Button {
                                        dismiss()
                                    } label: {
                                        VStack(spacing: 6) {
                                            GeometryReader { g in
                                                Image(doc.imageName)
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(width: g.size.width, height: 90)
                                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                            }
                                            .frame(height: 90)

                                            Text(doc.name)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(.primary)
                                                .lineLimit(1)

                                            HStack(spacing: 3) {
                                                Image(systemName: "folder").font(.caption2)
                                                Text(doc.category.rawValue)
                                                    .font(.caption2)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                            }
                                            .foregroundColor(.secondary)
                                        }
                                        .frame(maxWidth: .infinity)
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.bottom, 100) // space for search bar
                        }
                    }
                }
            }

            // Search bar fixed at bottom — floats above keyboard
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
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isFocused = true
            }
        }
    }
}
