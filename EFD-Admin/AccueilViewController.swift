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
    
    @IBAction func deliverymanView(_ sender: Any) {
        createVC(goTo: DeliverymanViewController(), actu: self)
    }
    
    @IBAction func parcelView(_ sender: Any) {
        createVC(goTo: ParcelViewController(), actu: self)
    }
    
    @IBAction func deliveryView(_ sender: Any) {
        createVC(goTo: DeliveryViewController(), actu: self)
    }
    
    @IBAction func deliveryTourView(_ sender: Any) {
        self.navigationController?.pushViewController(MapDeliveryTourViewController(), animated: true)
          
         
    }
    static func newInstance()->AccueilViewController{
        let accueilVC = AccueilViewController()
        
        let Home = UINavigationController(rootViewController: AccueilViewController())
        
        
        
        let Deliveryman : UINavigationController = goToSplitFromNavBar(goTo: DeliverymanViewController(), name: "Deliverymans", image: UIImage(named: "Deliveryman"), selectedImage: UIImage(named: "Deliveryman_selected"))
        
        let Parcel: UINavigationController = goToSplitFromNavBar(goTo: ParcelViewController(), name: "Parcels", image: UIImage(named: "Parcel"), selectedImage: UIImage(named: "Parcel_selected"))
        
        let Delivery: UINavigationController = goToSplitFromNavBar(goTo: DeliveryViewController(), name: "Deliveries", image: UIImage(named: "Delivery"), selectedImage: UIImage(named: "Delivery_selected"))
        
        
        
        
        
        
        let tabBarController = UITabBarController()
        
        tabBarController.viewControllers = [
            Home,
            Deliveryman,
            Parcel,
            Delivery,
        ]
                                            
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        appDelegate.window?.rootViewController = tabBarController
        
        return accueilVC
    }

}
