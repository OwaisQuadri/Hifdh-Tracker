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

    func perform() async throws -> some IntentResult & ReturnsValue<PageEntity?> & ProvidesDialog {
        guard SubscriptionManager.shared.isPremium else {
            return .result(
                value: nil,
                dialog: .init(stringLiteral: "This feature requires a premium subscription. Please open the app to adjust your settings.")
            )
        }
        var page: PageEntity? = nil
        withCoreData { context in
            let pageNumber = Page.fetchPages(in: context).first(where: {
                $0.isMemorized == false
            })?.pageNumber
            page = PageEntity(pageNumber: Int(pageNumber ?? 0))
        }
        var dialog: IntentDialog
        if let page {
            dialog = .init("The next suggested page is \(page)")
        } else {
            dialog = .init("We could not determine the next page. please open the app to refresh shortcut availability")
        }
        return .result(
            value: page,
            dialog: dialog
        )
    }
}

