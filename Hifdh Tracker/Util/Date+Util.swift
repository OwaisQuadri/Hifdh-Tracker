//
//  Date+Util.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-22.
//

import Foundation

extension Date {
    
    static func from(year: Int, month: Int, day: Int) -> Date {
        let dateComponents = DateComponents(year: year, month: month, day: day)
        let date = Calendar.current.date(from: dateComponents) ?? Date()
        return date
    }
    
    func startOfMonth(using calendar: Calendar = .gregorian) -> Date {
        return calendar.date(from: calendar.dateComponents([.calendar, .year, .month], from: self))!
    }
}

extension Calendar {
    static let gregorian = Calendar(identifier: .gregorian)
}

