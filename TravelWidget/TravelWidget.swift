//
//  TravelWidget.swift
//  TravelWidget
//
//  Created by M. Arief Rahman Hakim on 20/04/26.
//

import WidgetKit
import SwiftUI
 
// MARK: - Category Icon Helper
struct CategoryIcon {
    static func icon(for category: String) -> String {
        switch category.lowercased() {
        case "identity":            return "person.text.rectangle"
        case "transportation":      return "airplane"
        case "accommodation":       return "bed.double"
        case "activity & attraction",
             "activity":            return "figure.walk"
        default:                    return "folder"
        }
    }
 
    static func url(for category: String, tripName: String) -> URL {
        let encodedCategory = category.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedTrip = tripName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "journease://category?name=\(encodedCategory)&trip=\(encodedTrip)")!
    }
}
 
// MARK: - Mock Data
struct TravelEntry: TimelineEntry {
    let date: Date
    let tripName: String
    let startDate: String
    let status: String
    let categories: [String]
    let pouchColorHex: String
}
 
// MARK: - Provider
struct TravelProvider: TimelineProvider {
    func placeholder(in context: Context) -> TravelEntry {
        TravelEntry(
            date: Date(),
            tripName: "Japan Trip",
            startDate: "START DD/MM/YYYY",
            status: "On Going",
            categories: ["Identity", "Transportation", "Accommodation", "Activity & Attraction"],
            pouchColorHex: "63BBF9"
        )
    }
 
    func getSnapshot(in context: Context, completion: @escaping (TravelEntry) -> Void) {
        completion(placeholder(in: context))
    }
 
    func getTimeline(in context: Context, completion: @escaping (Timeline<TravelEntry>) -> Void) {
        let entry = placeholder(in: context)
        completion(Timeline(entries: [entry], policy: .never))
    }
}
 
// MARK: - Color from Hex
extension Color {
    init(widgetHex hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r = Double((int >> 16) & 0xFF) / 255
        let g = Double((int >> 8) & 0xFF) / 255
        let b = Double(int & 0xFF) / 255
        self.init(.sRGB, red: r, green: g, blue: b, opacity: 1)
    }
}
 
// MARK: - Category Circle View
struct CategoryCircleView: View {
    let category: String
    let size: CGFloat
 
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(Color.black.opacity(0.15))
                    .frame(width: size, height: size)
                Image(systemName: CategoryIcon.icon(for: category))
                    .font(.system(size: size * 0.38, weight: .medium))
                    .foregroundColor(.black.opacity(0.75))
            }
            Text(category)
                .font(.system(size: size * 0.2, weight: .medium))
                .foregroundColor(.black.opacity(0.75))
                .lineLimit(1)
                .truncationMode(.tail)
                .frame(maxWidth: size + 10)
        }
    }
}
 
// MARK: - Large Widget View
struct TravelWidgetLargeView: View {
    let entry: TravelEntry
 
    var pouchColor: Color { Color(widgetHex: entry.pouchColorHex) }
 
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
 
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(pouchColor)
 
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.tripName.uppercased())
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Text(entry.startDate)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.black.opacity(0.5))
                            .tracking(1)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Text(entry.status)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                        Circle().fill(Color.yellow).frame(width: 7, height: 7)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color.white.opacity(0.4))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
 
                // Category Circles Grid — each is a deep link
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(entry.categories, id: \.self) { category in
                        Link(destination: CategoryIcon.url(for: category, tripName: entry.tripName)) {
                            CategoryCircleView(category: category, size: 64)
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.bottom, 18)
            }
        }
    }
}
 
// MARK: - Medium Widget View
struct TravelWidgetMediumView: View {
    let entry: TravelEntry
 
    var pouchColor: Color { Color(widgetHex: entry.pouchColorHex) }
 
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
 
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22).fill(pouchColor)
 
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.tripName.uppercased())
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.black)
                            .lineLimit(1)
                        Text(entry.startDate)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.black.opacity(0.5))
                            .tracking(0.5)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text(entry.status)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.black.opacity(0.7))
                        Circle().fill(Color.yellow).frame(width: 6, height: 6)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.white.opacity(0.4))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
 
                // Category Circles — 4 in a row, each is a deep link
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(entry.categories, id: \.self) { category in
                        Link(destination: CategoryIcon.url(for: category, tripName: entry.tripName)) {
                            CategoryCircleView(category: category, size: 44)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 12)
            }
        }
    }
}
 
// MARK: - Entry View
struct TravelWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: TravelEntry
 
    var body: some View {
        switch family {
        case .systemMedium:
            TravelWidgetMediumView(entry: entry)
        case .systemLarge:
            TravelWidgetLargeView(entry: entry)
        default:
            TravelWidgetMediumView(entry: entry)
        }
    }
}
 
// MARK: - Widget Configuration
struct TravelWidget: Widget {
    let kind: String = "TravelWidget"
 
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TravelProvider()) { entry in
            TravelWidgetEntryView(entry: entry)
                .containerBackground(Color(widgetHex: entry.pouchColorHex), for: .widget)
        }
        .configurationDisplayName("Journease")
        .description("See your trip and document categories at a glance.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}
 
// MARK: - Preview
#Preview(as: .systemMedium) {
    TravelWidget()
} timeline: {
    TravelEntry(
        date: Date(),
        tripName: "Japan Trip",
        startDate: "START 12/05/2025",
        status: "On Going",
        categories: ["Identity", "Transportation", "Accommodation", "Activity & Attraction"],
        pouchColorHex: "63BBF9"
    )
}
 
#Preview(as: .systemLarge) {
    TravelWidget()
} timeline: {
    TravelEntry(
        date: Date(),
        tripName: "Japan Trip",
        startDate: "START 12/05/2025",
        status: "On Going",
        categories: ["Identity", "Transportation", "Accommodation", "Activity & Attraction"],
        pouchColorHex: "63BBF9"
    )
}
