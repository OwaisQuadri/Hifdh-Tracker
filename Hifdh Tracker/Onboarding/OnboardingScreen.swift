//
//  OnboardingScreen.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-26.
//

import UIKit

struct OnboardingScreen {
    var caption: String
    var image: UIImage
    
    static let all = [
        OnboardingScreen(
            caption: NSLocalizedString("Use the switch to log single pages", comment: "tell the user to use the switch to log single pages on a single date"),
            image: UIImage(named: "onboarding")!
        ),
        OnboardingScreen(
            caption: NSLocalizedString("Use the “+” to log multiple pages on a single date", comment: "using the plus symbol to log more than one page on a single date"),
            image: UIImage(named: "onboarding2")!
        ),
        OnboardingScreen(
            caption: NSLocalizedString("View your stats on the “Profile” tab", comment: "use the profile tab to view stats"),
            image: UIImage(named: "onboarding3")!
        ),
        OnboardingScreen(
            caption: NSLocalizedString("Create and edit your goals in the “Goals” tab by pressing the “+” button", comment: "add and edit goals"),
            image: UIImage(named: "onboarding4")!
        ),
    ]
}
