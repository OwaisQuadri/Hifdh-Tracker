//
//  GoalTableViewCell.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-22.
//

import UIKit

class GoalTableViewCell: UITableViewCell {

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

}
