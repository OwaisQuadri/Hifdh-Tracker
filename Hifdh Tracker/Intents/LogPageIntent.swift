//
//  LogPageIntent.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-06-22.
//

import UIKit
import AppIntents

struct LogPageIntent: AppIntent {// OpenIntent for intents that open your app

    static var title: LocalizedStringResource = "Log a Page"

    @Parameter(title: "Page")
    var page: PageEntity

    func perform() async throws -> some IntentResult & ProvidesDialog {
        guard SubscriptionManager.shared.isPremium else {
            return .result(
                dialog: .init(stringLiteral: "This feature requires a premium subscription. Please open the app to adjust your settings.")
            )
        }
        await MainActor.run {
            withCoreData {_ in 
                let currentPage = Page.logs[page.pageNumber-1]
                currentPage.isMemorized = true
                currentPage.dateMemorized = .now
                Analytics.shared.track(events: .logPage)
            }
        }
        return .result(dialog: .init("\(page) was  logged as memorized"))

    }
    static var parameterSummary: some ParameterSummary {
        Summary("Mark \(\.$page) as Memorized")
    }
}
