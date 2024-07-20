//
//  IncrementCounter.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-07-20.
//

import Foundation
import AppIntents
import AVFAudio

struct IncrementCounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Increment the Counter"
    private var defaults: UserDefaults {
        UserDefaults(suiteName: "group.HifdhTracker") ?? .standard
    }
    func perform() async throws -> some IntentResult {
        var counter: Int =  defaults.integer(forKey: "counter") {
            didSet {
                defaults.setValue(counter, forKey: "counter")
            }
        }
        let maxCounter =  defaults.integer(forKey: "maxCounter")
        counter += 1
        if counter >= maxCounter {
            counter = 0
            Task {
                for _ in 0...2 {
                    try? await Task.sleep(for: .milliseconds(200))
                    Haptics.shared.play(.heavy)
                }
            }
            if let path = Bundle.main.path(forResource: "beep", ofType:"mp3") {
                let url = URL(fileURLWithPath: path)
                do {
                    let audioPlayer = try AVAudioPlayer(contentsOf: url)
                    audioPlayer.play()
                } catch let error {
                    print(error.localizedDescription)
                }
            }
        } else {
            Haptics.shared.play(.soft)
        }
        return .result()
    }

}
struct ResetCounterIntent: AppIntent {
    static var title: LocalizedStringResource = "Reset the Counter"
    private var defaults: UserDefaults {
        UserDefaults(suiteName: "group.HifdhTracker") ?? .standard
    }
    func perform() async throws -> some IntentResult {
        var counter: Int =  defaults.integer(forKey: "counter") {
            didSet {
                defaults.setValue(counter, forKey: "counter")
            }
        }
        counter = 0
        Haptics.shared.notify(.success)
        return .result()
    }

}
