//
//  OpenCounterIntent.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-07-19.
//

import Foundation
import AppIntents
import UIKit

struct OpenCounterIntent: AppIntent {

    static var title: LocalizedStringResource = "Open Counter Session"
    static var openAppWhenRun: Bool = true

    func perform() async throws -> some IntentResult & OpensIntent {
        NotificationCenter.default.post(name: Notification.Name("openCountersPage"), object: nil)
        return .result()
    }


}
