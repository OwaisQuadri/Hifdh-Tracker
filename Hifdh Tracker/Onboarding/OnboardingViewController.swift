//
//  OnboardingViewController.swift
//  Hifdh Tracker
//
//  Created by Owais on 2023-07-26.
//

import UIKit

class OnboardingViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    let onBoardingScreens: [OnboardingScreen] = OnboardingScreen.all
    var currentPage: Int! {
        didSet {
            switch currentPage {
                case 0:
                    previousButton.isHidden = true
                    nextButton.setTitle("Next", for: .normal)
                case onBoardingScreens.count - 1:
                    nextButton.setTitle("Get Started", for: .normal)
                    previousButton.isHidden = false
                default:
                    nextButton.setTitle("Next", for: .normal)
                    previousButton.isHidden = false
                    
            }
            pageControl.currentPage = currentPage
            
        }
    }
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var onboardingCollectionVew: UICollectionView!
    @IBOutlet weak var nextButton: UIButton!
    
    let isIpad = UIDevice().userInterfaceIdiom == UIUserInterfaceIdiom.pad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentPage = 0
        // Do any additional setup after loading the view.
        if (isIpad)
        {
            // device is ipad
            currentPage = onBoardingScreens.count - 1
            pageControl.isHidden = true
            previousButton.isHidden = true
        }
        
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
        if !isIpad {
            currentPage = Int(scrollView.contentOffset.x / width)
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

}