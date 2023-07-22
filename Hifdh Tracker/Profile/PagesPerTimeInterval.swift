//
//  PagesPerTimeInterval.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-22.
//

import SwiftUI
import Charts
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

// MARK: SwiftUI View

struct MemorizationHistory: View {
    var pagesPerMonthList = PagesPerMonth.list
    var body: some View {
        VStack{
            Text("Pages Memorized per Month")
                .multilineTextAlignment(.center)
                .font(.headline)
                .fontWeight(.bold)
                .frame(alignment: .center)
            
            ScrollView(.horizontal) {
                let maxPagesMemorized = pagesPerMonthList.max(by: { $1.pagesMemorized > $0.pagesMemorized}) ?? PagesPerMonth(date: Date(), pagesMemorized: 1)
                let maxYAxisValue = (max(maxPagesMemorized.pagesMemorized,Int(PagesPerMonth.overall)) * 2)
                Chart {
                    ForEach(pagesPerMonthList) { pagesPerMonth in
                        BarMark(
                            x: .value("Week", pagesPerMonth.date, unit: .month),
                            y: .value("Pages", pagesPerMonth.pagesMemorized)
                        )
                        .foregroundStyle(.foreground)
                    }
                    
                    
                    RuleMark(y:.value("Average", PagesPerMonth.overall))
                        .foregroundStyle(Color.red)
                        .lineStyle(StrokeStyle(dash: [5]))
                        .annotation(alignment: .leading){
                            (
                                Text("Avg: ")
                                + Text(NumberFormatter.twoDecimals(PagesPerMonth.overall) ?? "0.00")
                            )
                            .font(.caption)
                            .foregroundColor(.red)
                        }
                    
                }
                .padding()
                .frame(minWidth: 200, minHeight: 200)
                .chartYScale(domain: 0...maxYAxisValue)
                .chartXScale(domain: (pagesPerMonthList.min(by: {$1.date>$0.date})?.date ?? Date())...Date.now)
                .chartXAxis {
                    AxisMarks( values: pagesPerMonthList.map{ $0.date }){ _ in
                        AxisValueLabel(format: .dateTime.month(.narrow))
                        AxisTick()
                        AxisGridLine()
                    }
                }
                .scaledToFill()
            }.frame(maxWidth: 1000)
                .scaledToFill()
        }
    }
}

