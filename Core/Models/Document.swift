//
//  Document.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import Foundation
import SwiftData

@Model
class Document {
    var name: String
    var category: String
    var filePath: String?
    var fileType: String?
    var startDate: Date?
    var endDate: Date?
    var desc: String
    var createdAt: Date
    var trip: Trip?             

    init(
        name: String,
        category: String = DocumentCategory.others.rawValue,
        filePath: String? = nil,
        fileType: String? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        desc: String = "",
        trip: Trip? = nil
    ) {
        self.name = name
        self.category = category
        self.filePath = filePath
        self.fileType = fileType
        self.startDate = startDate
        self.endDate = endDate
        self.desc = desc
        self.createdAt = Date()
        self.trip = trip
    }
}
