//
//  ConfigurationTableViewCell.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-10.
//

import UIKit

class ConfigurationTableViewCell: UITableViewCell {

    @IBOutlet weak var configSegmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func configControlValueChanged(_ sender: Any) {
        // change page logs to surah logs and vice versa
    }
}
