//
//  PageEntity.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-07-20.
//

import Foundation
import AppIntents

// MARK: AppEntity
struct PageEntity: AppEntity {
    var id: Int {
        pageNumber
    }

    var pageNumber: Int

    static var defaultQuery = PageEntityQuery()

    public static var typeDisplayRepresentation: TypeDisplayRepresentation = "Page"

    public var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(
            title: .init(stringLiteral: self.description),
            subtitle: "A Page from the Mushaf Al-Madinah Quran (1-604)",
            image: .init(systemName: "book.pages")
        )
    }
}

extension PageEntity: CustomStringConvertible {
    var description: String {
        "Page \(pageNumber)"
    }
}

struct PageEntityQuery: EntityQuery, EnumerableEntityQuery {
    func allEntities() async throws -> [PageEntity] {
        var entities = [PageEntity]()
            entities = Page.logs.filter {
                !$0.isMemorized
            } .map {
                PageEntity(
                    pageNumber: Int(
                        $0.pageNumber
                    )
                )
            }
        return entities
    }

    func entities(for identifiers: [Int]) async throws -> [PageEntity] {
        // Provide entities based on identifiers
        // Assuming identifiers are correctly mapped
        return identifiers.compactMap { pageNumber in
            // Example: You may need to fetch actual data based on the identifier
            // Replace with actual mapping if available
            PageEntity(pageNumber: pageNumber)
        }
    }
    //    func defaultResult() async -> PageEntity? {
    //        try? await suggestedEntities().first
    //    }
    func suggestedEntities() async throws -> [PageEntity] {
        let allSuggestions = try await allEntities()
        //        var suggested = Array(allSuggestions.prefix(1))
        //        allSuggestions.removeFirst()
        //        if let last = allSuggestions.last {
        //            suggested.append(last)
        //        }
        return allSuggestions
    }
}

