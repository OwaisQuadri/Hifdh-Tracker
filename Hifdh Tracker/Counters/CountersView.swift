//
//  CountersView.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-04-13.
//

import SwiftUI
import UserNotifications
import AVFoundation

struct CountersView: View {
    @State var audioPlayer: AVAudioPlayer?
    @State private var maxCounter = 10
    @State private var counter = 0
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
                .onChange(of: maxCounter) { newValue in
                    if counter >= maxCounter { counter = 0 }
                }
                Button {
                    counter += 1
                    if counter >= maxCounter {
                        counter = 0
                        Haptics.shared.play(.heavy)
                        guard let path = Bundle.main.path(forResource: "beep", ofType:"mp3") else {
                            return }
                        let url = URL(fileURLWithPath: path)
                        do {
                            audioPlayer = try AVAudioPlayer(contentsOf: url)
                            audioPlayer?.play()
                        } catch let error {
                            print(error.localizedDescription)
                        }
//                        // send notification with sound
//                        if showNotification {
//                            let content = UNMutableNotificationContent()
//                            content.title = "Counter Completed!"
//                            content.body = "You have read this portion \(maxCounter) times, the counter has been reset."
//                            content.sound = UNNotificationSound.default
//
//                            // show this notification five seconds from now
//                            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//                            // choose a random identifier
//                            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//                            // add our notification request
//                            UNUserNotificationCenter.current().add(request)
//                        } else {
                        // play a sound
//                        }

                    } else {
                        Haptics.shared.play(.soft)
                    }
                } label: {
                    Text("\(counter)")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .font(.largeTitle)
                .buttonStyle(.borderedProminent)
                .padding()
                Button("Reset Counter") {
                    counter = 0
                    Haptics.shared.notify(.success)
                }
                .padding()
            }
            .navigationTitle("Counter")
        }
        .task {
            // ask for notification permission
//            do {
//                print("Requesting permission")
//                showNotification = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound])
//                if showNotification {
//                    print("Permission granted")
//                } else {
//                    print("Permission denied")
//                }
//            } catch {
//                print(error.localizedDescription)
//            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    CountersView()
}
