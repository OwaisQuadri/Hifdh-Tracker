//
//  AppDelegate.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-09.
//

import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    let userDefaults = UserDefaults.standard
    let sharedUserDefaults = UserDefaults(suiteName: "group.HifdhTracker") ?? .standard
    let isIpad = UIDevice().userInterfaceIdiom == UIUserInterfaceIdiom.pad

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        // MARK: Init UserDefaults booleans
        // set default first run values
        let defaultValues = [UserDefaultsKey.isFirstRun.rawValue : true, UserDefaultsKey.isFromFront.rawValue : true]
        userDefaults.register(defaults: defaultValues)
        let managedContext = persistentContainer.viewContext

        // if first run
        if userDefaults.bool(forKey: UserDefaultsKey.isFirstRun.rawValue) {
            Page.getDefaultPages(managedContext)
            userDefaults.set(true, forKey: UserDefaultsKey.isFirstRun.rawValue)
        }

        registerNotifHandlers()

        Task { @MainActor in
            await SubscriptionManager.shared.updatePurchasedProducts()
            if SubscriptionManager.shared.isPremium {
                HTShortcuts.updateAppShortcutParameters()
            }
        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer =  {
        let container = NSPersistentContainer(name: "Hifdh_Tracker")
        container.loadPersistentStores() { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        if let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.HifdhTracker")?.appendingPathComponent("Hifdh_Tracker.sqlite") {
            let storeDescription = NSPersistentStoreDescription(url: url)
            container.persistentStoreDescriptions = [storeDescription]
        }
        return container
    }()


    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

fileprivate extension AppDelegate {

    func registerNotifHandlers() {
        // openCountersPage notif
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(
                openCountersPage
            ),
            name: Notification.Name(
                "openCountersPage"
            ),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(
                handleDataUpdateRequest(
                    _:
                )
            ),
            name: Notification.Name(
                "withCoreData"
            ),
            object: nil
        )


    }
    
    @objc func handleDataUpdateRequest(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let completion = userInfo["completion"] as? (NSManagedObjectContext) -> Void else {
            return
        }
        
        // Fetch data from Core Data
        let context = persistentContainer.viewContext
        
        completion(context)
        saveContext()
    }

    @objc func openCountersPage() {
        DispatchQueue.main.async {
            if
                let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                let window = scene.windows.first
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                if
                    let viewController = storyboard.instantiateInitialViewController() as? UITabBarController {
                    Task {@MainActor in
                        window.rootViewController = viewController
                        viewController.selectedIndex = 3
                    }
                }
            }
        }
    }
}
