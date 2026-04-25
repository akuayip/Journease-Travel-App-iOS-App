//
//  Trip.swift
//  Journease
//
//  Created by M. Arief Rahman Hakim on 21/04/26.
//

import SwiftUI

struct Trip: Identifiable {
    let id = UUID()
    var name: String
    var totalDocuments: Int
    var pouchColor: String
    var startDate: Date?

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
}
