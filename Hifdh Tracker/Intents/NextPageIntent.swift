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

    func perform() async throws -> some IntentResult & ReturnsValue<PageEntity> {
        guard SubscriptionManager.shared.isPremium else {
            throw IntentError.notPremium
        }
        var page: PageEntity? = nil
        withCoreData { context in
            let pageNumber = Page.fetchPages(in: context).first(where: {
                $0.isMemorized == false
            })?.pageNumber
            page = PageEntity(pageNumber: Int(pageNumber ?? 0))
        }
        let defaultValue = PageEntity(pageNumber: 0)
        return .result(value: page ?? defaultValue)
    }
}

