//
//  LogTableViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-09.
//

import UIKit
import CoreData

class LogTableViewController: UITableViewController {
    var foundFirstNotInMemory = false
    var firstNotInMemoryIndexPath: IndexPath?
    var logs : [Page] = []
    // give access to appdelegate
    let delegate = UIApplication.shared.delegate as? AppDelegate
    
    override func viewWillAppear(_ animated: Bool) {
        // load from db
        if let context = delegate?.persistentContainer.viewContext {
            
            let request: NSFetchRequest<Page> = Page.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "pageNumber", ascending: true)]
            if let pageLogsFromCoreData = try? context.fetch(request) {
                logs = pageLogsFromCoreData
                firstNotInMemoryIndexPath = IndexPath(row: logs.firstIndex(where: { !$0.isMemorized }) ?? 0, section: 1)
                tableView.reloadData()
                tableView.scrollToRow(at: firstNotInMemoryIndexPath!, at: .middle, animated: true)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        2
    }
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? { return section==1 ? "Pages" : nil }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {return logs.count}
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            switch indexPath.row {
                case 0:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? DateTableViewCell {
                        cell.titleLabel.text = "Start Date:"
                        
                        //set the date from persisting storage
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MM/dd/yyyy"
                        let startDate = dateFormatter.date(from: "05/01/2022")
                        cell.datePicker.date = startDate ?? Date()
                        
                        return cell
                    }
                case 1:
                    if let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as? DateTableViewCell {
                        cell.titleLabel.text = "Today's Date:"
                        cell.datePicker.isEnabled = false
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
                    if let _ = self.delegate?.persistentContainer.viewContext {
                        currentPage.isMemorized = !currentPage.isMemorized
                        currentPage.dateMemorized = logCell.datePicker.date
                        delegate?.saveContext()
                    }
                    updateDatePickerInPageCell(logCell)
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
                 destination.logs = self.logs
                 destination.delegate = self.delegate
                 destination.isDismissed = {[weak self] in
                     self?.tableView.reloadData()
                 }
             }
         }
     }
    
}
