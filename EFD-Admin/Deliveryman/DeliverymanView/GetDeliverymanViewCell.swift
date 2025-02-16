//
//  GetDeliverymanViewCell.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 15/02/2025.
//

import UIKit

class DeliverymanTableViewCell: UITableViewCell {
        
    @IBOutlet weak var bigDescription: UILabel!
    
    func reload(with deliveryman: Deliver) {
        bigDescription.text = "\(deliveryman.first_name)\n \(deliveryman.name)\n📞 \(deliveryman.phone)\n"

    }

    
}

