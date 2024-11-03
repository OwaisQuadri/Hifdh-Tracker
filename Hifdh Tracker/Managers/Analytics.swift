//
//  Analytics.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-11-03.
//

import Mixpanel
enum Screen: String {
    case log, stats, counter, paywall, goals
}
enum AnalyticsEvent: String {
    case logPage = "Log a page"
    case counterIncrement = "Incremented Counter"
    case resetCounter = "Reset Counter"
    case addGoal = "Add a Goal"
    case subToPremium_monthly
    case subToPremium_yearly
}
class Analytics {
    private let mp = Mixpanel.mainInstance()
    static let shared = Analytics()
    private init() {}
    func track(events: AnalyticsEvent...) {
        for event in events {
            Mixpanel.mainInstance().track(event:event.rawValue)
        }
    }
    func view(screen: Screen) {
        Mixpanel.mainInstance().track(event:"Screen Viewed: \(screen.rawValue)")
    }
}
