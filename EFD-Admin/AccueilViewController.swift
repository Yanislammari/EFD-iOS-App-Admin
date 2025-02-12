//
//  AccueilViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 13/02/2025.
//

import UIKit

class AccueilViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    static func newInstance()->AccueilViewController{
        let accueilVC = AccueilViewController()
        
        let Home = UINavigationController(rootViewController: AccueilViewController())
        
        let tabBarController = UITabBarController()
        
        tabBarController.viewControllers = [Home]
                                            
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = tabBarController
                                            
        
        return accueilVC
    }

}
