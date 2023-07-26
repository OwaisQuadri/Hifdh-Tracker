//
//  Goal+CoreDataProperties.swift
//  
//
//  Created by Owais on 2023-07-23.
//
//

import CoreData
import UIKit

enum GoalType: String {
    case findEndDate = "findEndDate"
    case findPagesPerTimePeriod = "findPagesPerTimePeriod"
    case findEndPage = "findEndPage"
    
}

extension Goal {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Goal> {
        return NSFetchRequest<Goal>(entityName: "Goal")
    }

    @NSManaged public var goalDate: Date?
    @NSManaged public var goalPages: Double
    @NSManaged public var goalPagesPerDay: Double
    @NSManaged public var goalType: String
    @NSManaged public var goalName: String?

}


extension Goal: Identifiable {
    
    var type: GoalType {
        get {
            return GoalType(rawValue: goalType) ?? .findEndDate
        }
        set {
            self.goalType = newValue.rawValue
        }
    }
    
    convenience init(name: String, pages: Double = 604, by date: Date, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.goalName = name
        self.goalDate = date
        self.goalPages = pages
        self.type = .findPagesPerTimePeriod
    }
    
    convenience init(name: String, _ pages: Double, pagesPer timeUnits: TimeUnits, forTotalPages goalPages: Double = 604, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.goalName = name
        self.goalPagesPerDay = pages.convert(from: .days, to: timeUnits)
        self.goalPages = goalPages
        self.type = .findEndDate
    }
    
    convenience init(name: String, _ pages: Double, pagesPer timeUnits: TimeUnits, until date: Date, in context: NSManagedObjectContext) {
        self.init(context: context)
        self.goalName = name
        self.goalPagesPerDay = pages.convert(from: .days, to: timeUnits)
        self.goalDate = date
        self.type = .findEndPage
    }
    
    var dateOfGoalComplete: Date? {
        if type != .findEndDate { return nil }
        let currentDate = Date()
        if Page.numberOfMemorized >= goalPages { return currentDate }
        let pagesRemaining = goalPages - Page.numberOfMemorized
        return currentDate + TimeInterval(pagesRemaining/goalPagesPerDay).convert(from: .days, to: .seconds)
    }
    
    func pagesPer(_ timeUnits: TimeUnits) -> Double? {
        if type != .findPagesPerTimePeriod { return nil }
        let pagesRemaining = goalPages - Page.numberOfMemorized
        if pagesRemaining <= 0.0 { return 0.0}
        let timeUnitsRemaining = Date().distance(to: goalDate! ).convert(from: .seconds, to: timeUnits)
        return pagesRemaining/timeUnitsRemaining
        
    }
    
    var endPage: Double? {
        if type != .findEndPage || goalPagesPerDay < 0 { return nil }
        //pagesPerDay multiplied by range
        let daysRemaining = goalDate!.distance(to: Date()).magnitude.convert(to: .days)
        if daysRemaining <= 0 { return Page.numberOfMemorized }
        return min(604.0, Page.numberOfMemorized + goalPagesPerDay * daysRemaining)
    }
    
    static func fetchGoals(in context: NSManagedObjectContext) -> [Goal] {
        let request: NSFetchRequest<Goal> = Goal.fetchRequest()
        if let goalsFromCoreData = try? context.fetch(request) {
            return goalsFromCoreData
        }
        return []
    }
    static var goals: [Goal] {
        get {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            return fetchGoals(in: delegate.persistentContainer.viewContext)
        }
    }
    func delete(in context: NSManagedObjectContext) {
        do{
            context.delete(self)
            try context.save()
        } catch {
            // TODO: err handle
        }
    }
    
}
