//
//  TravelWidget.swift
//  TravelWidget
//
//  Created by M. Arief Rahman Hakim on 20/04/26.
//

import WidgetKit
import SwiftUI
 
// MARK: - Mock Data
struct TravelEntry: TimelineEntry {
    let date: Date
    let tripName: String
    let startDate: String
    let status: String
    let categories: [String]
}
 
// MARK: - Provider
struct TravelProvider: TimelineProvider {
    func placeholder(in context: Context) -> TravelEntry {
        TravelEntry(
            date: Date(),
            tripName: "Japan Trip",
            startDate: "START DD/MM/YYYY",
            status: "On Going",
            categories: ["Identity", "Transportation", "Accommodation", "Activity & Attraction"]
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
 
// MARK: - Large Widget View
struct TravelWidgetLargeView: View {
    let entry: TravelEntry
 
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
 
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28).fill(Color.black)
            VStack(alignment: .leading, spacing: 16) {
                // Header
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.tripName.uppercased())
                            .font(.system(size: 26, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(entry.startDate)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.gray)
                            .tracking(1)
                    }
                    Spacer()
                    HStack(spacing: 6) {
                        Text(entry.status)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.primary)
                        Circle().fill(Color.yellow).frame(width: 7, height: 7)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
 
                // Category Grid
                LazyVGrid(columns: columns, spacing: 10) {
                    ForEach(entry.categories, id: \.self) { category in
                        Text(category)
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 16)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                    }
                }
                .padding(.horizontal, 14)
                .padding(.bottom, 16)
            }
        }
    }
}
 
// MARK: - Medium Widget View
struct TravelWidgetMediumView: View {
    let entry: TravelEntry
 
    let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
 
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 22).fill(Color.black)
            VStack(alignment: .leading, spacing: 10) {
                // Header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(entry.tripName.uppercased())
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        Text(entry.startDate)
                            .font(.system(size: 9, weight: .medium))
                            .foregroundColor(.gray)
                            .tracking(0.5)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text(entry.status)
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.primary)
                        Circle().fill(Color.yellow).frame(width: 6, height: 6)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
                }
                .padding(.horizontal, 14)
                .padding(.top, 12)
 
                // Category Grid
                LazyVGrid(columns: columns, spacing: 8) {
                    ForEach(entry.categories, id: \.self) { category in
                        Text(category)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.primary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 10)
                            .background(Color(.systemGray5))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 10)
                .padding(.bottom, 12)
            }
        }
    }
}
 
// MARK: - Entry View (switch berdasarkan ukuran)
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
                .containerBackground(.black, for: .widget)
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
        categories: ["Identity", "Transportation", "Accommodation", "Activity & Attraction"]
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
        categories: ["Identity", "Transportation", "Accommodation", "Activity & Attraction"]
    )
}
