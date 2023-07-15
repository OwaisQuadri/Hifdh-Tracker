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
    // give access to appdelegate
    let delegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var percentBarButton: UIBarButtonItem!
    
    override func viewWillAppear(_ animated: Bool) {
        // load from db
        guard let context = delegate?.persistentContainer.viewContext else { return }
        withCoreData {
            let request: NSFetchRequest<Page> = Page.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "pageNumber", ascending: true)]
            
            if let pageLogsFromCoreData = try? context.fetch(request) {
                self.logs = pageLogsFromCoreData
                let firstNotInMemoryIndexPath = IndexPath(row: self.logs.firstIndex(where: { !$0.isMemorized }) ?? 0, section: 1)
                self.updateData()
                self.tableView.scrollToRow(at: firstNotInMemoryIndexPath, at: .middle, animated: true)
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
    
    private func updateData(){
        tableView.reloadData()
        updateTopLeftPercent()
    }
    
    private func updateTopLeftPercent() {
        var percentMemorized: Double = 0.0
        withCoreData {
            // load total memorized percentage from CoreDate
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
                        // get start date, from coredata
                        
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
                    withCoreData {
                        currentPage.isMemorized = !currentPage.isMemorized
                        currentPage.dateMemorized = logCell.datePicker.date
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
                 destination.isDismissed = {[weak self] in
                     //reload tableview when I come back
                     self?.updateData()
                 }
             }
         }
     }
    
}
