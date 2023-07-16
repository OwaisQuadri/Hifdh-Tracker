//
//  LogTableViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-09.
//

import UIKit
import CoreData

class LogTableViewController: UITableViewController {
    var logs : [Page] = []
    var startDate: Date?
    var firstNotInMemoryIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    // give access to appdelegate
    let delegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var percentBarButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        fetchData(delegate)
        self.tableView.scrollToRow(at: self.firstNotInMemoryIndexPath, at: .middle, animated: true)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func fetchData(_ delegate: AppDelegate?) {
        // load from db
        if let context = delegate?.persistentContainer.viewContext  {
            withCoreData { [self] in
                let request: NSFetchRequest<Page> = Page.fetchRequest()
                request.sortDescriptors = [NSSortDescriptor(key: "pageNumber", ascending: (delegate?.userDefaults.bool(forKey: UserDefaultsKey.isFromFront.rawValue)) ?? true)]
                
                if let pageLogsFromCoreData = try? context.fetch(request) {
                    self.logs = pageLogsFromCoreData
                    self.firstNotInMemoryIndexPath = IndexPath(row: self.logs.firstIndex(where: { !$0.isMemorized }) ?? 0, section: 1)
                    self.updateData()
                }
            }
        }
    }
    
    func refresh() {
        fetchData(delegate)
        tableView.reloadData()
    }
    
    private func updateData(){
        self.startDate = self.logs.map{ $0.dateMemorized ?? Date() }.min(by: { $0 < $1 })
        tableView.reloadData()
        updateTopLeftPercent()
    }
    
    private func updateTopLeftPercent() {
        var percentMemorized: Double = 0.0
        withCoreData {
            // load total memorized percentage from CoreData
            let arrayOfMemorized = self.logs.compactMap{$0.isMemorized ? $0 : nil}
            percentMemorized = Double(arrayOfMemorized.count) / 604.0
        }
        // set top bar item to number with format
        let percentFormat = NumberFormatter()
        percentFormat.numberStyle = .percent
        percentFormat.maximumFractionDigits = 1
        percentFormat.minimumFractionDigits = 1
        let formattedTitle = percentFormat.string(from: NSNumber(floatLiteral: percentMemorized))
        percentBarButton.title = formattedTitle
    }
    
    func withCoreData(completion: @escaping() -> Void ){
        if let _ = delegate?.persistentContainer.viewContext {
            completion()
        }
        delegate?.saveContext()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return section==1 ? "Pages" : nil }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {return logs.count}
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
                case 0:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? DateTableViewCell {
                        cell.titleLabel.text = "Start Date:"
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        // get start date, from coredata
                        cell.datePicker.date = startDate ?? Date()
                        cell.datePicker.isEnabled = false
                        
                        return cell
                    }
                case 1:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? DateTableViewCell {
                        cell.titleLabel.text = "Today's Date:"
                        cell.datePicker.date = Date()
                        cell.datePicker.isEnabled = false
                        return cell
                    }
                case 2:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "configCell") as? ConfigTableViewCell {
                        withCoreData { [self] in
                            cell.directionSegmentedControl.selectedSegmentIndex = ((delegate?.userDefaults.bool(forKey: UserDefaultsKey.isFromFront.rawValue)) ?? true) ? 0 : 1
                            cell.directionValueChangedAction = { [self] in
                                delegate?.userDefaults.set(cell.directionSegmentedControl.selectedSegmentIndex == 0, forKey: UserDefaultsKey.isFromFront.rawValue)
                                refresh()
                                self.tableView.scrollToRow(at: self.firstNotInMemoryIndexPath, at: .middle, animated: true)
                            }
                        }
                        return cell
                    }
                default: return UITableViewCell()
            }
        } else {
            if let logCell = tableView.dequeueReusableCell(withIdentifier: "logCell") as? LogTableViewCell {
                let currentPage = logs[indexPath.row]
                logCell.titleLabel.text = String(currentPage.pageNumber)
                logCell.datePicker.setDate(currentPage.dateMemorized ?? Date (), animated: true)
                let inMemory = currentPage.isMemorized
                logCell.memorySwitch.isOn = inMemory
                updateDatePickerInPageCell(logCell)
                logCell.switchValueChangedAction = { [self] in
                    withCoreData {
                        currentPage.isMemorized = !currentPage.isMemorized
                        currentPage.dateMemorized = logCell.datePicker.date
                        var rowNumber = Int(currentPage.pageNumber)
                        if !UserDefaults.standard.bool(forKey: UserDefaultsKey.isFromFront.rawValue) { rowNumber = 603 - rowNumber}
                        self.tableView.scrollToRow(at: IndexPath(row: rowNumber, section: 1), at: .middle, animated: true)
                    }
                    updateDatePickerInPageCell(logCell)
                    updateData()
                }
                return logCell
            }
        }
        return UITableViewCell()
    }
    func updateDatePickerInPageCell(_ logCell: LogTableViewCell) {
        if logCell.memorySwitch.isOn {
            logCell.datePicker.isEnabled = false
        } else {
            logCell.datePicker.isEnabled = true
            logCell.datePicker.date = Date()
        }
    }
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
         if (segue.identifier == "addLog") {
             if let destination = segue.destination as? AddLogViewController {
                 //passing data
                 destination.logs = self.logs
                 destination.delegate = self.delegate
                 destination.isDismissed = {[weak self] (pageNumber) in
                     //reload tableview when I come back
                     self?.updateData()
                     self?.tableView.scrollToRow(at: IndexPath(row: pageNumber, section: 1), at: .middle, animated: true)
                 }
             }
         }
     }
    
}
