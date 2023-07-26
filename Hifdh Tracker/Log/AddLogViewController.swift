//
//  AddLogViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-10.
//

import UIKit
import CoreData

class AddLogViewController: UIViewController {
    
    // MARK: Outlets
    @IBOutlet weak var fromPageTextField: UITextField!
    @IBOutlet weak var untilPageTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var hideErrorConstraint: NSLayoutConstraint!
    @IBOutlet weak var showErrorConstraint: NSLayoutConstraint!
    
    // MARK: Variables
    var delegate: AppDelegate? // give access to appdelegate through segue
    
    // MARK: viewDid...
    override func viewDidLoad() {
        super.viewDidLoad()
        datePicker.maximumDate = Date()
    }
    // MARK: VC's onDismiss
    var isDismissed: ( (Int) -> Void )?
    
    func dismiss(andScrollTo pageNumber: Int) {
        isDismissed?(pageNumber)
        self.dismiss(animated: true)
    }
    
    // MARK: Actions
    @IBAction func createLogButtonTouchUpInside(_ sender: Any) {
        
        //take values from "from" and "to" text fields and make them ints
        var indexStart = (Int(fromPageTextField.text!) ?? 0) - 1
        var indexEnd = (Int(untilPageTextField.text!) ?? 0) - 1
        if indexStart < -1 || indexStart > 603 || indexEnd < -1 || indexEnd > 603 || (indexEnd == -1 && indexStart == -1) {
            // handle error "enter a number between 1 and 604"
            showError(message: "Please enter a value from 1-604")
            return
        }
        showErrorConstraint.isActive = false
        hideErrorConstraint.isActive = true
        self.view.layoutIfNeeded()
        if indexStart == -1 {
            Page.logs[indexEnd].isMemorized = true
            Page.logs[indexEnd].dateMemorized = datePicker.date
        } else if indexEnd == -1 {
            Page.logs[indexStart].isMemorized = true
            Page.logs[indexStart].dateMemorized = datePicker.date
        } else {
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
            }}
        delegate?.saveContext()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.33) {
            // Put your code which should be executed with a delay here
            self.dismiss(andScrollTo: max(indexStart, indexEnd))
        }
    }
    func showError(message: String){
        hideErrorConstraint.isActive = false
        showErrorConstraint.isActive = true
        errorLabel.text = message
        self.view.layoutIfNeeded()
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
