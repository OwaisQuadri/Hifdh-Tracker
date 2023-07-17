//
//  ProfileViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-16.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {
    let delegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet weak var memorizationProgressbar: UIProgressView!
    
    var logs : [Page] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        fetchData(delegate)
        setupProgressBar()
    }
    
    func fetchData(_ delegate: AppDelegate?) {
        // load from db
        if let context = delegate?.persistentContainer.viewContext  {
            withCoreData { [self] in
                let request: NSFetchRequest<Page> = Page.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "pageNumber", ascending: (delegate?.userDefaults.bool(forKey: UserDefaultsKey.isFromFront.rawValue)) ?? true)]
                
                if let pageLogsFromCoreData = try? context.fetch(request) {
                    self.logs = pageLogsFromCoreData
                }
            }
        }
    }
    
    func setupProgressBar() {
        var percentMemorized: Float = 0.0
        withCoreData {
            // load total memorized percentage from CoreData
            let arrayOfMemorized = self.logs.compactMap{$0.isMemorized ? $0 : nil}
            percentMemorized = Float(arrayOfMemorized.count) / 604.0
        }
        memorizationProgressbar.progress = percentMemorized
    }
    
    // MARK: Core Data
    
    func withCoreData(completion: @escaping() -> Void ){
        if let _ = delegate?.persistentContainer.viewContext {
            completion()
        }
        delegate?.saveContext()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
