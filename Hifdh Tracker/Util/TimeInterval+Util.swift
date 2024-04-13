//
//  TimeInterval+Util.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-20.
//

import Foundation

enum TimeUnit: Double {
    case seconds = 1
    case minutes = 60
    case hours = 3600
    case days = 86400
    case weeks = 604800
    case months = 2629800
    case years = 31536000
}
extension Double {
    // convert from seconds to days or reverse
    func convert(from: TimeUnit = .seconds, to: TimeUnit) -> Double {
        let fromSeconds = from.rawValue
        let toSeconds = to.rawValue
        return self * (fromSeconds / toSeconds)
    }
}
