//
//  TimeInterval+Util.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-20.
//

import Foundation

extension TimeInterval {
    func convert(from fromUnit: TimeUnits = .seconds, to toUnit: TimeUnits) -> TimeInterval {
        var x = self
        switch fromUnit {
            case .seconds:
                break
            case .days:
                x *= (60*60*24)
            case .weeks:
                x *= (60*60*24*7)
            case .months:
                x *= (60*60*24*30)
            case .years:
                x *= (60*60*24*365)
        }
        switch toUnit {
            case .seconds:
                break
            case .days:
                x /= (60*60*24)
            case .weeks:
                x /= (60*60*24*7)
            case .months:
                x /= (60*60*24*30)
            case .years:
                x /= (60*60*24*365)
        }
        return x
    }
}
