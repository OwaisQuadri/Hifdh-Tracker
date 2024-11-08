//
//  CountersViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2024-04-13.
//

import CoreData
import SnapKit
import SwiftUI
import UIKit
import StoreKit

class CountersViewController: UIViewController {

    // MARK: Constants
    let delegate = UIApplication.shared.delegate as? AppDelegate

    // MARK: Variables

    // MARK: Outlets

    // MARK: ViewDid...

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let maxCounter = delegate?.sharedUserDefaults.integer(forKey: "maxCounter") ?? 10
        let swiftUIView = CountersView(maxCounter: maxCounter)
        let swiftUIcontroller = UIHostingController(rootView: swiftUIView)
        addChild(swiftUIcontroller)
        swiftUIcontroller.view.frame = view.bounds
        view.addSubview(swiftUIcontroller.view)
        swiftUIcontroller.didMove(toParent: self)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillAppear(_ animated: Bool) {
        Task {
            await SubscriptionManager.shared.updatePurchasedProducts()
            if !SubscriptionManager.shared.isPremium {
                FullscreenCoverManager.shared.presentFullscreenCover()
            } else {
                Analytics.shared.view(screen: .goals)
            }
        }
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    func showAlert(title: String) {
        let alert = UIAlertController(title: title, message: nil, preferredStyle: .alert)
        alert.addAction(.init(title: Localized.okAllCaps, style: .default))
        self.present(alert, animated: true, completion: nil)
    }
}
