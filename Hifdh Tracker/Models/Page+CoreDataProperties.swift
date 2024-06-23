//
//  Page+CoreDataProperties.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-10.
//
//

import CoreData
import UIKit
import AppIntents
import SwiftUI

// MARK: Page Model
extension Page {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page")
    }
    
    @NSManaged public var dateMemorized: Date?
    @NSManaged public var isMemorized: Bool
    @NSManaged public var pageNumber: Int16
    
}

extension Page : Identifiable {
    
    // MARK: custom init
    convenience init(_ pageNumber: Int16, _ context: NSManagedObjectContext) {
        self.init(context: context)
        self.pageNumber = pageNumber
        self.isMemorized = false
        self.dateMemorized = nil
    }
    
    // MARK: Global array
    static var logs: [Page] {
        get {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            return fetchPages(in: delegate.persistentContainer.viewContext)
        }
    }
    
    // MARK: Delete all data
    static func deleteAll(in context: NSManagedObjectContext) {
        // Initialize Fetch Request
        let request: NSFetchRequest<Page> = Page.fetchRequest()
        
        do {
            let items = try context.fetch(request)
            for item in items {
                context.delete(item)
            }
            try context.save()
            
        } catch {
            // TODO: Error Handling
        }
    }
    
    // MARK: Reset all data
    static func getDefaultPages(_ context: NSManagedObjectContext) -> Void {
        Page.deleteAll(in: context)
        try? context.save()
        for i:Int16 in 1...604 {
            let _ = Page(i, context)
            try? context.save()
        }
    }
    
    // MARK: Fetch all in context
    static func fetchPages(in context: NSManagedObjectContext) -> [Page] {
        let request: NSFetchRequest<Page> = Page.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "pageNumber", ascending: (UserDefaults.standard.bool(forKey: UserDefaultsKey.isFromFront.rawValue)))]
        
        if let pageLogsFromCoreData = try? context.fetch(request) {
            return pageLogsFromCoreData
        }
        return []
    }
    
    // MARK: Statistics and calculations
    
    static var firstNotInMemoryIndexPath: IndexPath {
        return IndexPath(row: Page.logs.firstIndex(where: { !$0.isMemorized }) ?? 0, section: 1)
    }
    
    static var selectedStat: Statistic?
    
    static var lowestLogDate: Date? {
        arrayOfMemorized.compactMap { $0.dateMemorized }.min()
    }
    
    static var highestLogDate: Date? {
        arrayOfMemorized.compactMap { $0.dateMemorized }.max()
    }
    
    static var arrayOfMemorized: [Page] {
        return Page.logs.compactMap { $0.isMemorized ? $0 : nil }
    }
    
    static var numberOfMemorized: Double {
        return Double(arrayOfMemorized.count)
    }
    
    static var numberOfNotMemorized: Double {
        return 604.0 - numberOfMemorized
    }
    
    static var percentMemorized: Double {
        return numberOfMemorized / 604.0
    }
    
    static var percentMemorizedAsString: String {
        let percentFormat = NumberFormatter()
        percentFormat.numberStyle = .percent
        percentFormat.maximumFractionDigits = 1
        percentFormat.minimumFractionDigits = 1
        return percentFormat.string(from: NSNumber(floatLiteral: percentMemorized)) ?? "0.0%"
    }
    
    static var pagesPerDay: Double {
        get {
            if let highestLogDate = highestLogDate, let lowestLogDate = lowestLogDate {
                let durationOfHidfh = (highestLogDate.distance(to: lowestLogDate).magnitude).convert(to: .days)
                return (numberOfMemorized/(durationOfHidfh + 1).rounded())
            } else { return 0.0 }
        }
    }
    
    static var completionDate: Date {
        return(Date().advanced(by: ((numberOfNotMemorized/pagesPerDay).convert(from: .days, to: .seconds))))
    }
}

// MARK: AppIntent
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
        await withCoreData {
            entities = Page.logs.filter {
                !$0.isMemorized
            } .map {
                PageEntity(
                    pageNumber: Int(
                        $0.pageNumber
                    )
                )
            }
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
        var allSuggestions = try await allEntities()
//        var suggested = Array(allSuggestions.prefix(1))
//        allSuggestions.removeFirst()
//        if let last = allSuggestions.last {
//            suggested.append(last)
//        }
        return allSuggestions
    }
}

// MARK: Enumerations

enum Statistic: Int {
    case completionDate = 0
    case pagesPerDay = 1
    case pagesMemorized = 2
    case percentMemorized = 3

    static let defaultValue: Self = .pagesPerDay
}
