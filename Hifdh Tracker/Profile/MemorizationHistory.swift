//
//  MemorizationHistory.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-23.
//

import SwiftUI
import Charts

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
            let maxPagesMemorized = pagesPerMonthList.max(by: { $1.pagesMemorized > $0.pagesMemorized}) ?? PagesPerMonth(date: Date(), pagesMemorized: 1)
            let maxYAxisValue = (max(maxPagesMemorized.pagesMemorized,Int(PagesPerMonth.overall)) * 2)
            Chart (pagesPerMonthList) { pagesPerMonth in
                BarMark(
                    x: .value("Week", pagesPerMonth.date, unit: .month),
                    y: .value("Pages", pagesPerMonth.pagesMemorized)
                )
                .foregroundStyle(Color.accentColor.gradient)
                
                
                
                RuleMark(y:.value("Average", PagesPerMonth.overall))
                    .foregroundStyle(Color.accentColor)
                    .lineStyle(StrokeStyle(dash: [5]))
                    .annotation(alignment: .leading){
                        (
                            Text("Avg: ")
                            + Text(NumberFormatter.twoDecimals(PagesPerMonth.overall) ?? "0.00")
                        )
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .background(.background.opacity(0.15))
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
        }
    }
}
