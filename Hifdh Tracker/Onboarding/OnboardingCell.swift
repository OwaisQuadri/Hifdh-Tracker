//
//  OnboardingCell.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-26.
//

import UIKit

class OnboardingCell: UICollectionViewCell {
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    func setupCell(_ onboardingScreen: OnboardingScreen) {
        imageView.image = onboardingScreen.image
        captionLabel.text = onboardingScreen.caption
    }
}
