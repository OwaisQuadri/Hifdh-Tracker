//
//  FullscreenCoverManager.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-11-03.
//

import UIKit
import SwiftUI

class FullscreenCoverManager {
    static let shared = FullscreenCoverManager()

    private init() {}
    
    func presentFullscreenCover(onDismiss: (() -> Void)? = nil) {
        if
            let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
            let window = scene.windows.first
        {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            if
                let viewController = storyboard.instantiateInitialViewController() as? UITabBarController {
                Task {@MainActor in
                    viewController.selectedIndex = 1
                    window.rootViewController = viewController
                    let swiftUIView = PaywallView()

                    let hostingController = UIHostingController(rootView: swiftUIView)
                    hostingController.modalPresentationStyle = .fullScreen
                    guard let rootViewController = window.rootViewController else { return }
                    Analytics.shared.view(screen: .paywall)
                    rootViewController.present(hostingController, animated: true, completion: nil)
                }
            }
        }
    }
}
