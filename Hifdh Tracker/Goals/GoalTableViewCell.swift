//
//  GoalTableViewCell.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-22.
//

import UIKit

class GoalTableViewCell: UITableViewCell {

    var myGoal: Goal?
    @IBOutlet weak var timePeriodSelectorHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var timePeriodSelector: UISegmentedControl!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var parameterLabel1: UILabel!
    @IBOutlet weak var parameterLabel0: UILabel!
    @IBOutlet weak var goalLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func timeUnitChanged(_ sender: Any) {
        if let myGoal = self.myGoal {

            var timeUnits: TimeUnit = .days

            switch self.timePeriodSelector.selectedSegmentIndex {
            case 0:
                timeUnits = .days
            case 1:
                timeUnits = .weeks
            case 2:
                timeUnits = .months
            default:
                break
            }
            switch myGoal.type {
            case .findEndDate, .findEndPage:
                self.parameterLabel1.text = String(format: Localized.perTimePeriodFormat, myGoal.goalPagesPerDay.convert(from: timeUnits, to: .days))
            case .findPagesPerTimePeriod:
                self.goalLabel.text = String(format: Localized.perTimePeriodFormat, myGoal.pagesPer(timeUnits) ?? 0.0) 
            }

        }
    }
}
extension Localized {
    static let perTimePeriodFormat = NSLocalizedString("%.2f per", comment: "2 decimal number representing pages, memorized per time period")
}
