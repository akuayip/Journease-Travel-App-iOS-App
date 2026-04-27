//
//  TravelApp.swift
//  Travel
//
//  Created by M. Arief Rahman Hakim on 17/04/26.
//

import SwiftUI
import SwiftData

@main
struct TravelApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(for: Trip.self)
    }

    func handleDeepLink(_ url: URL) {
        guard url.scheme == "journease",
              url.host == "category",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        else { return }

        let categoryName = components.queryItems?.first(where: { $0.name == "name" })?.value ?? ""
        let tripName = components.queryItems?.first(where: { $0.name == "trip" })?.value ?? ""

        NotificationCenter.default.post(
            name: .openCategory,
            object: nil,
            userInfo: [
                "category": categoryName,
                "trip": tripName
            ]
        )
    }
}

extension Notification.Name {
    static let openCategory = Notification.Name("openCategory")
}
