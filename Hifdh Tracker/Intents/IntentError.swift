//
//  IntentError.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-11-03.
//

import Foundation

public enum IntentError: Error {
    case notPremium

    var localizedDescription: String {
        switch self {
        case .notPremium:
            return "This feature requires a premium subscription."
        }
    }
}
