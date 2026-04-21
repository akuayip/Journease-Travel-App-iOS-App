//
//  PreviewDocument.swift
//  Travel
//
//  Created by M. Arief Rahman Hakim on 18/04/26.
//

import SwiftUI

struct PreviewDocumentView: View {
    var body: some View {
        
        ZStack{
            Color(.systemGray6)
                .ignoresSafeArea()
            
            VStack {
                HStack {
                    Button {
                        print("Kembali")
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 65, height: 65)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    Spacer()
                    
                    Text("Identity Docs")
                        .font(.title3)
                        .bold()
                    
                    
                    Spacer()
                    
                    Button {
                        print("Kembali")
                    } label: {
                        Image(systemName: "square.and.pencil")
                            .font(.title2)
                            .foregroundColor(.primary)
                            .frame(width: 65, height: 65)
                            .background(.ultraThinMaterial)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    
                }
                .padding(20)
                
                ZStack{
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 400)
                        .padding(20)
                        .overlay(Image("ktp"))
                            
                }
                Spacer()
                
            }
            
        }
        //
    }
}

#Preview {
    PreviewDocumentView()
}
