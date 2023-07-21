//
//  UIView+Util.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-20.
//

import UIKit

extension UIView {
    func layoutSubviews(duration: TimeInterval?) {
        UIView.animate(withDuration: duration ?? 0) {
            self.layoutIfNeeded()
        }
    }
}
