//
//  TravelWidgetLiveActivity.swift
//  TravelWidget
//
//  Created by M. Arief Rahman Hakim on 20/04/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TravelWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct TravelWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TravelWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TravelWidgetAttributes {
    fileprivate static var preview: TravelWidgetAttributes {
        TravelWidgetAttributes(name: "World")
    }
}

extension TravelWidgetAttributes.ContentState {
    fileprivate static var smiley: TravelWidgetAttributes.ContentState {
        TravelWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TravelWidgetAttributes.ContentState {
         TravelWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: TravelWidgetAttributes.preview) {
   TravelWidgetLiveActivity()
} contentStates: {
    TravelWidgetAttributes.ContentState.smiley
    TravelWidgetAttributes.ContentState.starEyes
}
