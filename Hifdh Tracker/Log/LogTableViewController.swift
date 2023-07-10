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
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3 + logs.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
            case 2:
                if let configCell = tableView.dequeueReusableCell(withIdentifier: "configCell") as? ConfigurationTableViewCell {
                    return configCell
                }
            default:
                if let logCell = tableView.dequeueReusableCell(withIdentifier: "logCell") as? LogTableViewCell {
                    logCell.titleLabel.text = String(logs[indexPath.row - 3].pageNumber)
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
