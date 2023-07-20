//
//  StartDateTableViewCell.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-09.
//

import UIKit

class DateTableViewCell: UITableViewCell {
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
