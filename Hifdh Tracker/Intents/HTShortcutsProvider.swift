//
//  HTShortcutsProvider.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-06-22.
//

import Foundation
import AppIntents

struct HTShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: OpenCounterIntent(),
            phrases: [
                "open counter session in \(.applicationName)",
                "\(.applicationName) counter",
            ],
            shortTitle: "Open Counter Session",
            systemImageName: "gauge.badge.plus"
        )
        AppShortcut(
            intent: LogPageIntent(),
            phrases: [
                "Log \(\.$page) in \(.applicationName)",
                "Log a page in \(.applicationName)"
            ],
            shortTitle: "Log a Page",
            systemImageName: "doc.fill.badge.plus"
            //            parameterPresentation: .init(for: \LogPageIntent.$page, summary: .init("Log a Page"))
        )
        AppShortcut(
            intent: NextPageIntent(),
            phrases: [
                "Which page should I memorize next in \(.applicationName)?",
                "What page should I memorize next in \(.applicationName)?",
                "Which page do i do next in \(.applicationName)?",
                "What page do i do next in \(.applicationName)?",
                "\(.applicationName) suggested page",
                "What page am i on in \(.applicationName)?"
            ],
            shortTitle: "Suggested Page",
            systemImageName: "character.book.closed.fill.ar"
            //            parameterPresentation: .init(for: \LogPageIntent.$page, summary: .init("Log a Page"))
        )

    }
}
