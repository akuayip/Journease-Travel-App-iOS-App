//
//  FileManagerHelper.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 27/04/26.
//

import Foundation
import UIKit
import PDFKit

struct FileManagerHelper {
    
    // Simpan gambar → return path
    static func saveImage(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        try? data.write(to: url)
        return filename
    }
    
    // Simpan PDF → return path
    static func savePDF(_ data: Data) -> String? {
        let filename = UUID().uuidString + ".pdf"
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        try? data.write(to: url)
        return filename
    }
    
    // Ambil URL dari path
    static func getURL(for filename: String) -> URL {
        return getDocumentsDirectory().appendingPathComponent(filename)
    }
    
    // Load gambar dari path
    static func loadImage(from filename: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        return UIImage(contentsOfFile: url.path)
    }
    
    // Load thumbnail halaman pertama PDF
    static func loadPDFThumbnail(from filename: String) -> UIImage? {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        guard let document = PDFDocument(url: url),
              let page = document.page(at: 0) else { return nil }
        
        let pageRect = page.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        let image = renderer.image { ctx in
            // Background putih
            UIColor.white.set()
            ctx.fill(pageRect)
            // Flip koordinat — PDF dari bawah, UIKit dari atas
            ctx.cgContext.translateBy(x: 0, y: pageRect.size.height)
            ctx.cgContext.scaleBy(x: 1, y: -1)
            // Render halaman PDF
            page.draw(with: .mediaBox, to: ctx.cgContext)
        }
        return image
    }
    
    // Hapus file
    static func deleteFile(filename: String) {
        let url = getDocumentsDirectory().appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
    
    private static func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
}
