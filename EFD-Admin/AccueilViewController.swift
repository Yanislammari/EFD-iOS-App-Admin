//
//  AccueilViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 13/02/2025.
//

import UIKit

class AccueilViewController: UIViewController {

    @IBOutlet weak var disconnectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func handleDisconnect(_ sender: UIButton) {
        if let homeVC = self.navigationController?.viewControllers.first(where: { $0 is HomeViewController }) as? HomeViewController {
                homeVC.deconnexion()
            } else {
                let homeVC = HomeViewController()
                homeVC.deconnexion()
            }
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
