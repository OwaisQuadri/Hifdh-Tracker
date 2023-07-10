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
    
    override func viewWillAppear(_ animated: Bool) {
        // load from db
        if let context = delegate?.persistentContainer.viewContext {
            
            let request: NSFetchRequest<Page> = Page.fetchRequest()
            request.sortDescriptors = [NSSortDescriptor(key: "pageNumber", ascending: true)]
            if let pageLogsFromCoreData = try? context.fetch(request) {
                logs = pageLogsFromCoreData
                tableView.reloadData()
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
                logCell.titleLabel.text = String(logs[indexPath.row].pageNumber)
                return logCell
            }
        }
        return UITableViewCell()
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
