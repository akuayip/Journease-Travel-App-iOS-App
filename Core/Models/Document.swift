//
//  Document.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import Foundation

struct Document: Identifiable {
    let id = UUID()
    var name: String
    var category: String
    var imageName: String
    var startDate: Date?
    var endDate: Date?
    var description: String?
}
