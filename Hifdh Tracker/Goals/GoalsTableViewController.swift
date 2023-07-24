//
//  GoalsTableViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-22.
//

import UIKit

class GoalsTableViewController: UITableViewController {
    
    var delegate = UIApplication.shared.delegate as? AppDelegate
    
    @IBOutlet weak var percentBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    override func viewWillAppear(_ animated: Bool) {
        configureViews()
    }
    
    func configureViews(){
        tableView.reloadData()
        tableView.separatorStyle = .none
        percentBarButton.title = Page.percentMemorizedAsString
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            guard let context = delegate?.persistentContainer.viewContext else { return }
            Goal.goals[indexPath.row].delete(in: context)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 1 { return 1 }
        return Goal.goals.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            
            if let goalCell = tableView.dequeueReusableCell(withIdentifier: "goalTableViewCell") as? GoalTableViewCell {
                let currentGoal = Goal.goals[indexPath.row]
                goalCell.titleLabel.text = currentGoal.goalName
                switch currentGoal.type {
                    case .findEndDate:
                        if (Page.numberOfMemorized >= currentGoal.goalPages){
                            goalCell.parameterLabel0.text = "\(NumberFormatter.integer(currentGoal.goalPages)!) of \(NumberFormatter.integer(currentGoal.goalPages)!) pages"
                        } else {
                            goalCell.parameterLabel0.text = "\(NumberFormatter.integer(Page.numberOfMemorized)!) of \(NumberFormatter.integer(currentGoal.goalPages)!) pages"
                        }
                        goalCell.goalLabel.text = "\(DateFormatter.mmmDDyyyy(currentGoal.dateOfGoalComplete!)!)"
                        goalCell.myGoal = currentGoal
                        break
                    case .findEndPage:
                        goalCell.parameterLabel1.text = "\(DateFormatter.mmmDDyyyy(currentGoal.goalDate ?? Date.distantFuture)!)"
                        goalCell.goalLabel.text = "\(NumberFormatter.integer(currentGoal.endPage ?? 604)!)"
                        goalCell.myGoal = currentGoal
                        break
                    case .findPagesPerTimePeriod:
                        goalCell.parameterLabel0.text = "\(DateFormatter.mmmDDyyyy(currentGoal.goalDate ?? Date.distantFuture)!)"
                        if (Page.numberOfMemorized >= currentGoal.goalPages){
                            goalCell.parameterLabel1.text = "\(NumberFormatter.integer(currentGoal.goalPages)!) of \(NumberFormatter.integer(currentGoal.goalPages)!) pages"
                        } else {
                            goalCell.parameterLabel1.text = "\(NumberFormatter.integer(Page.numberOfMemorized)!) of \(NumberFormatter.integer(currentGoal.goalPages)!) pages"
                        }
                        goalCell.myGoal = currentGoal
                        break
                }
                goalCell.timeUnitChanged(self)
                return goalCell
            }
        } else if indexPath.section == 1 {
            if let addGoalCell = tableView.dequeueReusableCell(withIdentifier: "addGoalCell") as? addGoalTableViewCell {
                return addGoalCell
            }
        }
        
        return UITableViewCell()
    }
    
    
    
    /*
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the specified item to be editable.
     return true
     }
     */
    
    /*
     // Override to support editing the table view.
     override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
     if editingStyle == .delete {
     // Delete the row from the data source
     tableView.deleteRows(at: [indexPath], with: .fade)
     } else if editingStyle == .insert {
     // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
     }
     */
    
    /*
     // Override to support rearranging the table view.
     override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {
     
     }
     */
    
    /*
     // Override to support conditional rearranging of the table view.
     override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
     // Return false if you do not want the item to be re-orderable.
     return true
     }
     */
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "addGoal") {
            if let destination = segue.destination as? AddGoalViewController {
                //passing data
                destination.delegate = self.delegate
                destination.isDismissed = { [self] in
                    self.configureViews()
                }
            }
        }
    }
}
