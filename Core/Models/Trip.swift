//
//  Trip.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 26/04/26.
//

import SwiftUI
import SwiftData

@Model
class Trip {
    var name: String
    var pouchColor: String
    var createdAt: Date
    var order: Int

    @Relationship(deleteRule: .cascade, inverse: \Document.trip)
    var documents: [Document] = []

    init(name: String = "Trip", pouchColor: String, order: Int = 0) {
        self.name = name
        self.pouchColor = pouchColor
        self.createdAt = Date()
        self.order = order
    }

    // Computed property color — tetap ada seperti sebelumnya
    var color: Color {
        let pouchToColor: [String: Color] = [
            "pouch_blue"   : Color(hex: "63BBF9"),
            "pouch_gray"   : Color(hex: "D4D6D9"),
            "pouch_green"  : Color(hex: "9CDDD0"),
            "pouch_pink"   : Color(hex: "F7B6C5"),
            "pouch_purple" : Color(hex: "BAABEB"),
            "pouch_yellow" : Color(hex: "FCDC7E")
        ]
        return pouchToColor[pouchColor] ?? Color(hex: "63BBF9")
    }

    // Warna random untuk trip baru
    static func randomPouchColor() -> String {
        let colors = ["pouch_blue", "pouch_gray", "pouch_green",
                      "pouch_pink", "pouch_purple", "pouch_yellow"]
        return colors.randomElement() ?? "pouch_blue"
    }
}
