//
//  DetailDeliveryViewController.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 15/02/2025.
//

import UIKit

class DetailDeliveryViewController: UIViewController {
    
    var deliver:Deliver!
    
    @IBOutlet weak var deliverymanName: UILabel!
    
    @IBOutlet weak var bigDescription: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bigDescription.layer.cornerRadius = 10
        bigDescription.layer.masksToBounds = true
        
        

    }


    static func newInstance(deliver:Deliver)->DetailDeliveryViewController{
        let detailVC = DetailDeliveryViewController()
        detailVC.deliver = deliver
        return detailVC
    }

}
