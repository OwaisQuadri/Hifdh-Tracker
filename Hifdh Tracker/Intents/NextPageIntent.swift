//
//  NextPageIntent.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-06-22.
//

import UIKit
import AppIntents

struct NextPageIntent: AppIntent {// OpenIntent for intents that open your app
    static var title: LocalizedStringResource = "Suggested Next Page"

    func perform() async throws -> some IntentResult & ProvidesDialog & ReturnsValue<PageEntity> {
        var page: PageEntity = PageEntity(pageNumber: 0)
        await withCoreData {
            if let pageNumber = Page.logs.first(where: {
                $0.isMemorized == false
            })?.pageNumber {
                page = PageEntity(pageNumber: Int(pageNumber) )
            }
        }
        return .result(value: page, dialog: .init( stringLiteral: page.pageNumber == 0 ? "None" : "\(page)"))
    }
}

