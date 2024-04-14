//
//  Haptics+Util.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-04-14.
//

import UIKit

class Haptics {
    static let shared = Haptics()

    private init() { }

    func play(_ feedbackStyle: UIImpactFeedbackGenerator.FeedbackStyle) {
        UIImpactFeedbackGenerator(style: feedbackStyle).impactOccurred()
    }

    func notify(_ feedbackType: UINotificationFeedbackGenerator.FeedbackType) {
        UINotificationFeedbackGenerator().notificationOccurred(feedbackType)
    }
}
