//
//  OnboardingViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-26.
//

import UIKit

class OnboardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let onBoardingScreens: [OnboardingScreen] = OnboardingScreen.all
    var currentPage: Int = 0 {
        didSet {
            switch currentPage {
            case 0:
                previousButton.isHidden = true
                nextButton.setTitle(Localized.next, for: .normal)
            case onBoardingScreens.count - 1:
                nextButton.setTitle(Localized.getStarted, for: .normal)
                previousButton.isHidden = false
            default:
                nextButton.setTitle(Localized.next, for: .normal)
                previousButton.isHidden = false

            }
            pageControl.currentPage = currentPage

        }
    }
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var onboardingCollectionVew: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    @IBAction func previousButtonPressed(_ sender: Any) {
        goToPage(currentPage-1)
    }
    @IBAction func nextButtonPressed(_ sender: Any) {
        if currentPage != onBoardingScreens.count - 1 {
            goToPage(currentPage+1)
        } else {
            UserDefaults.standard.set(false, forKey: UserDefaultsKey.isFirstRun.rawValue)
            self.dismiss(animated: true)
        }
    }
    func goToPage(_ newPageNumber: Int) {
        onboardingCollectionVew.scrollToItem(at: IndexPath(row: newPageNumber, section: 0), at: .centeredHorizontally, animated: true)
        currentPage = newPageNumber
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "onboardingCell", for: indexPath) as! OnboardingCell
        cell.setupCell(onBoardingScreens[indexPath.row])
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return onBoardingScreens.count
    }
    // scroll detects page number
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let width = scrollView.frame.width
        currentPage = Int(scrollView.contentOffset.x / width)
    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */

}
extension OnboardingViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
extension Localized {
    static let next = NSLocalizedString("Next", comment: "Next Page button")
    static let getStarted = NSLocalizedString("Get Started", comment: "Get Started button")
}
