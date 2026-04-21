//
//  DocumentFormView.swift
//  Travel
//
//  Created by M. Arief Rahman Hakim on 18/04/26.
//

import SwiftUI
import PhotosUI
 
struct DocumentFormView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var docName: String
    @State private var category: String = "ID"
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var description: String = ""
    @State private var showActionSheet: Bool = false
    @State private var showDeleteAlert: Bool = false
    
    @State private var selectedImage: UIImage? = nil
    @State private var photosItem: PhotosPickerItem? = nil
    var initialDocName: String = ""

    init(initialDocName: String = "", selectedImage: UIImage? = nil) {
        self._docName = State(initialValue: initialDocName)
        self._selectedImage = State(initialValue: selectedImage)
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 25) {
                        
                        // Image
                        if let image = selectedImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity)
                                .frame(height: 250)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
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
                                Text("Document Name")
                                    .font(.title3)
                                Text("*").foregroundColor(.red)
                            }
                            .font(.subheadline)
                            
                            TextField("KTP, Passport, Ticket, dll", text: $docName)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(15)
                        }
                        
                        // Category & Date
                        VStack(spacing: 0) {
                            HStack {
                                Text("Category")
                                    .font(.title3)
                                Text("*").foregroundColor(.red)
                                Spacer()
                                Text(category)
                                    .foregroundColor(.secondary)
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                            
                            Divider().padding(.horizontal)
                            
                            HStack {
                                Text("Starts")
                                    .font(.title3)
                                Text("*").foregroundColor(.red)
                                Spacer()
                                DatePicker("", selection: $startDate)
                                    .labelsHidden()
                            }
                            .padding()
                            
                            Divider().padding(.horizontal)
                            
                            HStack {
                                Text("Ends")
                                    .font(.title3)
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
                            Text("Description")
                                .font(.title3)
                            
                            TextField("Notes...", text: $description, axis: .vertical)
                                .lineLimit(3...10)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(15)
                        }
                        
                        // Save Button
                        Button {
                            print("Save Document")
                            dismiss()
                        } label: {
                            Text("Save")
                                .font(.title3)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(.black)
                                .clipShape(Capsule())
                        }
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
                        Button {
                            showActionSheet = false
                            print("Edit Photo")
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
//                    .padding(.top, 10)
                    .padding(.trailing, 15)
                }
            }
            .navigationTitle("Japan Trip")
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
            .alert("Delete File", isPresented: $showDeleteAlert) {
                Button("Delete", role: .destructive) {
                    print("File deleted")
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete this file? This action cannot be undone.")
            }
        }
    }
}
 
#Preview {
    DocumentFormView()
}
