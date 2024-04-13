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
    @State var currentActiveItem: PagesPerMonth?
    var body: some View {
        VStack{
            Text(Localized.pagesMemorizedPerMonth)
                .multilineTextAlignment(.center)
                .font(.headline)
                .fontWeight(.bold)
                .frame(alignment: .center)
            let maxPagesMemorized = pagesPerMonthList.max(by: { $1.pagesMemorized > $0.pagesMemorized}) ?? PagesPerMonth(date: Date(), pagesMemorized: 1)
            let maxYAxisValue = (max(maxPagesMemorized.pagesMemorized,Int(PagesPerMonth.overall)) * 2)
            Chart (pagesPerMonthList) { pagesPerMonth in
                BarMark(
                    x: .value(Localized.month, pagesPerMonth.date, unit: .month),
                    y: .value(Localized.pages, pagesPerMonth.pagesMemorized)
                )
                .foregroundStyle(Color.accentColor.gradient)
                
                // MARK: Rule mark for dragging item
                if let currentActiveItem, currentActiveItem.id == pagesPerMonth.id {
                    RuleMark(x: .value(Localized.month, currentActiveItem.date.advanced(by: (15).convert(from: .days, to: .seconds))))
                        .foregroundStyle(.secondary)
                        .lineStyle(.init(dash: [3]))
                        .annotation(position: .top) {
                            VStack {
                                Text("\(DateFormatter.getMonthOfYear(from: currentActiveItem.date)!)")
                                    .font(.caption)
                                Text(String(currentActiveItem.pagesMemorized))
                                    .font(.title3)
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 4, style: .continuous)
                                    .fill(.background.shadow(.drop(radius: 2))).opacity(0.95)
                            }
                        }
                }
                
                RuleMark(y:.value(Localized.average, PagesPerMonth.overall))
                    .foregroundStyle(Color.accentColor)
                    .lineStyle(StrokeStyle(dash: [5]))
                    .annotation(alignment: .leading){
                        (
                            Text(Localized.avg)
                            + Text(NumberFormatter.twoDecimals(PagesPerMonth.overall) ?? "0.00")
                        )
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .background(.background.opacity(0.15))
                    }
                
            }
            .chartOverlay(content: { proxy in
                GeometryReader { innerProxy in
                    Rectangle()
                        .fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture()
                                .onChanged {value in
                                    //get current coords
                                    let location = value.location
                                    
                                    
                                    if let date: Date = proxy.value(atX: location.x) {
                                        let month = Calendar.current.component(.month, from: date)
                                        let year = Calendar.current.component(.year, from: date)
                                        if let currentItem = pagesPerMonthList.first(where: {item in
                                            Calendar.current.component(.month, from: item.date) == month && Calendar.current.component(.year, from: item.date) == year
                                        }) {
                                            self.currentActiveItem = currentItem
                                        }
                                    }
                                }.onEnded{ value in
                                    self.currentActiveItem = nil
                                }
                        )
                }
            })
            .padding()
            .frame(minWidth: 200, minHeight: 200)
            .chartYScale(domain: 0...maxYAxisValue)
            .chartXScale(domain: (pagesPerMonthList.min(by: {$1.date>$0.date})?.date ?? Date())...(Page.percentMemorized == 1 ? Page.highestLogDate ?? Date.now : Date.now))
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
extension Localized {
    static let pagesMemorizedPerMonth = NSLocalizedString("Pages Memorized per Month", comment: "Title for the chart that shows the pages memorized per month")
    static let pages = NSLocalizedString("Pages", comment: "Title for the y-coord of the chart data points")
    static let month = NSLocalizedString("Month", comment: "Title for the x-coord of the chart data points")
    static let average = NSLocalizedString("Average", comment: "Label for the average pages memorized per month")
    static let avg = NSLocalizedString("Avg: ", comment: "Label for the average pages memorized per month, abbreviated to 3 letters, Sentence case, ends with ': '")
}
