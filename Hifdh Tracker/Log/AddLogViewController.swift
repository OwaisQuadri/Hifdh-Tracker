//
//  AddLogViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-10.
//

import UIKit
import CoreData

class AddLogViewController: UIViewController {
    
    @IBOutlet weak var fromPageTextField: UITextField!
    @IBOutlet weak var untilPageTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var hideErrorConstraint: NSLayoutConstraint!
    @IBOutlet weak var showErrorConstraint: NSLayoutConstraint!
    // give access to appdelegate and logs
    var delegate: AppDelegate?
    
    //reload on dismiss
    var isDismissed: ( (Int) -> Void )?
    
    func dismiss(andScrollTo pageNumber: Int) {
        isDismissed?(pageNumber)
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func createLogButtonTouchUpInside(_ sender: Any) {
        
        //take values from "from" and "to" text fields and make them ints
        var indexStart = (Int(fromPageTextField.text!) ?? 0) - 1
        var indexEnd = (Int(untilPageTextField.text!) ?? 0) - 1
        if indexStart < 0 || indexStart > 603 || indexEnd < 0 || indexEnd > 603 {
        // handle error "enter a number between 1 and 604"
            hideErrorConstraint.isActive = false
            showErrorConstraint.isActive = true
            errorLabel.text = "Please enter a value from 1-604"
            self.view.layoutIfNeeded()
            return
        }
        showErrorConstraint.isActive = false
        hideErrorConstraint.isActive = true
        self.view.layoutIfNeeded()
        if !UserDefaults.standard.bool(forKey: UserDefaultsKey.isFromFront.rawValue) {
            indexStart = 603 - indexStart
            indexEnd = 603 - indexEnd
        }
        let x = min(indexEnd, indexStart)
        let y = max(indexEnd, indexStart)
        if let _ = delegate?.persistentContainer.viewContext {
            for i in x...y {
                Page.logs[i].isMemorized = true
                Page.logs[i].dateMemorized = datePicker.date
            }
        }
        delegate?.saveContext()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
            // Put your code which should be executed with a delay here
            self.dismiss(andScrollTo: max(indexStart, indexEnd))
        }
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
