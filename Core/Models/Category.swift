//
//  Category.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import Foundation

struct TripCategory: Identifiable {
    let id = UUID()
    var name: String
    var documents: [Document]

    var documentCount: Int { documents.count }
}
