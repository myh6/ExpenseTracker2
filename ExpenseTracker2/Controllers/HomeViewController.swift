//
//  ViewController.swift
//  ExpenseTracker2
//
//  Created by curry敏 on 2021/8/4.
//

import UIKit

class HomeViewController: UIViewController {
    
    @IBOutlet weak var customNav: UIView!
    @IBOutlet weak var homeButton: UIButton!
    @IBOutlet weak var calenderButton: UIButton!
    @IBOutlet weak var chartButton: UIButton!
    @IBOutlet weak var settingButton: UIButton!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var screenCoverButton: UIButton!
    @IBOutlet weak var listButton: UIButton!
    @IBOutlet weak var menuCurveImageView: UIImageView!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet var containerViews: [UIView]!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        hideMenu()
        
        containerViews[0].isHidden = false
        containerViews[1].isHidden = true
        containerViews[2].isHidden = true
    }
    
    
    @IBAction func listButtonPressed(_ sender: UIButton) {
        showMenu()
    }
    
    
    @IBAction func screeCoverdCancel(_ sender: UIButton) {
        hideMenu()
    }
    
    func showMenu() {
        
        menuView.isHidden = false
        UIView.animate(withDuration: 0.4) {
            self.screenCoverButton.alpha = 0.7
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.3, options: [.curveEaseOut, .allowUserInteraction]) {
            self.profileImageView.transform = .identity
            self.settingButton.transform = .identity
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveEaseOut, .allowUserInteraction]) {
            self.homeButton.transform = .identity
            self.shareButton.transform = .identity
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut, .allowUserInteraction]) {
            self.chartButton.transform = .identity
            self.calenderButton.transform = .identity
        }
        
        UIView.animate(withDuration: 0.4, delay: 0, options: .curveEaseOut) {
            self.menuCurveImageView.transform = .identity
        }

    }
    
    func hideMenu() {
        UIView.animate(withDuration: 0.4) {
            self.screenCoverButton.alpha = 0
        }
        
        //Button Curve Out
        UIView.animate(withDuration: 0.4, delay: 0, options: [.curveEaseOut, .allowUserInteraction]) {
            self.profileImageView.transform = CGAffineTransform(translationX: -self.menuView.frame.width, y: 0)
            self.settingButton.transform = CGAffineTransform(translationX: -self.menuView.frame.width, y: 0)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.1, options: [.curveEaseOut, .allowUserInteraction]) {
            self.homeButton.transform = CGAffineTransform(translationX: -self.menuView.frame.width, y: 0)
            self.shareButton.transform = CGAffineTransform(translationX: -self.menuView.frame.width, y: 0)
        }
        
        UIView.animate(withDuration: 0.4, delay: 0.2, options: [.curveEaseOut, .allowUserInteraction]) {
            self.chartButton.transform = CGAffineTransform(translationX: -self.menuView.frame.width, y: 0)
            self.calenderButton.transform = CGAffineTransform(translationX: -self.menuView.frame.width, y: 0)
        }
        
        //Menu Curve Out
        UIView.animate(withDuration: 0.4, delay: 0.3, options: .curveLinear) {
            self.menuCurveImageView.transform = CGAffineTransform(translationX: -self.menuCurveImageView.frame.width, y: 0)
        } completion: { success in
            self.menuView.isHidden = true
        }
        
    }
    
    @IBAction func toHome(_ sender: UIButton) {
        for cview in containerViews {
            cview.isHidden = true
        }
        containerViews[0].isHidden = false
        hideMenu()
    }
    
    @IBAction func toCalender(_ sender: UIButton) {
        for cview in containerViews {
            cview.isHidden = true
        }
        containerViews[1].isHidden = false
        hideMenu()
    }
    
    @IBAction func toChart(_ sender: UIButton) {
        for cview in containerViews {
            cview.isHidden = true
        }
        containerViews[2].isHidden = false
        hideMenu()
    }
    
    @IBAction func toShare(_ sender: UIButton) {
        for cview in containerViews {
            cview.isHidden = true
        }
        containerViews[3].isHidden = false
        hideMenu()
    }
    
    @IBAction func toSetting(_ sender: UIButton) {
        for cview in containerViews {
            cview.isHidden = true
        }
        containerViews[4].isHidden = false
        hideMenu()
    }
    
}

