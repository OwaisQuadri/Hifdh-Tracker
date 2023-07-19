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
    @IBOutlet weak var mainStatTitleLabel: UILabel!
    @IBOutlet weak var mainStatValueLabel: UILabel!
    @IBOutlet weak var statisticDropDownButton: UIButton!
    @IBOutlet weak var memorizationProgressbar: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        configureProgressBar()
        configureMainStatCard(for: Page.selectedStat ?? .pagesMemorized)
        
        
    }
    
    func configureProgressBar() {
        var percentMemorized: Float = 0.0
        withCoreData {
            percentMemorized = Float(Page.numberOfMemorized) / 604.0
        }
        memorizationProgressbar.progress = percentMemorized
    }
    
    func configureMainStatCard(for statistic: Statistic) -> Void {
        
        switch statistic {
            case .completionDate:
                // configure for date first
                mainStatTitleLabel.text = "Predicted Hifdh Completion"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM/dd/yyyy"
                var mainStatValueString: String = ""
                withCoreData {
                    mainStatValueString = dateFormatter.string(from: Page.completionDate)
                }
                mainStatValueLabel.text = mainStatValueString
            case .pagesPerDay:
                mainStatTitleLabel.text = "Pages per Day"
                let pageFormat = NumberFormatter()
                pageFormat.maximumFractionDigits = 2
                pageFormat.minimumFractionDigits = 2
                mainStatValueLabel.text = pageFormat.string(from: NSNumber(floatLiteral: Page.pagesPerDay))
            case .pagesMemorized:
                mainStatTitleLabel.text = "Pages Memorized"
                mainStatValueLabel.text = "\(Int(Page.numberOfMemorized))"
            case .percentMemorized:
                mainStatTitleLabel.text = "Percent Memorized"
                let percentFormat = NumberFormatter()
                percentFormat.numberStyle = .percent
                percentFormat.maximumFractionDigits = 1
                percentFormat.minimumFractionDigits = 1
                mainStatValueLabel.text = percentFormat.string(from: NSNumber(floatLiteral: Page.percentMemorized))
        }
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
