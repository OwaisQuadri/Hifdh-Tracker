//
//  Page+CoreDataProperties.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-10.
//
//

import Foundation
import CoreData


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
    static func getDefaultPages(_ context: NSManagedObjectContext) -> Void {
        Page.deleteAll(in: context)
        try? context.save()
        for i:Int16 in 1...604 {
            let _ = Page(i, context)
            try? context.save()
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
