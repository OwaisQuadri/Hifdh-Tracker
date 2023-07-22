//
//  Format+Util.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-22.
//

import Foundation

extension NumberFormatter {
    
    static func twoDecimals(_ number: Double) -> String? {
        let twoDecimalFormat = NumberFormatter()
        twoDecimalFormat.maximumFractionDigits = 2
        twoDecimalFormat.minimumFractionDigits = 2
        return twoDecimalFormat.string(from: NSNumber(floatLiteral: number))
    }
    
    static func percent(_ number: Double) -> String? {
        let percentFormat = NumberFormatter()
        percentFormat.numberStyle = .percent
        percentFormat.maximumFractionDigits = 1
        percentFormat.minimumFractionDigits = 1
        return percentFormat.string(from: NSNumber(floatLiteral: number))
    }
}
