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

        if
            let scene = await UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = await scene.windows.first
        {
            let storyboard = await UIStoryboard(name: "Main", bundle: nil)
            if
                let viewController = await storyboard.instantiateInitialViewController() as? UITabBarController {
                Task {@MainActor in
                    window.rootViewController = viewController
                    viewController.selectedIndex = 3
                }
            }
        }
        return .result()
    }


}
