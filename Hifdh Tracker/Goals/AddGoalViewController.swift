//
//  AddGoalViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-23.
//

import UIKit

class AddGoalViewController: UIViewController {
    
    var delegate: AppDelegate?
    var isDismissed: ( () -> Void )?
    
    @IBOutlet weak var goalNameTextField: UITextField!
    @IBOutlet weak var datePickerYConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagesPerYConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfPagesYConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfPagesTextField: UITextField!
    @IBOutlet weak var timeUnitSelector: UISegmentedControl!
    @IBOutlet weak var pagesPerTextField: UITextField!
    @IBOutlet weak var dateTitleHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var dateTitle: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timeUnitSelectorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var pagesPerTimeHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var numberOfPagesHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var goalTypeSegmentedControl: UISegmentedControl!
    
    var goalType: GoalType?
    
    func dismiss() {
        isDismissed?()
        self.dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        goalTypeChanged(self)
        datePicker.minimumDate = Date()
        pagesPerTextField.text = "\(NumberFormatter.twoDecimals(Page.pagesPerDay)!)"
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: Dynamic Constraints
    func goalDateIsVisible(_ show : Bool){
        if show {
            datePickerYConstraint.constant = 25
            datePicker.isHidden = false
            datePickerHeightConstraint.constant = 30
            dateTitle.isHidden = false
            dateTitleHeightConstraint.constant = 30
        } else {
            datePickerYConstraint.constant = 0
            datePicker.isHidden = true
            datePickerHeightConstraint.constant = 0
            dateTitle.isHidden = true
            dateTitleHeightConstraint.constant = 0
        }
    }
    func goalPagesPerTimeIsVisible(_ show : Bool){
        if show {
            pagesPerYConstraint.constant = 25
            pagesPerTextField.isHidden = false
            pagesPerTimeHeightConstraint.constant = 30
            timeUnitSelector.isHidden = false
            timeUnitSelectorHeightConstraint.constant = 30
        } else {
            pagesPerYConstraint.constant = 0
            pagesPerTextField.isHidden = true
            pagesPerTimeHeightConstraint.constant = 0
            timeUnitSelector.isHidden = true
            timeUnitSelectorHeightConstraint.constant = 0
        }
    }
    func goalPagesIsVisible(_ show : Bool){
        if show {
            numberOfPagesYConstraint.constant = 25
            numberOfPagesTextField.isHidden = false
            numberOfPagesHeightConstraint.constant = 30
        } else {
            numberOfPagesYConstraint.constant = 0
            numberOfPagesTextField.isHidden = true
            numberOfPagesHeightConstraint.constant = 0
        }
    }
    
    // MARK: IBActions
    @IBAction func goalTypeChanged(_ sender: Any) {
        switch goalTypeSegmentedControl.selectedSegmentIndex {
            case 0:
                goalDateIsVisible(false)
                goalPagesIsVisible(true)
                goalPagesPerTimeIsVisible(true)
                goalType = .findEndDate
                self.goalNameTextField.placeholder = Constants.dateGoalDefaultName
            case 1:
                goalPagesPerTimeIsVisible(false)
                goalPagesIsVisible(true)
                goalDateIsVisible(true)
                goalType = .findPagesPerTimePeriod
                self.goalNameTextField.placeholder = Constants.pagesPerIntervalGoalDefaultName
            case 2:
                goalPagesIsVisible(false)
                goalPagesPerTimeIsVisible(true)
                goalDateIsVisible(true)
                goalType = .findEndPage
                self.goalNameTextField.placeholder = Constants.endPageGoalDefaultName
            default:
                break
        }
        view.layoutSubviews(duration: 0.3)
    }
    @IBAction func createGoal(_ sender: Any) {
        guard let context = delegate?.persistentContainer.viewContext,
              let pagesPerString = pagesPerTextField.text,
              let numberOfPagesString = numberOfPagesTextField.text
        else { return } // TODO: Err handle
        let numOfPages = Double(numberOfPagesString) ?? 604
        let pagesPer = Double(pagesPerString) ?? Page.pagesPerDay
        var timeUnits: TimeUnits = .days
        switch timeUnitSelector.selectedSegmentIndex {
            case 0:
                timeUnits = .days
            case 1:
                timeUnits = .weeks
            case 2:
                timeUnits = .months
            default:
                break
        }
        let goalDate = datePicker.date
        let goalName = goalNameTextField.text == "" ? nil : goalNameTextField.text
        
        withCoreData { [self] in
            switch goalType {
                case .findEndDate:
                    if !areFieldsEmpty([numberOfPagesTextField]) {
                        showErrorAlert(message: Constants.genericTextFieldEmptyError)
                        return
                    }
                    _ = Goal(name: goalName ?? Constants.dateGoalDefaultName , pagesPer, pagesPer: timeUnits, forTotalPages: numOfPages, in: context)
                case .findPagesPerTimePeriod:
                    if !areFieldsEmpty([numberOfPagesTextField]) {
                        showErrorAlert(message: Constants.genericTextFieldEmptyError)
                        return
                    }
                    _ = Goal(name: goalName ?? Constants.pagesPerIntervalGoalDefaultName, pages: numOfPages, by: goalDate, in: context)
                case .findEndPage:
                    _ = Goal(name: goalName ?? Constants.endPageGoalDefaultName, pagesPer, pagesPer: timeUnits, until: goalDate, in: context)
                case .none:
                    break
            }
            delegate?.saveContext()
            dismiss()
        }
    }
    
    // MARK: Handling "Next" in the textfields
    func textFieldShouldReturn(_ sender: UITextField) {
        switch sender {
            case goalNameTextField:
                _ = numberOfPagesTextField.isHidden ? pagesPerTextField.becomeFirstResponder() : numberOfPagesTextField.becomeFirstResponder()
            default:
                break
        }
        self.resignFirstResponder()
    }
    @IBAction func goalNameTextFieldPrimaryAction(_ sender: UITextField) {
        textFieldShouldReturn(sender)
    }
    
    // MARK: Error Handling
    func areFieldsEmpty(_ fields: [UITextField]) -> Bool {
        for field in fields {
            if field.text == "" || field.text == nil {
                return false
            }
        }
        return true
    }
    
    func showErrorAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive))
        present(alert, animated: true)
    }
    
    // MARK: Core Data (for writing values)
    func withCoreData(completion: @escaping() -> Void ) {
        if let _ = delegate?.persistentContainer.viewContext {
            completion()
        }
        delegate?.saveContext()
    }
    
}
