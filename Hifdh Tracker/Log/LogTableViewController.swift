//
//  LogTableViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-09.
//

import UIKit
import CoreData
import WidgetKit

class LogTableViewController: UITableViewController, UITabBarControllerDelegate {

    // MARK: Variables
    var firstNotInMemoryIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    var isFirstInput = false
    // give access to appdelegate
    let delegate = UIApplication.shared.delegate as? AppDelegate
    // MARK: Outlets
    @IBOutlet weak var percentBarButton: UIBarButtonItem!

    // MARK: viewDid...
    override func viewWillDisappear(_ animated: Bool) {
        isFirstInput = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        handleOnboarding()
        self.tabBarController?.delegate = self
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        if let scrollToIndexPath = Page.firstNotInMemoryIndexPath {
            self.tableView.scrollToRow(at: scrollToIndexPath, at: .middle, animated: true)
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Analytics.shared.view(screen: .log)
        configureViews()
    }

    // MARK: Onboarding

    func handleOnboarding() {
        if let delegate {
            if delegate.userDefaults.bool(forKey: UserDefaultsKey.isFirstRun.rawValue) {
                // show Onboarding
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let onboardingController = storyboard.instantiateViewController(withIdentifier: "OnboardingViewController") as! OnboardingViewController
                onboardingController.modalPresentationStyle = .fullScreen
                self.present(onboardingController, animated: true)
            }
        }
    }

    // MARK: UITabBarControllerDelegate

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        if tabBarIndex == 1 {
            if isFirstInput { isFirstInput = false } else {
                if let scrollToIndexPath = Page.firstNotInMemoryIndexPath {
                    self.tableView.scrollToRow(at: scrollToIndexPath, at: .middle, animated: true)
                }
            }
        }

    }

    // MARK: Configurations
    private func configureViews() {
        tableView.reloadData()
        configureTopLeftBarItem()
        tick()
    }

    private func configureTopLeftBarItem() {
        percentBarButton.title = Page.percentMemorizedAsString
    }

    func configureDatePickerInPageCell(_ logCell: LogTableViewCell) {
        if logCell.memorySwitch.isOn {
            logCell.datePicker.isEnabled = false
        } else {
            logCell.datePicker.isEnabled = true
        }
    }

    // MARK: tableView
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return section == 1 ? Localized.pages : nil }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {return Page.logs.count}
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? DateTableViewCell {
                    cell.titleLabel.text = Localized.startDate
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "MM/dd/yyyy"
                    // get start date, from coredata
                    cell.datePicker.date = Page.lowestLogDate ?? Date()
                    cell.datePicker.isEnabled = false

                    return cell
                }
            case 1:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? DateTableViewCell {
                    if Page.percentMemorized == 1 {
                        cell.titleLabel.text = Localized.completedOn
                        cell.datePicker.date = Page.highestLogDate ?? Date()
                    } else {
                        cell.titleLabel.text = Localized.todaysDate
                        cell.datePicker.date = Date()
                    }
                    cell.datePicker.isEnabled = false
                    return cell
                }
            case 2:
                if let cell = tableView.dequeueReusableCell(withIdentifier: "configCell") as? ConfigTableViewCell {
                    cell.directionSegmentedControl.selectedSegmentIndex = ((delegate?.userDefaults.bool(forKey: UserDefaultsKey.isFromFront.rawValue)) ?? true) ? 0 : 1
                    cell.directionValueChangedAction = { [self] in
                        withCoreData {_ in
                            self.delegate?.userDefaults.set(cell.directionSegmentedControl.selectedSegmentIndex == 0, forKey: UserDefaultsKey.isFromFront.rawValue)
                        }
                        configureViews()

                        if let scrollToIndexPath = Page.firstNotInMemoryIndexPath {
                            self.tableView.scrollToRow(at: scrollToIndexPath, at: .middle, animated: true)
                        }                        }
                    return cell
                }
            default: return UITableViewCell()
            }
        } else {
            if let logCell = tableView.dequeueReusableCell(withIdentifier: "logCell") as? LogTableViewCell {
                let currentPage = Page.logs[indexPath.row]
                logCell.memorySwitch.tintColor = .accent
                logCell.titleLabel.text = String(currentPage.pageNumber)
                logCell.datePicker.setDate(currentPage.dateMemorized ?? Date(), animated: true)
                let inMemory = currentPage.isMemorized
                logCell.memorySwitch.isOn = inMemory
                configureDatePickerInPageCell(logCell)
                logCell.switchValueChangedAction = { [self] in
                    withCoreData {_ in
                        currentPage.isMemorized = !currentPage.isMemorized
                        currentPage.dateMemorized = logCell.datePicker.date
                        Analytics.shared.track(events: .logPage)
                    }
                    var rowNumber = Int(currentPage.pageNumber) - 1
                    if !UserDefaults.standard.bool(forKey: UserDefaultsKey.isFromFront.rawValue) { rowNumber = 603 - rowNumber}
                    self.tableView.scrollToRow(at: IndexPath(row: rowNumber, section: 1), at: .middle, animated: true)
                    configureDatePickerInPageCell(logCell)
                    configureViews()
                }
                return logCell
            }
        }
        return UITableViewCell()
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "addLog") {
            if let destination = segue.destination as? AddLogViewController {
                //passing data
                destination.delegate = self.delegate
                destination.isDismissed = {[weak self] (pageNumber) in
                    //reload tableview when I come back
                    self?.configureViews()
                    self?.tableView.scrollToRow(at: IndexPath(row: pageNumber, section: 1), at: .middle, animated: true)
                }
            }
        }
    }

    func tick() {
        WidgetCenter.shared.reloadAllTimelines()
    }
}
// MARK: - Localized Strings
extension Localized {
    static let startDate = NSLocalizedString("Start Date:", comment: "Start Date: row title")
    static let completedOn = NSLocalizedString("Completed on:", comment: "Completed on: row title")
    static let todaysDate = NSLocalizedString("Today's Date:", comment: "Today's Date: row title")
}

