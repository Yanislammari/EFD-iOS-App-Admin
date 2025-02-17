//
//  DetailDeliveryTourViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 17/02/2025.
//

import UIKit

class DetailDeliveryTourViewController: UIViewController {
    
    var delivery:Delivery!


    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }


    static func newInstance(delivery: Delivery) -> DetailDeliveryTourViewController {
        let detailVC = DetailDeliveryTourViewController()
        detailVC.delivery = delivery
        return detailVC
    }

}
