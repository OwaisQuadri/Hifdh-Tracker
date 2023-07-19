//
//  ProfileViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-16.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController {
    var isDropDownExpanded: Bool = false
    let delegate = UIApplication.shared.delegate as? AppDelegate
    @IBOutlet weak var statisticDropDownButton: UIButton!
    @IBOutlet weak var memorizationProgressbar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        setupProgressBar()
    }
    
    func setupProgressBar() {
        var percentMemorized: Float = 0.0
        withCoreData {
            // load total memorized percentage from CoreData
            let arrayOfMemorized = Page.logs.compactMap{$0.isMemorized ? $0 : nil}
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
    
    @IBAction func statisticsDropDownButtonPressed(_ sender: UIButton) {
        var imageName = "chevron."
        if isDropDownExpanded {
            isDropDownExpanded = false
            imageName += "down"
        } else {
            isDropDownExpanded = true
            imageName += "up"
        }
        UIView.animate(withDuration: 10, animations: {[self] in
            statisticDropDownButton.setImage(UIImage(systemName: imageName), for: .normal)
        })
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
