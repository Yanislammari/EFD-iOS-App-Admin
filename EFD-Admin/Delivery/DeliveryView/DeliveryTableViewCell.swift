//
//  DeliveryTableViewCell.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 17/02/2025.
//

import UIKit

class DeliveryTableViewCell: UITableViewCell {

    @IBOutlet weak var bigDescription: UILabel!
    
    func reload(with delivery: Delivery) {
        bigDescription.text = "\(delivery.delivery_id)\n\(delivery.livraison_date)\n\(delivery.status)"


    }
}
