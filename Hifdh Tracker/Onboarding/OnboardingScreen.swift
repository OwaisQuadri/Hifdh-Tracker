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
        OnboardingScreen(caption: "Use the switch to log single pages", image: UIImage(named: "onboarding")!),
        OnboardingScreen(caption: "Use the “+” to log multiple pages on a single date", image: UIImage(named: "onboarding2")!),
        OnboardingScreen(caption: "View your stats on the “Profile” tab", image: UIImage(named: "onboarding3")!),
        OnboardingScreen(caption: "Create goals in the “Goals” tab by pressing the “+” button", image: UIImage(named: "onboarding4")!),
    ]
}
