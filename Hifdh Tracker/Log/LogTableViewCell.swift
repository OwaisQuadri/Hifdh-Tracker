//
//  LogTableViewCell.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-10.
//

import UIKit

class LogTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var memorySwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    var switchValueChangedAction: (() -> Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        datePicker.maximumDate = Date()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchValueChanged(_ sender: Any) {
        switchValueChangedAction?()
    }
}
