//
//  HifdhTrackerWidgets.swift
//  HifdhTrackerWidgets
//
//  Created by Owais on 2024-07-19.
//

import WidgetKit
import SwiftUI
import AppIntents

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        return SimpleEntry(date: Date(), counter: getCounter(), maxCounter: getMaxCounter(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), counter: getCounter(), maxCounter: getMaxCounter(), configuration: configuration)
    }

    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries, 15 mins apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: hourOffset * 15, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, counter: getCounter(), maxCounter: getMaxCounter(), configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
    private func getCounter() -> Int {
        let defaults = UserDefaults(suiteName: "group.HifdhTracker") ?? .standard
        let counter = defaults.integer(forKey: "counter")
        return counter
    }
    private func getMaxCounter() -> Int {
        let defaults = UserDefaults(suiteName: "group.HifdhTracker") ?? .standard
        let counter = defaults.integer(forKey: "maxCounter")
        return counter
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    let counter: Int
    let maxCounter: Int
    let configuration: ConfigurationAppIntent
}

struct HifdhTrackerWidgetsEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        ZStack {
            Text("\(entry.counter)/\(entry.maxCounter)")
                .contentTransition(.numericText())
                .monospacedDigit()
                .font(.largeTitle).bold()
            VStack(alignment: .center) {
                Text("Hifdh Tracker Counter")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .font(.caption)
                Spacer()
                HStack(alignment: .center) {
                    Button(intent: ResetCounterIntent()) {
                        Image(systemName: "arrow.counterclockwise")
                            .font(.title).bold()
                            .frame(width: 40, height: 40)
                    }
                    .aspectRatio(1, contentMode: .fit)
                    Spacer()
                    Button(intent: IncrementCounterIntent()) {
                        Image(systemName: entry.counter + 1 == entry.maxCounter ? "checkmark" : "plus")
                            .font(.title).bold()
                            .frame(width: 40, height: 40)
                            .contentTransition(.symbolEffect(.replace))
                    }
                    .aspectRatio(1, contentMode: .fit)
                }
                .tint(.accent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct HifdhTrackerWidgets: Widget {
    let kind: String = "Counter Widget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            HifdhTrackerWidgetsEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
                .widgetURL(.init(string: "hifdh-tracker://openCountersPage"))
        }
        .description("Shows the current counter state. Pressing the background will take you to the in-app counter.")
        .configurationDisplayName("Counter Widget")
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Widget Intent"
    static var description = IntentDescription("This is a widget.")
}
