//
//  Delivery.swift
//  EFD-Admin
//
//  Created by Rishi Balasubramanim on 17/02/2025.
//

import Foundation

class Delivery {
    var delivery_id: String
    var deliveryman_id: Deliver?
    var livraison_date: String
    var status: String
    var created_at: String
    var updated_at: String
    
    init(delivery_id: String, deliveryman_id: Deliver?, livraison_date: String, status: String, created_at: String, updated_at: String) {
        self.delivery_id = delivery_id
        self.deliveryman_id = deliveryman_id
        self.livraison_date = livraison_date
        self.status = status
        self.created_at = created_at
        self.updated_at = updated_at
    }
    
    static func fromJSON(dict: [String: Any]) -> Delivery? {
            guard let delivery_id = dict["uuid"] as? String,
                  let livraison_date = dict["livraison_date"] as? String,
                  let status = dict["status"] as? String,
                  let created_at = dict["created_at"] as? String,
                  let updated_at = dict["updated_at"] as? String
            else {
                return nil
            }
            
        let deliveryman_id: Deliver? = {
            if let deliverymanDict = dict["deliveryman_id"] as? [String: Any] {
                return Deliver.fromJSON(dict: deliverymanDict)
            }
            return nil
        }()
            
            return Delivery(delivery_id: delivery_id, deliveryman_id: deliveryman_id, livraison_date: livraison_date, status: status, created_at: created_at, updated_at: updated_at)
        }
    
}
