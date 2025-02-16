//
//  ParcelTableViewCell.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 16/02/2025.
//

import UIKit

class ParcelTableViewCell: UITableViewCell {

    @IBOutlet weak var bigDescription: UILabel!
    
    func reload(with parcel: Parcel) {
        bigDescription.text = "\(parcel.destination_name)\n \(parcel.status)\n"

        }
    
}
