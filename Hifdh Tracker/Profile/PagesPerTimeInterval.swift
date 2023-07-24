//
//  PagesPerTimeInterval.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-22.
//

import Foundation

// MARK: Chart's Model
struct PagesPerMonth: Identifiable {
    let id = UUID()
    let date: Date
    let pagesMemorized: Int
    
    static var list: [PagesPerMonth] {
        var dict: [Date:Int] = [:]
        let listOfDates = Page.logs.compactMap { $0.isMemorized ? $0.dateMemorized : nil }
        let aYearAgo = Date()-TimeInterval(1).convert(from:.years, to: .seconds)
        let firstDate = min((listOfDates).min() ?? aYearAgo,aYearAgo)
        var currentDate = Date()
        while currentDate > firstDate {
            dict[currentDate.startOfMonth()] = 0
            currentDate -= TimeInterval(1).convert(from: .months ,to: .seconds)
        }
        for date in listOfDates {
            dict[date.startOfMonth()]? += 1
        }
        let output = dict.map{ PagesPerMonth(date: $0.key, pagesMemorized: $0.value)}
        return output
    }
    
    static var overall: Double {
        return (Page.pagesPerDay*30)
    }
    
}
