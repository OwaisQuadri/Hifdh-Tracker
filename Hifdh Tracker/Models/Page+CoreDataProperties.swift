//
//  Page+CoreDataProperties.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-10.
//
//

import CoreData
import UIKit


extension Page {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Page> {
        return NSFetchRequest<Page>(entityName: "Page")
    }

    @NSManaged public var dateMemorized: Date?
    @NSManaged public var isMemorized: Bool
    @NSManaged public var pageNumber: Int16

}

extension Page : Identifiable {
    convenience init(_ pageNumber: Int16, _ context: NSManagedObjectContext) {
        self.init(context: context)
        self.pageNumber = pageNumber
        self.isMemorized = false
        self.dateMemorized = nil
    }
    static var logs: [Page] {
        get {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            return fetchPages(in: delegate.persistentContainer.viewContext)
        }
    }
    static func getDefaultPages(_ context: NSManagedObjectContext) -> Void {
        Page.deleteAll(in: context)
        try? context.save()
        for i:Int16 in 1...604 {
            let _ = Page(i, context)
            try? context.save()
        }
    }
    
    enum Stat {
        case completionDate
        case pagesPerDay
    }
    
    static func fetchPages(in context: NSManagedObjectContext) -> [Page] {
        let request: NSFetchRequest<Page> = Page.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "pageNumber", ascending: (UserDefaults.standard.bool(forKey: UserDefaultsKey.isFromFront.rawValue)))]
        
        if let pageLogsFromCoreData = try? context.fetch(request) {
            return pageLogsFromCoreData
        }
        return []
    }
    
    static func getStatistic(called statisticName: Stat) {
        switch statisticName {
            case .completionDate:
                
                return
            case .pagesPerDay:
                return
        }
    }
    
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
}
