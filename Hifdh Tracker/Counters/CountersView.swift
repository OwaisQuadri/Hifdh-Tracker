//
//  CountersView.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-04-13.
//

import SwiftUI
import UserNotifications
import AVFoundation
import WidgetKit

struct CountersView: View {
    @State var audioPlayer: AVAudioPlayer?
    @AppStorage("maxCounter", store: UserDefaults(suiteName: "group.HifdhTracker")) var maxCounter = 10
    @AppStorage("counter", store: UserDefaults(suiteName: "group.HifdhTracker")) var counter = 0
//    @State private var showNotification = false
    var body: some View {
        NavigationStack {
            VStack {
                LabeledContent("Select max count:") {
                        Picker("Select a number", selection: $maxCounter) {
                            Text("3").tag(3)
                            Text("5").tag(5)
                            Text("10").tag(10)
                            Text("20").tag(20)
                            Text("33").tag(33)
                            Text("50").tag(50)
                            Text("100").tag(100)
                        }
                        .font(.callout)
                }
                .padding()
                .onChange(of: maxCounter) {
                    if counter >= maxCounter { counter = 0 }
                    WidgetCenter.shared.reloadAllTimelines()
                }
                .onChange(of: counter) {
                    WidgetCenter.shared.reloadAllTimelines()
                }
                Button(intent: IncrementCounterIntent()) {
                    Text("\(counter)")
                        .contentTransition(.numericText())
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .font(.largeTitle)
                .buttonStyle(.borderedProminent)
                .padding()
                Button(intent: ResetCounterIntent(), label: {
                    Text("Reset Counter")
                })
                .padding()
            }
            .navigationTitle("Counter")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

}

#Preview {
    CountersView()
}
