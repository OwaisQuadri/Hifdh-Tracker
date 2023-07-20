//
//  ProfileViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-16.
//

import UIKit
import CoreData

class ProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Constants
    let delegate = UIApplication.shared.delegate as? AppDelegate
    
    
    // MARK: Variables
    var isDropDownExpanded: Bool = false
    
    
    // MARK: Outlets
    @IBOutlet weak var mainStatPicker: UIPickerView!
    @IBOutlet weak var mainStatTitleLabel: UILabel!
    @IBOutlet weak var mainStatValueLabel: UILabel!
    @IBOutlet weak var statisticDropDownButton: UIButton!
    @IBOutlet weak var memorizationProgressbar: UIProgressView!
    @IBOutlet weak var mainStatPickerHeight: NSLayoutConstraint!
    
    // MARK: ViewDid...
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.layoutIfNeeded()
        configureProgressBar()
        configureStatPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update all views
        self.configureMainStatCard(for: Page.selectedStat ?? .pagesMemorized)
    }
    
    // MARK: Configurations
    
    private func configureStatPicker() {
        mainStatPicker.dataSource = self
        mainStatPicker.delegate = self
        mainStatPicker.selectRow((Page.selectedStat ?? Statistic.pagesMemorized).rawValue, inComponent: 0, animated: false)
        setMainStatPickerVisibility(to: isDropDownExpanded)
    }
    
    private func configureProgressBar() {
        var percentMemorized: Float = 0.0
        percentMemorized = Float(Page.numberOfMemorized) / 604.0
        memorizationProgressbar.progress = percentMemorized
    }
    
    private func configureMainStatCard(for statistic: Statistic) -> Void {
        
        switch statistic {
            case .completionDate:
                // configure for date first
                mainStatTitleLabel.text = "Predicted Hifdh Completion"
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM/dd/yyyy"
                var mainStatValueString: String = ""
                mainStatValueString = dateFormatter.string(from: Page.completionDate)
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
                mainStatValueLabel.text = Page.percentMemorizedAsString
        }
    }
    
    // MARK: Actions
    @IBAction func statisticsDropDownButtonPressed(_ sender: UIButton) {
        var imageName = "chevron."
        if isDropDownExpanded {
            isDropDownExpanded = false
            imageName += "down"
            Page.selectedStat = Statistic(rawValue: self.mainStatPicker.selectedRow(inComponent: 0))
            
        } else {
            isDropDownExpanded = true
            imageName += "up"
        }
        statisticDropDownButton.setImage(UIImage(systemName: imageName), for: .normal)
        setMainStatPickerVisibility(to: isDropDownExpanded)
    }
    
    // MARK: Animations / Dynamic Constraints
    private func setMainStatPickerVisibility(to show: Bool) {
        
        UIView.animate(withDuration: 0.3){ [self] in
            if show {
                mainStatPickerHeight.constant = 100
                self.view.layoutIfNeeded()
            } else {
                mainStatPickerHeight.constant = 0
                self.view.layoutIfNeeded()
                
            }
        }
    }
    
    // MARK: UIPicker
    
    let mainStatistics = ["Predicted Hifdh Completion", "Pages per Day", "Pages Memorized", "Percent Memorized",]
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return mainStatistics.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return mainStatistics[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        Page.selectedStat = Statistic(rawValue: self.mainStatPicker.selectedRow(inComponent: 0))
        configureMainStatCard(for: Page.selectedStat ?? .pagesMemorized)
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
