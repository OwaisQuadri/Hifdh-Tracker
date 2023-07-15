//
//  ConfigTableViewCell.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-15.
//

import UIKit

class ConfigTableViewCell: UITableViewCell {

    @IBOutlet weak var directionSegmentedControl: UISegmentedControl!
    var directionValueChangedAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func directionValueChanged(_ sender: Any) {
        directionValueChangedAction?()
    }
}
