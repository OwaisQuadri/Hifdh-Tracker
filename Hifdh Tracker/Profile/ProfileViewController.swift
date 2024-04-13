//
//  ProfileViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-16.
//

import CoreData
import SnapKit
import SwiftUI
import UIKit
import StoreKit

class ProfileViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: Constants
    let delegate = UIApplication.shared.delegate as? AppDelegate
    let swiftUIcontroller = UIHostingController(rootView: MemorizationHistory())
    
    // MARK: Variables
    var isDropDownExpanded: Bool = false
    var products: [SKProduct] = []

    
    // MARK: Outlets
    @IBOutlet weak var percentBarButton: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
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
        IAPManager.shared.purchaseStatusBlock = { [weak self] (type) in
            self?.showAlert(title: type.message)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // update all views
        configureViews()
    }
    
    // MARK: Configurations
    private func configureViews() {
        configureMainStatCard(for: Page.selectedStat ?? .defaultValue)
        configureTopRightMenu()
        configureStatPicker()
        configureProgressBar()
        configureChart()
        configureTopLeftBarItem()

        IAPManager.shared.initialize()
        IAPManager.shared.fetchAvailableProductsBlock = { (productsArray) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.products = productsArray
            }
        }

    }
    
    private func configureTopLeftBarItem() {
        percentBarButton.title = Page.percentMemorizedAsString
    }
    
    private func configureChart(){
        cleanUpChart()
        guard let chartView = swiftUIcontroller.view else { return }
        scrollView.addSubview(chartView)
        chartView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(mainStatPicker.snp.bottom).offset(25)
            make.leading.equalToSuperview().offset(25)
            make.trailing.equalToSuperview().inset(25)
        }
    }
    
    private func configureTopRightMenu() {
        let resetAllDataMenuItem = UIAction(title: Localized.resetAllData, image: UIImage(systemName: "trash"), attributes: .destructive) { [self] (_) in
            if let context = delegate?.persistentContainer.viewContext {
                // are you sure?
                let areYouSureAlert = UIAlertController(title: Localized.warningExclamation, message: Localized.areYouSure, preferredStyle: .alert)
                areYouSureAlert.addAction(.init(title: Localized.yesImSure, style: .destructive){_ in
                    Page.getDefaultPages(context)
                    self.configureViews()
                })
                areYouSureAlert.addAction(.init(title: Localized.cancel, style: .cancel))
                self.present(areYouSureAlert, animated: true)
            }
        }
        let showOnboardingMenuItem = UIAction(title: Localized.showTutorial, image: UIImage(systemName: "book.pages.fill")) { [self] (_) in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let onboardingController = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
            onboardingController.modalPresentationStyle = .fullScreen
            self.present(onboardingController, animated: true)
        }
        let buyMeACoffeeMenuItem = UIAction(title: Localized.buyMeACoffee, image: UIImage(systemName: "cup.and.saucer.fill")) {[weak self]_ in
            IAPManager.shared.purchaseProduct(withId: HTProduct.buyMeACoffee.id)
            self?.resignFirstResponder()
        }
        let topRightMenu = UIMenu(children: [buyMeACoffeeMenuItem, showOnboardingMenuItem, resetAllDataMenuItem])
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: nil, image: UIImage(systemName: "gear"), primaryAction: nil, menu: topRightMenu)
        
        view.layoutSubviews(duration: 0.5)
    }
    
    private func configureStatPicker() {
        mainStatPicker.dataSource = self
        mainStatPicker.delegate = self
        mainStatPicker.selectRow((Page.selectedStat ?? Statistic.defaultValue).rawValue, inComponent: 0, animated: false)
        setMainStatPickerVisibility(to: isDropDownExpanded)
        
        view.layoutIfNeeded()
    }
    
    private func configureProgressBar() {
        var percentMemorized: Float = 0.0
        percentMemorized = Float(Page.numberOfMemorized) / 604.0
        memorizationProgressbar.progress = percentMemorized
        
        view.layoutSubviews(duration: 0.5)
    }
    
    private func configureMainStatCard(for statistic: Statistic) -> Void {
        
        switch statistic {
            case .completionDate:
                // configure for date first
                mainStatTitleLabel.text = Localized.predictedHifdhCompletion
                var mainStatValueString: String = ""
                mainStatValueString = DateFormatter.mmmDDyyyy(Page.completionDate) ?? ""
                mainStatValueLabel.text = mainStatValueString
            case .pagesPerDay:
                mainStatTitleLabel.text = Localized.pagesPerDay
                let pageFormat = NumberFormatter()
                pageFormat.maximumFractionDigits = 2
                pageFormat.minimumFractionDigits = 2
                mainStatValueLabel.text = pageFormat.string(from: NSNumber(floatLiteral: Page.pagesPerDay))
            case .pagesMemorized:
                mainStatTitleLabel.text = Localized.pagesMemorized
                mainStatValueLabel.text = "\(Int(Page.numberOfMemorized))"
            case .percentMemorized:
                mainStatTitleLabel.text = Localized.percentMemorized
                mainStatValueLabel.text = Page.percentMemorizedAsString
        }
        
        view.layoutIfNeeded()
    }

    // MARK: Cleanup Views
    private func cleanUpChart(){
        swiftUIcontroller.rootView = MemorizationHistory()
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
        
        view.layoutSubviews(duration: 0.5)
    }
    
    // MARK: Dynamic Constraints
    private func setMainStatPickerVisibility(to show: Bool) {
        if show {
            mainStatPicker.isHidden = false
            mainStatPickerHeight.constant = 100
        } else {
            mainStatPicker.isHidden = true
            mainStatPickerHeight.constant = 0
        }
    }
    
    // MARK: UIPicker
    
    let mainStatistics = [Localized.predictedHifdhCompletion, Localized.pagesPerDay, Localized.pagesMemorized, Localized.percentMemorized]

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
        configureMainStatCard(for: Page.selectedStat ?? .defaultValue)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: Localized.okAllCaps, style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}

extension Localized {
    static let okAllCaps = NSLocalizedString("OK", comment: "'OK' in all caps")
    static let predictedHifdhCompletion = NSLocalizedString("Predicted Hifdh Completion", comment: "Predicted Hifdh Completion title")
    static let pagesPerDay = NSLocalizedString("Pages per Day", comment: "Pages per Day title")
    static let pagesMemorized = NSLocalizedString("Pages Memorized", comment: "Pages Memorized title")
    static let percentMemorized = NSLocalizedString("Percent Memorized", comment: "Percent Memorized title")
    static let showTutorial = NSLocalizedString("Show Tutorial", comment: "Show Tutorial menu item")
    static let resetAllData = NSLocalizedString("Reset All Data", comment: "Reset All Data menu item")
    static let buyMeACoffee = NSLocalizedString("Buy Me a Coffee", comment: "Buy Me a Coffee menu item")
    static let areYouSure = NSLocalizedString("Are you sure you want to delete all your data?", comment: "Data deletion alert message")
    static let warningExclamation = NSLocalizedString("Warning!", comment: "Warning alert title")
    static let cancel = NSLocalizedString("Cancel", comment: "Cancel alert button")
    static let yesImSure = NSLocalizedString("Yes, I'm sure", comment: "Delete Data alert primary button")
}
